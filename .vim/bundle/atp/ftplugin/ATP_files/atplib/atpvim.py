#!/usr/bin/env python

import vim

__all__ = [ 'read', 'readlines', 'getbuffer', ]

def getbuffer(fpath):
    """ Return bufer number of fpath,

    fpath should be a full path of a file.
    """
    for buf in vim.buffers:
	if buf.name == fpath:
            return buf
    else:
        return None

def read(file_path):
    """ Read lines from fname, check if the fname is loaded get tge buffer."""

    buffer = getbuffer(file_path)
    if buffer and int(vim.eval('bufloaded(%d)' % buffer.number)):
        return "\n".join(buffer)

    try:
        with open(file_path, 'r') as fo:
            # we are not decoding: since we have to assume that files are in &encoding
            # vim stores buffers, variables, ... in &encoding.
            return fo.read()
    except IOError:
        return ""

def readlines(file_path):
    """ Read lines from fname, if the fname is loaded get the buffer."""

    buffer = getbuffer(file_path)
    if buffer and int(vim.eval('bufloaded(%d)' % buffer.number)):
        return buffer

    try:
        with open(file_path, 'r') as fo:
            # we are not decoding: since we have to assume that files are in &encoding
            # and vim stores buffers, variables, ... in &encoding.
            return fo.read().splitlines()
    except IOError:
        return []
