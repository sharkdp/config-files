#!/usr/bin/python
# -*- coding: utf-8 -*-

# This file was part of the Gedit Synctex plugin.
# Slightly modified by _vicious_ ...
#
# Copyright (C) 2010 Jose Aliste <jose.aliste@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public Licence as published by the Free Software
# Foundation; either version 2 of the Licence, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public Licence for more
# details.
#
# You should have received a copy of the GNU General Public Licence along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA  02110-1301, USA

import dbus
import subprocess
import time
import os.path
import logging

from optparse import OptionParser
usage = """\nto make evince sync (it will exit when sync is done):\n    %prog EVINCE output_file line_number input_file\n\nto make gvim sync in response to evince clicks (keep it running):\n    %prog GVIM gvim_server_name output_file input_file\n\noutput_file -- file path [might be relative to the current directory]\ninput_file  -- as above"""

parser  = OptionParser(usage=usage)
parser.add_option("-e", "--evince_version", default=None, type="int", action="store", dest="EVINCE_VERSION")
parser.add_option("-v",  default=False, action="store_true", dest="debug", help="verbose output")
(options, args) = parser.parse_args()

LOG_FILENAME = "/tmp/evince_sync.log"
if options.debug:
    log_level = logging.DEBUG
else:
    log_level = logging.INFO
print(log_level == logging.DEBUG)
logger = logging.getLogger('evince_sync')
logger.setLevel(log_level)
fh = logging.FileHandler(LOG_FILENAME)
fh.setLevel(log_level)
ch = logging.StreamHandler()
ch.setLevel(log_level)
formatter = logging.Formatter('%(asctime)s:%(name)s:%(levelname)s: %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
logger.addHandler(fh)
logger.addHandler(ch)

EVINCE_VERSION=options.EVINCE_VERSION
if EVINCE_VERSION is None:
    import subprocess, re
    cmd = ["evince", "--version"]
    ev_ver=subprocess.Popen(cmd, stdout=subprocess.PIPE)
    ev_ver.wait()
    ev_version = ev_ver.stdout.read()
    EVINCE_VERSION = int(re.search('(\d)(?:\d|\.)+\s*$', ev_version).group(1))

RUNNING, CLOSED = range(2)

EV_DAEMON_PATH = "/org/gnome/evince/Daemon"
EV_DAEMON_NAME = "org.gnome.evince.Daemon"
EV_DAEMON_IFACE = "org.gnome.evince.Daemon"

EVINCE_PATH = "/org/gnome/evince/Evince"
EVINCE_IFACE = "org.gnome.evince.Application"

EV_WINDOW_IFACE = "org.gnome.evince.Window"




class EvinceWindowProxy(object):
    """A DBUS proxy for an Evince Window."""
    daemon = None
    bus = None

    def __init__(self, uri, spawn = False, logger = None):
        self._log = logger
        self.uri = uri
        self.spawn = spawn
        self.status = CLOSED
        self.source_handler = None
        self.dbus_name = ''
        self._handler = None
        try:
            if EvinceWindowProxy.bus is None:
                EvinceWindowProxy.bus = dbus.SessionBus()

            if EvinceWindowProxy.daemon is None:
                EvinceWindowProxy.daemon = EvinceWindowProxy.bus.get_object(EV_DAEMON_NAME,
                                                EV_DAEMON_PATH,
                                                follow_name_owner_changes=True)
            self._get_dbus_name(False)

        except dbus.DBusException:
            if self._log:
                self._log.debug("Could not connect to the Evince Daemon")

    def _get_dbus_name(self, spawn):
        EvinceWindowProxy.daemon.FindDocument(self.uri,spawn,
                     reply_handler=self.handle_find_document_reply,
                     error_handler=self.handle_find_document_error,
                     dbus_interface = EV_DAEMON_IFACE)

    def handle_find_document_error(self, error):
        if self._log:
            self._log.debug("FindDocument DBus call has failed")

    def handle_find_document_reply(self, evince_name):
        if self._handler is not None:
            handler = self._handler
        else:
            handler = self.handle_get_window_list_reply
        if evince_name != '':
            self.dbus_name = evince_name
            self.status = RUNNING
            self.evince = EvinceWindowProxy.bus.get_object(self.dbus_name, EVINCE_PATH)
            self.evince.GetWindowList(dbus_interface = EVINCE_IFACE,
                          reply_handler = handler,
                          error_handler = self.handle_get_window_list_error)

    def handle_get_window_list_error (self, e):
        if self._log:
            self._log.debug("GetWindowList DBus call has failed")

    def handle_get_window_list_reply (self, window_list):
        if len(window_list) > 0:
            window_obj = EvinceWindowProxy.bus.get_object(self.dbus_name, window_list[0])
            self.window = dbus.Interface(window_obj,EV_WINDOW_IFACE)
            self.window.connect_to_signal("Closed", self.on_window_close)
            self.window.connect_to_signal("SyncSource", self.on_sync_source)
        else:
            #That should never happen. 
            if self._log:
                self._log.debug("GetWindowList returned empty list")

    def set_source_handler (self, source_handler):
        self.source_handler = source_handler

    def on_window_close(self):
        self.window = None
        self.status = CLOSED

    def on_sync_source(self, input_file, source_link, timestamp):
        if self.source_handler is not None:
            if EVINCE_VERSION >= 3:
                self.source_handler(input_file, source_link, timestamp)
            else:
                self.source_handler(input_file, source_link)

    def SyncView(self, input_file, data, timestamp):
        if self.status == CLOSED:
            if self.spawn:
                self._tmp_syncview = [input_file, data, timestamp];
                self._handler = self._syncview_handler
                self._get_dbus_name(True)
        else:
            self.window.SyncView(input_file, data, timestamp, dbus_interface = "org.gnome.evince.Window")

    def _syncview_handler(self, window_list):
        self.handle_get_window_list_reply(window_list)

        if self.status == CLOSED:
            return False
        if EVINCE_VERSION >= 3:
            self.window.SyncView(self._tmp_syncview[0],
                                 self._tmp_syncview[1],
                                 self._tmp_syncview[2],
                                 dbus_interface="org.gnome.evince.Window")
        else:
            self.window.SyncView(self._tmp_syncview[0],
                                 self._tmp_syncview[1],
                                 dbus_interface="org.gnome.evince.Window")
        del self._tmp_syncview
        self._handler = None
        return True

## This file can be used as a script to support forward search and backward search in vim.
## It should be easy to adapt to other editors. 
##  evince_dbus  pdf_file  line_source input_file
if __name__ == '__main__':
    import dbus.mainloop.glib, gobject, glib, sys, os

    def print_usage():
        usage = """\nto make evince sync (it will exit when sync is done):\n    %(prog)s EVINCE output_file line_number input_file\n\nto make gvim sync in response to evince clicks (keep it running):\n    %(prog)s GVIM gvim_server_name output_file input_file\nor\n    %(prog)s VIM vim_server_name output_file input_file\n\noutput_file -- file path (might be relative to the current directory)\ninput_file  -- as above"""
        print(usage % { 'prog' : os.path.basename(sys.argv[0])})
        sys.exit(1)

    if len(args) != 4:
        print_usage()
        sys.exit(os.EX_USAGE)

    if args[0] == 'EVINCE':
        try:
            line_number = int(args[2])
        except ValueError:
            print_usage()
            sys.exit(os.EX_USAGE)

        output_file = args[1]
        input_file  = args[3]
        if output_file[0] != '/':
            path_output = os.path.join(os.getcwd(), output_file)
        else:
            path_output = output_file
        if input_file[0] == '/':
            path_input   = os.path.dirname(input_file) + '/./' + os.path.basename(input_file)
        else:
            path_input   = os.getcwd() + '/./' + os.path.basename(input_file)

        if not os.path.isfile(path_output):
            error_msg = "Error: output path '%s' is not a file\n" % path_output
            logger.error(error_msg)
            print_usage()
            sys.exit(os.EX_USAGE)

        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        a = EvinceWindowProxy('file://%s' % path_output, True, logger=logger )

        def sync_view(ev_window, path_input, line_number):
            if EVINCE_VERSION >= 3:
                ev_window.SyncView (path_input, (line_number, 1), 0)
            else:
                ev_window.SyncView (path_input, (line_number, 1))
            exit(0)

        glib.timeout_add(400, sync_view, a, path_input, line_number)
        loop = gobject.MainLoop()
        loop.run()

    elif args[0] == 'GVIM' or args[0] == 'VIM':

        if len(args) != 4:
            print_usage()
            sys.exit(os.EX_USAGE)

        if args[0] == 'GVIM':
            progname = 'gvim'
        else:
            progname = 'vim'
        gvim_server_name = args[1]
        output_file = args[2]
        input_file  = args[3]
        if output_file[0] == '/':
            path_output = output_file
        else:
            path_output  = os.path.join(os.getcwd(),output_file)
        if input_file[0] == '/':
            path_input   = input_file
        else:
            path_input   = os.path.join(os.getcwd(), input_file)

        logger.debug("path_output='%s'" % path_output)
        logger.debug("path_input='%s'" % path_input)

        if not os.path.isfile(path_input):
            error_msg = "Error: input path '%s' is not a file\n" % path_input
            logger.error(error_msg)
            print_usage()
            sys.exit(OS_EXUSAGE)

        def source_view_handler(input_file, source_link, timestamp):
            if str(input_file).startswith("file://"):
                input_file = input_file[7:]
            cmd = progname+' --servername "' + gvim_server_name + '" --remote +' + str(source_link[0]) + ' ' + input_file
            logger.debug('executing: %s' % cmd)
            os.system(cmd)

        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        a = EvinceWindowProxy('file://' + path_output, True, logger = logger )

        a.set_source_handler(source_view_handler)
        loop = gobject.MainLoop()
        loop.run()
    else:
        print_usage()


# ex:ts=4:et:
