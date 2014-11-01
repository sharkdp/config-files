#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Python-XRandR provides a high level API for the XRandR extension of the
# X.org server. XRandR allows to configure resolution, refresh rate, rotation 
# of the screen and multiple outputs of graphics cards.
#
# This module allows to get information for gtk.gdk.Screen objects
#
# In many aspects it follows the design of the xrand tool written by
# Keith Packard.
#
# Copyright 2007 © Sebastian Heinlein <sebastian.heinlein@web.de>
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

import pygtk
pygtk.require("2.0")
import gtk.gdk

import xrandr

#FIXME: Perhaps using gdk_x11_screen_get_xscreen would be more elegant

def get_default_screen_config():
    dpy = gtk.gdk.display_get_default()
    screen = dpy.get_default_screen()
    return get_screen_config(screen)

def get_screen_config(screen):
    """Returns the XRandR screen config instance for the given gtk.gdk.Screen"""
    dpy = screen.get_display()
    dpy_url = dpy.get_name()
    count = screen.get_number()
    return xrandr.get_screen_of_display(dpy_url, count)

# vim:ts=4:sw=4:et
