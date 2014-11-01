###############################################################################
# nvcmd.py - nvidia NV-CONTROL X extension functions in python
#
# this file contains only a subset of the NV-CONTROL functions, expand and
# share when needed! See the nvidia-settings source for a complete C-based
# implementation.  This file contains high-level functions. If you need to
# add support for another command, please add it to this class.
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

_all = ['GPU', 'Screen', 'NVidiaControl', 'metamode_clone', 'metamode_add_extend' ]

import re
from nvctrl import *
from nvctrl import NVidiaControl as NVidiaControlLowLevel
from metamodes import *

__BUS_TYPES = ['AGP', 'PCI', 'PCI Express', 'Integrated']
__OS_TYPES = ['Linux', 'FreeBSD', 'SunOS']
__ARCH_TYPES = ['x86', 'x86-64', 'IA64']


class NVidiaControl(NVidiaControlLowLevel):
    '''This class extends nvctrl.NVidiaControl with methods for
    accessing the NV-CONTROL functions on a higher level.'''


    def get_GPU_count(target):
        '''Return the number of GPU's present in the system.'''
        gpc = self.query_target_count(GPU())
        return gpc.count

    def get_bus_type(self, target):
        '''Return the bus type through which the GPU driving the specified X
        screen is connected to the computer.'''
        br = self.query_int_attribute(target, [], NV_CTRL_BUS_TYPE)
        return __BUS_TYPES[br.value]

    def get_OS_type(target):
        '''return the operating system on which the X server is running.'''
        ot = self.query_int_attribute(GPU(), [], NV_CTRL_OPERATING_SYSTEM )
        return __OS_TYPES[ot.value]

    def get_host_architecture(target):
        '''return the architecture on which the X server is running.'''
        ha = self.query_int_attribute(GPU(), NV_CTRL_TARGET_TYPE_X_SCREEN, [], NV_CTRL_ARCHITECTURE )
        return __ARCH_TYPES[ha.value]

    def get_vram(self, target):
        '''Return the total amount of memory available to the specified GPU
        (or the GPU driving the specified X screen). Note: if the GPU supports
        TurboCache(TM), the value reported may exceed the amount of video
        memory installed on the GPU. The value reported for integrated GPUs may
        likewise exceed the amount of dedicated system memory set aside by the
        system BIOS for use by the integrated GPU.'''
        vr = self.query_int_attribute(target, NV_CTRL_TARGET_TYPE_GPU, [], NV_CTRL_VIDEO_RAM)
        return vr.value

    def get_IRQ(self, target):
        '''Return the interrupt request line used by the GPU driving the screen'''
        irq = self.query_int_attribute(target, NV_CTRL_TARGET_TYPE_GPU, [], NV_CTRL_IRQ)
        return irq.value

    def get_connected_displays(self, target):
        '''Return an array with connected display numbers'''
        cd = self.query_int_attribute(target, [], NV_CTRL_CONNECTED_DISPLAYS)
        return self._mask2displays(cd.value)

    def get_enabled_displays(self, target):
        '''returns an array of displays that are enabled on the specified X
        screen or GPU.'''
        ed = self.query_int_attribute(target, [], NV_CTRL_ENABLED_DISPLAYS)
        return self._mask2displays(ed.value)

    def supports_framelock(self, target):
        '''returns whether the underlying GPU supports Frame Lock. All of the
        other frame lock attributes are only applicable if this returns True.'''
        fl = self.query_int_attribute(target, [], NV_CTRL_FRAMELOCK)
        return fl.value == 1

    def get_name(self, target):
        '''the GPU product name on which the specified X screen is running'''
        ns = self.query_string_attribute(target, [], NV_CTRL_STRING_PRODUCT_NAME)
        return ns.string

    def get_current_modeline(self, target):
        '''Return the ModeLine currently being used by the specified display
        device. This attribute may be queried using a GPU() or Screen() target.
        The ModeLine string may be prepended with a comma-separated list of
        "token=value" pairs, separated from the ModeLine string by "::". This
        "token=value" syntax is the same as that used in TODO'''
        dm = self.query_string_attribute( target, [], NV_CTRL_STRING_CURRENT_MODELINE)
        return dm.string

    def GVO_supported(target):
        '''returns whether this X screen supports GVO; if this screen does not
        support GVO output, then all other GVO attributes are unavailable.'''
        gv = self.query_int_attribute(Screen(), [], NV_CTRL_GVO_SUPPORTED)
        return gv.value == 1

    def get_core_temp(self, target):
        '''return the current core temperature of the GPU driving the X screen.'''
        ct = self.query_int_attribute(target, [], NV_CTRL_GPU_CORE_TEMPERATURE)
        return ct.value

    def get_core_threshold(self, target):
        '''return the current GPU core slowdown threshold temperature. It
        reflects the temperature at which the GPU is throttled to prevent
        overheating.'''
        th = self.query_int_attribute(target, [], NV_CTRL_GPU_CORE_THRESHOLD)
        return th.value

    def get_default_core_threshold(self, target):
        '''return the default core threshold temperature.'''
        dt = self.query_int_attribute(target, [], NV_CTRL_GPU_DEFAULT_CORE_THRESHOLD)
        return dt.value

    def get_max_core_threshold(self, target):
        '''return the maximum core threshold temperature.'''
        mt = self.query_int_attribute(target, [], NV_CTRL_GPU_MAX_CORE_THRESHOLD)
        return mt.value

    def get_ambient_temp(self, target):
        '''return the current temperature in the immediate neighbourhood of
        the GPU driving the X screen.'''
        at = self.query_int_attribute(target, [], NV_CTRL_AMBIENT_TEMPERATURE)
        return at.value

    def get_2D_clocks(self, target):
        '''query the 2D (GPU, memory) clocks of the device driving the X screen.
        All clock values are in MHz.'''
        cl = self.query_int_attribute(target, [], NV_CTRL_GPU_2D_CLOCK_FREQS)
        return (cl.value >> 16, cl.value & 0xFFFF)

    def get_3D_clocks(self, target):
        '''query the 3D (GPU, memory) clocks of the device driving the X screen.
        All clock values are in MHz.'''
        cl = self.query_int_attribute(target, [], NV_CTRL_GPU_3D_CLOCK_FREQS)
        return (cl.value >> 16, cl.value & 0xFFFF)

    def get_default_2D_clocks(self, target):
        '''query the default 2D (GPU, memory) clocks of the device driving the
        X screen. All clock values are in MHz.'''
        cl = self.query_int_attribute(target, [], NV_CTRL_GPU_DEFAULT_2D_CLOCK_FREQS)
        return (cl.value >> 16, cl.value & 0xFFFF)

    def get_default_3D_clocks(self, target):
        '''query the default 3D (GPU, memory) clocks of the device driving the
        X screen. All clock values are in MHz.'''
        cl = self.query_int_attribute(target, [], NV_CTRL_GPU_DEFAULT_3D_CLOCK_FREQS)
        return (cl.value >> 16, cl.value & 0xFFFF)

    def get_current_clocks(self, target):
        '''return the current (GPU, memory) clocks of the graphics device
        driving the X screen.'''
        cl = self.query_int_attribute(target, [], NV_CTRL_GPU_DEFAULT_CLOCK_FREQS)
        return (cl.value >> 16, cl.value & 0xFFFF)

    def get_xinerama_enabled(self, target):
        '''return whether Xinerama is enabled or not'''
        xn = self.query_int_attribute(target, [], NV_CTRL_XINERAMA)
        return xn.value == 1

    def get_refresh_rate(self, target, display):
        '''return the refresh rate of the specified display device in Hz.'''
        rr = self.query_int_attribute(target, [display], NV_CTRL_REFRESH_RATE)
        return rr.value / 100.0

    def probe_displays(self, target):
        '''re-probes the hardware to detect what display devices are connected
        to the GPU or GPU driving the specified X screen. Returns an array
        of displays.'''
        md = self.query_int_attribute(target, [], NV_CTRL_PROBE_DISPLAYS)
        return self._mask2displays(md.value)

    def get_display_name(self, target, display):
        '''return the name of the display device number.'''
        ns = self.query_string_attribute(target, [display], NV_CTRL_STRING_DISPLAY_DEVICE_NAME)
        return ns.string

    def get_display_modelines(self, target, display):
        '''return a display device's supported ModeLines as an array of
        ModeLine strings. The attribute may be queried through a GPU() or
        Display().

        Each ModeLine string may be prepended with a comma-separated list
        of token=value pairs, separated from the ModeLine string with a
        "::".'''
        mls = self.query_binary_data(target, [display], NV_CTRL_BINARY_DATA_MODELINES)
        return filter(lambda x: x, mls.data.split('\0'))

    def get_current_metamode(self, target):
        '''returns the metamode currently being used by the specified X
        screen. The MetaMode string has the same syntax as the MetaMode
        X configuration option, as documented in the NVIDIA driver README.

        The returned string may be prepended with a comma-separated list of
        "token=value" pairs, separated from the MetaMode string by "::".
        This "token=value" syntax is the same as that used in
        get_metamodes().'''
        mm = self.query_string_attribute(target, [], NV_CTRL_STRING_CURRENT_METAMODE)
        return MetaMode(mm.string)

    def get_metamodes(self, target):
        '''return an X screen's supported MetaModes as an array of MetaMode
        strings. The attribute must be queried through a Display().
        Each MetaMode string may be prepended with a comma-separated list
        of token=value paris, separated from the  MetaMode string with
        "::".'''
        mms = self.query_binary_data(target, [], NV_CTRL_BINARY_DATA_METAMODES)
        return MetaModeList(filter(lambda x: x, mms.data.split('\0')))

    def add_metamode(self, target, mm):
        '''provide a MetaMode string as input. return newly created MetaMode
        on success, or -1 if it failed.

        All ModeLines referenced in the MetaMode must already exist for each
        display device (as returned by get_metamodes()).
        
        The MetaMode string should have the same syntax as the MetaMode X
        configuration option, as documented in the NVIDIA driver README.
        
        The input string can optionally be prepended with a string of
        comma-separated "token=value" pairs, separated from the MetaMode string
        by "::". Currently, the only valid token is "index" which indicates the
        insertion index for the MetaMode.'''
        #res = self.set_string_attribute(target, [], NV_CTRL_STRING_ADD_METAMODE, mm)
        res = self.string_operation(target, [], NV_CTRL_STRING_OPERATION_ADD_METAMODE, str(mm))
        r = re.match('id=(\d+)', res.string)
        if not r: return -1
        return int(r.group(1))

    def delete_metamode(self, target, mm):
        '''Deletes an existing MetaMode from the specified X Screen. The
        currently selected MetaMode cannot be deleted. (This also means you
        cannot delete the last MetaMode).  The MetaMode string should have the
        same syntax as the MetaMode X configuration option, as documented in
        the NVIDIA driver README.

        The argument can either be a metamode, MetaMode, or a mode id (integer).'''
        if type(mm) == int:
            # retrieve id from MetaModes
            mm = self.get_metamodes(target).find(mm)
            if not mm:
                # not found, modeline id not found
                return False
            mm = mm.src
        elif isinstance(mm, MetaMode):
            # get original string from metamode
            mm = mm.src
        mm = re.sub(r'^.*::\s*', r'', mm)
        res = self.set_string_attribute(target, [], NV_CTRL_STRING_DELETE_METAMODE, mm)
        return res.flags

    def move_metamode(self, target, mm, to):
        '''moves a MetaMode to the specified index location.
        The MetaMode must already exist in the X Screen's list of MetaModes (as
        returned by the get_metamodes(). If the index is larger than the number
        of MetaModes in the list, the MetaMode is moved to the end of the list.
        The MetaMode string should have the same syntax as the MetaMode X
        configuration option, as documented in the NVIDIA driver README.
 
        The MetaMode string must be prepended with a comma-separated list
        of "token=value" pairs, separated from the MetaMode string by "::".
        Currently, the only valid token is "index", which indicates where
        in the MetaMode list the MetaMode should be moved to.
        
        Other tokens may be added in the future.
        
        E.g.,
          "index=5 :: CRT-0: 1024x768 @1024x768 +0+0"
        
        The mm argument can either be a metamode, MetaMode, or a mode id (integer).
        '''
        if type(mm) == int:
            # retrieve id from MetaModes
            mm = self.get_metamodes(target).find(mm)
            if not mm:
                # not found, modeline id not found
                return False
            mm = mm.src
        elif isinstance(mm, MetaMode):
            # get original string from metamode
            mm = mm.src
        mm = "index=%d :: %s"%(to, re.sub(r'^.*::\s*', r'', mm))
        res = self.set_string_attribute(target, [], NV_CTRL_STRING_MOVE_METAMODE, mm)
        return res.flags
         

    def build_display_modepool(self, target, display, opt=None):
        '''build a ModePool for the specified display device on the specified
        target (either an X screen or a GPU). This is typically used to
        generate a ModePool for a display device on a GPU on which no X screens
        are present.
        
        Currently, a display device's ModePool is static for the life of the X
        server, so this will return False if requested to build a ModePool on a
        display device that already has a ModePool.
        
        The string input opt may be NULL. If it is not NULL, then it is
        interpreted as a double-semicolon ("::") separated list of
        "option=value" pairs, where the options and the syntax of their values
        are the X configuration options that impact the behavior of modePool
        construction; namely: "ModeValidation" "HorizSync" "VertRefresh"
        "FlatPanelProperties" "TVStandard" "ExactModeTimingsDVI" "UseEdidFreqs"
        
        An example input string might look like:
        "ModeValidation=NoVesaModes :: HorizSync=50-110 :: VertRefresh=50-150"
        
        Returns a boolean.'''
        res = self.string_operation(target, [display], NV_CTRL_STRING_OPERATION_BUILD_MODEPOOL, opt)
        return res.flags

    def get_screen_associated_displays(self, target):
        '''return array of display devices that are "associated" with the
        specified X screen.'''
        res = self.query_int_attribute(target, [], NV_CTRL_ASSOCIATED_DISPLAY_DEVICES)
        return self._mask2displays(res.value)

    def set_screen_associated_displays(self, target, displays):
        '''set which display devices are "associated" with the specified X
        screen (ie: are available to the X screen for displaying the X
        screen).'''
        mask = self._displays2mask(displays)
        res = self.set_int_attribute(target, [], NV_CTRL_ASSOCIATED_DISPLAY_DEVICES, mask)
        return res.flags

    def get_frontend_resolution(self, target, display):
        '''return the dimensions of the frontend (current) resolution as
        determined by the NVIDIA X Driver as [width, height].'''
        res = self.query_int_attribute(target, [display], NV_CTRL_FRONTEND_RESOLUTION)
        if not res.flags: return False
        return res>>16, res&0xffff

    def get_backend_resolution(self, target, display):
        '''return the dimensions of the backend resolution as determined by the
        NVIDIA X Driver as [width, height].

        The backend resolution is the resolution (supported by the display
        device) the GPU is set to scale to.  If this resolution matches the
        frontend resolution, GPU scaling will not be needed/used.'''
        res = self.query_int_attribute(target, [display], NV_CTRL_BACKEND_RESOLUTION)
        if not res.flags: return False
        return res.value>>16, res.value&0xffff

    def get_dfp_native_resolution(self, target, display):
        '''return the dimensions of the native resolution of the flat panel as
        determined by the NVIDIA X Driver as [width, height].

        The native resolution is the resolution at which a flat panel
        must display any image.  All other resolutions must be scaled to this
        resolution through GPU scaling or the DFP's native scaling capabilities
        in order to be displayed.

        This attribute is only valid for flat panel (DFP) display devices.'''
        res = self.query_int_attribute(target, [display], NV_CTRL_FLATPANEL_NATIVE_RESOLUTION)
        if not res.flags: return False
        return res.value>>16, res.value&0xffff

    def get_dfp_best_fit_resolution(self, target, display):
        '''return the dimensions of the resolution, selected by the X driver,
        from the DFP's EDID that most closely matches the frontend resolution
        of the current mode as [width, height]. The best fit resolution is
        selected on a per-mode basis. set_scaling() is used to select between
        get_best_fit_resolution() and get_native_resolution().

        This attribute is only valid for flat panel (DFP) display devices.'''
        res = self.query_int_attribute(target, [display], NV_CTRL_FLATPANEL_BEST_FIT_RESOLUTION)
        if not res.flags: return False
        return res.value>>16, res.value&0xffff

    def set_gpu_scaling(self, target, display, starget, smethod):
        '''controls what the GPU scales to and how. If starget is 'best-fit',
        the GPU scales the frontend (current) mode to the closest larger
        resolution in the flat panel's EDID and allow the flat panel to do its
        own scaling to the native resolution. If starget is 'native', the GPU
        scales the frontend (current) mode to the flat panel's native
        resolution, thus disabling any internal scaling the flat panel might
        have.
        
        smethod can be 'strechted', 'centered' or 'aspect-scaled'.
        
        starget and smethod can also be numbers.'''
        mode = 0
        if type(starget) == int:
            mode += (starget&0xffff)<<16
        elif starget == 'native':
            mode += 1<<16
        elif starget == 'best-fit':
            mode += 2<<16
        else:
            raise ValueError('Scaling target must be either "best fit" or "native"')
        if type(smethod) == int:
            mode += smethod & 0xffff
        elif smethod == 'stretched':
            mode += 1
        elif smethod == 'centered':
            mode += 2
        elif smethod == 'aspect-scaled':
            mode += 3
        else:
            raise ValueError('Scaling method must be one of "stretched", "centered" or "aspect-scaled"')
        res = self.set_int_attribute(target, [display], NV_CTRL_GPU_SCALING, mode)
        return res.flags

    def get_gpu_scaling(self, target, display):
        '''return current GPU scaling as [target, method].
        See set_gpu_scaling() for details.'''
        res = self.query_int_attribute(target, [display], NV_CTRL_GPU_SCALING)
        if not res.flags: return False
        starget = res.value >> 16
        if starget == 1:   starget = 'native'
        elif starget == 2: starget = 'best-fit'
        smethod = res.value & 0xffff
        if smethod == 1:   smethod = 'stretched'
        elif smethod == 2: smethod = 'centered'
        elif smethod == 3: smethod = 'aspect-scaled'
        return starget, smethod

    def get_max_displays(self, target):
        '''return the maximum number of display devices that can be driven
        simultaneously on a GPU (e.g., that can be used in a MetaMode at once).
        Note that this does not indicate the maximum number of bits that can be
        set in NV_CTRL_CONNECTED_DISPLAYS, because more display devices can be
        connected than are actively in use.'''
        res = self.query_int_attribute(target, [], NV_CTRL_MAX_DISPLAYS)
        if not res.flags: return False
        return res.value

    def get_display_edid(self, target, display):
        '''return a display device's EDID information data'''
        mms = self.query_binary_data(target, [display], NV_CTRL_BINARY_DATA_EDID)
        if not mms.flags: return False
        return mms.data
    
    def get_xinerama_info_order(self, target):
        '''return the order that display devices will be returned via
        Xinerama when TwinViewXineramaInfo is enabled.  Follows the same
        syntax as the TwinViewXineramaInfoOrder X config option.'''
        res = self.query_string_attribute(target, [], NV_CTRL_STRING_TWINVIEW_XINERAMA_INFO_ORDER)
        if not res.flags: return False
        return res.string
        
    def set_xinerama_info_order(self, target, displays):
        '''specify the order that display devices will be returned via
        Xinerama when TwinViewXineramaInfo is enabled.  Follows the same
        syntax as the TwinViewXineramaInfoOrder X config option.'''
        res = self.set_string_attribute(target, [], NV_CTRL_STRING_TWINVIEW_XINERAMA_INFO_ORDER, ', '.join(displays))
        return res.flags


# vim:ts=4:sw=4:expandtab:
