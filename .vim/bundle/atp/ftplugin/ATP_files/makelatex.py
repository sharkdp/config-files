#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: Marcin Szamotulski
# Date: 23 IV 2011
# This file is a part of AutomaticTexPlugin plugin for Vim.
# It is distributed under General Public Licence v3 or higher.
# 
# Note: this script, in order to work well, needs a high value of
# max_print_line (ATP uses 2000) in order to not break log messages into lines.
# This can be passed using the --env switch. (On the command line it is used in
# this form: max_print_line=2000 latex .... )

# import signal, os
# def handler(signum, frame):


import sys
import os
import os.path
import shutil
import re
import optparse
import subprocess
import traceback
import psutil
import tempfile
import atexit
import locale

encoding = locale.getpreferredencoding()

import latex_log

from optparse import OptionParser
from os import getcwd
from collections import deque

usage   = "usage: %prog [options]"
parser  = OptionParser(usage=usage)

parser.add_option("--texfile",          dest="texfile"                                                  )
parser.add_option("--bufnr",            dest="bufnr"                                                    )
parser.add_option("--cmd",              dest="cmd",             default="pdflatex"                      )
parser.add_option("--output-format",    dest="output_format",   default="pdf"                           )
parser.add_option("--bibcmd",           dest="bibcmd",          default="bibtex"                        )
parser.add_option("--tex-options",      dest="tex_options",     default=""                              )
parser.add_option("--outdir",           dest="outdir"                                                   )
parser.add_option("--logdir",           dest="logdir"                                                   )
parser.add_option("--tempdir",          dest="tempdir",         default=""                              )
parser.add_option("--progname",         dest="progname",        default="gvim"                          )
parser.add_option("--servername",       dest="servername"                                               )
parser.add_option("--viewer",           dest="viewer",          default="xpdf"                          )
parser.add_option("--xpdf-server",      dest="xpdf_server",                                             )
parser.add_option("--viewer-options",   dest="viewer_opt",      default="",                             )
parser.add_option("--start",            dest="start",           default=0,              type="int"      )
parser.add_option("--keep",             dest="keep",            default="aux,toc,bbl,ind,pdfsync,synctex.gz")
parser.add_option("--reload-viewer",    dest="reload_viewer",   default=False,          action="store_true")
parser.add_option("--reload-on-error",  dest="reload_on_error", default=False,          action="store_true")
parser.add_option("--bibliographies",   dest="bibliographies",  default="",                             )
parser.add_option("--verbose",          dest="verbose",         default="silent"                        )
parser.add_option("--no-callback",      dest="callback",        default=True,           action="store_false")
# This is not yet used:
parser.add_option("--force",            dest="force",           default=False,          action="store_true")
parser.add_option("--env",              dest="env",             default=""                              )


(options, args) = parser.parse_args()

debugfile=os.path.join(options.logdir, "makelatex.log")
debug_file=open(debugfile, "w")

texfile = options.texfile
bufnr   = options.bufnr
basename = os.path.splitext(os.path.basename(texfile))[0]
texfile_dir = os.path.dirname(texfile)
debug_file.write("texfile_dir='%s'\n" % texfile_dir)
if options.tempdir == "":
    options.tempdir = os.path.join(texfile_dir,".tmp")
logfile = basename+".log"
debug_file.write("logfile='%s'\n" % logfile)
auxfile = basename+".aux"
bibfile = basename+".bbl"
idxfile = basename+".idx"
indfile = basename+".ind"
tocfile = basename+".toc"
loffile = basename+".lof"
lotfile = basename+".lot"
thmfile = basename+".thm"

if not os.path.exists(options.tempdir):
        # This is the main tmp dir (./.tmp) 
        # it will not be deleted by this script
        # as another instance might be using it.
        # it is removed by Vim on exit.
    os.mkdir(options.tempdir)
tmpdir  = tempfile.mkdtemp(dir=options.tempdir,prefix="")

# List of pids runing.
pids    = []
# Cleanup on exit:
def cleanup(debug_file):
    debug_file.close()
    shutil.rmtree(tmpdir)
atexit.register(cleanup, debug_file)

# FILTER:
nonempty = lambda x: (re.match('\s*$', x) is None)

servername      = options.servername
debug_file.write("SERVERNAME="+servername+"\n")
progname        = options.progname
debug_file.write("PROGNAME="+progname+"\n")
cmd		= options.cmd
debug_file.write("CMD="+cmd+"\n")
tex_options	= options.tex_options
debug_file.write("TEX_OPTIONS="+tex_options+"\n")
output_format   = options.output_format
if output_format == "pdf":
    output_ext = ".pdf"
else:
    output_ext = ".dvi"
output_fp       = os.path.join(texfile_dir,basename+output_ext)
debug_file.write("OUTPUT_FORMAT="+output_format+"\n")
bibcmd		= options.bibcmd
debug_file.write("BIBCMD="+bibcmd+"\n")
biber=False
if re.search(bibcmd, '^\s*biber'):
    biber=True
debug_file.write("BIBER="+str(biber)+"\n")
bibliographies  = options.bibliographies.split(",")
bibliographies  = list(filter(nonempty, bibliographies))

tex_options     = list(filter(nonempty,re.split('\s*,\s*',options.tex_options)))
debug_file.write("TEX_OPTIONS_LIST="+str(tex_options)+"\n")

outdir		= os.path.abspath(options.outdir)
debug_file.write("OUTDIR="+outdir+"\n")
force		= options.force
debug_file.write("FORCE="+str(force)+"\n")
start           = options.start
viewer          = options.viewer
XpdfServer      = options.xpdf_server
reload_viewer   = options.reload_viewer
reload_on_error = options.reload_on_error
viewer_rawopt   = re.split('\s*;\s*', options.viewer_opt)
viewer_it       = list(filter(nonempty,viewer_rawopt))
viewer_opt      =[]
for opt in viewer_it:
    viewer_opt.append(opt)
viewer_rawopt   = viewer_opt
if viewer == "xpdf" and XpdfServer != None:
    viewer_opt.extend(["-remote", XpdfServer])
keep            = options.keep.split(',')
keep            = list(filter(nonempty, keep))
debug_file.write("KEEP="+str(keep)+"\n")

if len(options.env)>0:
    env = list(map(lambda x: re.split('\s*=\s*', x), list(filter(nonempty, re.split('\s*;\s*',options.env)))))
else:
    env = []


# RUN NUMBER
run   = 0
# BOUND (do not run pdflatex more than this) 
# echoerr in Vim if bound is reached.
bound = 6

# FUNCTIONS
def vim_remote_expr(servername, expr):
    """Send <expr> to vim server,

    expr must be well quoted:
          vim_remote_expr('GVIM', "atplib#CatchStatus()")
    (this is the only way it works)
        print("VIM_REMOTE_EXPR "+str(expr))"""
    if not options.callback:
        return
    cmd=[progname, '--servername', servername, '--remote-expr', expr]
    try:
        with open(os.devnull, "w+") as fsock:
            subprocess.Popen(cmd, stdout=fsock, stderr=subprocess.STDOUT).wait()
    except IOError:
        print("IOError: cannot open os.devnull")
        sys.exit(1)

def latex_progress_bar(cmd):
    """Run latex and send data for progress bar,"""

    debug_file.write("RUN %s\n  CMD %s\n  CDIR %s\n" % (run, cmd, os.path.abspath(os.curdir)))

    child = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    pid   = child.pid
    pids.append(pid)

    vim_remote_expr(servername, "atplib#callback#LatexPID("+str(pid)+")")
    stack = deque([])
    while True:
        try:
            out = child.stdout.read(1).decode(errors="replace")
        except UnicodeDecodeError:
            debug_file.write("UNICODE DECODE ERROR:\n")
            debug_file.write(child.stdout.read(1).encode(errors="ignore"))
            debug_file.write("\n")
            out = ""
        if out == '' and child.poll() != None:
            break
        if out != '':
            stack.append(out)

            if len(stack)>10:
                stack.popleft()
            match = re.match('\[(\n?\d(\n|\d)*)({|\])',''.join(stack))
            if match:
                vim_remote_expr(servername, "atplib#callback#ProgressBar("+match.group(1)[match.start():match.end()]+","+str(pid)+","+str(bufnr)+")")
    child.wait()
    vim_remote_expr(servername, "atplib#callback#ProgressBar('end',"+str(pid)+","+str(bufnr)+")")
    vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_LatexPIDs\")")
    return child

def xpdf_server_file_dict():
    """Make dictionary of the type { xpdf_servername : [ file, xpdf_pid ] },

    to test if the server host file use:
    basename(xpdf_server_file_dict().get(server, ['_no_file_'])[0]) == basename(file)
    this dictionary always contains the full path (Linux).
    TODO: this is not working as I want to:
       when the xpdf was opened first without a file it is not visible in the command line
       I can use 'xpdf -remote <server> -exec "run('echo %f')"'
       where get_filename is a simple program which returns the filename. 
       Then if the file matches I can just reload, if not I can use:
             xpdf -remote <server> -exec "openFile(file)"
     """
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

def reload_xpdf():
    """Reload xpdf if asked,"""

    if re.search(viewer, '^\s*xpdf\e') and reload_viewer:
        cond=xpdf_server_file_dict().get(XpdfServer, ['_no_file_']) != ['_no_file_']
        if cond and ( reload_on_error or latex.returncode == 0 or bang ):
            debug_file.write("reloading Xpdf\n")
            cmd=['xpdf', '-remote', XpdfServer, '-reload']
            with open(os.devnull, "w+") as devnull:
                subprocess.Popen(cmd, stdout=devnull, stderr=subprocess.STDOUT)

def copy_back_output(tmpdir):
    """Copy pdf(dvi) and (aux) files back to working directory,

    aux file is copied also to _aux file used by ATP."""
    os.chdir(tmpdir)
    if os.path.exists(basename+output_ext):
        shutil.copy(basename+output_ext, outdir)
    if os.path.exists(basename+".aux"):
        shutil.copy(basename+".aux", outdir)
        shutil.copy(basename+".aux", os.path.join(outdir, basename+"._aux"))
    os.chdir(texfile_dir)

def copy_back(tmpdir, latex_returncode):

    os.chdir(tmpdir)
    if not latex_returncode or not os.path.exists(os.path.join(texfile_dir, auxfile)):
        ext_list=list(keep)
    else:
        ext_list=list(filter(lambda x: x != 'aux', keep))
    for ext in ext_list:
        file_cp=basename+"."+ext
        if os.path.exists(file_cp):
            shutil.copy(file_cp, outdir)
    os.chdir(texfile_dir)

try:
    # Send pid to ATP:
    vim_remote_expr(servername, "atplib#callback#PythonPID("+str(os.getpid())+")")

    # Note always run first time.
    # this ensures that the aux, ... files are uptodate.

    # COPY FILES TO TEMP DIR
    debug_file.write("TMPDIR="+tmpdir+"\n")
    tmplog  = os.path.join(tmpdir,basename+".log")
    debug_file.write("TMPLOG="+tmplog+"\n")
    tmpaux  = os.path.join(tmpdir,basename+".aux")
    dirs = filter(lambda d: os.path.isdir(d), os.listdir(texfile_dir))
    dirs = map(lambda d: os.path.basename(d),dirs)
    for d in dirs:
        os.mkdir(os.path.join(tmpdir, d))

    cdir = os.curdir
    os.chdir(outdir)
    for ext in filter(lambda x: x != 'log', keep):
        file_cp=basename+"."+ext
        if os.path.exists(file_cp):
            shutil.copy(file_cp, tmpdir)
    os.chdir(texfile_dir)

    debug_file.write("bibliographies = %s\n" % bibliographies)
    for bib in bibliographies:
        if os.path.exists(os.path.join(outdir,os.path.basename(bib))):
            if hasattr(os, 'symlink'):
                os.symlink(os.path.join(outdir,os.path.basename(bib)),os.path.join(tmpdir,os.path.basename(bib)))
            else:
                shutil.copyfile(os.path.join(outdir,os.path.basename(bib)),os.path.join(tmpdir,os.path.basename(bib)))
        elif os.path.exists(os.path.join(texfile_dir,os.path.basename(bib))):
            if hasattr(os, 'symlink'):
                os.symlink(os.path.join(texfile_dir,os.path.basename(bib)),os.path.join(tmpdir,os.path.basename(bib)))
            else:
                shutil.copyfile(os.path.join(texfile_dir,os.path.basename(bib)),os.path.join(tmpdir,os.path.basename(bib)))

    debug_file.write("TMPDIR contains: %s\n" % os.listdir(tmpdir))
    # SET ENVIRONMENT
    for var in env:
        os.putenv(var[0], var[1])

    # SOME VARIABLES
    did_bibtex      = False
    did_makeidx     = False

    # WE RUN FOR THE FIRST TIME:
    # Set Environment:
    if len(env) > 0:
        for var in env:
            os.putenv(var[0], var[1])

    output_exists=os.path.exists(os.path.join(texfile_dir,basename+output_ext))
    debug_file.write("OUTPUT_EXISTS="+str(output_exists)+":"+os.path.join(texfile_dir,basename+output_ext)+"\n")
    latex=latex_progress_bar([cmd, '-interaction=nonstopmode', '-output-directory='+tmpdir]+tex_options+[texfile])
    run  += 1
    latex.wait()
    vim_remote_expr(servername, "atplib#callback#TexReturnCode('"+str(latex.returncode)+"')")
    os.chdir(tmpdir)
    if not output_exists:
        copy_back_output(tmpdir)
        reload_xpdf()

    # AFTER FIRST TIME LOG FILE SHOULD EXISTS:
    if os.path.isfile(tmplog):

        need_runs = [0]

        if sys.version_info.major < 3:
            with open(tmplog, "r") as log_file:
                log = log_file.read().decode(encoding, errors='replace')
        else:
            with open(tmplog, "r", enconding=encoding, errors="replace") as log_file:
                log = log_file.read()
        log_list=re.findall('(undefined references)|(Citations undefined)|(There were undefined citations)|(Label\(s\) may have changed)|(Writing index file)|(run Biber on the file)',log)
        citations       =False
        labels          =False
        makeidx         =False
        for el in log_list:
            if el[0] != '' or el[1] != '' or el[2] != '':
                citations       =True
                if biber:
                    need_runs.append(1)
                else:
                    # Bibtex:
                    need_runs.append(2)
            if el[3] != '':
                labels          =True
            if el[4] != '':
                makeidx         =True
                need_runs.append(1)

        debug_file.write("citations="+str(citations)+"\n")
        debug_file.write("labels="+str(labels)+"\n")
        debug_file.write("makeidx="+str(makeidx)+"\n")

        # Scan for openout files to know if we are makeing: toc, lot, lof, thm
        openout_list=re.findall("\\\\openout\d+\s*=\s*`\"?([^'\"]*)\"?'",log)
        toc     =False
        lot     =False
        lof     =False
        thm     =False
        loa     =False
        for el in openout_list:
            if re.search('\.toc$',el):
                toc=True
                need_runs.append(1)
                # We need only one more run, because of the 0-run.
            if re.search('\.lof$',el):
                lof=True
                need_runs.append(1)
            if re.search('\.lot$',el):
                lot=True
                need_runs.append(1)
            if re.search('\.thm$',el):
                thm=True
                need_runs.append(1)
            if re.search('\.loa',el):
                loa=True
                need_runs.append(1)

        debug_file.write("A0 need_runs="+str(need_runs)+"\n")

        # Aux file should be readable (we always run for the first time)
        #     auxfile_readable = os.path.isfile(auxfile)
        idxfile_readable = os.path.isfile(idxfile)
        tocfile_readable = os.path.isfile(tocfile)
        loffile_readable = os.path.isfile(loffile)
        lotfile_readable = os.path.isfile(lotfile)
        thmfile_readable = os.path.isfile(thmfile)

        debug_file.write("AUXFILE: %s\n" % tmpaux)
        try:
            if sys.version_info.major < 3:
                with open(tmpaux, "r") as aux_file:
                    aux=aux_file.read().decode(encoding, errors="replace")
            else:
                with open(tmpaux, "r", encondig=encoding, errors="replace") as aux_file:
                    aux=aux_file.read()
        except IOError:
            aux=""
        bibtex=re.search(r'\\bibdata\s*{', aux)
        # This can be used to make it faster and use the old bbl file.
        # For this I have add a switch (bang).
        #         bibtex=re.search('No file '+basename+'\.bbl\.', log)
        if not bibtex:
            # Then search for biblatex package. Alternatively, I can search for biblatex messages in log file.
            if sys.version_info.major < 3:
                with open(texfile, 'r') as sock:
                    tex_lines = sock.read().decode(encoding=encoding, errors="replace").split("\n")
            else:
                with open(texfile, 'r', encoding=encoding, errors="replace") as sock:
                    tex_lines = sock.read().split("\n")
            for line in tex_lines:
                if re.match(r'[^%]*\\usepackage\s*(\[[^]]*\])?\s*{(\w\|,)*biblatex',line):
                    bibtex=True
                    break
                elif re.search(r'\\begin\s*{\s*document\s*}',line):
                    break
        debug_file.write("BIBTEX="+str(bibtex)+"\n")

        # I have to take the second condtion (this is the first one):
        condition = citations or labels or makeidx or run <= max(need_runs)
        debug_file.write(str(run)+"condition="+str(condition)+"\n")

        # HERE IS THE MAIN LOOP:
        # I guess some of the code done above have to be put inside the loop.
        # Maybe it would be nice to make functions from some parts of the code.
        while condition:
            if run == 1:
                # BIBTEX
                if bibtex:
                    bibtex      = False
                    did_bibtex  = True
                    os.chdir(tmpdir)
                    if re.search(bibcmd, '^\s*biber'):
                        auxfile = basename
                    bibtex=subprocess.Popen([bibcmd, auxfile], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                    vim_remote_expr(servername, "atplib#callback#BibtexPID('"+str(bibtex.pid)+"')")
                    vim_remote_expr(servername, "atplib#callback#redrawstatus()")
                    pids.append(bibtex.pid)
                    bibtex.wait()
                    vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_BibtexPIDs\")")
                    bibtex_output=re.sub('"', '\\"', bibtex.stdout.read().decode())
                    bibtex_returncode=bibtex.returncode
                    vim_remote_expr(servername, "atplib#callback#BibtexReturnCode('"+str(bibtex_returncode)+"',\""+str(bibtex_output)+"\")")
                    os.chdir(texfile_dir)
                # MAKEINDEX
                if makeidx:
                    makeidx=False
                    did_makeidx=True
                    os.chdir(tmpdir)
                    index=subprocess.Popen(['makeindex', idxfile], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                    vim_remote_expr(servername, "atplib#callback#MakeindexPID('"+str(index.pid)+"')")
                    vim_remote_expr(servername, "atplib#callback#redrawstatus()")
                    pids.append(index.pid)
                    index.wait()
                    vim_remote_expr(servername, "atplib#callback#PIDsRunning(\"b:atp_MakeindexPIDs\")")
                    makeidx_output=re.sub('"', '\\"', index.stdout.read().decode())
                    index_returncode=index.returncode
                    vim_remote_expr(servername, "atplib#callback#MakeidxReturnCode('"+str(index_returncode)+"',\""+str(makeidx_output)+"\")")
                    os.chdir(texfile_dir)

            # LATEX
            os.chdir(texfile_dir)
            latex=latex_progress_bar([cmd, '-interaction=nonstopmode', '-output-directory='+tmpdir]+tex_options+[texfile])
            run  += 1
            latex.wait()
            vim_remote_expr(servername, "atplib#CatchStatus('"+str(latex.returncode)+"')")
            copy_back_output(tmpdir)
            reload_xpdf()

            #CONDITION
            try:
                if sys.version_info.major < 3:
                    with open(tmplog, "r") as sock:
                        log=sock.read().decode(encoding, errors='replace')
                else:
                    with open(tmplog, "r", errors="replace") as sock:
                        log=sock.read()
            except IOError:
                log=""

            # Citations undefined|Label(s) may have changed
            log_list=re.findall('(undefined references)|(Citations undefined)|(Label\(s\) may have changed)',log)
            citations       =False
            labels          =False
            for el in log_list:
                if el[0] != '' or el[1] != '':
                    citations       =True
                if el[2] != '':
                    labels          =True
            debug_file.write(str(run)+"citations="+str(citations)+"\n")
            debug_file.write(str(run)+"labels="+str(labels)+"\n")
            debug_file.write(str(run)+"makeidx="+str(makeidx)+"\n")

            debug_file.write(str(run)+"need_runs="+str(need_runs)+"\n")

            condition = ( (citations and run <= max(need_runs)) or labels or makeidx or run <= max(need_runs) ) and run <= bound
            debug_file.write(str(run)+"condition="+str(condition)+"\n")

    # Start viewer: (reloading xpdf is done after each compelation) 
    if re.search(viewer, '^\s*xpdf\e') and reload_viewer:
        # The condition tests if the server XpdfServer is running
        xpdf_server_dict=xpdf_server_file_dict()
        cond = xpdf_server_dict.get(XpdfServer, ['_no_file_']) != ['_no_file_']
        if start == 1:
            debug_file.write("Starting Xpdf\n")
            run=['xpdf']
            run.extend(viewer_opt)
            run.append(output_fp)
            subprocess.Popen(run)
    else:
        if start >= 1:
            debug_file.write("Starting "+str(viewer))
            run=[viewer]
            run.extend(viewer_opt)
            run.append(output_fp)
            with open(os.devnull, "w+") as devnull:
                subprocess.Popen(run, stdout=devnull, stderr=subprocess.STDOUT)
        if start == 2:
            debug_file.write("SyncTex with "+str(viewer))
            vim_remote_expr(servername, "atplib#SyncTex()")
    copy_back(tmpdir, latex.returncode)
except Exception:
    error_str=re.sub("'", "''",re.sub('"', '\\"', traceback.format_exc()))
    traceback.print_exc(None, debug_file)
    vim_remote_expr(servername, "atplib#callback#Echo(\"[ATP:] error in makelatex.py, catched python exception:\n"+error_str+"[ATP info:] this error message is recorded in makelatex.log under g:atp_TempDir\",'echo','ErrorMsg')")

# Rewrite the LaTeX log file.
latex_log.rewrite_log(os.path.join(outdir,logfile), check_path=True, project_dir=texfile_dir, project_tmpdir=tmpdir)

debug_file.write("PIDS="+str(pids))
vim_remote_expr(servername, "atplib#callback#Echo('[ATP:] MakeLatex finished.', 'echomsg', 'Normal')")
if did_bibtex and bibtex_returncode != 0:
    vim_remote_expr(servername, "atplib#callback#Echo('[MakeLatex:] bibtex returncode "+str(bibtex_returncode)+".', 'echo', 'Normal')")
if did_makeidx and index_returncode != 0:
    vim_remote_expr(servername, "atplib#callback#Echo('[MakeLatex:] makeidx returncode "+str(index_returncode)+".', 'echo', 'Normal')")
vim_remote_expr(servername, "atplib#callback#CallBack('"+str(bufnr)+"','"+str(options.verbose)+"','COM','"+str(did_bibtex)+"','"+str(did_makeidx)+"')")
sys.exit(latex.returncode)
