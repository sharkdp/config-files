#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Python-XRandR provides a high level API for the XRandR extension of the
# X.org server. XRandR allows to configure resolution, refresh rate, rotation 
# of the screen and multiple outputs of graphics cards.
#
# Copyright 2007 © Sebastian Heinlein <sebastian.heinlein@web.de>
# Copyright 2007 © Michael Vogt <mvo@ubuntu.com>
# Copyright 2007 © Canonical Ltd.
#
# In many aspects it follows the design of the xrand tool of the X.org, which
# comes with the following copyright:
#
# Copyright © 2001 Keith Packard, member of The XFree86 Project, Inc.
# Copyright © 2002 Hewlett Packard Company, Inc.
# Copyright © 2006 Intel Corporation
#
# And can be downloaded here:
#
# git://anongit.freedesktop.org/git/xorg/app/xrandr
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

import os
from ctypes import *

import xrandr

# some fundamental datatypes·
RRCrtc = c_long
RROutput = c_long
RRMode = c_long
Connection = c_ushort
SubpixelOrder = c_ushort
Time = c_ulong
Rotation = c_ushort
Status = c_int

xlib = cdll.LoadLibrary("libX11.so.6")
rr = cdll.LoadLibrary("libXrandr.so.2")

# query resources
class _XRRModeInfo(Structure):
    _fields_ = [
        ("id", RRMode), # XID is c_long
        ("width", c_int),
        ("height", c_int),
        ("dotClock", c_long),
        ("hSyncStart", c_int),
        ("hSyncEnd", c_int),
        ("hTotal", c_int),
        ("hSkew", c_int),
        ("vSyncStart", c_int),
        ("vSyncEnd", c_int),
        ("vTotal", c_int),
        ("name", c_char_p),
        ("nameLength", c_int),
        ("modeFlags", c_long),
        ]

class _XRRScreenSize(Structure):
    _fields_ = [
        ("width", c_int),
        ("height", c_int),
        ("mwidth", c_int),
        ("mheight", c_int)
        ]

class _XRRCrtcInfo(Structure):
    _fields_ = [
        ("timestamp", Time),
        ("x", c_int),
        ("y", c_int),
        ("width", c_int),
        ("height", c_int),
        ("mode", RRMode),
        ("rotation", c_int),
        ("noutput", c_int),
        ("outputs", POINTER(RROutput)),
        ("rotations", Rotation),
        ("npossible", c_int),
        ("possible", POINTER(RROutput)),
        ]
    
class _XRRScreenResources(Structure):
    _fields_ = [
        ("timestamp", Time),
        ("configTimestamp", Time),
        ("ncrtc", c_int),
        ("crtcs", POINTER(RRCrtc)),
        ("noutput", c_int),
        ("outputs", POINTER(RROutput)),
        ("nmode", c_int),
        ("modes", POINTER(_XRRModeInfo)),
        ]

class RRError(Exception):
    """Base exception class of the module"""
    pass

class UnsupportedRRError(RRError):
    """Raised if the required XRandR extension version is not available"""
    def __init__(self, required, current):
        self.required = required
        self.current = current

# XRRGetOutputInfo
class _XRROutputInfo(Structure):
    _fields_ = [
        ("timestamp", Time),
        ("crtc", c_int),
        ("name", c_char_p),
        ("nameLen", c_int),
        ("mm_width", c_ulong),
        ("mm_height", c_ulong),
        ("connection", Connection),
        ("subpixel_order", SubpixelOrder),
        ("ncrtc", c_int),
        ("crtcs", POINTER(RRCrtc)),
        ("nclone", c_int),
        ("clones", POINTER(RROutput)),
        ("nmode", c_int),
        ("npreferred", c_int),
        ("modes", POINTER(RRMode))
        ]

class _XRRCrtcGamma(Structure):
    _fields_ = [
        ('size', c_int),
        ('red', POINTER(c_ushort)),
        ('green', POINTER(c_ushort)),
        ('blue', POINTER(c_ushort)),
        ]

def _array_conv(array, type, conv = lambda x:x):
    length = len(array)
    res = (type*length)()
    for i in range(length):
        res[i] = conv(array[i])
    return res

class Output:
    """The output is a reference to a supported output jacket of the graphics
       card. Outputs are attached to a hardware pipe to be used. Furthermore
       they can be a clone of another output or show a subset of the screen"""
    def __init__(self, info, id, screen):
        """Initializes an output instance"""
        self._info = info
        self.id = id
        self._screen = screen
        # Store changes later here
        self._mode = None
        self._crtc = None
        self._rotation = xrandr.RR_ROTATE_0
        self._relation = None
        self._relation_offset = 0
        self._relative_to = None
        self._position = None
        self._reflection = None
        self._automatic = None
        self._rate = None
        self._changes = xrandr.CHANGES_NONE
        self._x = 0
        self._y = 0

        self.name = self._info.contents.name

    def __del__(self):
        """Frees the internal reference to the output info if the output gets
           removed"""
        rr.XRRFreeOutputInfo(self._info)
    def get_physical_width(self):
        """Returns the display width reported by the connected output device"""
        return self._info.contents.mm_width
    def get_physical_height(self):
        """Returns the display height reported by the connected output device"""
        return self._info.contents.mm_height
    def get_crtc(self):
        """Returns the xid of the hardware pipe to which the the output is
           attached. If the output is disabled it will return 0"""
        return self._info.contents.crtc
    def get_crtcs(self):
        """Returns the xids of the hardware pipes to which the output could
           be attached"""
        crtcs = []
        for i in range(self._info.contents.ncrtc):
            for crtc in self._screen.crtcs:
                if crtc.xid == self._info.contents.crtcs[i]:
                    crtcs.append(crtc)
        return crtcs

    def get_available_rotations(self):
        """Returns a binary flag of the supported rotations of the output or
           0 if the output is disabled"""
        rotations = xrandr.RR_ROTATE_0
        found = False
        if self.is_active():
            # Get the rotations supported by all crtcs to make assigning
            # crtcs easier. Furthermore there don't seem to be so many
            # cards which show another behavior
            for crtc in self.get_crtcs():
                # Set rotations to the value of the first found crtc and
                # then create a subset only for all other crtcs
                if not found:
                    rotations = crtc.get_available_rotations()
                    found = True
                else:
                    rotations = rotations & crtc.get_available_rotations()
        return rotations

    def get_available_modes(self):
        """Returns the list of supported mode lines (resolution, refresh rate)
           that are supported by the connected device"""
        modes = []
        for m in range(self._info.contents.nmode):
            output_modes = self._info.contents.modes
            for s in range(self._screen._resources.contents.nmode):
                screen_modes = self._screen._resources.contents.modes
                if screen_modes[s].id == output_modes[m]:
                    modes.append(screen_modes[s])
        return modes

    def get_available_resolutions(self, reverse=False):
        """Return a list of available resolution pairs"""
        res = set()
        for mode in self.get_available_modes():
            res.add((mode.width, mode.height))
        ls = list(res)
        ls.sort(reverse=reverse)
        return  ls

    def get_available_rates_for_resolution(self, width, height, reverse=False):
        """Return a list of rates that are available for the given
           resolution"""
        rates = set()
        for mode in self.get_available_modes():
            if mode.width == width and mode.height == height:
                rates.add(mode.dotClock / (mode.hTotal * mode.vTotal))
        ls = list(rates)
        ls.sort(reverse=reverse)
        return ls

    def get_current_rate(self):
        """Return a tuple with the current height and width"""
        if self.is_active():
            mode = self._screen.get_mode_by_xid(self._mode)
            return mode.dotClock / (mode.hTotal * mode.vTotal)
        else:
            return None

    def get_current_resolution(self):
        """Return a tuple with the height and width of the current resolution"""
        if self.is_active():
            mode = self._screen.get_mode_by_xid(self._mode)
            return (mode.width, mode.height)
        else:
            return (None, None)

    def get_preferred_mode(self):
        """Returns an index that refers to the list of available modes and 
           points to the preferred mode of the connected device"""
        return self._info.contents.npreferred

    def is_active(self):
        """Returns True if the output is attached to a hardware pipe, is
           enabled"""
        return self._info.contents.crtc != 0

    def is_connected(self):
        """Return True if a device is detected at the output"""
        if self._info.contents.connection in (xrandr.RR_CONNECTED,
                                              xrandr.RR_UNKOWN_CONNECTION):
            return True
        return False

    def disable(self):
        """Disable the output"""
        if not self.is_active(): return
        self._mode = None
        self._crtc._outputs.remove(self)
        self._crtc = None
        self._changes = self._changes | xrandr.CHANGES_CRTC | xrandr.CHANGES_MODE

    def set_to_mode(self, mode):
        """Change the output to the given mode"""
        modes = self.get_available_modes()
        if mode in range(len(modes)):
            self._mode = modes[mode].id
            return
        raise RRError("Mode is not available")

    def set_to_preferred_mode(self):
        """Set the output to its preferred mode"""
        modes = self.get_available_modes()
        mode = modes[self.get_preferred_mode()]
        if mode != None:
            self._mode = mode.id
            return
        raise RRError("Preferred mode is not available")

    def get_clones(self):
        """Return the xids of the outputs which can be clones of the output"""
        clones = []
        for i in range(self._info.contents.nclone):
            id = self._info.contents.clones[i]
            o = self._screen.get_output_by_id(id)
            clones.append(o)
        return clones

    def set_relation(self, relative, relation, offset=0):
        """Set the position of the output in relation to the given one"""
        rel = self._screen.get_output_by_name(relative)
        if rel and relation in (xrandr.RELATION_LEFT_OF,
                                xrandr.RELATION_RIGHT_OF,
                                xrandr.RELATION_ABOVE,
                                xrandr.RELATION_BELOW,
                                xrandr.RELATION_SAME_AS):
            self._relation = relation
            self._relative_to = rel
            self._relation_offset = offset
            self._changes = self._changes | xrandr.CHANGES_RELATION
        else:
            raise RRError("The given relative output or relation is not "
                          "available")

    def has_changed(self, changes=None):
        """Checks if the output has changed: Either for a specific change or
           generally"""
        if changes:
            return self._changes & changes
        else:
            return self._changes != xrandr.CHANGES_NONE

class Crtc:
    """The crtc is a reference to a hardware pipe that is provided by the
       graphics device. Outputs can be attached to crtcs"""
    def __init__(self, info, xid, screen):
        """Initializes the hardware pipe object"""
        self._info = info
        self.xid = xid
        self._screen = screen
        self._outputs = []

    def __del__(self):
        """Frees the reference to the rendering pipe if the instance gets 
           removed"""
        rr.XRRFreeCrtcConfigInfo(self._info)

    def get_xid(self):
        """Returns the internal id of the crtc from the X server"""
        return self.xid

    def get_available_rotations(self):
        """Returns a binary flag that contains the supported rotations of the
           hardware pipe"""
        return self._info.contents.rotations

    def set_config(self, x, y, mode, outputs, rotation=xrandr.RR_ROTATE_0):
        """Configures the render pipe with the given mode and outputs. X and y
           set the position of the crtc output in the screen"""
        rr.XRRSetCrtcConfig(self._screen._display,
                            self._screen._resources,
                            self.xid,
                            self._screen.get_timestamp(),
                            c_int(x), c_int(y),
                            mode,
                            rotation,
                            _array_conv(outputs, RROutput, lambda x: x.id),
                            len(outputs))

    def apply_changes(self):
        """Applies the stored changes"""
        if len(self._outputs) > 0:
            output = self._outputs[0]
            self.set_config(output._x, output._y, output._mode, 
                            self._outputs, output._rotation)
        else:
            self.disable()

    def disable(self):
        """Turns off all outputs on the crtc"""
        self.set_config(0, 0, None, [])

    #FIXME: support gamma settings
    """
    def get_gamma_size(self):
        return rr.XRRGetCrtcGammaSize(self._screen._display, self.id)
    def get_gamma(self):
        result = rr.XRRGetCrtcGamma(self._screen._display, self.id)
        return _from_gamma(result)
    def set_gamma(self, gamma):
        g = _to_gamma(gamma)
        rr.XRRSetCrtcGamma(self._screen._display, self.id, g)
        rr.XRRFreeGamma(g)
        gamma = property(get_gamma, set_gamma)"""

    def load_outputs(self):
        """Get the currently assigned outputs"""
        outputs = []
        for i in range(self._info.contents.noutput):
            id = self._info.contents.outputs[i]
            o = self._screen.get_output_by_id(id)
            outputs.append(o)
        self._outputs = outputs

    def get_outputs(self):
        """Returns the list of attached outputs"""
        return self._outputs

    def add_output(self, output):
        """Adds the specified output to the crtc"""
        output._crtc = self
        self._outputs.append(output)

    def supports_output(self, output):
        """Check if the output can be used by the crtc. 
           See check_crtc_for_output in xrandr.c"""
        if not self.xid in map(lambda c: c.xid, output.get_crtcs()):
            return False
        if len(self._outputs):
            for other in self._outputs:
                if other == output: continue
                if other._x != output._x: return False
                if other._y != output._y: return False
                if other._mode != output._mode: return False
                if other._rotation != output._rotation: return False
        #FIXME: pick_crtc is still missing
        elif self._info.contents.noutput > 0:
            if self._info.contents.x != output._x: return False
            if self._info.contents.y != output._y: return False
            if self._info.contents.mode_info != output._mode: return False
            if self._info.rotation != output._rotation: return False
        return True

    def supports_rotation(self, rotation):
        """Check if the given rotation is supported by the crtc"""
        rotations = self._info.contents.rotations
        dir = rotation & (xrandr.RR_ROTATE_0|xrandr.RR_ROTATE_90|xrandr.RR_ROTATE_180|xrandr.RR_ROTATE_270)
        reflect = rotation & (xrandr.RR_REFLECT_X|xrandr.RR_REFLECT_Y)
        if (((rotations & dir) != 0) and ((rotations & reflect) == reflect)):
            return True
        return False

    def has_changed(self):
        """Check if there are any new outputs assigned to the crtc or any
           outputs with a changed mode or position"""
        if len(self._outputs) != self._info.contents.noutput:
            return True
        for i in range(self._info.contents.noutput):
            id = self._info.contents.outputs[i]
            output = self._screen.get_output_by_id(id) 
            if not output in self._outputs: return True
            if output.has_changed(): return True
        return False

class Screen:
    def __init__(self, dpy, screen=-1):
        """Initializes the screen"""
        # Some sane default values
        self.outputs = {}
        self.crtcs = []
        self._width = 0
        self._height = 0
        self._width_max = 0
        self._height_max = 0
        self._width_min = 0
        self._height_min = 0
        self._width_mm = 0
        self._height_mm = 0

        self._display = dpy
        if not -1 <= screen < xlib.XScreenCount(dpy):
            raise RRError("The chosen screen is not available", screen)
        elif screen == -1:
            self._screen = xlib.XDefaultScreen(dpy)
        else:
            self._screen = screen
        self._root = xlib.XDefaultRootWindow(self._display, self._screen)
        self._id = rr.XRRRootToScreen(self._display, self._root)
        
        self._load_resources()
        self._load_config()
        (self._width, self._height, 
         self._width_mm, self._height_mm) = self.get_size()
        if xrandr.get_version() >= (1,2):
            self._load_screen_size_range()
            self._load_crtcs()
            self._load_outputs()

        # Store XRandR 1.0 changes here
        self._rate = self.get_current_rate()
        self._rotation = self.get_current_rotation()
        self._size_index = self.get_current_size_index()

    def __del__(self):
        """Free the reference to the interal screen config if the screen
           gets removed"""
        rr.XRRFreeScreenConfigInfo(self._config)

    def _load_config(self):
        """Loads the screen configuration. Only needed privately by the
           the bindings"""
        class XRRScreenConfiguration(Structure):
            " private to Xrandr "
            pass
        gsi = rr.XRRGetScreenInfo
        gsi.restype = POINTER(XRRScreenConfiguration)
        self._config = gsi(self._display, self._root)
        
    def _load_screen_size_range(self):
        """Detects the dimensionios of the screen"""
        minWidth = c_int()
        minHeight = c_int()
        maxWidth = c_int()
        maxHeight = c_int()
        res = rr.XRRGetScreenSizeRange(self._display, self._root, 
                                       byref(minWidth), byref(minHeight),
                                       byref(maxWidth), byref(maxHeight))
        if res:
            self._width_max = maxWidth.value
            self._width_min = minWidth.value
            self._height_max = maxHeight.value
            self._height_min = minHeight.value

    def _load_resources(self):
        """Loads the screen resources. Only needed privately for the 
           bindings"""
        gsr = rr.XRRGetScreenResources
        gsr.restype = POINTER(_XRRScreenResources)
        self._resources = gsr(self._display, self._root)

    def _load_crtcs(self):
        """Loads the available XRandR 1.2 crtcs (hardware pipes) of
           the screen"""
        gci = rr.XRRGetCrtcInfo
        gci.restype = POINTER(_XRRCrtcInfo)
        c = self._resources.contents.crtcs
        for i in range(self._resources.contents.ncrtc):
            xrrcrtcinfo = gci(self._display, self._resources, c[i])
            self.crtcs.append(Crtc(xrrcrtcinfo, c[i], self))

    def _load_outputs(self):
        """Loads the available XRandR 1.2 outputs of the screen"""
        goi = rr.XRRGetOutputInfo
        goi.restype = POINTER(_XRROutputInfo)
        o = self._resources.contents.outputs
        for i in range(self._resources.contents.noutput):
            xrroutputinfo = goi(self._display, self._resources, o[i])
            output = Output(xrroutputinfo, o[i], self)
            self.outputs[xrroutputinfo.contents.name] = output
            # Store the mode of the crtc in the output instance
            crtc = self.get_crtc_by_xid(output.get_crtc())
            if crtc:
                output._mode = crtc._info.contents.mode
                crtc.add_output(output)

    def get_size(self):
        """Returns the current pixel and physical size of the screen"""
        width = xlib.XDisplayWidth(self._display, self._screen)
        width_mm = xlib.XDisplayWidthMM(self._display, self._screen)
        height = xlib.XDisplayHeight(self._display, self._screen)
        height_mm = xlib.XDisplayHeightMM(self._display, self._screen)
        return width, height, width_mm, height_mm

    def get_timestamp(self):
        """Creates a X timestamp that must be used when applying changes, since
           they can be delayed"""
        config_timestamp = Time()
        rr.XRRTimes.restpye = c_ulong
        return rr.XRRTimes(self._display, self._id, byref(config_timestamp))

    def get_crtc_by_xid(self, xid):
        """Returns the crtc with the given xid or None"""
        for crtc in self.crtcs:
            if crtc.xid == xid:
                return crtc
        return None

    def get_current_rate(self):
        """Returns the currently used refresh rate"""
        xrandr._check_required_version((1,0))
        xccr = rr.XRRConfigCurrentRate
        xccr.restype = c_int
        return xccr(self._config)

    def get_available_rates_for_size_index(self, size_index):
        """Returns the refresh rates that are supported by the screen for
           the given resolution. See get_available_sizes for the resolution to
           which size_index points"""
        xrandr._check_required_version((1,0))
        rates = []
        nrates = c_int()
        rr.XRRConfigRates.restype = POINTER(c_ushort)
        _rates = rr.XRRConfigRates(self._config, size_index, byref(nrates))
        for r in range(nrates.value):
            rates.append(_rates[r])
        return rates

    def get_current_rotation(self):
        """Returns the currently used rotation. Can be RR_ROTATE_0, 
        RR_ROTATE_90, RR_ROTATE_180 or RR_ROTATE_270"""
        xrandr._check_required_version((1,0))
        current = c_ushort()
        rotations = rr.XRRConfigRotations(self._config, byref(current))
        return current.value

    def get_available_rotations(self):
        """Returns a binary flag that holds the available resolutions"""
        xrandr._check_required_version((1,0))
        current = c_ushort()
        rotations = rr.XRRConfigRotations(self._config, byref(current))
        return rotations

    def get_current_size_index(self):
        """Returns the position of the currently used resolution size in the
           list of available resolutions. See get_available_sizes"""
        xrandr._check_required_version((1,0))
        rotation = c_ushort()
        size = rr.XRRConfigCurrentConfiguration(self._config,
                                                byref(rotation))
        return size

    def get_available_sizes(self):
        """Returns the available resolution sizes of the screen. The size
           index points to the corresponding resolution of this list"""
        xrandr._check_required_version((1,0))
        sizes = []
        nsizes = c_int()
        xcs = rr.XRRConfigSizes
        xcs.restype = POINTER(_XRRScreenSize)
        _sizes = xcs(self._config, byref(nsizes))
        for r in range(nsizes.value):
            sizes.append(_sizes[r])
        return sizes

    def set_config(self, size_index, rate, rotation):
        """Configures the screen with the given resolution at the given size 
           index, rotation and refresh rate. To get in effect call
           Screen.apply_config()"""
        xrandr._check_required_version((1,0))
        self.set_size_index(size_index)
        self.set_refresh_rate(rate)
        self.set_rotation(rotation)

    def set_size_index(self, index):
        """Sets the reoslution of the screen. To get in effect call
           Screen.apply_config()"""
        if index in range(len(self.get_available_sizes())):
            self._size_index = index
        else:
            raise RRError("There isn't any size associated "
                          "to the index %s" % index)

    def set_rotation(self, rotation):
        """Sets the rotation of the screen. To get in effect call
           Screen.apply_config()"""
        if self.get_available_rotations() & rotation:
            self._rotation = rotation
        else:
            raise RRError("The chosen rotation is not supported")

    def set_refresh_rate(self, rate):
        """Sets the refresh rate of the screen. To get in effect call
           Screen.apply_config()"""
        if rate in self.get_available_rates_for_size_index(self._size_index):
            self._rate = rate
        else:
            raise RRError("The chosen refresh rate %s is not "
                          "supported" % rate)

    def get_mode_by_name(self, name):
        """Returns the mode of the given name"""
        screen_modes = self._resources.contents.modes
        for s in range(self._resources.contents.nmode):
            if screen_modes[s].name == name:
                return screen_modes[s]
        return None

    def get_mode_by_xid(self, xid):
        """Returns the mode of the given xid"""
        screen_modes = self._resources.contents.modes
        for s in range(self._resources.contents.nmode):
            if screen_modes[s].id == xid:
                return screen_modes[s]
        return None

    def get_output_by_name(self, name):
        """Returns the output of the screen with the given name or None"""
        if self.outputs.has_key(name):
            return self.outputs[name]
        else:
            return None

    def get_output_by_id(self, id):
        """Returns the output of the screen with the given xid or None"""
        for o in self.outputs.values():
            if o.id == id:
                return o
        return None

    def print_info(self, verbose=False):
        """Prints some information about the detected screen and its outputs"""
        xrandr._check_required_version((1,0))
        print "Screen %s: minimum %s x %s, current %s x %s, maximum %s x %s" %\
              (self._screen,
               self._width_min, self._height_min,
               self._width, self._height,
               self._width_max, self._height_max)
        print "          %smm x %smm" % (self._width_mm, self._height_mm)
        print "Crtcs: %s" % len(self.crtcs)
        if verbose:
            print "Modes (%s):" % self._resources.contents.nmode
            modes = self._resources.contents.modes
            for i in range(self._resources.contents.nmode):
                print "  %s - %sx%s" % (modes[i].name,
                                       modes[i].width,
                                       modes[i].height)
        i = 0
        print "Sizes @ Refresh Rates:"
        for s in self.get_available_sizes():
            print "  [%s] %s x %s @ %s" % (i, s.width, s.height,
                                           self.get_available_rates_for_size_index(i))
            i += 1
        print "Rotations:",
        rots = self.get_available_rotations()
        if rots & xrandr.RR_ROTATE_0: print "normal",
        if rots & xrandr.RR_ROTATE_90: print "right",
        if rots & xrandr.RR_ROTATE_180: print "inverted",
        if rots & xrandr.RR_ROTATE_270: print "left",
        print ""
        print "Outputs:"
        for o in self.outputs.keys():
            output = self.outputs[o]
            print "  %s"  % o,
            if output.is_connected():
                print "(%smm x %smm)" % (output.get_physical_width(),
                                         output.get_physical_height())
                modes = output.get_available_modes()
                print "    Modes:"
                for m in range(len(modes)):
                    mode = modes[m]
                    refresh = mode.dotClock / (mode.hTotal * mode.vTotal)
                    print "      [%s] %s x %s @ %s" % (m,
                                                       mode.width,
                                                       mode.height,
                                                       refresh),
                    if mode.id == output._mode:
                        print "*",
                    if m == output.get_preferred_mode():
                        print "(preferred)",
                    print ""
                print "    Rotations:",
                rots = output.get_available_rotations()
                if rots & xrandr.RR_ROTATE_0: print "normal",
                if rots & xrandr.RR_ROTATE_90: print "right",
                if rots & xrandr.RR_ROTATE_180: print "inverted",
                if rots & xrandr.RR_ROTATE_270: print "left",
                print ""
            else: 
                print "(not connected)"
            if verbose:
                print "    Core properties:"
                for (f,t) in output._info.contents._fields_:
                    print "      %s: %s" % (f,
                                            getattr(output._info.contents, f))

    def get_outputs(self):
        """Returns the outputs of the screen"""
        xrandr._check_required_version((1,2))
        return self.outputs.values()

    def get_output_names(self):
        xrandr._check_required_version((1,2))
        return self.outputs.keys()

    def set_size(self, width, height, width_mm, height_mm):
        """Apply the given pixel and physical size to the screen"""
        xrandr._check_required_version((1,2))
        # Check if we really need to apply the changes
        if (width, height, width_mm, height_mm) == self.get_size(): return
        rr.XRRSetScreenSize(self._display, self._root,
                            c_int(width), c_int(height),
                            c_int(width_mm), c_int(height_mm))

    def apply_output_config(self):
        """Used for instantly applying RandR 1.2 changes"""
        xrandr._check_required_version((1,2))
        self._arrange_outputs()
        self._calculate_size()
        self.set_size(self._width, self._height,
                      self._width_mm, self._height_mm)

        # Assign all active outputs to crtcs
        for output in self.outputs.values():
            if not output._mode or output._crtc: continue
            for crtc in output.get_crtcs():
                if crtc and crtc.supports_output(output):
                    crtc.add_output(output)
                    output._changes = output._changes | xrandr.CHANGES_CRTC
                    break
            if not output._crtc:
                #FIXME: Take a look at the pick_crtc code in xrandr.c
                raise RRError("There is no matching crtc for the output")

        # Apply stored changes of crtcs
        for crtc in self.crtcs:
            if crtc.has_changed(): 
                crtc.apply_changes()

    def apply_config(self):
        """Used for instantly applying RandR 1.0 changes"""
        xrandr._check_required_version((1,0))
        status = rr.XRRSetScreenConfigAndRate(self._display,
                                              self._config,
                                              self._root,
                                              self._size_index,
                                              self._rotation,
                                              self._rate,
                                              self.get_timestamp())

    def _arrange_outputs(self):
        """Arrange all output positions according to their relative position"""
        for output in self.get_outputs():
            # Skip not changed and not used outputs
            if not output.has_changed(xrandr.CHANGES_RELATION) or \
               output._mode == None: continue
            relative = output._relative_to
            mode = self.get_mode_by_xid(output._mode)
            mode_relative = self.get_mode_by_xid(relative._mode)
            if not relative or not relative._mode:
                output._x = 0
                output._y = 0
                output._changes = output._changes | xrandr.CHANGES_POSITION
            if output._relation == xrandr.RELATION_LEFT_OF:
                output._y = relative._y + output._relation_offset
                output._x = relative._x - \
                            get_mode_width(mode, output._rotation)
            elif output._relation == xrandr.RELATION_RIGHT_OF:
                output._y = relative._y + output._relation_offset
                output._x = relative._x + get_mode_width(mode_relative,
                                                         output._rotation)
            elif output._relation == xrandr.RELATION_ABOVE:
                output._y = relative._y - get_mode_height(mode,
                                                          output._rotation)
                output._x = relative._x + output._relation_offset
            elif output._relation == xrandr.RELATION_BELOW:
                output._y = relative._y + get_mode_height(mode_relative,
                                                          output._rotation)
                output._x = relative._x + output._relation_offset
            elif output._relation == xrandr.RELATION_SAME_AS:
                output._y = relative._y + output._relation_offset
                output._x = relative._x + output._relation_offset
            output._changes = output._changes | xrandr.CHANGES_POSITION
        # Normalize the postions so to the upper left cornor of all outputs 
        # is at 0,0
        min_x = 32768
        min_y = 32768
        for output in self.get_outputs():
            if output._mode == None: continue
            if output._x < min_x: min_x = output._x
            if output._y < min_y: min_y = output._y
        for output in self.get_outputs():
            if output._mode == None: continue
            output._x -= min_x
            output._y -= min_y
            output._changes = output._changes | xrandr.CHANGES_POSITION

    def _calculate_size(self):
        """Recalculate the pixel and physical size of the screen so that
           it covers all outputs"""
        width = 1
        height = 1
        for output in self.get_outputs():
            if not output._mode: continue
            mode = self.get_mode_by_xid(output._mode)
            x = output._x
            y = output._y
            w = get_mode_width(mode, output._rotation)
            h = get_mode_height(mode, output._rotation)
            if x + w > width: width = x + w
            if y + h > height: height = y + h
        if width > self._width_max or height > self._height_max:
            raise RRError("The required size is not supported",
                          (width, height), (self._width_max, self._width_min))
        else:
            if height < self._height_min: 
                self._fb_height = self._height_min
            else:
                self._height = height
            if width < self._width_min: 
                self._width = self._width_min
            else:
                self._width = width
        #FIXME: Physical size is missing

def _to_gamma(gamma):
    g = rr.XRRAllocGamma(len(gamma[0]))
    for i in range(gamma[0]):
        g.red[i] = gamma[0][i]
        g.green[i] = gamma[1][i]
        g.blue[i] = gamma[2][i]
    return g

def _from_gamma(g):
    gamma = ([], [], [])
    for i in range(g.size):
        gamma[0].append(g.red[i])
        gamma[1].append(g.green[i])
        gamma[2].append(g.blue[i])
    rr.XRRFreeGamma(g)

def get_mode_height(mode, rotation):
    """Return the height of the given mode taking the rotation into account"""
    if rotation & (xrandr.RR_ROTATE_0 | xrandr.RR_ROTATE_180):
        return mode.height
    elif rotation & (xrandr.RR_ROTATE_90 | xrandr.RR_ROTATE_270):
        return mode.width
    else:
        return 0

def get_mode_width(mode, rotation):
    """Return the width of the given mode taking the rotation into account"""
    if rotation & (xrandr.RR_ROTATE_0 | xrandr.RR_ROTATE_180):
        return mode.width
    elif rotation & (xrandr.RR_ROTATE_90 | xrandr.RR_ROTATE_270):
        return mode.height
    else:
        return 0

# vim:ts=4:sw=4:et
