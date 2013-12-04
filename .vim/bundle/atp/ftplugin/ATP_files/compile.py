#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: Marcin Szamotulski <mszamot[@]gmail[.]com>
# This file is a part of Automatic TeX Plugin for Vim.

import sys
import os
import errno
import os.path
import shutil
import subprocess
import psutil
import re
import tempfile
import optparse
import glob
import traceback
import atexit

from optparse import OptionParser
from collections import deque

import latex_log
import locale
encoding = locale.getpreferredencoding()

# readlink is not available on Windows.
readlink=True
try:
    from os import readlink
except ImportError:
    readlink=False

####################################
#
#       Parse Options:   
#
####################################

usage   = "usage: %prog [options]"
parser  = OptionParser(usage=usage)

parser.add_option("--command",          dest="command",         default="pdflatex"                      )
parser.add_option("--bibcommand",       dest="bibcommand",      default="bibtex"                        )
parser.add_option("--progname",         dest="progname",        default="gvim"                          )
parser.add_option("--aucommand",        dest="aucommand",       default=False, action="store_true"      )
parser.add_option("--tex-options",      dest="tex_options",     default="-synctex=1,-interaction=nonstopmode")
parser.add_option("--output-dir",       dest="output_dir",      default=os.path.abspath(os.curdir)      )
parser.add_option("--verbose",          dest="verbose",         default="silent"                        )
parser.add_option("--file",             dest="mainfile",                                                )
parser.add_option("--bufnr",            dest="bufnr",                                                   )
parser.add_option("--output-format",    dest="output_format",   default="pdf"                           )
parser.add_option("--runs",             dest="runs",            default=1,             type="int"       )
parser.add_option("--no-callback",      dest="callback",        default=True,           action="store_false")
parser.add_option("--progressbar_file", dest="pb_fname",        default="",                             )
parser.add_option("--servername",       dest="servername",                                              )
parser.add_option("--start",            dest="start",           default=0,             type="int"       )
parser.add_option("--viewer",           dest="viewer",          default="xpdf"                          )
parser.add_option("--xpdf-server",      dest="xpdf_server",                                             )
parser.add_option("--viewer-options",   dest="viewer_opt",      default=""                              )
parser.add_option("--keep",             dest="keep",            default="aux,toc,bbl,ind,pdfsync,synctex.gz")
parser.add_option("--env",              dest="env",             default=""  )
parser.add_option("--logdir",           dest="logdir")
# Boolean switches:
parser.add_option("--reload-viewer",    action="store_true",    default=False,  dest="reload_viewer")
parser.add_option("--bibtex",           action="store_true",    default=False,  dest="bibtex"           )
parser.add_option("--reload-on-error",  action="store_true",    default=False,  dest="reload_on_error"  )
parser.add_option("--bang",             action="store_false",   default=False,  dest="bang"             )
parser.add_option("--gui-running",      action="store_true",    default=False,  dest="gui_running"      )
parser.add_option("--autex_wait",       action="store_true",    default=False,  dest="autex_wait"       )
parser.add_option("--no-progress-bar",  action="store_false",   default=True,   dest="progress_bar"     )
parser.add_option("--bibliographies",                           default="",     dest="bibliographies"   )
parser.add_option("--tempdir",                                  default="",     dest="tempdir"          )

(options, args) = parser.parse_args()

# Debug file should be changed for sth platform independent
# There should be a switch to get debug info.

def nonempty(string):
    if str(string) == '':
        return False
    else:
        return True

logdir          = os.path.abspath(options.logdir)
script_logfile  = os.path.join(logdir, 'compile.log')
debug_file      = open(script_logfile, 'w')

# Cleanup on exit:
def cleanup(debug_file):
    debug_file.close()
    shutil.rmtree(tmpdir)
atexit.register(cleanup, debug_file)

command         = options.command
bibcommand      = options.bibcommand
progname        = options.progname
aucommand_bool  = options.aucommand
if aucommand_bool:
    aucommand="AU"
else:
    aucommand="COM"
command_opt     = list(filter(nonempty,re.split('\s*,\s*', options.tex_options)))
mainfile_fp     = options.mainfile
bufnr           = options.bufnr
output_format   = options.output_format
if output_format == "pdf":
    extension = ".pdf"
else:
    extension = ".dvi"
runs            = options.runs
servername      = options.servername
pb_fname        = options.pb_fname
start           = options.start
viewer          = options.viewer
autex_wait      = options.autex_wait
XpdfServer      = options.xpdf_server
viewer_rawopt   = re.split('\s*;\s*', options.viewer_opt)
viewer_it       = list(filter(nonempty,viewer_rawopt))
viewer_opt      =[]
for opt in viewer_it:
    viewer_opt.append(opt)
viewer_rawopt   = viewer_opt
if viewer == "xpdf" and XpdfServer != None:
    viewer_opt.extend(["-remote", XpdfServer])
verbose         = options.verbose
keep            = options.keep.split(',')
keep            = list(filter(nonempty, keep))

env             = list(map(lambda x: re.split('\s*=\s*', x), list(filter(nonempty, re.split('\s*;\s*',options.env)))))

# Boolean options
reload_viewer   = options.reload_viewer
bibtex          = options.bibtex
bibliographies  = options.bibliographies.split(",")
bibliographies  = list(filter(nonempty, bibliographies))
bang            = options.bang
reload_on_error = options.reload_on_error
gui_running     = options.gui_running
progress_bar    = options.progress_bar
options.output_dir = os.path.abspath(options.output_dir)

debug_file.write("COMMAND "+command+"\n")
debug_file.write("BIBCOMMAND "+bibcommand+"\n")
debug_file.write("AUCOMMAND "+aucommand+"\n")
debug_file.write("PROGNAME "+progname+"\n")
debug_file.write("COMMAND_OPT "+str(command_opt)+"\n")
debug_file.write("OUTPUT DIR %s\n" % options.output_dir)
debug_file.write("MAINFILE_FP "+str(mainfile_fp)+"\n")
debug_file.write("OUTPUT FORMAT "+str(output_format)+"\n")
debug_file.write("EXT "+extension+"\n")
debug_file.write("RUNS "+str(runs)+"\n")
debug_file.write("VIM_SERVERNAME "+str(servername)+"\n")
debug_file.write("START "+str(start)+"\n")
debug_file.write("VIEWER "+str(viewer)+"\n")
debug_file.write("XPDF_SERVER "+str(XpdfServer)+"\n")
debug_file.write("VIEWER_OPT "+str(viewer_opt)+"\n")
debug_file.write("DEBUG MODE (verbose) "+str(verbose)+"\n")
debug_file.write("KEEP "+str(keep)+"\n")
debug_file.write("BIBLIOGRAPHIES "+str(bibliographies)+"\n")
debug_file.write("ENV OPTION "+str(options.env)+"\n")
debug_file.write("ENV "+str(env)+"\n")
debug_file.write("*BIBTEX "+str(bibtex)+"\n")
debug_file.write("*BANG "+str(bang)+"\n")
debug_file.write("*RELOAD_VIEWER "+str(reload_viewer)+"\n")
debug_file.write("*RELOAD_ON_ERROR "+str(reload_on_error)+"\n")
debug_file.write("*GUI_RUNNING "+str(gui_running)+"\n")
debug_file.write("*PROGRESS_BAR "+str(progress_bar)+"\n")

####################################
#
#       Functions:   
#
####################################

def write_pbf(string):
    # Open pb_fname and write nr to it 
    # only if int(string) is greater than what is in this file 

    cond = False
    try:
        if sys.version_info.major < 3:
            with open(pb_fname, 'r') as fobj:
                pb_file = fobj.read().decode(encoding, errors="replace")
        else:
            with open(pb_fname, 'r', encoding=encoding, errors='replace') as fobj:
                pb_file = fobj.read()
    except IOError as ioerror:
        debug_file.write("write_pbf at line %d: %s" % (sys.exc_info()[2].tb_lineno, str(ioerror)))
        cond = True
    if not cond:
        pb = re.match('(\d*)', pb_file)
        if pb:
            try:
                nr = int(pb.group(1))
            except ValueError:
                nr = -1
        else:
            nr = 0
        try:
            if nr >= 0:
                cond = (int(string) > nr)
            else:
                cond = True
        except ValueError:
            cond = False
    if cond:
        try:
            with open(pb_fname, 'w') as fobj:
                fobj.write((string+"\n").encode(encoding, errors="replace"))
        except IOError as ioerror:
            debug_file.write("write_pbf at line %d: %s" % (sys.exc_info()[2].tb_lineno, str(ioerror)))

def latex_progress_bar(cmd):
    # Run latex and send data for progress bar,

    child = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    pid   = child.pid
    vim_remote_expr(servername, "atplib#callback#LatexPID("+str(pid)+")")
    debug_file.write("latex pid "+str(pid)+"\n")
    stack = deque([])
    while True:
        try:
            if sys.version_info >= (2, 7):
                out = child.stdout.read(1).decode(errors="replace")
            else:
                # XXX: set the encoding in a better way. 
                # we could check what is the encoding of the log file.
                out = child.stdout.read(1).decode(sys.getdefaultencoding(), "replace")
        except UnicodeDecodeError:
            debug_file.write("UNICODE DECODE ERROR:\n")
            if sys.version_info >= (2, 7):
                debug_file.write(child.stdout.read(1).encode(errors="ignore"))
            else:
                debug_file.write(child.stdout.read(1).encode(sys.getdefaultencoding(), "ignore"))
            debug_file.write("\n")
            debug_file.write("stack="+''.join(stack)+"\n")
            out = ""
        if out == '' and child.poll() != None:
            break
        if out != '':
            stack.append(out)
            if len(stack)>10:
                stack.popleft()
            match = re.match('\[(\n?\d(\n|\d)*)({|\])',''.join(stack))
            if match:
                if options.callback:
                    vim_remote_expr(servername, "atplib#callback#ProgressBar("+match.group(1)[match.start():match.end()]+","+str(pid)+","+str(bufnr)+")")
                else:
                    write_pbf(match.group(1)[match.start():match.end()])
    child.wait()
    vim_remote_expr(servername, "atplib#callback#ProgressBar('end',"+str(pid)+","+str(bufnr)+")")
    vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_LatexPIDs\")")
    if not options.callback:
        try:
            with open(pb_fname, 'w') as fobj:
                pass
        except IOError as ioerror:
            debug_file.write("latex_progress_bar at line %d : %s" % (sys.exc_info()[2].tb_lineno, str(ioerror)))
            pass
    return child

def xpdf_server_file_dict():
    # Make dictionary of the type { xpdf_servername : [ file, xpdf_pid ] },

    # to test if the server host file use:
    # basename(xpdf_server_file_dict().get(server, ['_no_file_'])[0]) == basename(file)
    # this dictionary always contains the full path (Linux).
    # TODO: this is not working as I want to:
    #    when the xpdf was opened first without a file it is not visible in the command line
    #    I can use 'xpdf -remote <server> -exec "run('echo %f')"'
    #    where get_filename is a simple program which returns the filename. 
    #    Then if the file matches I can just reload, if not I can use:
    #          xpdf -remote <server> -exec "openFile(file)"
    ps_list=psutil.get_pid_list()
    server_file_dict={}
    for pr in ps_list:
        try:
            name=psutil.Process(pr).name
            cmdline=psutil.Process(pr).cmdline
            if name == 'xpdf':
                try:
                    ind=cmdline.index('-remote')
                except:
                    ind=0
                if ind != 0 and len(cmdline) >= 1:
                    server_file_dict[cmdline[ind+1]]=[cmdline[len(cmdline)-1], pr]
        except psutil.error.NoSuchProcess:
            pass
        except psutil.error.AccessDenied:
            pass
    return server_file_dict

def vim_remote_expr(servername, expr):
    """Send <expr> to vim server,

    expr must be well quoted:
          vim_remote_expr('GVIM', "atplib#callback#TexReturnCode()")"""
    if not options.callback:
        return
    cmd=[progname, '--servername', servername, '--remote-expr', expr]
    child = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE).wait()


####################################
#
#       Arguments:   
#
####################################

# If mainfile_fp is not a full path make it. 
glob=glob.glob(os.path.join(os.getcwd(),mainfile_fp))
if len(glob) != 0:
    mainfile_fp = glob[0]
mainfile        = os.path.basename(mainfile_fp)
mainfile_dir    = os.path.dirname(mainfile_fp)
if mainfile_dir == "":
    mainfile_fp = os.path.join(os.getcwd(), mainfile)
    mainfile    = os.path.basename(mainfile_fp)
    mainfile_dir= os.path.dirname(mainfile_fp)
if options.tempdir == "":
    options.tempdir = os.path.join(mainfile_dir,".tmp")
if os.path.islink(mainfile_fp):
    if readlink:
        mainfile_fp = os.readlink(mainfile_fp)
    # The above line works if the symlink was created with full path. 
    mainfile    = os.path.basename(mainfile_fp)
    mainfile_dir= os.path.dirname(mainfile_fp)

mainfile_dir    = os.path.normcase(mainfile_dir)
[basename, ext] = os.path.splitext(mainfile)
output_fp       = os.path.join(options.output_dir,basename+extension)

try:
    # Send pid to ATP:
    if verbose != "verbose":
        vim_remote_expr(servername, "atplib#callback#PythonPID("+str(os.getpid())+")")
    ####################################
    #
    #       Make temporary directory,
    #       Copy files and Set Environment:
    #
    ####################################
    cwd     = os.getcwd()
    if not os.path.exists(options.tempdir):
        # This is the main tmp dir (./.tmp) 
        # it will not be deleted by this script
        # as another instance might be using it.
        # it is removed by Vim on exit.
        os.mkdir(options.tempdir)
    tmpdir  = tempfile.mkdtemp(dir=options.tempdir,prefix="")
    debug_file.write("TMPDIR: "+tmpdir+"\n")
    tmpaux  = os.path.join(tmpdir,basename+".aux")
    dirs = filter(lambda d: os.path.isdir(d), os.listdir(os.path.dirname(mainfile_fp)))
    dirs = map(lambda d: os.path.basename(d),dirs)
    for d in dirs:
        os.mkdir(os.path.join(tmpdir, d))

    command_opt.append('-output-directory='+tmpdir)
    latex_cmd      = [command]+command_opt+[mainfile_fp]
    debug_file.write("COMMAND "+str(latex_cmd)+"\n")
    debug_file.write("COMMAND "+" ".join(latex_cmd)+"\n")

    # Copy important files to output directory:
    # /except the log file/
    # os.chdir(mainfile_dir)
    os.chdir(options.output_dir)
    for ext in filter(lambda x: x != "log", keep):
        file_cp=basename+"."+ext
        if os.path.exists(file_cp):
            shutil.copy(file_cp, tmpdir)
    os.chdir(mainfile_dir)

    tempdir_list = os.listdir(tmpdir)
    debug_file.write("\nls tmpdir "+str(tempdir_list)+"\n")

    # Set environment
    for var in env:
        debug_file.write("ENV "+var[0]+"="+var[1]+"\n")
        os.putenv(var[0], var[1])

    # Link local bibliographies:
    for bib in bibliographies:
        if os.path.exists(os.path.join(mainfile_dir,os.path.basename(bib))):
            if hasattr(os, 'symlink'):
                os.symlink(os.path.join(mainfile_dir,os.path.basename(bib)),os.path.join(tmpdir,os.path.basename(bib)))
            else:
                shutil.copyfile(os.path.join(mainfile_dir,os.path.basename(bib)),os.path.join(tmpdir,os.path.basename(bib)))

    ####################################
    #
    #       Compile:   
    #
    ####################################
    # Start Xpdf (this can be done before compelation, because we can load file
    # into afterwards) in this way Xpdf starts faster (it is already running when
    # file compiles). 
    # TODO: this might cause problems when the tex file is very simple and short.
    # Can we test if xpdf started properly?  okular doesn't behave nicely even with
    # --unique switch.

    # Latex might not run this might happen with bibtex (?)
    latex_returncode=0
    if bibtex and os.path.exists(tmpaux):
        if bibcommand == 'biber':
            bibfname = basename
        else:
            bibfname = basename+".aux"
        debug_file.write("\nBIBTEX1"+str([bibcommand, bibfname])+"\n")
        os.chdir(tmpdir)
        bibtex_popen=subprocess.Popen([bibcommand, bibfname], stdout=subprocess.PIPE)
        vim_remote_expr(servername, "atplib#callback#BibtexPID('"+str(bibtex_popen.pid)+"')")
        vim_remote_expr(servername, "atplib#callback#redrawstatus()")
        bibtex_popen.wait()
        vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_BibtexPIDs\")")
        os.chdir(mainfile_dir)
        bibtex_returncode=bibtex_popen.returncode
        bibtex_output=re.sub('"', '\\"', bibtex_popen.stdout.read())
        debug_file.write("BIBTEX RET CODE "+str(bibtex_returncode)+"\nBIBTEX OUTPUT\n"+bibtex_output+"\n")
        if verbose != 'verbose':
            vim_remote_expr(servername, "atplib#callback#BibtexReturnCode('"+str(bibtex_returncode)+"',\""+str(bibtex_output)+"\")")
        else:
            print(bibtex_output)
        # We need run latex at least 2 times
        bibtex=False
        runs=max([runs, 2])
    elif bibtex:
        # we need run latex at least 3 times
        runs=max([runs, 3])

    debug_file.write("\nRANGE="+str(range(1,int(runs+1)))+"\n")
    debug_file.write("RUNS="+str(runs)+"\n")
    for i in range(1, int(runs+1)):
        debug_file.write("RUN="+str(i)+"\n")
        debug_file.write("DIR="+str(os.getcwd())+"\n")
        tempdir_list = os.listdir(tmpdir)
        debug_file.write("ls tmpdir "+str(tempdir_list)+"\n")
        debug_file.write("BIBTEX="+str(bibtex)+"\n")

        if verbose == 'verbose' and i == runs:
            debug_file.write("VERBOSE"+"\n")
            latex=subprocess.Popen(latex_cmd)
            pid=latex.pid
            debug_file.write("latex pid "+str(pid)+"\n")
            latex.wait()
            latex_returncode=latex.returncode
            debug_file.write("latex ret code "+str(latex_returncode)+"\n")
        else:
            if progress_bar and verbose != 'verbose':
                latex=latex_progress_bar(latex_cmd)
            else:
                latex = subprocess.Popen(latex_cmd, stdout=subprocess.PIPE)
                pid   = latex.pid
                vim_remote_expr(servername, "atplib#callback#LatexPID("+str(pid)+")")
                debug_file.write("latex pid "+str(pid)+"\n")
                latex.wait()
                vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_LatexPIDs\")")
            latex_returncode=latex.returncode
            debug_file.write("latex return code "+str(latex_returncode)+"\n")
            tempdir_list = os.listdir(tmpdir)
            debug_file.write("JUST AFTER LATEX ls tmpdir ("+str(tmpdir)+") "+str(tempdir_list)+"\n")
        # Return code of compilation:
        if verbose != "verbose":
            vim_remote_expr(servername, "atplib#callback#TexReturnCode('"+str(latex_returncode)+"')")
        if bibtex and i == 1:
            if bibcommand == 'biber':
                bibfname = basename
            else:
                bibfname = basename+".aux"
            debug_file.write("BIBTEX2 "+str([bibcommand, bibfname])+"\n")
            debug_file.write(os.getcwd()+"\n")
            tempdir_list = os.listdir(tmpdir)
            debug_file.write("ls tmpdir "+str(tempdir_list)+"\n")
            os.chdir(tmpdir)
            bibtex_popen=subprocess.Popen([bibcommand, bibfname], stdout=subprocess.PIPE)
            vim_remote_expr(servername, "atplib#callback#BibtexPID('"+str(bibtex_popen.pid)+"')")
            vim_remote_expr(servername, "atplib#callback#redrawstatus()")
            bibtex_popen.wait()
            vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_BibtexPIDs\")")
            os.chdir(mainfile_dir)
            bibtex_returncode=bibtex_popen.returncode
            bibtex_output=re.sub('"', '\\"', bibtex_popen.stdout.read())
            debug_file.write("BIBTEX2 RET CODE"+str(bibtex_returncode)+"\n")
            if verbose != 'verbose':
                vim_remote_expr(servername, "atplib#callback#BibtexReturnCode('"+str(bibtex_returncode)+"',\""+str(bibtex_output)+"\")")
            else:
                print(bibtex_output)

    ####################################
    #
    #       Copy Files:
    #
    ####################################

    # Copy files:
    os.chdir(tmpdir)
    for ext in list(filter(lambda x: x != 'aux', keep))+[output_format]:
        file_cp=basename+"."+ext
        if os.path.exists(file_cp):
            debug_file.write(file_cp+' \n')
            shutil.copy(file_cp, options.output_dir)

    # Copy aux file if there were no compilation errors or if it doesn't exists in mainfile_dir.
    # copy aux file to _aux file (for atplib#tools#GrepAuxFile)
    if latex_returncode == 0 or not os.path.exists(os.path.join(mainfile_dir, basename+".aux")):
        file_cp=basename+".aux"
        if os.path.exists(file_cp):
            shutil.copy(file_cp, options.output_dir)
    file_cp=basename+".aux"
    if os.path.exists(file_cp):
        shutil.copy(file_cp, os.path.join(options.output_dir, basename+"._aux"))
    os.chdir(cwd)

    ####################################
    #
    #       Call Back Communication:   
    #
    ####################################
    if verbose != "verbose":
        debug_file.write("CALL BACK "+"atplib#callback#CallBack('"+str(bufnr)+"','"+str(verbose)+"','"+aucommand+"','"+str(options.bibtex)+"')"+"\n")
        vim_remote_expr(servername, "atplib#callback#CallBack('"+str(bufnr)+"','"+str(verbose)+"','"+aucommand+"','"+str(options.bibtex)+"')")
        # return code of compelation is returned before (after each compilation).


    ####################################
    #
    #       Reload/Start Viewer:   
    #
    ####################################
    if re.search(viewer, '^\s*xpdf\e') and reload_viewer:
        # The condition tests if the server XpdfServer is running
        xpdf_server_dict=xpdf_server_file_dict()
        cond = xpdf_server_dict.get(XpdfServer, ['_no_file_']) != ['_no_file_']
        debug_file.write("XPDF SERVER DICT="+str(xpdf_server_dict)+"\n")
        debug_file.write("COND="+str(cond)+":"+str(reload_on_error)+":"+str(bang)+"\n")
        debug_file.write("COND="+str( not reload_on_error or bang )+"\n")
        debug_file.write(str(xpdf_server_dict)+"\n")
        if start == 1:
            run=['xpdf']
            run.extend(viewer_opt)
            run.append(output_fp)
            debug_file.write("D1: "+str(run)+"\n")
            viewer_s=subprocess.Popen(run)
            # We cannot read stderr, since if there is no error it will freeze the script.
        elif cond and ( reload_on_error or latex_returncode == 0 or bang ):
            run=['xpdf', '-remote', XpdfServer, '-reload']
            viewer_s=subprocess.Popen(run)
            debug_file.write("D2: "+str(['xpdf',  '-remote', XpdfServer, '-reload'])+"\n")
    else:
        if start >= 1:
            run=[viewer]
            run.extend(viewer_opt)
            run.append(output_fp)
            print(run)
            debug_file.write("RUN "+str(run)+"\n")
            subprocess.Popen(run, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if start == 2:
            vim_remote_expr(servername, "atplib#SyncTex()")

    # Rewrite LaTeX log file
    latex_log.rewrite_log(os.path.splitext(output_fp)[0]+".log", check_path=True, project_dir=mainfile_dir, project_tmpdir=tmpdir)

####################################
#
#       Clean:
#
####################################
except Exception:
    latex_returncode = 0
    error_str=re.sub("'", "''",re.sub('"', '\\"', traceback.format_exc()))
    traceback.print_exc(None, debug_file)
    if options.callback:
        vim_remote_expr(servername, "atplib#callback#Echo(\"[ATP:] error in compile.py, catched python exception:\n"+error_str+"[ATP info:] this error message is recorded in compile.py.log under g:atp_TempDir\",'echo','ErrorMsg')")
    else:
        print(error_str)

sys.exit(latex_returncode)
