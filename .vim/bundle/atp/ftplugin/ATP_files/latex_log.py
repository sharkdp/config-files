#!/usr/bin/python
# -*- coding: utf-8 -*-

# Usage: latex_log.py {tex_log_file}
# Produces a "._log" file.

# Author: Marcin Szamotulski
# http://atp-vim.sourceforge.net
#
# Copyright Statement: 
#     This file is a part of Automatic Tex Plugin for Vim.
#
#     Automatic Tex Plugin for Vim is free software: you can redistribute it
#     and/or modify it under the terms of the GNU General Public License as
#     published by the Free Software Foundation, either version 3 of the
#     License, or (at your option) any later version.
# 
#     Automatic Tex Plugin for Vim is distributed in the hope that it will be
#     useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License along
#     with Automatic Tex Plugin for Vim.  If not, see <http://www.gnu.org/licenses/>.

# INFO: 
# This is a python script which reads latex log file (which path is gven as
# the only argument) and it writes back a log messages which are in the
# following format:
# WARNING_TYPE::FILE::INPUT_LINE::INPUT_COL::MESSAGE (ADDITIONAL_INFO)
# this was intendent to be used for vim quick fix:
# setl errorformat=LaTeX\ %tarning::%f::%l::%c::%m,Citation\ %tarning::%f::%l::%c::%m,Reference\ %tarning::%f::%l::%c::%m,Package\ %tarning::%f::%l::%c::%m,hbox\ %tarning::%f::%l::%c::%m,LaTeX\ %tnfo::%f::%l::%c::%m,LaTeX\ %trror::%f::%l::%c::%m
#
# The fowllowing WARNING_TYPEs are available:
# LaTeX Warning
# Citation Warning
# Reference Warning
# Package Warning
# hbox Warning                  : Overfull and Underfull hbox warnings
# LaTeX Font Warning
# LaTeX Font Info
# LaTeX Info
# LaTeX Error
# Input File
# Input Package                 : includes packges and document class

# Note: when FILE,INPUT_LINE,INPUT_COL doesn't exists 0 is put.

# It will work well when the tex file was compiled with a big value of 
# max_print_line (for example with `max_print_line=2000 latex file.tex')
# so that latex messages are not broken into lines.

# The scripts assumes the default encoding to be utf-8. Though you will not see
# errors since decode(errors='replace') is used, that is bytes not recognized
# will be substituted with '?'.

import sys, re, os, os.path, fnmatch
from optparse import OptionParser

__all__ = [ 'rewrite_log' ]

class Dict(dict):
    """ 2to3 Python transition. """
    def iterkeys(self):
        if sys.version_info < (3,0):
            return super(type(self), self).iterkeys()
        else:
            return self.keys()

    def iteritems(self):
        if sys.version_info < (3,0):
            return super(type(self), self).iteritems()
        else:
            return self.items()

    def itervalues(self):
        if sys.version_info < (3,0):
            return super(type(self), self).itervalues()
        else:
            return self.values()

def shift_dict( dictionary, nr ):
    '''
    Add nr to every value of dictionary.
    '''
    for key in dictionary.iterkeys():
        dictionary[key]+=nr
    return dictionary

if sys.platform.startswith('linux'):
    log_to_path = "/tmp/latex_log.log"
else:
    log_to_path = None

def rewrite_log(input_fname, output_fname=None, check_path=False, project_dir="", project_tmpdir="", encoding="utf8"):
    """This function rewrites LaTeX log file (input_fname) to output_fname,
    changeing its format to something readable by Vim.
    check_path -- ATP process files in a temporary directory, with this
    option the files under project_tmpdir will be written using project_dir
    (this is for the aux file).
    """

    if output_fname is None:
        output_fname = os.path.splitext(input_fname)[0]+"._log"

    output_dir = os.path.dirname(output_fname)

    try:
        if sys.version_info < (3, 0):
            log_file = open(input_fname, 'r')
        else:
            # We are assuming the default encoding (utf-8)
            log_file = open(input_fname, 'r', errors='replace')
    except IOError:
        print("IOError: cannot open %s file for reading" % input_fname)
        sys.exit(1)
    else:
        log_stream = log_file.read().decode(encoding, 'ignore')
        log_file.close()
    # Todo: In python3 there is UnicodeDecodeError. I should remove all the
    # bytes where python cannot decode the character.

    dir = os.path.dirname(os.path.abspath(input_fname))
    os.chdir(dir)

    # Filter the log_stream: remove all unbalanced brackets (:)
    # some times the log file contains unbalanced brackets!
    # This removes all the lines after 'Overfull \hbox' message until first non
    # empty line and all lines just after 'Runaway argument?'.
    log_lines = log_stream.split("\n")
    output_lines = []
    idx = 0
    remove = False
    prev_line = ""
    overfull = False
    runawayarg = False
    for line in log_lines:
        idx+=1
        match_overfull   = re.match(r'(Over|Under)full \\hbox ',line)
        match_runawayarg = re.match('Runaway argument\?',prev_line)
        if match_overfull or match_runawayarg:
            if match_overfull:
                overfull = True
            if match_runawayarg:
                runawayarg = True
            remove = True
        elif re.match('^\s*$', line) and overfull:
            remove = False
            overfull = False
        elif runawayarg:
            remove = False
            runawayarg = False
        if not remove or match_overfull:
            output_lines.append(line)
        prev_line = line
    log_stream='\n'.join(output_lines)
    del output_lines
    output_data = []
    log_lines = log_stream.split("\n")
    global log_to_path
    if log_to_path:
        try:
            log_fo=open(log_to_path, 'w')
        except IOError:
            print("IOError: cannot open %s file for writting" % log_to_path)
        else:
            # log_fo.write(log_stream.encode(encoding, 'ignore'))
            log_fo.write("PROJECT_DIR='%s'\n" % project_dir)
            log_fo.close()

    # File stack
    file_stack = []

    line_nr = 1
    col_nr = 1

    # Message Patterns:
    latex_warning_pat = re.compile('(LaTeX Warning: )')
    latex_warning= "LaTeX Warning"

    font_warning_pat = re.compile('LaTeX Font Warning: ')
    font_warning = "LaTeX Font Warning"

    font_info_pat = re.compile('LaTeX Font Info: ')
    font_info = "LaTeX Font Info"

    package_warning_pat = re.compile('Package ((?:\w|\.)+) Warning: ')
    package_warning = "Package Warning"

    package_info_pat = re.compile('Package (\w+) Info: ')
    package_info = "Package Info"

    hbox_info_pat = re.compile(r'(Over|Under)full \\hbox ')
    hbox_info = "hbox Warning"

    latex_info_pat = re.compile('LaTeX Info: ')
    latex_info = "LaTeX Info"

    latex_emergency_stop_pat = re.compile('\! Emergency stop\.')
    latex_emergency_stop = "LaTeX Error"

    latex_error_pat = re.compile('\! (?:LaTeX Error: |Package (\w+) Error: )?')
    latex_error = "LaTeX Error"

    input_package_pat = re.compile('(?:Package: |Document Class: )')
    input_package = 'Input Package'

    open_dict = Dict({})
    # This dictionary is of the form:
    # { file_name : number_of_brackets_opened_after_the_file_name_was_found ... }

    idx=-1
    line_up_to_col = ""
    # This variable stores the current line up to the current column.
    for char in log_stream:
        idx+=1
        if char == "\n":
            line_nr+=1
            col_nr=0
            line_up_to_col = ""
        else:
            col_nr+=1
            line_up_to_col += char
        if char == "(" and not re.match('l\.\d+', line_up_to_col):
            # If we are at the '(' bracket, check for the file name just after it.
            line = log_lines[line_nr-1][col_nr:]
            fname_re = re.match('([^\(\)]*\.(?:tex|sty|cls|cfg|def|aux|fd|out|bbl|blg|bcf|lof|toc|lot|ind|idx|thm|synctex\.gz|pdfsync|clo|lbx|mkii|run\.xml|spl|snm|nav|brf|mpx|ilg|maf|glo|mtc[0-9]+))', line)
            if fname_re:
                fname_ = fname_re.group(1)
                fname = os.path.basename(fname_)
                fname_dir = os.path.dirname(fname_)
                if check_path:
                    # ATP specific path rewritting:
                    if os.path.splitext(fname)[1] in [ '.tex', '.bib' ]:
                        if os.path.isfile(os.path.normpath(os.path.join(project_dir, fname))):
                            fname = os.path.normpath(os.path.join(project_dir, fname))
                        else:
                            fname = fname_
                    else:
                        if os.path.isfile(os.path.normpath(os.path.join(output_dir, fname))):
                            fname = os.path.normpath(os.path.join(output_dir, fname))
                        else:
                            fname = fname_
                output_data.append(["Input File", fname, "0", "0", "Input File"])
                file_stack.append(fname)
                open_dict[fname]=0
            open_dict = shift_dict(open_dict, 1)
        elif char == ")" and not re.match('l\.\d+', line_up_to_col):
            if len(file_stack) and not( re.match('\!', log_lines[line_nr-1]) or re.match('\s{5,}',log_lines[line_nr-1]) or re.match('l\.\d+', log_lines[line_nr-1])):
            # If the ')' is in line that we check, then substrackt 1 from values of
            # open_dict and pop both the open_dict and the file_stack. 
                open_dict = shift_dict(open_dict, -1)
                if open_dict[file_stack[-1]] == 0:
                    open_dict.pop(file_stack[-1])
                    file_stack.pop()

        line = log_lines[line_nr-1][col_nr:]
        if col_nr == 0:
            # Check for the error message in the current line 
            # (that's why we only check it when col_nr == 0)
            try:
                last_file = file_stack[-1]
            except IndexError:
                last_file = "0"
            if check_path and fnmatch.fnmatch(last_file, project_tmpdir+"*"):
                # ATP specific path rewritting:
                last_file = os.path.normpath(os.path.join(project_dir, os.path.relpath(last_file, project_tmpdir)))
            if re.match(latex_warning_pat, line):
                # Log Message: 'LaTeX Warning: '
                input_line = re.search('on input line (\d+)', line)
                warning_type = re.match('LaTeX Warning: (Citation|Reference|Hyper reference)', line)
                if warning_type:
                    wtype = warning_type.group(1)
                else:
                    wtype = ""
                if wtype == 'Hyper reference': 
                    wtype = 'Reference'
                msg = re.sub('\s+on input line (\d+)', '', re.sub(latex_warning_pat,'', line))
                if msg == "":
                    msg = " "
                if input_line:
                    output_data.append([wtype+" "+latex_warning, last_file, input_line.group(1), "0", msg])
                else:
                    output_data.append([latex_warning, last_file, "0", "0", msg])
            elif re.match(font_warning_pat, line):
                # Log Message: 'LaTeX Font Warning: '
                input_line = re.search('on input line (\d+)', line)
                if not input_line and line_nr < len(log_lines) and re.match('\(Font\)', log_lines[line_nr]):
                    input_line = re.search('on input line (\d+)', log_lines[line_nr])
                if not input_line and line_nr+1 < len(log_lines) and re.match('\(Font\)', log_lines[line_nr+1]):
                    input_line = re.search('on input line (\d+)', log_lines[line_nr+1])
                msg = re.sub(' on input line \d+', '', re.sub(font_warning_pat,'', line))
                if msg == "":
                    msg = " "
                i=0
                while line_nr+i < len(log_lines) and re.match('\(Font\)', log_lines[line_nr+i]):
                    msg += re.sub(' on input line \d+', '', re.sub('\(Font\)\s*', ' ', log_lines[line_nr]))
                    i+=1
                if not re.search("\.\s*$", msg):
                    msg = re.sub("\s*$", ".", msg)
                if input_line:
                    output_data.append([font_warning, last_file, input_line.group(1), "0", msg])
                else:
                    output_data.append([font_warning, last_file, "0", "0", msg])
            elif re.match(font_info_pat, line):
                # Log Message: 'LaTeX Font Info: '
                input_line = re.search('on input line (\d+)', line)
                if not input_line and line_nr < len(log_lines) and re.match('\(Font\)', log_lines[line_nr]):
                    input_line = re.search('on input line (\d+)', log_lines[line_nr])
                if not input_line and line_nr+1 < len(log_lines) and re.match('\(Font\)', log_lines[line_nr+1]):
                    input_line = re.search('on input line (\d+)', log_lines[line_nr+1])
                msg = re.sub(' on input line \d+', '', re.sub(font_info_pat,'', line))
                if msg == "":
                    msg = " "
                i=0
                while line_nr+i < len(log_lines) and re.match('\(Font\)', log_lines[line_nr+i]):
                    msg += re.sub(' on input line \d+', '', re.sub('\(Font\)\s*', ' ', log_lines[line_nr]))
                    i+=1
                if not re.search("\.\s*$", msg):
                    msg = re.sub("\s*$", ".", msg)
                if input_line:
                    output_data.append([font_info, last_file, input_line.group(1), "0", msg])
                else:
                    output_data.append([font_info, last_file, "0", "0", msg])
            elif re.match(package_warning_pat, line):
                # Log Message: 'Package (\w+) Warning: '
                package = re.match(package_warning_pat, line).group(1)
                input_line = re.search('on input line (\d+)', line)
                msg = re.sub(package_warning_pat,'', line)
                if line_nr < len(log_lines):
                    nline = log_lines[line_nr]
                    i=0
                    while re.match('\('+package+'\)',nline):
                        msg+=re.sub('\('+package+'\)\s*', ' ', nline)
                        if not input_line:
                            input_line = re.search('on input line (\d+)', nline)
                        i+=1
                        if line_nr+i < len(log_lines):
                            nline = log_lines[line_nr+i]
                        else:
                            break
                if msg == "":
                    msg = " "
                msg = re.sub(' on input line \d+', '', msg)
                if input_line:
                    output_data.append([package_warning, last_file, input_line.group(1), "0", "%s (%s package)" % (msg, package)])
                else:
                    output_data.append([package_warning, last_file, "0", "0",  "%s (%s package)" % (msg, package)])
            elif re.match(package_info_pat, line):
                # Log Message: 'Package (\w+) Info: '
                package = re.match(package_info_pat, line).group(1)
                input_line = re.search('on input line (\d+)', line)
                msg = re.sub(package_info_pat,'', line)
                if line_nr < len(log_lines):
                    nline = log_lines[line_nr]
                    i=0
                    while re.match(('\(%s\)' % package), nline):
                        msg+=re.sub(('\(%s\)\s*' % package), ' ', nline)
                        if not input_line:
                            input_line = re.search('on input line (\d+)', nline)
                        i+=1
                        if line_nr+i < len(log_lines):
                            nline = log_lines[line_nr+i]
                        else:
                            break
                if msg == "":
                    msg = " "
                msg = re.sub(' on input line \d+', '', msg)
                if input_line:
                    output_data.append([package_info, last_file, input_line.group(1), "0", msg+" ("+package+")"])
                else:
                    output_data.append([package_info, last_file, "0", "0", msg+" ("+package+")"])
            elif re.match(hbox_info_pat, line):
                # Log Message: '(Over|Under)full \\\\hbox'
                input_line = re.search('at lines? (\d+)(?:--(?:\d+))?', line)
                if re.match('Underfull', line):
                    h_type = 'Underfull '
                else:
                    h_type = 'Overfull '
                msg = h_type+'\\hbox '+str(re.sub(hbox_info_pat, '', line))
                if msg == "":
                    msg = " "
                if input_line:
                    output_data.append([hbox_info, last_file, input_line.group(1), "0", msg])
                else:
                    output_data.append([hbox_info, last_file, "0", "0", msg])
            elif re.match(latex_info_pat, line):
                # Log Message: 'LaTeX Info: '
                input_line = re.search('on input line (\d+)', line)
                msg = re.sub(' on input line \d+', '', re.sub(latex_info_pat,'', line))
                if msg == "":
                    msg = " "
                if input_line:
                    output_data.append([latex_info, last_file, input_line.group(1), "0", msg])
                else:
                    output_data.append([latex_info, last_file, "0", "0", msg])
            elif re.match(input_package_pat, line):
                # Log Message: 'Package: ', 'Document Class: '
                msg = re.sub(input_package_pat, '', line)
                if msg == "":
                    msg = " "
                output_data.append([input_package, last_file, "0", "0", msg])
            elif re.match(latex_emergency_stop_pat, line):
                # Log Message: '! Emergency stop.'
                msg = "Emergency stop."
                nline = log_lines[line_nr]
                match = re.match('<\*>\s+(.*)', nline)
                if match:
                    e_file = match.group(1)
                else:
                    e_file = "0"
                i=-1
                while True:
                    i+=1
                    try:
                        nline = log_lines[line_nr-1+i]
                        line_m = re.match('\*\*\*\s+(.*)', nline)
                        if line_m:
                            rest = line_m.group(1)
                            break
                        elif i>50:
                            rest = ""
                            break
                    except IndexError:
                        rest = ""
                        break
                msg += " "+rest
                output_data.append([latex_emergency_stop, e_file, "0", "0",msg])
            elif re.match(latex_error_pat, line):
                # Log Message: '\! (?:LaTeX Error: |Package (\w+) Error: )?'
                # get the line unmber of the error
                match = re.search('on input line (\d+)', line)
                input_line = (match and [match.group(1)] or [None])[0]
                i=-1
                while True:
                    i+=1
                    try:
                        nline = log_lines[line_nr-1+i]
                        line_m = re.match('l\.(\d+) (.*)', nline)
                        if line_m:
                            if input_line is None:
                                input_line = line_m.group(1)
                            rest = line_m.group(2)+re.sub('^\s*', ' ', log_lines[line_nr+i])
                            break
                        elif i>50:
                            if input_line is None:
                                input_line="0"
                            rest = ""
                            break
                    except IndexError:
                        if input_line is None:
                            input_line="0"
                        rest = ""
                        break
                msg = re.sub(latex_error_pat, '', line)
                if msg == "":
                    msg = " "
                p_match = re.match('! Package (\w+) Error', line)
                if p_match:
                    info = p_match.group(1)
                elif rest:
                    info = rest
                else:
                    info = ""
                if re.match('\s*\\\\]\s*', info) or re.match('\s*$', info):
                    info = ""
                if info != "":
                    info = " |"+info
                if re.match('!\s+A <box> was supposed to be here\.', line) or \
                        re.match('!\s+Infinite glue shrinkage found in a paragraph', line) or \
                        re.match('!\s+Missing \$ inserted\.', line):
                    info = ""
                verbose_msg = ""
                for j in range(1,i):
                    if not re.match("See\s+the\s+\w+\s+manual\s+or\s+\w+\s+Companion\s+for\s+explanation\.|Type\s+[HI]", log_lines[line_nr-1+j]):
                        verbose_msg+=re.sub("^\s*", " ", log_lines[line_nr-1+j])
                    else:
                        break
                if re.match('\s*<(?:inserted text|to be read again|recently read)>', verbose_msg) or \
                        re.match('\s*See the LaTeX manual', verbose_msg) or \
                        re.match('!\s+Infinite glue shrinkage found in a paragraph', line):
                    verbose_msg = ""
                if not re.match('\s*$',verbose_msg):
                    verbose_msg = " |"+verbose_msg

                if last_file == "0":
                    i=-1
                    while True:
                        i+=1
                        try:
                            nline = log_lines[line_nr-1+i]
                            line_m = re.match('<\*>\s+(.*)', nline)
                            if line_m:
                                e_file = line_m.group(1)
                                break
                            elif i>50:
                                e_file="0"
                                break
                        except IndexError:
                            e_file="0"
                            break
                else:
                    e_file = last_file
                if not match:
                    index = len(output_data)
                else:
                    # Find the correct place to put the error message:
                    try:
                        try:
                            prev_element=filter(lambda d: d[1] == e_file and int(d[2]) <= int(input_line), output_data)[-1]
                            index = output_data.index(prev_element)+1
                        except IndexError:
                            prev_element=filter(lambda d: d[1] == e_file and int(d[2]) > int(input_line), output_data)[0]
                            index = output_data.index(prev_element)
                    except IndexError:
                        index = len(output_data)

                output_data.insert(index, [latex_error, e_file, input_line, "0", msg+info+verbose_msg])

    output_data=map(lambda x: "::".join(x), output_data)
    try:
        output_fo=open(output_fname, 'w')
    except IOError:
        print("IOError: cannot open %s file for writting" % output_fname)
        sys.exit(1)
    else:
        output_fo.write(('\n'.join(output_data)+'\n').encode(encoding, 'ignore'))
        output_fo.close()

# Main call
if __name__ == '__main__':

    usage = "%prog [options] {log_file}"
    parser  = OptionParser(usage=usage)

    import locale
    encoding = locale.getpreferredencoding()

    parser.add_option("-e", "--encoding", dest="encoding", default=encoding, help="encoding to use (default=%s)" % encoding)
    (options, args) = parser.parse_args()

    try:
        rewrite_log(args[0], encoding=options.encoding)
    except IOError:
        pass
