###############################################################################
# nvtarget.py - targets for nvidia commands
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

NV_CTRL_TARGET_TYPE_X_SCREEN = 0
NV_CTRL_TARGET_TYPE_GPU = 1
NV_CTRL_TARGET_TYPE_FRAMELOCK = 2
NV_CTRL_TARGET_TYPE_VCSC = 3

###############################################################################
# Targets, to indicate where a command should be executed.
#
class Target:
    _name = None
    _id = None
    _type = None

    def id(self):
        return self._id
    def type(self):
        return self._type
    
    def __str__(self):
        return '<nVidia %s #%d>'%(self._name, self.id())

class GPU(Target):
    def __init__(self, ngpu=0):
        '''Target a GPU'''
        self._id = ngpu
        self._type = NV_CTRL_TARGET_TYPE_GPU
        self._name = 'GPU'

class Screen(Target):
    def __init__(self, nscr=0):
        '''Target an X screen'''
        self._id = nscr
        self._type = NV_CTRL_TARGET_TYPE_X_SCREEN
        self._name = 'X screen'


