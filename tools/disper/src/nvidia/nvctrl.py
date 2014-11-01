###############################################################################
# nvctrl.py - nvidia NV-CONTROL X extension functions in python
#
# this file contains only a subset of the NV-CONTROL functions,
# expand and share when needed! See the nvidia-settings source
# for a complete C-based implementation.
# This file contains low-level communication functionality only.
#
# code based on NvThermometer by Harry Organs
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

import xnet
import minx

from nvtarget import *

###############################################################################
# NV-CONTROL integer attrs. this list contains constants defined in both
# NVCtrl.h and NVCtrlAttributes.h. these constants are the attr codes
#
# target types defined in nvtarget

NV_CTRL_BUS_TYPE                        = 5   #/* R--G */
NV_CTRL_VIDEO_RAM                       = 6   #/* R--G */
NV_CTRL_IRQ                             = 7   #/* R--G */
NV_CTRL_OPERATING_SYSTEM                = 8   #/* R--G */
NV_CTRL_CONNECTED_DISPLAYS              = 19  #/* R--G */
NV_CTRL_ENABLED_DISPLAYS                = 20  #/* R--G */
NV_CTRL_FRAMELOCK                       = 21  #/* R--G */
NV_CTRL_ARCHITECTURE                    = 41  #/* R--- */
NV_CTRL_CURSOR_SHADOW                   = 43  #/* RW-- */
NV_CTRL_GPU_CORE_TEMPERATURE            = 60  #/* R--G */
NV_CTRL_GPU_CORE_THRESHOLD              = 61  #/* R--G */
NV_CTRL_GPU_DEFAULT_CORE_THRESHOLD      = 62  #/* R--G */
NV_CTRL_GPU_MAX_CORE_THRESHOLD          = 63  #/* R--G */
NV_CTRL_AMBIENT_TEMPERATURE             = 64  #/* R--G */
NV_CTRL_GVO_SUPPORTED                   = 67  #/* R--- */
NV_CTRL_GPU_2D_CLOCK_FREQS              = 89  #/* RW-G */
NV_CTRL_GPU_3D_CLOCK_FREQS              = 90  #/* RW-G */
NV_CTRL_GPU_DEFAULT_2D_CLOCK_FREQS      = 91  #/* R--G */
NV_CTRL_GPU_DEFAULT_3D_CLOCK_FREQS      = 92  #/* R--G */
NV_CTRL_GPU_CURRENT_CLOCK_FREQS         = 93  #/* R--G */
NV_CTRL_XINERAMA                        = 222 #/* R--G */
NV_CTRL_XINERAMA_STEREO                 = 223 #/* RW-- */
NV_CTRL_BUS_RATE                        = 224 #/* R--G */
NV_CTRL_ASSOCIATED_DISPLAY_DEVICES      = 231 #/* RW-- */
NV_CTRL_PROBE_DISPLAYS                  = 234 #/* R--G */
NV_CTRL_REFRESH_RATE                    = 235 #/* R-DG */
NV_CTRL_PCI_BUS                         = 239 #/* R--G */
NV_CTRL_PCI_DEVICE                      = 240 #/* R--G */
NV_CTRL_PCI_FUNCTION                    = 241 #/* R--G */
NV_CTRL_MAX_SCREEN_WIDTH                = 243 #/* R--G */
NV_CTRL_MAX_SCREEN_HEIGHT               = 244 #/* R--G */
NV_CTRL_MAX_DISPLAYS                    = 245 #/* R--G */
NV_CTRL_MULTIGPU_DISPLAY_OWNER          = 247 #/* R--- */
NV_CTRL_GPU_SCALING                     = 248 #/* RWDG */
NV_CTRL_FRONTEND_RESOLUTION             = 249 #/* R-DG */
NV_CTRL_BACKEND_RESOLUTION              = 250 #/* R-DG */
NV_CTRL_FLATPANEL_NATIVE_RESOLUTION     = 251 #/* R-DG */
NV_CTRL_FLATPANEL_BEST_FIT_RESOLUTION   = 252 #/* R-DG */
NV_CTRL_GPU_POWER_SOURCE                = 262 #/* R--G */

NV_CTRL_DEPTH_30_ALLOWED                = 279 #/* R--G */
NV_CTRL_LAST_ATTRIBUTE                  = NV_CTRL_DEPTH_30_ALLOWED

NV_CTRL_BINARY_DATA_EDID                = 0   #/* R-DG */
NV_CTRL_BINARY_DATA_MODELINES           = 1   #/* R-DG */
NV_CTRL_BINARY_DATA_METAMODES           = 2   #/* R-D- */
NV_CTRL_BINARY_DATA_XSCREENS_USING_GPU  = 3   #/* R-DG */
NV_CTRL_BINARY_DATA_GPUS_USED_BY_XSCREEN= 4   #/* R--- */
NV_CTRL_BINARY_DATA_GPUS_USING_FRAMELOCK= 5   #/* R-DF */
NV_CTRL_BINARY_DATA_DISPLAY_VIEWPORT    = 6   #/* R-DG */
NV_CTRL_BINARY_DATA_FRAMELOCKS_USED_BY_GPU=7  #/* R-DG */
NV_CTRL_BINARY_DATA_GPUS_USING_VCSC     = 8   #/* R-DV */
NV_CTRL_BINARY_DATA_VCSCS_USED_BY_GPU   = 9   #/* R-DG */

NV_CTRL_BINARY_DATA_LAST_ATTRIBUTE      = NV_CTRL_BINARY_DATA_VCSCS_USED_BY_GPU

###############################################################################
# extensions defined in NVCtrlAttributes.h
#
NV_CTRL_ATTR_BASE                       = NV_CTRL_LAST_ATTRIBUTE + 1
NV_CTRL_ATTR_EXT_BASE                   = (NV_CTRL_ATTR_BASE)
NV_CTRL_ATTR_EXT_NV_PRESENT             = (NV_CTRL_ATTR_EXT_BASE + 0)
NV_CTRL_ATTR_EXT_VM_PRESENT             = (NV_CTRL_ATTR_EXT_BASE + 1)
NV_CTRL_ATTR_EXT_XV_OVERLAY_PRESENT     = (NV_CTRL_ATTR_EXT_BASE + 2)
NV_CTRL_ATTR_EXT_XV_TEXTURE_PRESENT     = (NV_CTRL_ATTR_EXT_BASE + 3)
NV_CTRL_ATTR_EXT_XV_BLITTER_PRESENT     = (NV_CTRL_ATTR_EXT_BASE + 4)

NV_CTRL_ATTR_EXT_LAST_ATTRIBUTE         = (NV_CTRL_ATTR_EXT_XV_BLITTER_PRESENT)
NV_CTRL_ATTR_NV_BASE                    = (NV_CTRL_ATTR_EXT_LAST_ATTRIBUTE + 1)


###############################################################################
# NV-CONTROL string attrs. this list contains constants defined in both
# NVCtrl.h and NVCtrlAttributes.h. these constants are the attr codes
# for use with the string functions
#
NV_CTRL_STRING_PRODUCT_NAME             = 0   #/* R--G */
NV_CTRL_STRING_VBIOS_VERSION            = 1   #/* R--G */
NV_CTRL_STRING_NVIDIA_DRIVER_VERSION    = 3   #/* R--G */
NV_CTRL_STRING_DISPLAY_DEVICE_NAME      = 4   #/* R-DG */
NV_CTRL_STRING_CURRENT_MODELINE         = 9   #/* R-DG */
NV_CTRL_STRING_ADD_MODELINE             = 10  #/* -WDG */
NV_CTRL_STRING_DELETE_MODELINE          = 11  #/* -WDG */
NV_CTRL_STRING_CURRENT_METAMODE         = 12  #/* R--- */
NV_CTRL_STRING_ADD_METAMODE             = 13  #/* -W-- */
NV_CTRL_STRING_DELETE_METAMODE          = 14  #/* -WD- */
NV_CTRL_STRING_MOVE_METAMODE            = 23  #/* -W-- */
NV_CTRL_STRING_VALID_HORIZ_SYNC_RANGES  = 24  #/* R-DG */
NV_CTRL_STRING_VERT_REFRESH_RANGES      = 25  #/* R-DG */
NV_CTRL_STRING_XINERAMA_SCREEN_INFO     = 26  #/* R--- */
NV_CTRL_STRING_TWINVIEW_XINERAMA_INFO_ORDER=27#/* RW-- */
NV_CTRL_STRING_SLI_MODE                 = 28  #/* R--- */
NV_CTRL_STRING_PERFORMANCE_MODES        = 29  #/* R--G */
NV_CTRL_STRING_LAST_ATTRIBUTE           = NV_CTRL_STRING_PERFORMANCE_MODES

NV_CTRL_STRING_OPERATION_ADD_METAMODE   = 0
NV_CTRL_STRING_OPERATION_GTF_MODELINE   = 1
NV_CTRL_STRING_OPERATION_CVT_MODELINE   = 2
NV_CTRL_STRING_OPERATION_BUILD_MODEPOOL = 3   # /* DG  */
NV_CTRL_STRING_OPERATION_LAST_ATTRIBUTE = NV_CTRL_STRING_OPERATION_BUILD_MODEPOOL


###############################################################################
# NV-CONTROL major op numbers. these constants identify the request type
#
_X_nvCtrlQueryExtension                  = 0
_X_nvCtrlQueryAttribute                  = 2
_X_nvCtrlQueryStringAttribute            = 4
_X_nvCtrlQueryValidAttributeValues       = 5
_X_nvCtrlSetStringAttribute              = 9
_X_nvCtrlSetAttributeAndGetStatus        = 19
_X_nvCtrlQueryBinaryData                 = 20
_X_nvCtrlQueryTargetCount                = 24
_X_nvCtrlStringOperation                 = 25


###############################################################################
# various lists that go with attrs, but are handled more compactly
# this way. these lists are indexed by the possible values of their attrs
# and are explained in NVCtrl.h
#

ATTRIBUTE_TYPE_UNKNOWN              = 0
ATTRIBUTE_TYPE_INTEGER              = 1
ATTRIBUTE_TYPE_BITMASK              = 2
ATTRIBUTE_TYPE_BOOL                 = 3
ATTRIBUTE_TYPE_RANGE                = 4
ATTRIBUTE_TYPE_INT_BITS             = 5

ATTRIBUTE_TYPE_READ                 = 0x01
ATTRIBUTE_TYPE_WRITE                = 0x02
ATTRIBUTE_TYPE_DISPLAY              = 0x04
ATTRIBUTE_TYPE_GPU                  = 0x08
ATTRIBUTE_TYPE_FRAMELOCK            = 0x10
ATTRIBUTE_TYPE_X_SCREEN             = 0x20
ATTRIBUTE_TYPE_XINERAMA             = 0x40
ATTRIBUTE_TYPE_VCSC                 = 0x80




###############################################################################
# NV-CONTROL Query Extension
#
class _NVCtrlQueryExtensionRequest:
    '''this class wraps the NV-CONTROL query request.
    it requires the major self.opcode of NV-CONTROL as a
    constructor arg. the self.opcode can be obtained with
    an XQueryExtension'''

    def __init__(self, opcode):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlQueryExtension),
            minx.XData('CARD16',1,1))


class _NVCtrlQueryExtensionReply:
    '''the reply to a NVCtrlQueryExtension request. returns
    the major and minor versions of the NV-CONTROL extension
    (if supported, of course)'''

    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('PAD',1,'padb1'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'reply_length'),
            minx.XData('CARD16',1,'major'),
            minx.XData('CARD16',1,'minor'),
            minx.XData('CARD32',1,'padl4'),
            minx.XData('CARD32',1,'padl5'),
            minx.XData('CARD32',1,'padl6'),
            minx.XData('CARD32',1,'padl7'),
            minx.XData('CARD32',1,'padl8'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )


###############################################################################
# NV-CONTROL Query Attribute
#
class _NVCtrlQueryAttributeRequest:
    '''this class wraps the NV-CONTROL query attr request.
    it requires the major opcode of NV-CONTROL, the display or gpu
    to query, what type of target (display or gpu), the display
    mask (if target is a display, mask can be obtained with
    GetConnectedDisplays or GetActiveDisplays, if gpu, not used),
    and identifier of the attr to query as constructor args. it
    returns the value of an integer driver attr. this
    one can raise Value Error and Match error. see NVCtrlLib.h'''

    def __init__(self,opcode,target_id,target_type,display_mask,attr):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlQueryAttribute),
            minx.XData('CARD16',1,4),
            minx.XData('CARD16',1,target_id),
            minx.XData('CARD16',1,target_type),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr))
        

class _NVCtrlQueryAttributeReply:
    '''the reply to NVCtrlQueryAttribute request. returns
    the value and the flags, which describe whether attr
    is read-only, etc. see NVCtrlLib.h'''

    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('BYTE',1,'pad0'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('INT32',1,'value'),
            minx.XData('CARD32',1,'pad4'),
            minx.XData('CARD32',1,'pad5'),
            minx.XData('CARD32',1,'pad6'),
            minx.XData('CARD32',1,'pad7'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )


###############################################################################
# NV-CONTROL Set Attribute And Get Status
#
class _NVCtrlSetAttributeAndGetStatusRequest:
    def __init__(self,opcode,screen,display_mask,attr,value):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlSetAttributeAndGetStatus),
            minx.XData('CARD16',1,5),
            minx.XData('CARD32',1,screen),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr),
            minx.XData('INT32',1,value))

class _NVCtrlSetAttributeAndGetStatusReply:
    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('BYTE',1,'pad0'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('CARD32',1,'pad3'),
            minx.XData('CARD32',1,'pad4'),
            minx.XData('CARD32',1,'pad5'),
            minx.XData('CARD32',1,'pad6'),
            minx.XData('CARD32',1,'pad7'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )



###############################################################################
# NV-CONTROL Query Target Count
#
class _NVCtrlQueryTargetCountRequest:
    '''this class wraps the NV-CONTROL query target count
    request. it requires the major opcode of NV-CONTROL and the
    type of target to count as args. the target types are kind of
    explained in NVCtrl.h. this request will return a count of
    the gpu's on the system, for example, with target type 1'''

    def __init__(self, opcode, target):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlQueryTargetCount),
            minx.XData('CARD16',1,2),
            minx.XData('CARD32',1,target))


class _NVCtrlQueryTargetCountReply:
    '''the reply to a NVCtrlQueryTargetCount request. returns
    the count of the given target type. causes an X Value error
    if the target type does not exist at all, so check for errors
    if u query something that might not be there'''

    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('PAD',1,'padb1'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'count'),
            minx.XData('CARD32',1,'padl4'),
            minx.XData('CARD32',1,'padl5'),
            minx.XData('CARD32',1,'padl6'),
            minx.XData('CARD32',1,'padl7'),
            minx.XData('CARD32',1,'padl8'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )


###############################################################################
# NV-CONTROL Query Binary Data
#
class _NVCtrlQueryBinaryDataRequest:
    '''this class wraps the NV-CONTROL query binary data request.
    it requires the major opcode of NV-CONTROL, the display or gpu
    to query, what type of target (display or gpu), the display
    mask (if target is a display, mask can be obtained with
    GetConnectedDisplays or GetActiveDisplays, if gpu, not used),
    and identifier of the attr to query as constructor args. it
    returns the value of an integer driver attr. this
    one can raise Value Error and Match error. see NVCtrlLib.h'''

    def __init__(self,opcode,target_id,target_type,display_mask,attr):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlQueryBinaryData),
            minx.XData('CARD16',1,4),
            minx.XData('CARD16',1,target_id),
            minx.XData('CARD16',1,target_type),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr))
 

class _NVCtrlQueryBinaryDataReply:
    '''the reply to a NVCtrlQueryBinaryData request. returns
    the count of the given target type. causes an X Value error
    if the target type does not exist at all, so check for errors
    if u query something that might not be there'''

    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('PAD',1,'pad0'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('CARD32',1,'n'),
            minx.XData('CARD32',1,'pad4'),
            minx.XData('CARD32',1,'pad5'),
            minx.XData('CARD32',1,'pad6'),
            minx.XData('CARD32',1,'pad7'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )

        rs, ad = minx.decode(ad,
            minx.XData('STRING8',self.n,'data'))
        self.data = str(rs['data'])


###############################################################################
# NV-CONTROL Query String Attribute
#
class _NVCtrlQueryStringAttributeRequest:
    '''this is the string version of Query Attribute. works
    just like the int version, only the reply is different'''

    def __init__(self,opcode,target_id,target_type,display_mask,attr):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlQueryStringAttribute),
            minx.XData('CARD16',1,4),
            minx.XData('CARD16',1,target_id),
            minx.XData('CARD16',1,target_type),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr))

class _NVCtrlQueryStringAttributeReply:
    '''the reply to NVCtrlQueryStringAttribute request. returns
    the string and the flags, which describe whether attr
    is read-only, like int version. the attr string len
    is also returned by this variation in 'n'. n is NOT the
    length>>2, it is the true number of bytes in string. the
    'length' field is equiv to X 'size' field, 'n' is equiv
    to X 'string length' field'''

    def __init__(self,encoding):
        xreply, ad = minx.decode( encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('BYTE',1,'pad0'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('CARD32',1,'n'),
            minx.XData('CARD32',1,'pad4'),
            minx.XData('CARD32',1,'pad5'),
            minx.XData('CARD32',1,'pad6'),
            minx.XData('CARD32',1,'pad7'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )

        rs, ad = minx.decode(ad,
            minx.XData('STRING8',self.n,'string'))
        self.string = str(rs['string'])
        if self.string.endswith('\0'): self.string = self.string[:-1]


###############################################################################
# NV-CONTROL Set String Attribute
#
class _NVCtrlSetStringAttributeRequest:
    def __init__(self,opcode,screen,display_mask,attr,data):
        dlen = len(data)+1 #include terminating 0
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlSetStringAttribute),
            minx.XData('CARD16',1,5 + (((dlen+3)&~3) >> 2) ),
            minx.XData('CARD32',1,screen),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr),
            minx.XData('CARD32',1,dlen),
            minx.XData('STRING8',dlen,data+'\0'))


class _NVCtrlSetStringAttributeReply:
    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('BYTE',1,'pad0'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('CARD32',1,'pad3'),
            minx.XData('CARD32',1,'pad4'),
            minx.XData('CARD32',1,'pad5'),
            minx.XData('CARD32',1,'pad6'),
            minx.XData('CARD32',1,'pad7'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )


###############################################################################
# NV-CONTROL Query Valid Attribute Values
#
class _NVCtrlQueryValidAttributeValuesRequest:
    '''this class handles the Query Valid Attribute Values request,
    which tells us whether or not the attr is present, and if so,
    what the valid values for it are'''

    def __init__(self,opcode,target_id,target_type,display_mask,attr):
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlQueryValidAttributeValues),
            minx.XData('CARD16',1,4),
            minx.XData('CARD16',1,target_id),
            minx.XData('CARD16',1,target_type),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr))


class _NVCtrlQueryValidAttributeValuesReply:
    '''the reply to NVCtrlQueryValidAttributeValues request. returns
    the value and the flags, which describe whether attr
    is read-only, etc. see NVCtrlLib.h'''

    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('BYTE',1,'pad0'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('INT32',1,'attr_type'),
            minx.XData('INT32',1,'min'),
            minx.XData('INT32',1,'max'),
            minx.XData('CARD32',1,'bits'),
            minx.XData('CARD32',1,'perms'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )


###############################################################################
# NV-CONTROL String Operation
#
class _NVCtrlStringOperationRequest:
    def __init__(self,opcode,target_id,target_type,display_mask,attr,data):
        dlen = 0
        if data and len(data) > 0:
            dlen = len(data)+1 #include terminating 0
        else:
            data = ''
        self.encoding = minx.encode(
            minx.XData('CARD8',1,opcode),
            minx.XData('CARD8',1,_X_nvCtrlStringOperation),
            minx.XData('CARD16',1,5 + (((dlen+3)&~3) >> 2) ),
            minx.XData('CARD16',1,target_id),
            minx.XData('CARD16',1,target_type),
            minx.XData('CARD32',1,display_mask),
            minx.XData('CARD32',1,attr),
            minx.XData('CARD32',1,dlen),
            minx.XData('STRING8',dlen,data+'\0'))


class _NVCtrlStringOperationReply:
    def __init__(self,encoding):
        xreply, ad = minx.decode(encoding,
            minx.XData('BYTE',1,'type'),
            minx.XData('BYTE',1,'padb1'),
            minx.XData('CARD16',1,'sequence_number'),
            minx.XData('CARD32',1,'length'),
            minx.XData('CARD32',1,'flags'),
            minx.XData('CARD32',1,'n'),
            minx.XData('CARD32',1,'padl4'),
            minx.XData('CARD32',1,'padl5'),
            minx.XData('CARD32',1,'padl6'),
            minx.XData('CARD32',1,'padl7'))

        for n, v in xreply.iteritems():
            setattr( self, n, v )

        rs, ad = minx.decode(ad,
            minx.XData('STRING8',self.n,'string'))
        self.string = str(rs['string'])


###############################################################################
# NV-CONTROL String Operation
#
class NVidiaControl:

    xsock = None    # X connection socket
    xscreen = None  # X screen
    opcode = None   # major opcode for X extension
    version = None  # NV-CONTROL extension version

    gpucount = 0    # number of GPUs in the system


    def __init__(self):
        '''Initialise the nVidia control extension. A KeyError is raised if no
        nVidia extension could be found, a ValueError is raised if it was
        found but found unsuitable.'''
        self.init_NV_CONTROL()

    def init_NV_CONTROL(self):
        '''Connect to X and confirm NV-CONTROL. Raise KeyError is NV-CONTROL
        not found, or raise ValueError is buggy NV-CONTROL (minor 8 or 9) is
        found.'''

        name, host, displayno, self.xscreen = xnet.get_X_display()
        self.xsock, self.xconn = minx.XConnect()
        try:
            NVCtrl = minx.XQueryExtension(self.xsock, 'NV-CONTROL')
            self.opcode = NVCtrl.major_opcode
        except Exception,e:
            self.xsock.close()
            raise e

        if not NVCtrl.present:
            self.xsock.close()
            self.xsock = None
            raise KeyError( 'NV-CONTROL extension not found, probably not an nVidia card' )

        version = self.get_version()

        if version[1] == 8 or version[1] == 9:
            self.xsock.close()
            raise ValueError( 'buggy NV-CONTROL extension (arg swap bug): '+'.'.join(version) )


    def validate_GPU_count(self):
        '''Count GPUs and make sure there is at least 1.
        raise ValueError if no nVidia GPUs are found'''

        self.gpucount = 0
        self.gpucount = query_target_count(GPU()).count
        if self.gpucount == 0:
            raise ValueError( "NV-CONTROL extension found but no corresponding GPU's detected" )



    def get_version(self):
        '''this function uses NVCtrlQueryExtension to get
        the major and minor versions of the NV-CONTROL extension
        in use. returned as a tuple (major,minor)'''

        if self.version:
            return self.version

        rq = _NVCtrlQueryExtensionRequest(self.opcode)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            nvc = _NVCtrlQueryExtensionReply(binrp)
            self.version = (nvc.major,nvc.minor)
            return self.version


    def query_int_attribute(self, target, displays, attr):
        '''return the value of an integer attribute'''
        display_mask = self._displays2mask(displays)
        rq = _NVCtrlQueryAttributeRequest(self.opcode, target.id(),
            target.type(), display_mask, attr)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlQueryAttributeReply(binrp)


    def set_int_attribute(self, target, displays, attr, value):
        '''set the value of an integer attribute. target has to be a Screen.'''
        if not isinstance(target, Screen):
            raise ValueError( 'SetIntAttribute can only be executed on a screen' )

        display_mask = self._displays2mask(displays)
        rq = _NVCtrlSetAttributeAndGetStatusRequest(self.opcode, target.id(),
            display_mask, attr, value)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlSetAttributeAndGetStatusReply(binrp)


    def query_string_attribute(self, target, displays, attr):
        '''return the value of a string attribute'''
        display_mask = self._displays2mask(displays)
        rq = _NVCtrlQueryStringAttributeRequest(self.opcode, target.id(),
            target.type(), display_mask, attr)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlQueryStringAttributeReply(binrp)


    def set_string_attribute(self, target, displays, attr, data):
        '''set the value of a string attribute. target has to be a Screen.'''
        if not isinstance(target, Screen):
            raise ValueError( 'SetStringAttribute can only be executed on a screen' )

        display_mask = self._displays2mask(displays)
        rq = _NVCtrlSetStringAttributeRequest(self.opcode, target.id(),
            display_mask, attr, data)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlSetStringAttributeReply(binrp)


    def query_target_count(self, target):
        '''return the target count'''
        rq = _NVCtrlQueryTargetCountRequest(self.opcode, target.type())
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlQueryTargetCountReply(binrp)


    def query_binary_data(self, target, displays, attr):
        '''return binary data'''
        display_mask = self._displays2mask(displays)
        rq = _NVCtrlQueryBinaryDataRequest(self.opcode, target.id(),
            target.type(), display_mask, attr)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlQueryBinaryDataReply(binrp)


    def query_valid_attr_values(self, target, displays, attr):
        display_mask = self._displays2mask(displays)
        rq = _NVCtrlQueryValidAttributeValuesRequest(self.opcode, target.id(),
            target.type(), display_mask, attr)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlQueryValidAttributeValuesReply(binrp)


    def get_valid_attr_values(self, target, attr):
        if not isinstance(target, GPU):
            raise ValueError( 'GetValidAttributeValues can only be executed on a GPU' )

        vv = query_valid_attr_values(target.id(),
            NV_CTRL_TARGET_TYPE_GPU, 0, attr)

        return vv


    def string_operation(self, target, displays, attr, data):
        '''execute a string operation'''
        display_mask = self._displays2mask(displays)
        rq = _NVCtrlStringOperationRequest(self.opcode, target.id(),
            target.type(), display_mask, attr, data)
        binrp = minx.Xchange(self.xsock, rq)

        if binrp[0] == 0:
            raise minx.XServerError(binrp)
        else:
            return _NVCtrlStringOperationReply(binrp)


    def _displays2mask(self, displays):
        '''return a display mask from an array of display numbers.'''
        mask = 0
        for d in displays:
            mask += ( 1 << self._displaystr2num(d) )
        return mask


    def _mask2displays(self, mask):
        '''return an array of display numbers from a display mask.'''
        displays = []
        for i in range(32):
            if mask & (1<<i):
                displays.append(self._displaynum2str(i))
        return displays

    def _displaynum2str(self, num):
        '''return a string uniquely representing a display number'''
        if num > 15:
            return 'DFP-%d'%(num-16)
        elif num > 7:
            return 'TV-%d'%(num-7)
        else:
            return 'CRT-%d'%(num)

    def _displaystr2num(self, st):
        '''return a display number from a string'''
        num = None
        for s,n in [('DFP-',16), ('TV-',8), ('CRT-',0)]:
            if st.startswith(s):
                try: 
                    curnum = int(st[len(s):])
                    if curnum >= 0 and curnum <= 7:
                        num = n + curnum
                        break
                except Exception:
                    pass
        if num != None:
            return num
        else:
            raise ValueError('Unrecognised display name: '+st)


# vim:ts=4:sw=4:expandtab:
