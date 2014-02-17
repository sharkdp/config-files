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

__author__ = "Sebastian Heinlein, Michael Vogt"
__version__ = "0.1.1.x"
__status__ = "development"

from ctypes import *
import os


RR_ROTATE_0 = 1
RR_ROTATE_90 = 2
RR_ROTATE_180 = 4
RR_ROTATE_270 = 8
RR_REFLECT_X = 16
RR_REFLECT_Y = 32

RR_CONNECTED = 0
RR_DISCONNECTED = 1
RR_UNKOWN_CONNECTION = 2

RR_BAD_OUTPUT = 0
RR_BAD_CRTC = 1
RR_BAD_MODE = 2

RR_SET_CONFIG_SUCCESS = 0
RR_SET_CONFIG_INVALID_CONFIG_TIME = 1
RR_SET_CONFIG_INVALID_TIME = 2
RR_SET_CONFIG_FAILED = 3

# Flags to keep track of changes
CHANGES_NONE = 0
CHANGES_CRTC = 1
CHANGES_MODE = 2
CHANGES_RELATION = 4
CHANGES_POSITION = 8
CHANGES_ROTATION = 16
CHANGES_REFLECTION = 32
CHANGES_AUTOMATIC = 64
CHANGES_REFRESH = 128
CHANGES_PROPERTY = 256

# Relation information
RELATION_ABOVE = 0
RELATION_BELOW = 1
RELATION_RIGHT_OF = 2
RELATION_LEFT_OF = 3
RELATION_SAME_AS = 4

from core import Screen, xlib, rr

def get_current_display():
    """Returns the currently used display"""
    display_url = os.getenv("DISPLAY")
    dpy = xlib.XOpenDisplay(display_url)
    return dpy

def get_current_screen():
    """Returns the currently used screen"""
    dpy = get_current_display()
    if not dpy: return None
    screen = Screen(dpy)
    return screen

def get_screen_of_display(display, count):
    """Returns the screen of the given display"""
    dpy = xlib.XOpenDisplay(display)
    return Screen(dpy, count)

def get_version():
    """Returns a tuple containing the major and minor version of the xrandr
       extension or None if the extension is not available"""
    major = c_int()
    minor = c_int()
    dpy = get_current_display()
    if not dpy: return None
    res = core.rr.XRRQueryVersion(dpy, byref(major), byref(minor))
    if res:
        return (major.value, minor.value)
    return None

def has_extension():
    """Returns True if the xrandr extension is available"""
    if XRANDR_VERSION:
        return True
    return False

def _check_required_version(version):
    """Raises an exception if the given or a later version of xrandr is not
       available"""
    if XRANDR_VERSION == None or XRANDR_VERSION < version:
        raise UnsupportedRRError(version, XRANDR_VERSION)

XRANDR_VERSION = get_version()

# vim:ts=4:sw=4:et
