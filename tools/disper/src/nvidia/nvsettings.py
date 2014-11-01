###############################################################################
# nvsettings.py - nvidia-settings configuration file parser
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

_all = ['NVidiaSettings', 'Screen', 'GPU']

import os
import re
import xnet
import socket
from nvtarget import *

class NVidiaSettings:
    '''nvidia-settings configuration file reader/parser'''

    _opts = None    # list of options: (location, param, device, value)

    def __init__(self, filename=None):
        self.load(filename)

    def load(self, filename=None):
        '''load an nvidia-settings configuration file; use None for the
        default ~/.nvidia-settings-rc'''
        if not filename:
            filename = os.path.expanduser('~/.nvidia-settings-rc')
        self._opts = []
        f = open(filename, 'r')
        for l in f:
            # remove comments
            l = l.split('#',2)[0]
            # remove all spaces (as nvidia-settings does in parse.c)
            l = filter(lambda s: not s.isspace(), l)
            # skip lines without an option assignment
            if not l: continue
            # parse and store
            m = re.match('((.+)\/)?(\w+)(\[(.+)?\])?=(.*)$', l)
            if m:
                # silently ignore malformed lines; TODO should warn
                self._opts.append((m.group(2),m.group(3),m.group(5),m.group(6)))
        f.close()

    def query(self, type, option, target=None, device=None):
        '''retrieve the value from an option for a target. If target is None,
        the first found target is found. Device should only be specified
        for options that require one. If the specified device is not found,
        the value of the option without a device specification is returned,
        if present. This is how nvidia-settings behaves if I'm correct.
        Returns first option found, or None if not found. The option is
        cast to type on success (so that you don't have to check for None
        and then cast it).
        Only options for the X display are found.

        TODO: make more specific targets in configfile get precedence.'''
        # option name
        opts = filter(lambda x: x[1]==option, self._opts)
        # device
        # TODO it's unclear if multiple devices may be specified for a single
        #      option in the configuration file
        if device:
            optsdfl = filter(lambda x: not x[2], opts)
            opts = filter(lambda x: x[2]==device, opts)
            if not opts: opts = optsdfl
        if not target: target = Screen(0)
        # target: only current host for display
        d,host,dno,screen = xnet.get_X_display()
        if not host: host=socket.gethostname()
        host = socket.gethostbyname(host)
        if isinstance(target, Screen): screen = target.id()
        # throw away all options that aren't for us
        for o in list(opts):
            loc = o[0]
            if not loc: continue
            # {host}:{display}.{screen}[target_type:target_id]
            m = re.match('(([\w\.]*):)?(\d+)(\.(\d+))?(\[(\w+):(\d+)\])?$', loc)
            if m:
                chost,cdno,cscreen = m.group(2),m.group(3),m.group(5)
                ctargettype,ctargetval = m.group(7),m.group(8)
                if chost: chost = socket.gethostbyname(chost)
                if (not chost or chost==host) and \
                   (not cdno or int(cdno)==int(dno)) and \
                   (not cscreen or int(cscreen)==int(screen)) and \
                   (not ctargettype or \
                     (ctargettype=='gpu' and isinstance(target, GPU)) or \
                     (ctargettype=='screen' and isinstance(target, Screen))
                   ) and \
                   (not ctargetval or ctargetval==target.id()):
                    # everything matches, keep
                    continue
            else:
                # TODO warn
                pass
            # no match, remove opts from list
            opts.remove(o)
        # return
        if len(opts)>0: return type(opts[0][3])
        else: return None


# some tests
if __name__ == '__main__':
    import os

    # make temporary file with test options
    # Note that each line of the here-document is indented with tabs which are
    # subsequently removed for easy reading. Make sure to use tabs!
    tmpfilename = '/tmp/nvsettings-nvidia-settings-rc-test'
    f = open(tmpfilename, 'w')
    f.write('''
		# test nvidia-settings-rc
	    
		# ConfigProperties:
		RcFileLocale = C
		Foo = Bar
		    
		# Attributes:
		0/SyncToVBlank=0
		1/SyncToVBlank=321
		0/DigitalVibrance=0
		0/DigitalVibrance[DFP-0]=1
		0.0/DigitalVibrance[CRT-0]=2
		localhost:0/TestAttr=hi_there
		127.0.0.1:0.0/OtherAttr=hi_here
        0.0.0.0:0/OtherAttr=not me
        #OtherFoo = BadBar # TODO
		0.0/OtherFoo = OtherBar
		0.1/OtherFoo = MoreBar
		[screen:0]/VideoRam=60
		localhost:0[screen:0]/VideoRam=50
		Plurk=1
		[gpu:0]/Plurk=100
    '''.expandtabs(0))
    f.close()

    nvs = NVidiaSettings(tmpfilename)

    try:
        if nvs.query(str, 'Foo') != 'Bar':
            print 'ERROR: Foo'
        if nvs.query(int, 'SyncToVBlank') != 0:
            print 'ERROR: SyncToVBlank'
        if nvs.query(int, 'SyncToVBlank', Screen(0)) != 0:
            print 'ERROR: 0/SyncToVBlank'
        if nvs.query(int, 'SyncToVBlank', Screen(1)) != 0:
            print 'ERROR: 0.1/SyncToVBlank'
        if nvs.query(int, 'DigitalVibrance') != 0:
            print 'ERROR: DigitalVibrance'
        if nvs.query(int, 'DigitalVibrance', None, 'DFP-0') != 1:
            print 'ERROR: DigitalVibrance[DFP-0]'
        if nvs.query(int, 'DigitalVibrance', None, 'CRT-0') != 2:
            print 'ERROR: DigitalVibrance[CRT-0]'
        if nvs.query(int, 'DigitalVibrance', None, 'CRT-9') != 0:
            print 'ERROR: DigitalVibrance[CRT-9]'

        if nvs.query(str, 'TestAttr') != 'hi_there':
            print 'ERROR: TestAttr'
        if nvs.query(str, 'OtherAttr') != 'hi_here':
            print 'ERROR: OtherAttr'

        # TODO
        #if nvs.query(str, 'OtherFoo') != 'BadBar':
        #    print 'ERROR: OtherFoo'
        if nvs.query(str, 'OtherFoo', Screen(0)) != 'OtherBar':
            print 'ERROR: 0/OtherFoo'
        if nvs.query(str, 'OtherFoo', Screen(1)) != 'MoreBar':
            print 'ERROR: 0.1/OtherFoo'

        os.environ['DISPLAY'] = 'localhost:1'
        if nvs.query(int, 'SyncToVBlank') != 321:
            print 'ERROR: 1/SyncToVBlank'
        os.environ['DISPLAY'] = 'localhost:2'
        if nvs.query(int, 'SyncToVBlank') != None:
            print 'ERROR: 2/SyncToVBlank'

    finally:
        os.unlink(tmpfilename)

# vim:ts=4:sw=4:expandtab:
