##############################################################################
# swxrandr.py - display switching using XRandR
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

import logging

import xrandr

from resolutions import *

class XRandrSwitcher:

    def __init__(self):
        self.log = logging.getLogger('xrandr')
        self.screen = xrandr.get_current_screen()
        if not xrandr.has_extension():
            raise Exception('No XRandR extension found')


    def get_displays(self):
        '''return an array of connected displays'''
        displays = self.screen.get_outputs()
        displays = filter(lambda o: o.is_connected(), displays)
        displays = map(lambda o: o.name, displays)
        return displays


    def get_primary_display(self):
        # no idea, just return first one for now
        return self.get_displays()[0]


    def get_display_name(self, ndisp):
        '''return the name of a display'''
        # nothing more as of now
        return ndisp


    def get_display_supported_res(self, ndisp):
        '''return a set of supported resolutions for a display.'''
        o = self.screen.get_output_by_name(ndisp)
        return o.get_available_resolutions()


    def get_display_preferred_res(self, ndisp):
        '''return the preferred resolution for a display.'''
        o = self.screen.get_output_by_name(ndisp)
        m = o.get_available_modes()[o.get_preferred_mode()]
        return [m.width,m.height]


    def get_display_edid(self, ndisp):
        '''return the EDID data for a display.'''
        # not available now
        return None


    def switch_clone(self, displays, res):
        '''switch to resolution and clone all displays'''
        ress = ResolutionSelection(res, displays)
        return self._switch(displays, ress, xrandr.RELATION_SAME_AS)


    def switch_extend(self, displays, direction, ress):
        '''extend desktop across all displays. direction is one of
        'left'/'right'/'bottom'/'top', and ress a dict of a resolution
        for each display.'''
        relation = None
        if direction=='left':
            relation = xrandr.RELATION_LEFT_OF
        elif direction=='right':
            relation = xrandr.RELATION_RIGHT_OF
        elif direction=='top':
            relation = xrandr.RELATION_ABOVE
        elif direction=='bottom':
            relation = xrandr.RELATION_BELOW
        else:
            raise ValueError('extend direction must be left/right/bottom/top')
        return self._switch(displays, ress, relation)


    def import_config(self, cfg):
        '''restore a display configuration as exported by export_config()'''
        raise NotImplementedError('import not yet implemented')


    def export_config(self):
        '''return a string that contains all information to set the current
        display configuration using import_config().'''
        raise NotImplementedError('export not yet implemented')


    def _switch(self, displays, ress, relation):
        '''switch displays to the specified resolution according to XRandR relation'''
        dprev = None
        for d in displays:
            res = ress[disp]
            # for each display, select mode with highest refresh rate at res
            o = self.screen.get_output_by_name(d)
            modes = []
            for i,mode in enumerate(o.get_available_modes()):
                if mode.width != res.width: continue
                if mode.height != res.height: continue
                refresh = mode.dotClock/(mode.hTotal*mode.vTotal)
                modes.append([i, refresh])
            modes.sort(lambda x,y: x[1]-y[1])
            if len(modes) > 1:
                self.log.info(str(d)+': available refresh rates for resolution '+
                    str(res)+': '+', '.join(map(lambda o: '%d'%(o[1]), modes)))
            mode = modes[-1]
            self.log.info(str(d)+': selecting XRandR mode #%d: %s %dHz'%(mode[0],res,mode[1]))
            o.set_to_mode(mode[0])
            if dprev:
                o.set_relation(dprev, relation)
            dprev = d
        self.screen.apply_output_config()

    def set_scaling(self, displays, scaling):
        raise NotImplementedError('scaling not implemented for XRandR')


# vim:ts=4:sw=4:expandtab:
