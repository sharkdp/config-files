#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: Marcin Szamotulski <mszamot[@]gmail[.]com>
# This script is a part of Automatic TeX Plugin for Vim.
# It can be destributed seprately under General Public Licence ver.3 or higher.

# SYNTAX:
# reverse_search.py <file> <line_nr> [<col_nr>]

# DESRIPTION: 
# This is a python sctipt which implements reverse searching (okular->vim)
# it uses atplib#FindAndOpen() function which finds the vimserver which hosts
# the <file>, then opens it on the <line_nr> and column <col_nr>.
# Column number is an optoinal argument if not set on the command line it is 1.

# HOW TO CONFIGURE OKULAR to get Reverse Search
# Designed to put in okular: 
# 		Settings>Configure Okular>Editor
# Choose: Custom Text Edit
# In the command field type: reverse_search.py '%f' '%l'
# If it is not in your $PATH put the full path of the script.

# DEBUG:
# debug file : /tmp/reverse_search.debug

import subprocess, sys, re, optparse, os
from optparse import OptionParser
from os import devnull

import signal

usage   = "usage: %prog [options]"
parser  = OptionParser(usage=usage)
parser.add_option("--gvim", dest="progname", action="store_const", const="gvim", default="gvim")
parser.add_option("--vim",  dest="progname", action="store_const", const="vim")
parser.add_option("--synctex", dest="synctex", action="store_true", default=False)
(options, args) = parser.parse_args()
progname = options.progname

f = open('/tmp/reverse_search.debug', 'w')

def vim_remote_expr(servername, expr):
    """Send <expr> to vim server,

    expr must be well quoted:
         vim_remote_expr('GVIM', "atplib#callback#TexReturnCode()")"""
    cmd=[progname, '--servername', servername, '--remote-expr', expr]
    with open(os.devnull, "w+") as devnull:
        subprocess.Popen(cmd, stdout=devnull, stderr=f).wait()

# Get list of vim servers.
output  = subprocess.Popen([progname, "--serverlist"], stdout=subprocess.PIPE)
servers = output.stdout.read().decode().split("\n")
server_list = filter(lambda x: len(x),servers)
f.write(">>> server list: %s\n" % server_list)
file    = args[0]
output_file = file
if not options.synctex:
    line=args[1]
    # Get the column (it is an optional argument)
    if (len(args) >= 3 and int(args[2]) > 0):
            column = str(args[2])
    else:
            column = str(1)
    synctex_returncode  = 0
else:
    # Run synctex
    page=args[1]
    x=args[2]
    y=args[3]
    if x == "0" and y == "0":
        f.write(">>> x=0 and y=0 exit with -1")
        f.close()
        sys.exit("-1")
    y=float(791.333)-float(y)
    synctex_cmd=["synctex", "edit", "-o", "%s:%s:%s:%s" % (page, x, y, file)]
    f.write('>>> synctex: %s\n' % ' '.join(synctex_cmd))
    synctex=subprocess.Popen(synctex_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    synctex.wait()
    synctex_output      = synctex.stdout.read()
    synctex_error       = synctex.stderr.read()
    synctex_error_list  = re.split('\n',synctex_error)
    synctex_returncode  = synctex.returncode
    error               = ""
    f.write('>>> synctex return code: %d\n' % synctex.returncode)
    for error_line in synctex_error_list:
        if re.match('SyncTeX ERROR', error_line):
            error=error_line
            f.write(">>> synctex error: %s\n" % error)
            break
    if synctex.returncode == 0:
        match_pos=re.findall("(?:Line:(-?\d+)|Column:(-?\d+))",synctex_output)
        if len(match_pos):
            line=match_pos[0][0]
            column=match_pos[1][1]
            if column == "-1":
                column = "1"
        else:
            line        = "-1"
            column      = "-1"
        match_pos=re.findall("Input:(.*)",synctex_output)
        f.write(">>> X %s\n" % str(match_pos))
        if len(match_pos):
            file = match_pos[0]
    else:
        msg=">>> synctex return code: %d" % synctex.returncode
        f.write(msg)
        line    = "-1"
        column  = "-1"

f.write(">>> args: '%s':%s:%s\n" % (file, line, column))
cmd = ''
if len(server_list):
    server = server_list[0]

    class TimeOutException(Exception):
        pass

    def timeout_handler(signum, frame):
        raise TimeOutException()

    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(1) # send a SIGALRM after 1 second,           
                    # this function is only available on Unix, 
                    # signal.alarm() works only with seconds.  

    f.write(">>> server: '%s'\n" % server)
    # Call atplib#FindAndOpen()     
    cmd="%s --servername %s --remote-expr \"atplib#FindAndOpen('%s','%s','%s','%s')\"" % (progname, server, file, output_file, line, column)
    findandopen=subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    try:
        f.write(findandopen.stdout.read())
    except TimeOutException:
        vim_server=None
        # Echo a message (this can also be done in the Exception. 
        # How to do that?
    else:
        vim_server=re.split("\n",findandopen.stdout.read())[0]
    f.write(">>> vim server: '%s'\n" % vim_server)
    if synctex_returncode and vim_server:
        cmd=""
        if error != "":
            vim_remote_expr(vim_server,
                "atplib#callback#Echo('[ATP:] %s','echomsg','WarninMsg', '1')" % error
                )
        else:
            vim_remote_expr(vim_server,
                "atplib#callback#Echo(\"[SyncTex:] synctex return with exit code: %d\",'echo','WarninMsg', '1')" % synctex.returncode
                )
    # Debug:
    f.write("""\
    >>> file: '%s'
    >>> line: '%s'
    >>> column: '%s'
    >>> cmd: '%s'
    """ % (file, line, column, cmd))
    f.close()
else:
    # no running vim:
    cmd="%s +%s '%s'" % (progname, line, file)
    f.write("""\
    >>> file: '%s'
    >>> line: '%s'
    >>> column: '%s'
    >>> cmd: '%s'
    """ % (file, line, column, cmd))
    f.close()
    p=subprocess.Popen(cmd, shell=True, stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr)
    p.wait()
