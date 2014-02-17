##############################################################################
# switcher-nvidia.py - display switching for nVidia cards
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#        
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License at http://www.gnu.org/licenses/gpl.txt
# By using, editing and/or distributing this software you agree to
# the terms and conditions of this license.

import os
import re
import logging

import nvidia

from resolutions import *

class NVidiaSwitcher:

    nv = None
    _display_associations = []
    _switch_method = None


    def __init__(self):
        self.nv = nvidia.NVidiaControl()
        self.screen = nvidia.Screen(self.nv.xscreen)
        self.log = logging.getLogger('nVidia')
        # either use XRandR module or command-line utility
        try:
            import xrandr
            self._switch_method=self._xrandr_switch_mod
        except:
            self.log.info('using xrandr command instead of XRandR module')
            self._switch_method=self._xrandr_switch_cmd


    def get_displays(self):
        '''return an array of connected displays'''
        displays = self.nv.probe_displays(self.screen)
        return displays


    def get_primary_display(self):
        '''return the primary display of this system. I'm not really sure how
        to do this, so currently the first found flat panel display (DFP) is
        returned, or CRT if none, or TV if neither.'''
        displays = self.get_displays()
        for d in ['DFP', 'CRT', 'TV']:
            for i in range(8):
                disp = '%s-%1d'%(d,i)
                if disp in displays:
                    return disp
        # this should be unreachable code, but be safe
        self.log.error('program error, could not determine primary display')
        return displays[0]


    def get_display_name(self, ndisp):
        '''return the name of a display'''
        return self.nv.get_display_name(self.screen, ndisp)


    def get_display_supported_res(self, ndisp):
        '''return a set of supported resolutions for a display.
        Displays need to be associated to probe their modelines, so this method
        temporarily changes that (and reverts to the old setup before
        returning).'''

        # Get display resolutions for display. The display needs to have
        # it associated to the X screen to be able to do this. So we check that
        # it is associated first and do so when needed. Restore associated
        # displays afterwards.
        # Note: When twinview has not been enabled before, the X server can
        #       *crash* when a display is associated that isn't mentioned in
        #       any metamode line. So create an autoselect modeline first.
        self._push_display_association([ndisp])
        try:
            self.nv.build_display_modepool(self.screen, ndisp)
            resolutions = set()
            for m in self.nv.get_display_modelines(self.screen, ndisp):
                r = re.search(r'::\s*"(\d+x\d+)"', m)
                if not r: continue
                resolutions.add(r.group(1))
        finally:
            self._pop_display_association()

        return resolutions


    def get_display_preferred_res(self, ndisp):
        '''return the preferred resolution for a display.
        Displays need to be associated to probe their modelines, so this method
        temporarily changes that (and reverts to the old setup before
        returning).'''
        self._push_display_association([ndisp])
        try:
            self.nv.build_display_modepool(self.screen, ndisp)
            res = self.nv.get_dfp_native_resolution(self.screen, ndisp)
        finally:
            self._pop_display_association()
        return res


    def get_display_edid(self, ndisp):
        '''return the EDID data for a display.'''
        return self.nv.get_display_edid(self.screen, ndisp)


    def switch_clone(self, displays, res):
        '''switch to resolution and clone all displays'''
        mm = nvidia.metamode_clone(displays, str(res))
        return self._switch(mm, displays)


    def switch_extend(self, displays, direction, ress):
        '''extend desktop across all displays. direction is one of
        'left'/'right'/'bottom'/'top', and ress a dict of a resolution
        for each display.'''
        mm = None
        for disp in displays:
            res = ress[disp]
            mm = nvidia.metamode_add_extend(mm, direction, disp, str(res))
        return self._switch(mm, displays)


    def import_config(self, cfg):
        '''restore a display configuration as exported by export_config()'''
        backend = displays = mmline = scaling = None
        for l in cfg.splitlines():
            key, sep, value = map(lambda s: s.strip(), l.partition(':'))
            if key == 'backend':
                backend = value
            elif key == 'associated displays':
                displays = map(lambda s: s.strip(), value.split(','))
            elif key == 'metamode':
                mmline = value.strip()
            elif key == 'scaling':
                scaling = map(lambda s: s.strip(), value.split(','))

        if not backend:
            self.log.warning('no backend specified, assuming nvidia')
        elif backend != 'nvidia':
            raise Exception('can only import what is exported by the nvidia backend')
        if not displays:
            raise Exception('"associated displays" missing from configuration')
        if not mmline:
            raise Exception('"metamode" missing from configuration')
        # scaling is optional

        self._switch(mmline, displays)

        if scaling:
            if len(scaling) != len(displays):
                raise Exception('number of entries in "scaling" must equal # associated displays')
            self.set_scaling(displays, scaling)
            

    def export_config(self):
        '''return a string that contains all information to set the current
        display configuration using import_config().'''
        cfg = ['backend: nvidia']
        # associated displays
        assocdisplays = self.nv.get_screen_associated_displays(self.screen)
        cfg.append('associated displays: ' + ', '.join(assocdisplays))
        # and current metamode; remove options since they can't be specified
        # when restoring
        mm = self.nv.get_current_metamode(self.screen)
        mm = re.sub(r'^.*::\s*', r'', str(mm))
        cfg.append('metamode: ' + mm)
        # scaling mode of displays
        scalings = self.get_scaling(assocdisplays)
        cfg.append('scaling: ' + ', '.join(scalings))
        return '\n'.join(cfg)


    def _switch(self, mmline, displays, scaling=None):
        '''switch to the specified metamode. mmline is a MetaMode, displays
        a list of displays to use, and scaling an optional argument specifying
        the gpu scaling, which is either an array of two elements as returned
        by NVidiaControl.get_gpu_scaling(), or an array of these elements, one
        for each display.'''
        
        '''the nvidia-settings source mentions the following in function
        update_screen_metamodes() defined in ctkdisplayconfig.c
        
        * preprocess
          - get current list of metamodes for this screen
          - add all new metamodes to the end of the list
        * mode switch if needed
        * postprocess
          - delete any unused mode
          - move metamodes to correct location
          
        pseudocode:
          metamode_strs = nv.get_current_list_of_metamodes()
          cur_metamode_str = nv.get_current_metamode()
          preprocess_metamodes(screen, metamode_strs) = {
            for metamode in screen.metamodes:
              if metamode in metamode_strs:
                metamode_strs.find(metamode).keep = True
              else:
                nv.add_metamode(metamode)
          }
          if metamode_str == screen->cur_metamode: clear_apply = 1
          postprocess_metamodes(screen, metamode_strs) = {
            for metamode in metamode_strs:
              if not metamode.keep:
                nv.delete_metamode(metamode)
            order_metamodes(screen) = {
              for i in len(metamodes):
                nv.move_metamode(metamode[i], i) 
            }
          }
        '''

        # make sure requested displays are connected (or metamode can't be created)
        unconndisplays = filter(lambda x: x not in self.get_displays(), displays)
        if len(unconndisplays) > 0:
            raise Exception('unconnected displays referenced, please connect: ' + \
                ', '.join(unconndisplays))

        # find or create MetaMode
        oldxio = self.nv.get_xinerama_info_order(self.screen)
        self._push_display_association(displays)
        try:
            mm = self.nv.get_metamodes(self.screen).find(mmline)
            if mm:
                mmid = mm.id
            else:
                mmid = self._add_metamode(mmline)
                if mmid < 0:
                    raise Exception('could not find nor create MetaMode: %s'%mmline)
                
            # set order before switch so it is detected
            self.log.info('setting xinerama info order: '+', '.join(displays))
            self.nv.set_xinerama_info_order(self.screen, displays)

            # change to this mode using xrandr and refresh as id
            self._xrandr_switch(mmid)
        except:
            # delete dangling metamodes and deassociate old
            self._cleanup_metamodes(displays)
            self._pop_display_association()
            self.nv.set_xinerama_info_order(self.screen, oldxio)
            raise

        # delete dangling metamodes and deassociate old
        self._cleanup_metamodes(displays)
        self._pop_display_association(False)
        self._set_associated_displays(displays)


    def _add_metamode(self,  mm):
        '''add a metamode. Returns id of newly created metamode, or -1 if it
        already existed.'''
        ## To enter a MetaMode line, the displays involved must have been
        ## associated or the nvidia driver doesn't remember display names.
        self.log.info('adding metamode: %s'%mm)
        return self.nv.add_metamode(self.screen, mm)


    def _add_metamode_autoselect(self, displays):
        '''add a temporary auto-select metamode that is needed before
        associating displays. returns id of metamode created, or -1 if it
        already existed'''
        ## There must be a metamode containing all displays when associating
        ## displays, or the X server may crash.
        mm = nvidia.metamode_clone(displays, 'nvidia-auto-select')
        self.log.info('adding auto-select metamode: %s'%str(mm))
        return self.nv.add_metamode(self.screen, mm)


    def _delete_metamode(self, id):
        '''delete the specified metamode.'''
        self.log.info('deleting metamode: %d'%id)
        return self.nv.delete_metamode(self.screen, id)


    def _set_associated_displays(self, displays):
        '''set the displays associated to the current X screen. Don't use this
        function directly, rather use both
        _push_display_association() and _pop_display_association().
        The primary display is kept associated always to avoid problems when
        switching from one single display device to another. [bug #315920]'''
        self.log.info('associating displays: %s'%(', '.join(displays)))
        d = set(displays)
        d.add(self.get_primary_display())
        return self.nv.set_screen_associated_displays(self.screen, d)


    def _push_display_association(self, displays):
        '''add a display to the currently associated displays and save
        previous state to return to using _pop_display_association().
        It is best to put the latter in a try ... finally clause to make
        sure it is always called.'''
        # change association when needed
        olddisplays = self.nv.get_screen_associated_displays(self.screen)
        assocdisplays = set(olddisplays).union(set(displays))
        if set(olddisplays) != set(assocdisplays):
            oldid = self._add_metamode_autoselect(assocdisplays)
            self._set_associated_displays(assocdisplays)
            self._display_associations.append((olddisplays, oldid))
        else:
            self._display_associations.append((None, -1))


    def _pop_display_association(self, dorestore = True):
        '''restore the previous display association from an earlier
        _push_display_association() call. If dorestore is False, only the old
        values will be popped and the display will not be restored, which is
        useful when the association is overridden afterwards.'''
        if len(self._display_associations) == 0:
            raise Exception('unbalanced _pop_display_assocation(), this is a program bug')
        olddisplays, oldid = self._display_associations.pop()
        # restore when needed
        if not olddisplays: return
        if oldid > 0:
            self._delete_metamode(oldid)
        if dorestore:
            self._set_associated_displays(olddisplays)


    def _xrandr_switch(self, mmid, virtualres=None):
        '''switch to the specified MetaMode id. Also the virtual resolution is
        needed; this will be retrieved when omitted.

        The virtual resolution is needed when a MetaMode is added and removed.
        I suspect that the XRandR refresh rates are not removed propely by the
        nVidia driver.'''
        if not virtualres:
            mm = self.nv.get_metamodes(self.screen).find(mmid)
            virtualres = mm.bounding_size()
        return self._switch_method(mmid, virtualres)

    def _xrandr_switch_mod(self, mmid, virtualres):
        '''_xrandr_switch that uses the xrandr python module'''
        import xrandr
        screen = xrandr.get_current_screen()
        sizeidx = -1
        for i,s in enumerate(screen.get_available_sizes()):
            if s.width != virtualres[0] or s.height != virtualres[1]: continue
            if mmid in screen.get_available_rates_for_size_index(i):
                res = '%dx%d' % ( s.width, s.height )
                sizeidx = i
                break
        if sizeidx < 0:
            raise Exception( 'could not switch to metamode %d: resolution not found' % mmid )
        screen.set_size_index(sizeidx)
        screen.set_refresh_rate(mmid)
        logging.info('switching to metamode %d: [%d] %s / %s'%(mmid,sizeidx,res,mmid))
        screen.apply_config()

    def _xrandr_switch_cmd(self, mmid, virtualres):
        '''_xrandr_switch that uses the command 'xrandr' '''
        cmd='xrandr -s %dx%d -r %d'%(virtualres[0],virtualres[1],mmid)
        logging.info('switching to metamode %d: %s'%(mmid,cmd))
        return os.system(cmd)

    def _cleanup_metamodes(self, displays):
        '''cleanup metamodes referencing displays that are not associated.
        driver loses display names in metamodes when displays are not
        associated and they remain around. Some more details to be found on
          http://www.nvnews.net/vbulletin/showthread.php?t=123781
        It is important that all displays currently present in the metamode
        list are still associated to the X screen.
        '''
        metamodes = self.nv.get_metamodes(self.screen)
        for mm in metamodes:
            for d in mm.metamodes:
                if d.display not in displays and d.physical:
                    self.log.info('deleting dangling metamode %d: %s'%(mm.id,mm))
                    r = self.nv.delete_metamode(self.screen, mm)
                    if not r: self.log.warning('deletion of dangling metamode %d failed'%mm.id)
                    break
        # nvidia-settings re-orders them, so do it here to be sure
        metamodes = self.nv.get_metamodes(self.screen)
        for i,mm in enumerate(metamodes):
            self.nv.move_metamode(self.screen, mm, i)

    def set_scaling(self, displays, scaling):
        '''update the flat panel scaling mode if it was set previously by
        nvidia-settings. scaling must be one of: default, native, scaled, centered,
        aspect-scaled. Alternatively, scaling can be a list specifying the scaling
        for each display separately.
        The default choice parses the nvidia-settings configuration file
        ~/.nvidia-settings-rc to obtain the default value, or does nothing if that
        fails. Note that nvidia-settings may or may not save this information from
        the gui; both has been observed. The relevant option is 'GPUScaling'.'''

        # this fails if it's done for all of them at once, so do it separately
        for i,d in enumerate(displays):
            xtrainfo=''
            curscaling = scaling
            if type(curscaling) == list: curscaling = curscaling[i]
            if curscaling=='default':
                try:
                    sc = nvidia.NVidiaSettings().query(int, 'GPUScaling', None, d)
                    if not sc: continue
                    if sc==65537: curscaling='stretched'
                    elif sc==65538: curscaling='centered'
                    elif sc==65539: curscaling='aspect-scaled'
                    else:
                        self.log.warn('unrecognised scaling value for %s from nvidia-settings: %d'%(d,sc))
                        continue
                    xtrainfo=' (from nvidia-settings configuration)'
                except IOError: continue
            if curscaling=='native':
                self.log.info('setting scaling of display %s to %s%s'%(d, curscaling, xtrainfo))
                self.nv.set_gpu_scaling(self.screen, d, 'native', 'stretched')
            else:
                self.log.info('setting scaling of display %s to %s%s'%(d, curscaling, xtrainfo))
                self.nv.set_gpu_scaling(self.screen, d, 'best-fit', curscaling)

    def get_scaling(self, displays):
        '''return an array of scaling modes for each display'''
        scalings = []
        for d in displays:
            res = self.nv.get_gpu_scaling(self.screen, d)
            if not res: # 'default' on error
                self.log.warning('could not get scaling for screen %s, reverting to "default"'%d)
                scalings.append('default')
            elif res[0]=='native':
                scalings.append('native')
            else:
                scalings.append(res[1])
        return scalings

# vim:ts=4:sw=4:expandtab:
