###############################################################################
# minx.py - an example of a minimal X Protocol interface in python
#
# code taken from NvThermometer by Harry Organs, which was based on the code
# for python-xlib, written by Peter Liljenberg
# http://python-xlib.sourceforge.net/
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

import struct
import socket
from platform import architecture
import xnet


__XFORMATBYTES = { 'CARD8':1,'CARD16':2,'INT8':1,'INT16':2,
'PAD':1,'BYTE':1,'CARD32':4,'INT32':4 ,'STRING8':1 }

__XFORMATS = { 'CARD8':'B','CARD16':'H','INT8':'b','INT16':'h',
'PAD':'B','BYTE':'B','CARD32':'I','INT32':'i','STRING8':'s0I' }

_ARCHW = architecture()[0]
if _ARCHW.startswith('32bit'): # adjust struct format strings for 32bit
    __XFORMATS['CARD32']='L'
    __XFORMATS['INT32']='l'
    __XFORMATS['STRING8']='s0L'

__XERRORMSG = { 1:'Request error. The major or minor opcode of a request is \
invalid.',
2:'Value error. A request contained a bad argument value.',
3:'Window error. A value for a WINDOW argument does not name a defined \
WINDOW.',
4:'Pixmap error. A value for a PIXMAP argument does not name a defined PIXMAP.',
5:'Atom error. A value for an ATOM argument does not name a defined ATOM.',
6:'Cursor error. A value for a CURSOR argument does not name a defined \
CURSOR.',
7:'Font error. A value for a FONT argument does not name a defined FONT \
or a value for a FONTABLE argument does not name a defined FONT or a \
defined GCONTEXT.',
8:'Match error. InputOnly window used as a DRAWABLE, or GCONTEXT argument \
does not have the same root and depth as the destination DRAWABLE argument, \
or argument(s) fails to match request requirements.',
9:'Drawable error. A value for a DRAWABLE argument does not name a defined \
WINDOW or PIXMAP.',
10:'Access error. Resource access violation or conflict with another client',
11:'Alloc error. The server failed to allocate the requested resource.',
12:'Colormap error. A value for a COLORMAP argument does not name a defined \
COLORMAP.',
13:'GContext error. A value for a GCONTEXT argument does not name a defined \
GCONTEXT.',
14:'IDChoice error. The value chosen for a resource identifier either is not \
included in the range assigned to the client or is already in use.',
15:'Name error. A font or color of the specified name does not exist.',
16:'Length error. The length of a request is shorter or longer than that \
required to minimally contain the arguments, or the length of a request \
exceeds the maximum length accepted by the server.',
17:'Implementation error. The server does not implement some aspect of the \
request.' }

_XServerError__XERRORMSG = __XERRORMSG

class XData:
    '''XData is a simple argument container used to avoid the
    pain and errors of indexing'''

    def __init__( self, f, s, v ):
        self.format = f
        self.size = s
        self.value = v


def encode( *arguments ):
    '''encode takes a variable argument list consisting of XData
    types and returns an encoded byte stream ready to send to the X server.
    the XData args are X type, number of elements, and the value(s). the
    order of fields in the resulting byte stream is determined by the order
    of their respective arguments'''

    bytestream = ''

    for arg in arguments:
        structcode = str(__XFORMATS[arg.format])

        if arg.size == 1:
            bytestream = bytestream + struct.pack( structcode, arg.value )
        else:
            if arg.format.startswith('STRING8'):
                structcode = str(arg.size) + structcode
                bytestream = bytestream + struct.pack( structcode, arg.value )
            else:
                for i in arg.value:
                    bytestream = bytestream + struct.pack( structcode, i )
            
    return bytestream


def decode( binary, *arguments ):
    '''decode takes a byte stream and a variable argument list of XData
    types and returns a dict containing the decoded byte stream.
    the XData args are X type, number of elements, and the key name to
    be associated with the value. the order of arguments determines
    what order the fields will be decoded in'''

    data = binary
    rdict = {}

    for arg in arguments:
        structcode = __XFORMATS[arg.format]
        fsz = __XFORMATBYTES[arg.format]
        
        if not isinstance(arg.size,str):
            asz = arg.size
        else:
            asz = rdict[arg.size]

        sz = asz * fsz

        if asz == 1:
            rdict[arg.value] = struct.unpack( structcode, data[:sz] )[0]
        else:
            structcode = str(asz) + structcode
            sz = struct.calcsize(structcode)
            if arg.format.startswith('STRING8'):
                rdict[arg.value] = struct.unpack( structcode, data[:sz] )[0]
            else:
                rdict[arg.value] = struct.unpack( structcode, data[:sz] )

        data = data[sz:]
            
    return rdict, data


###############################################################################
# Exception class for X server errors
#
class XServerError(Exception):
    '''XServerError is an Exception class to raise X errors.
    this class decodes the error return and selects the message
    to display. the error messages are copied from the X Protocol
    pdf. see the doc for an explanation of the other_info field,
    which contains extra data for some errors.'''

    def __init__(self,encoding):
        xreply, ad = decode( encoding,
        XData('CARD8',1,'Error'),
        XData('CARD8',1,'code'),
        XData('CARD16',1,'sequence_number'),
        XData('CARD32',1,'other_info'),
        XData('CARD16',1,'minor_opcode'),
        XData('CARD8',1,'major_opcode'),
        XData('PAD',21,'unused') )
        
        self.error_code = xreply['code']
        self.sequence_number = xreply['sequence_number']
        self.major_opcode = xreply['major_opcode']
        self.minor_opcode = xreply['minor_opcode']
        self.message = __XERRORMSG[self.error_code]
        self.other_info = xreply['other_info']
        
    def __str__(self):
        return 'X Error ' + str(self.error_code) + ': ' + self.message


        
###############################################################################
# Connection Setup request and replies
#
class XConnectRequest:
    '''XConnectRequest encodes the packet needed to connect to the X server'''

    def __init__(self, byte_order, proto_major,
    proto_minor, auth_name, auth_data ):    
        self.encoding = encode( XData('BYTE',1,byte_order),
        XData('PAD',1,0),
        XData('CARD16',1,proto_major),
        XData('CARD16',1,proto_minor),
        XData('CARD16',1,len(auth_name)),
        XData('CARD16',1,len(auth_data)),
        XData('PAD',2,[0,0]),
        XData('STRING8',len(auth_name),auth_name),  
        XData('STRING8',len(auth_data),auth_data) )

        
class XConnectRefusedReply:
    '''X server reply for failed logon attempt'''

    def __init__(self,encoding):
        xreply, n = decode( encoding,
        XData('BYTE',1,'Failed'),
        XData('BYTE',1,'sz_reason'),
        XData('CARD16',1,'protocol_major_version'),
        XData('CARD16',1,'protocol_minor_version'),
        XData('CARD16',1,'sz_additional'),
        XData('STRING8','sz_reason','reason') )
        
        for n, v in xreply.iteritems():
            setattr( self, n, v )

class XConnectAcceptedReply:
    '''the logon reply. contains all the info needed by
    clients to create windows, etc, as well as various
    server info like vendor name'''

    def __init__(self,encoding):
        xreply, ad = decode( encoding, 
        XData('BYTE',1,'Success'),
        XData('PAD',1,'unused_1'), 
        XData('CARD16',1,'protocol_major_version'),
        XData('CARD16',1,'protocol_minor_version'),
        XData('CARD16',1,'sz_additional'),
        XData('CARD32',1,'release_number'),
        XData('CARD32',1,'resource_id_base'),
        XData('CARD32',1,'resource_id_mask'),
        XData('CARD32',1,'motion_buffer_size'),
        XData('CARD16',1,'sz_vendor'),
        XData('CARD16',1,'maximum_request_length'),
        XData('CARD8',1,'n_SCREENS'),
        XData('BYTE',1,'n_FORMATS'),
        XData('BYTE',1,'image_byte_order'),
        XData('BYTE',1,'bitmap_format_bit_order'),
        XData('CARD8',1,'bitmap_format_scanline_unit'),
        XData('CARD8',1,'bitmap_format_scanline_pad'),
        XData('CARD8',1,'min_keycode'),
        XData('CARD8',1,'max_keycode'),
        XData('PAD',4,'unused_2'),
        XData('STRING8','sz_vendor','vendor') )

        for n, v in xreply.iteritems():
            setattr( self, n, v )
    
        self.pixmap_formats = []
        for p in range(self.n_FORMATS):
            pfe, ad = decode( ad, XData('CARD8',1,'depth'),
            XData('CARD8',1,'bits_per_pixel'),
            XData('CARD8',1,'scanline_pad'),
            XData('PAD',5,'unused') )
            self.pixmap_formats.append(pfe)
        
        self.roots = []
        for s in range(self.n_SCREENS):
            se, ad = decode( ad, XData('CARD32',1,'root'),
            XData('CARD32',1,'default_colormap'),
            XData('CARD32',1,'white_pixel'),
            XData('CARD32',1,'black_pixel'),
            XData('CARD32',1,'current_input-masks'),
            XData('CARD16',1,'width_in_pixels'),
            XData('CARD16',1,'height_in_pixels'),
            XData('CARD16',1,'width_in_millimeters'),
            XData('CARD16',1,'height_in_millimeters'),
            XData('CARD16',1,'min_installed_maps'),
            XData('CARD16',1,'max_installed_maps'),
            XData('CARD32',1,'root_visual'),
            XData('CARD8',1,'backing_stores'),
            XData('CARD8',1,'save_unders'),
            XData('CARD8',1,'root_depth'),
            XData('CARD8',1,'n_allowed_depths') )

            se['allowed_depths'] = []
            for d in range(se['n_allowed_depths']):
                de, ad = decode( ad, XData('CARD8',1,'depth'),
                XData('PAD',1,'unused_1'),
                XData('CARD16',1,'n_VISUALTYPES'),
                XData('PAD',4,'unused_2') )
                
                de['visuals'] = []
                for v in range(de['n_VISUALTYPES']):
                    ve, ad = decode( ad, XData('CARD32',1,'visual_id'),
                    XData('CARD8',1,'class'),
                    XData('CARD8',1,'bits_per_rgb_value'),
                    XData('CARD16',1,'colormap_entries'),
                    XData('CARD32',1,'red_mask'),
                    XData('CARD32',1,'green_mask'),
                    XData('CARD32',1,'blue_mask'),
                    XData('PAD',4,'unused') )

                    de['visuals'].append(ve)
                se['allowed_depths'].append(de)

            self.roots.append(se)



class XConnectAuthenticateReply:
    '''reply sent by secured servers to request client authentication.
    authentication procedures are not defined by the X protcol, so the
    way to handle this one is outside an X protocol interface. Should
    probably raise some kind of exception if unhandled'''

    def __init__(self,encoding):
        xreply, ad = decode( encoding,
        XData('BYTE',1,'Authenticate'),
        XData('PAD',5,'unused'),
        XData('CARD16',1,'sz_additional') )

        for n, v in xreply.iteritems():
            setattr( self, n, v )
        
        rs, ad = decode( ad,
        XData('STRING8',self.xdata['sz_additional']*4,'reason') )
        self.reason = rs['reason']


###############################################################################
# QueryExtension request and reply - opcode 98
#
class XQueryExtensionRequest:
    '''this class wraps the X Protocol Query Extension request. it
    requires the name of the extension to look for as a constructor arg'''

    def __init__(self,exname):
        self.encoding = encode( XData('CARD8',1,98),
        XData('PAD',1,0),
        XData('CARD16',1, 2 + ((len(exname)+(len(exname)%4)) /4) ),
        XData('CARD16',1,len(exname)),
        XData('PAD',2,[0,0]),
        XData('STRING8',len(exname),exname) )

class XQueryExtensionReply:
    '''the reply to a Query Extension request. if attr present is
    0, the extension isn't there. if present is 1, extension exists
    and the extension opcode, base error, and base event are returned'''

    def __init__(self,encoding):
        xreply, ad = decode( encoding,
        XData('CARD8',1,'reply'),
        XData('PAD',1,'unused_1'),
        XData('CARD16',1,'sequence_number'),
        XData('CARD32',1,'reply_length'),
        XData('CARD8',1,'present'),
        XData('CARD8',1,'major_opcode'),
        XData('CARD8',1,'first_event'),
        XData('CARD8',1,'first_error'),
        XData('PAD',20,'unused_2') )

        for n, v in xreply.iteritems():
            setattr( self, n, v )


###############################################################################
# ListExtensions request and reply - opcode 99
#
class XListExtensionsRequest:
    '''this class wraps the X List Extensions request'''

    def __init__(self):
        self.encoding = encode( XData('CARD8',1,99),
        XData('PAD',1,0),
        XData('CARD16',1,1) )

class XListExtensionsReply:
    '''this class wraps the X List Extensions reply. it contains
    the extensions as a list of strings, as well as the number
    of strings in the list and the sequence number of request'''

    def __init__(self,encoding):
        xreply, ad = decode( encoding,
        XData('CARD8',1,'reply'),
        XData('CARD8',1,'n_STRs'),
        XData('CARD16',1,'sequence_number'),
        XData('CARD32',1,'reply_length'),
        XData('PAD',24,'unused') )

        for n, v in xreply.iteritems():
            setattr( self, n, v )

        self.names = []
        for s in range(xreply['n_STRs']):
            sz = struct.unpack( 'B', ad[:1] )[0]
            self.names.append( str(ad[1:sz+1]) )
            ad = ad[sz+1:]



###############################################################################
# Procedures to use the request classes to get info, etc
#
def Xchange( xsock, rq) :
    xreply = ''
    try:
        xsock.send( rq.encoding )
        xreply = xsock.recv(65535) # TODO make sure it fits

    except socket.error, err:
        raise xnet.XConnectionError( 'Network error: %s' % err[1] )

    return xreply


def XConnect():

    name, host, displayno, screenno = xnet.get_X_display()
    xsock = xnet.get_X_socket( host, displayno )
    auth_name, auth_data = xnet.get_X_auth( xsock, name, host, displayno )
    byte_order = xnet.get_X_byteorder()

    rq = XConnectRequest( byte_order, 11, 0, auth_name, auth_data )

    xreply = Xchange( xsock, rq )

    if xreply[0] == '\x00':
        repobj = XConnectRefusedReply(xreply)
        raise xnet.XConnectionError( repobj.reason )

    elif xreply[0] == '\x01':
        repobj = XConnectAcceptedReply(xreply)

    elif xreply[0] == '\x02':
        repobj = XConnectAuthenticateReply(xreply) 
        raise xnet.XConnectionError( repobj.reason )

    else:
        raise xnet.XConnectionError( 'Unknown connection failure' )

    return xsock, repobj


def XListExtensions( xsock ):
    rq = XListExtensionsRequest()
    binrp = Xchange( xsock, rq )

    if binrp[0] == 0:
        raise XServerError( binrp )
    else:
        return XListExtensionsReply( binrp )


def XQueryExtension( xsock, exname ):
    rq = XQueryExtensionRequest(exname)
    binrp = Xchange( xsock, rq )

    if binrp[0] == 0:
        if binrp[1] > 0 and binrp[1] <= 17:
            raise XServerError( binrp )

    return XQueryExtensionReply( binrp )
    


