##############################################################################
# __init__.py - display switching with multiple backends
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

from edid import Edid
from resolutions import *

class Switcher:

    _displays = None
    _resolutions = ResolutionCollection()
    backend = None

    def __init__(self):
        '''Initialise the switcher and find a backend'''
        self.log = logging.getLogger('switcher')
        self._probe_backend()

    def _probe_backend(self):
        '''Find and instantiate a suitable backend'''
        self.backend = None
        try:
            # nVidia must be probed before XRandR because it uses XRandR in a
            # non-standard way
            from swnvidia import NVidiaSwitcher
            self.backend = NVidiaSwitcher()
            self.log.info('backend: nVidia')
            return
        except SyntaxError: raise
        except: pass
        try:
            from swxrandr import XRandrSwitcher
            self.backend = XRandrSwitcher()
            self.log.info('backend: XRandR')
            return
        except SyntaxError: raise
        except: pass

        if not self.backend:
            raise Exception('No suitable backend found')

    ## the following methods must be defined by backends; see swnvidia.py
    ## for a complete example and an explanation of these methods
    #def get_displays(self):
    #def get_primary_display(self):
    #def get_display_name(self, ndisp):
    #def get_display_supported_res(self, ndisp):
    #def get_display_preferred_res(self, ndisp):
    #def get_display_edid(self, ndisp):
    #def switch_clone(self, displays, res):
    #def switch_extend(self, displays, direction, ress):
    #def import_config(self, cfg):
    #def export_config(self):

    def __getattr__(self, name):
        '''Pass unrecognised methods to the switcher itself; this is to
        simulate binding to a parent class at runtime.'''
        return getattr(self.backend, name)

    def get_displays(self):
        '''return an array of connected displays'''
        # hash displays to avoid probing twice
        if self._displays: return self._displays
        self._displays = self.backend.get_displays()
        # always put primary display in front
        if self.get_primary_display() in self._displays:
            self._displays = [self.get_primary_display()] + \
                filter(lambda x: x!=self.get_primary_display(), self._displays)
        return self._displays

    def get_resolutions_display(self, disp):
        '''return a list of resolutions for the specified display'''
        # hash resolutions to avoid probing them twice
        if disp in self._resolutions: return self._resolutions[disp]
        # get supported resolutions from driver
        r = ResolutionList(self.backend.get_display_supported_res(disp))
        if len(r)==0:
            r = ResolutionList('800x600, 640x480')
            self.log.warning('no resolutions found for display %s, falling back to: %s'%(disp, r))
        # bump weight of flat-panel display with 1000
        res = self.backend.get_display_preferred_res(disp)
        if res:
            if res in r: r[r.index(res)].weight += 1000
            else: r.append(res)
        # bump weight of EDID resolutions with 100
        edid_data = self.backend.get_display_edid(disp)
        if edid_data:
            edid = Edid(edid_data)
            for d in edid.get_monitor_details():
                title, info = d
                if title != 'Detailed Timing': continue
                res = Resolution([info['horizontal_active'], info['vertical_active']])
                if res in r: r[r.index(res)].weight += 100
                else: r.append(res)
        self.log.info('resolutions of '+str(disp)+': '+', '.join(map(str,sorted(r))))
        self._resolutions[disp] = r
        return r

    def get_resolutions(self, displays):
        '''return a ResolutionCollection which is a hash with resolutions for
        each display'''
        res = ResolutionCollection()
        for disp in displays:
            res[disp] = self.get_resolutions_display(disp)
        return res

# vim:ts=4:sw=4:expandtab:
