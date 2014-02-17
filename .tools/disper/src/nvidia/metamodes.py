##############################################################################
# metamodes.py - metamode parsing for nvidia GPUs
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

import re


def res2array(res):
    '''return [w,h] from a resolution that is specified either as a string or
    as an array itself.'''
    if type(res)==str:
        c = res.split('x')
        try:
            if len(c) != 2: raise ValueError
            return map(int, c)
        except ValueError:
            raise Exception('malformed resolution: %s'%res)
    elif type(res)==tuple or type(res)==list:
        return res
    else:
        raise Exception('resolution has wrong type: %s'%str(res))


class MetaModeDisplay:
    '''Display part of a MetaMode'''

    display = None
    physical = None
    virtual = None
    position = None

    def __init__(self, value=None):
        self.set(value)

    def set(self, value):
        self.display = self.physical = self.virtual = self.position = None
        if not value: return
        # split display from its configuration
        r = re.match(r'^\s*(\S*)\s*:\s*(.*?)\s*$', value)
        if not r: raise ValueError('malformed metamode portion: %s'%value)
        self.display, dmm = r.group(1), r.group(2)
        # check display
        if not re.match(r'(DFP|CRT|TV)-\d$', self.display):
            raise Exception("Garbage metamode: restart X before changing the display configuration to avoid crashes in the nVidia driver")
        # parse display configuration
        if dmm == 'NULL': return
        dmmparts = dmm.split()
        self.physical = dmmparts.pop(0)
        try: self.physical = res2array(self.physical)
        except: pass
        if len(dmmparts) > 0 and dmmparts[0][0]=='@':
            self.virtual = dmmparts.pop(0)
            self.virtual = map(int, self.virtual[1:].split('x'))
        if len(dmmparts) > 0:
            r = re.match(r'^([+-]\d+)([+-]\d+)$', dmmparts.pop(0))
            if not r: raise ValueError('malformed metamode portion (bad position): %s'%value)
            self.position = [int(r.group(1)), int(r.group(2))]
        if len(dmmparts) > 0:
            raise ValueError('malformed metamode portion (too many components): %s'%value)

    def __str__(self):
        if not self.display:
            return self.__repr__()
        s = '%s: '%self.display

        if type(self.physical) == list:
            s += '%dx%d'%(self.physical[0],self.physical[1])
        elif not self.physical:
            s += 'NULL'
        else:
            s += str(self.physical)

        if self.virtual:
            s += ' @%dx%d'%(self.virtual[0],self.virtual[1])
        if self.position:
            s += ' %+d%+d'%(self.position[0],self.position[1])
        return s

    def __eq__(self, other):
        # fallback to physical resolution for viewport if not set
        virtualS = self.virtual
        if not virtualS: virtualS = self.physical
        virtualO = other.virtual
        if not virtualO: virtualO = other.physical
        return self.display == other.display and self.physical == other.physical \
            and virtualS == virtualO and self.position == other.position

    def __ne__(self, other):
        return not self.__eq__(other)

    def __nonzero__(self):
        return bool(self.display) and bool(self.physical)



class MetaMode:
    '''A MetaMode line'''

    id = None       # integer id of the modeline, if any
    options = {}    # options for modeline
    metamodes = []  # configuration for each display
    src = None      # source line, required for deleting a metamode

    def __init__(self, value=None):
        self.set(value)

    def set(self, value):
        self.src = value
        self.id = None
        self.options = {}
        self.metamodes = []
        if not value: return
        #opts, sep, line = value.partition('::') #python>=2.5
        opts, line = (value.split('::',1)+['']*2)[:2]
        if not line:
            line = opts
            opts = None
        # parse options
        if opts:
            opts = map(lambda x: x.strip(), opts.split(','))
            for opt in opts:
                #key, sep, val = opt.partition('=') # python>=2.5
                key, val = (opt.split('=',1)+['']*2)[:2]
                self.options[key] = val
            if 'id' in self.options:
                self.id = int(self.options['id'])
        # parse display settings
        for disp in line.split(','):
            mode = MetaModeDisplay(disp)
            if mode.physical:
                self.metamodes.append(mode)

    def __str__(self):
        s = ''
        s += ', '.join(map(lambda x: '%s=%s'%(x,self.options[x]), self.options.keys()))
        s += ' :: '
        s += ', '.join(map(str, self.metamodes))
        return s

    def __eq__(self, other):
        # compare by id if int, str, or MetaMode
        if type(other) == int:
            return self.id == other
        elif type(other) == str:
            return self == MetaMode(other)
        else:
            # Only compare metamodes, options don't matter. Displays that
            # have NULL (for which x.physical isn't defined) don't count.
            displaysS = filter(lambda x: x.physical, self.metamodes)
            displaysO = filter(lambda x: x.physical, other.metamodes)
            if len(displaysS) != len(displaysO): return False
            for m in displaysS:
                if not m in displaysO: return False
            return True

    def __ne__(self, other):
        return not self.__eq__(other)

    def __nonzero__(self):
        return len(self.metamodes)>0

    def bounding_size(self):
        '''return the size of the total virtual screen as (w,h)'''
        x,y,w,h = self.bounding_box()
        return w,h

    def bounding_box(self):
        '''return the bounding box coordinates of the total virtual screen
        as (x,y,w,h)'''
        cmin = cmax = None
        for d in self.metamodes:
            size = d.physical
            if d.virtual: size = d.virtual
            dmin = d.position
            dmax = [d.position[0]+size[0], d.position[1]+size[1]]
            if not cmin:
                cmin = dmin
                cmax = dmax
                continue
            cmin = ( min(cmin[0], dmin[0]), min(cmin[1], dmin[1]) )
            cmax = ( max(cmax[0], dmax[0]), max(cmax[1], dmax[1]) )
        return cmin[0], cmin[1], cmax[0]-cmin[0], cmax[1]-cmin[1]


class MetaModeList(list):
    '''A list of MetaModes.'''

    def __init__(self, metamodes=None):
        list.__init__(self)
        if metamodes: 
            for m in metamodes:
                self.append(MetaMode(m))

    def find(self, el):
        '''find a MetaMode by either id or string'''
        for i in self:
            if i == el:
                return i


def metamode_clone(displays, physical, virtual=None):
    '''return a MetaMode that clones the specified displays; physical is the 
    physical resolution specified as [w,h] or "WxH"; virtual is the virtual
    resolution, but can be omitted.'''
    try:
        physical = res2array(physical)
        physical = '%dx%d'%(physical[0],physical[1])
    except: pass
    if virtual:
        virtual = res2array(virtual)
        virtual = ' @%dx%d'%(virtual[0],virtual[1])
    else:
        virtual = ''
    mmline = ', '.join(map(lambda d: '%s: %s%s +0+0'%(d,physical,virtual), displays))
    return MetaMode(mmline)


def metamode_add_extend(metamode, direction, display, physical, virtual=None):
    '''add a display configuration to the supplied metamode; physical and
    virtual (optional) are resolutions specified as [w,h] or "WxH"; direction
    is either 'left'/'right'/'top'/'bottom', and metamode is an existing
    metamode, or None to create a new one.

    Displays are placed along the virtual screen as defined by the displays
    already in metamode. No intelligent packing is performed to minimise
    dead areas. I suggest to pack only in one direction (either horizontal
    or vertical, not both). Dead areas will arise when resolutions differ,
    unless the same virtual resolution is specified for each.

    Note that nvidia-auto-select is not allowed as resolution here.'''
    if physical != 'NULL':
        physical = size = res2array(physical)
        physical = '%dx%d'%(physical[0],physical[1])
    if virtual:
        virtual = size = res2array(virtual)
        virtual = ' @%dx%d'%(virtual[0],virtual[1])
    else:
        virtual = ''
    if not metamode:
        return MetaMode('%s: %s%s +0+0'%(display,physical,virtual))
    x,y,w,h = metamode.bounding_box()
    # negative offsets cannot be done need specification of total virtual
    # resolution which I haven't been able to do using dynamic twinview.
    # so we just keep the origin at 0,0 always and shift displays instead.
    if physical != 'NULL':
        offset = 0,0
        if direction == 'left':
            #offset = x - size[0], 0
            offset = 0, 0
            for d in metamode.metamodes:
                d.position[0] += size[0]
        elif direction == 'right':
            offset = x+w, 0
        elif direction == 'top':
            #offset = 0, y - size[1]
            offset = 0, 0
            for d in metamode.metamodes:
                d.position[1] += size[1]
        elif direction == 'bottom':
            offset = 0, y+h
        else:
            raise Exception('unknown extension direction for metamode: %s'%direction)
        mmdisp = MetaModeDisplay('%s: %s%s %+d%+d'%(display,physical,virtual,offset[0],offset[1]))
    else:
        mmdisp = MetaModeDisplay('%s: NULL'%(display))
    metamode.metamodes.append(mmdisp)
    return metamode


# a little testing
if __name__ == '__main__':
    # this is not a realistic metamode list, but it does contain a lot of
    # combinations that may appear in various configurations (and more).
    metamodesstr = [
        'source=xconfig, id=50, switchable=yes :: CRT-0: 1280x1024 @1280x1024 +1280+0, DFP-0: 1280x1024 @1280x1024 +0+0',
        'source=xconfig, id=51, switchable=yes :: CRT-0: 1024x768 @1024x768 +1024+0, DFP-0: 1024x768 @1024x768 +0+0',
        'source=xconfig, id=60, switchable=no :: CRT-0: 800x600 @800x600 -800-0, DFP-0: NULL',
        'source=xconfig, id=62, switchable=no :: DFP-0: 640x480 @640x480 +640+0, TV-0: 1024x768 @1024x768 +0+0',
        'id=63 :: DFP-9: 640x480 @640x480 +640+0, DFP-2: 123x321 @567x765 +640+0',
        '   id=64    ::  CRT-0  :      800x600    @800x600       +0+0   ',
        'id=65::CRT-1:800x600 @800x600 +0+0',
        'id=66 :: CRT-0: 10x10 @10x10 +1024+0, DFP-0: 10x10 @10x10 +0+0, TV-0: 10x10 @10x10 +0+0',
    ]
    mms = MetaModeList(metamodesstr)

    # make sure all are processed
    if len(mms) != len(metamodesstr):
        print 'ERROR: length %d != %d'%( len(mms), len(metamodestr) )

    # access all of them by id
    for i,mm in enumerate(mms):
        if mms.find(mm.id).src != mm.src:
            print 'ERROR: find by id failed for id %d' % mm.id
        if mms.find(str(mm)).src != mm.src:
            print 'ERROR: find by str failed for id %d' % mm.id
        if MetaMode(metamodesstr[i]) != mm:
            print 'ERROR: find by MetaMode failed for id %d' % mm.id

    # find variations in MetaMode strings
    for mm in [ 'CRT-0: 1024x768 @1024x768 +1024+0, DFP-0: 1024x768 @1024x768 +0+0',
                'CRT-0: 1024x768 +1024+0, DFP-0: 1024x768 +0+0',
                '  CRT-0 :    1024x768   +1024+0   ,DFP-0   :  1024x768     +0+0    ',
                'DFP-0: 1024x768 +0+0, CRT-0: 1024x768 +1024+0']:
        if not mms.find(mm) or mms.find(mm).id != 51:
            print 'ERROR: find variation by str failed: %s' % mm

    for mm in [ 'DFP-9: 640x480 @640x480 +640+0, DFP-2: 123x321 @567x765 +640+0',
                'DFP-2: 123x321 @567x765 +640+0, DFP-9: 640x480 @640x480 +640+0',
                ' DFP-2   :    123x321    @567x765  +640+0  ,  DFP-9 :    640x480    @640x480  +640+0  ']:
        if not mms.find(mm) or mms.find(mm).id != 63:
            print 'ERROR: find variation by str failed: %s' % mm

    # test bounding box sizes
    m = MetaMode('DFP-0: 800x600 +0+0, CRT-0: 800x600 +0+0')
    if m.bounding_size() != (800, 600):
        print 'ERROR: bounding box size: %s'%m
    m = MetaMode('DFP-0: 800x600 @1000x800 +0+0, CRT-0: 800x600 +0+0')
    if m.bounding_size() != (1000, 800):
        print 'ERROR: bounding box size: %s'%m
    m = MetaMode('DFP-0: 800x600 +0+0, CRT-0: 800x600 +900+0')
    if m.bounding_size() != (1700, 600):
        print 'ERROR: bounding box size: %s'%m
    m = MetaMode('DFP-0: 800x600 +0-300, CRT-0: 800x600 +0+0')
    if m.bounding_size() != (800, 900):
        print 'ERROR: bounding box size: %s'%m

    # test metamode creation stuff
    m1 = metamode_clone(['DFP-0','DFP-1','TV-2'], '800x600')
    m2 = MetaMode('DFP-0: 800x600 +0+0, DFP-1: 800x600 +0+0, TV-2: 800x600 +0+0')
    if m1 != m2:
        print 'ERROR: metamode_clone: %s'%str(m2)
    for dir,mmline in [
            ('right', 'CRT-0: 800x600   +0+000, DFP-0: 200x300 +800+000, TV-0: 640x480 +1000+000'),
           #('left',  'CRT-0: 800x600   +0+000, DFP-0: 200x300 -200+000, TV-0: 640x480  -840+000'),
            ('left',  'CRT-0: 800x600 +840+000, DFP-0: 200x300 +640+000, TV-0: 640x480    +0+000'),
           #('top',   'CRT-0: 800x600   +0+000, DFP-0: 200x300   +0-300, TV-0: 640x480    +0-780'),
            ('top',   'CRT-0: 800x600   +0+780, DFP-0: 200x300   +0+480, TV-0: 640x480    +0+000'),
            ('bottom','CRT-0: 800x600   +0+000, DFP-0: 200x300   +0+600, TV-0: 640x480    +0+900') ]:
        m = metamode_add_extend(None, dir, 'CRT-0', [800,600])
        m = metamode_add_extend(m, dir, 'DFP-0', [200,300])
        m = metamode_add_extend(m, dir, 'TV-0', [640,480])
        if m != MetaMode(mmline):
            print 'ERROR: metamode_extend %s: %s'%(dir,str(m))

    print 'tests finished.'


# vim:ts=4:sw=4:expandtab:
