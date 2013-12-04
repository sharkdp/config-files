#!/usr/bin/python
# -*- coding: utf-8 -*-
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

import re, optparse, subprocess, os, traceback, sys
from optparse import OptionParser
from time import strftime, localtime
import locale
encoding = locale.getpreferredencoding()

# Usage:
# latextags.py --files main_file.tex;input_file1.tex;input_file2.tex --auxfile main_file.aux --bibfiles bibfile.bib --dir ./
# --files       : specifies all the tex files in a ";"-separated list to parse (all input files) [this option is necessary]
# --auxfile     : the aux file [this option is necessary]
# --bibfiles    : specifies bibfiles
# --hyperref    : if added \hypertarget{}{} commands are scanned too.
# --cite        : has values: "natbib"/"biblatex"/"" (or not given). It sets apropriate pattern to find all \cite commands.
# --dir         : directory where to put the tag file
# --silent      : be silent
# --servername  : specifies the server name of vim, if given error messages are send to (g)vim
# --progname    : aparentely only two values are supported: "vim"/"gvim".


# ToDoList:
# (1) Use synstack function remotely to get tag_type.
# (2) Scan bib files to get bibkeys (but this might be slow)!
#       this could be written to seprate file.

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

# OPTIONS:
usage   = "usage: %prog [options]"
parser  = OptionParser(usage=usage)
parser.add_option("--files",    dest="files"    )
parser.add_option("--silent",   dest="silent",          default=False, action="store_true")
parser.add_option("--auxfile",  dest="auxfile"  )
parser.add_option("--hyperref", dest="hyperref",        default=False,  action="store_true")
parser.add_option("--servername", dest="servername",    default=""      )
parser.add_option("--progname", dest="progname",        default="gvim"  )
parser.add_option("--bibfiles", dest="bibfiles",        default=""      )
parser.add_option("--bibtags",  dest="bibtags",         default=False,  action="store_true")
parser.add_option("--bibtags_env",  dest="bibtags_env", default=False,  action="store_true")
parser.add_option("--dir",      dest="directory")
parser.add_option("--cite",     dest="cite",            default="default" )
(options, args) = parser.parse_args()
file_list=options.files.split(";")
bib_list=options.bibfiles.split(";")

# Cite Pattern:
if options.cite == "natbib":
    cite_pattern=re.compile('^(?:[^%]|\\\\%)*\\\\(?:c|C)ite(?:(?:al)?[tp]\*?|year(?:par)?|(?:full)?author\*?|num)?(?:\[.*\])?{([^}]*)}')
elif options.cite == "biblatex":
# there is no pattern for \[aA]utocites, \[tT]extcites, \[sS]martcites,
# \[pP]arencites, \[cC]ites, \footcites, \footcitetexts commands
    cite_pattern=re.compile('^(?:[^%]|\\\\%)*\\\\(?:[cC]ite\*?|[pP]arencite\*?|footcite(?:text)?|[tT]extcite|[sS]martcite|supercite|[aA]utocite\*?|[cC]iteauthor|citetitle\*?|cite(?:year|date|url)|nocite|(?:foot)?fullcite|(?:[vV]ol|fvol|ftvol|[sStTpP]vol)cite(?:\[.*\])?{(?:[^}]*)}|[nN]otecite|[pP]nocite|citename|citefield)(?:\[.*\])?{([^}]*)}')
# (?:[aA]utoc|[tT]extc|[sS]martc|[pP]arenc|[cC]|footc)ites(?:(?:\[.*\]{([^}]*)]))*
else:
    cite_pattern=re.compile('^(?:[^%]|\\\\%)*\\\\(?:no)?cite(?:\[.*\])?{([^}]*)}')

def vim_remote_expr(servername, expr):
    """Send <expr> to vim server,

    expr must be well quoted:
          vim_remote_expr('GVIM', "atplib#callback#TexReturnCode()")"""
    cmd=[options.progname, '--servername', servername, '--remote-expr', expr]
    subprocess.Popen(cmd)

def get_tag_type(line, match, label):
    """Find tag type,

    line is a string, match is an element of a MatchingObject."""
    tag_type=""
    if label == 'label':
        pat='(?:\\\\hypertarget{.*})?\s*\\\\label'
    else:
        pat='(?:\\\\label{.*})?\s*\\\\hypertarget'
    if re.search('\\\\part{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="part"
    elif re.search('\\\\chapter(?:\[.*\])?{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="chapter"
    elif re.search('\\\\section(?:\[.*\])?{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="section"
    elif re.search('\\\\subsection(?:\[.*\])?{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="subsection"
    elif re.search('\\\\subsubsection(?:\[.*\])?{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="subsubsection"
    elif re.search('\\\\paragraph(?:\[.*\])?{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="paragraph"
    elif re.search('\\\\subparagraph(?:\[.*\])?{.*}\s*%s{%s}' % (pat, match), line):
        tag_type="subparagraph"
    elif re.search('\\\\begin{[^}]*}', line):
        # \label command must be in the same line, 
        # To do: I should add searching in next line too.
        #        Find that it is inside \begin{equation}:\end{equation}.
        type_match=re.search('\\\\begin\s*{\s*([^}]*)\s*}(?:\s*{.*})?\s*(?:\[.*\])?\s*%s{%s}' % (pat, match), line)
        try:
            # Use the last found match (though it should be just one).
            tag_type=type_match.group(len(type_match.groups()))
        except AttributeError:
            tag_type=""
    return tag_type

def find_in_filelist(match, file_dict, get_type=False, type_pattern=None):
    """find match in list of files, 

    file_dict is a dictionary with { 'file_name' : file }."""
    r_file = ""
    r_type = ""
    for file in file_dict.iterkeys():
        flinenr=1
        for line in file_dict[file]:
            pat_match=re.search(match, line)
            if pat_match:
                r_file=file
                if get_type:
                    r_type=re.match(type_pattern, line).group(1)
                break
            flinenr+=1
    if get_type:
        return [ r_file, flinenr, r_type ]
    else:
        return [ r_file, flinenr ]

def comma_split(arg_list):
    ret_list = []
    for element in arg_list:
        ret_list.extend(element.split(","))
    return ret_list

try:
    # Read tex files:
    file_dict=Dict({})
    # { 'file_name' : list_of_lines }
    for file in file_list:
        try:
            if sys.version_info.major < 3:
                with open(file, "r") as file_obj:
                    file_data=file_obj.read().decode(encoding, errors="replace")
            else:
                with open(file, "r", encoding=enconding, errors="replace") as file_obj:
                    file_data=file_obj.read()
            file_dict[file]=file_data.split("\n")
        except IOError:
            if options.servername != "":
                vim_remote_expr(options.servername, "atplib#callback#Echo(\"[LatexTags:] file %s not found.\",'echomsg','WarningMsg')" % file)
            file_dict[file]=[]
            pass

    # Read bib files:
    if len(bib_list) > 1:
        bib_dict=Dict({})
        # { 'bib_name' : list_of_lines } 
        for bibfile in bib_list:
            if sys.version_info.major < 3 :
                with open(bibfile, "r") as file_obj:
                    bib_data=file_obj.read().decode(encoding, errors="replace")
            else:
                with open(bibfile, "r", encoding=encoding, errors="replace") as file_obj:
                    bib_data=file_obj.read()
            bib_dict[bibfile]=bib_data.split("\n")

    # GENERATE TAGS:
    # From \label{} and \hypertarget{}{} commands:
    tags=[]
    tag_dict=Dict({})
    for file_name in file_list:
        file_ll=file_dict[file_name]
        linenr=0
        p_line=""
        for line in file_ll:
            linenr+=1
            # Find LABELS in the current line:
            matches=re.findall('^(?:[^%]|\\\\%)*\\\\label{([^}]*)}', line)
            for match in matches:
                tag="%s\t%s\t%d" % (match, file_name, linenr)
                # Set the tag type:
                tag_type=get_tag_type(line, match, "label")
                if tag_type == "":
                    tag_type=get_tag_type(p_line+line, match, "label")
                tag+=";\"\tinfo:%s\tkind:label" % tag_type
                # Add tag:
                tags.extend([tag])
                tag_dict[str(match)]=[str(linenr), file_name, tag_type, 'label']
            # Find HYPERTARGETS in the current line:        /this could be switched on/off depending on useage of hyperref/
            if options.hyperref:
                matches=re.findall('^(?:[^%]|\\\\%)*\\\\hypertarget{([^}]*)}', line)
                for match in matches:
                    # Add only if not yet present in tag list:
                    if not str(match) in tag_dict:
                        tag_dict[str(match)]=[str(linenr), file_name, tag_type, 'hyper']
                        tag_type=get_tag_type(line, match, 'hypertarget')
                        if tag_type == "":
                            tag_type=get_tag_type(p_line+line, match, "label")
                        tags.extend(["%s\t%s\t%d;\"\tinfo:%s\tkind:hyper" % (match,file_name,linenr,tag_type)])
            # Find CITATIONS in the current line:
            if options.bibtags and not options.bibtags_env:
                # There is no support for \citealias comman in natbib.
                # complex matches are slower so I should pass an option if one uses natbib.
                matches=re.findall(cite_pattern, line)
                matches=comma_split(matches)
                for match in matches:
                    if not str(match) in tag_dict:
                        if len(bib_list) == 1:
                            tag="%s\t%s\t/%s/;\"\tkind:cite" % (match, bib_list[0], match)
                            tag_dict[str(match)]=['', bib_list[0], '', 'cite']
                            tags.extend([tag])
                        elif len(bib_list) > 1:
                            bib_file=""
                            [ bib_file, bib_linenr, bib_type ] = find_in_filelist(re.compile(str(match)), bib_dict, True, re.compile('\s*@(.*){'))
                            if bib_file != "":
                                tag="%s\t%s\t%d;\"\tkind:cite\tinfo:%s" % (match, bib_file, bib_linenr, bib_type)
                                tag_dict[str(match)]=['', bib_file, bib_type, 'cite']
                                tags.extend([tag])
            if options.bibtags and options.bibtags_env:
                matches=re.findall(cite_pattern, line)
                matches=comma_split(matches)
                for match in matches:
                    if not str(match) in tag_dict:
                        [ r_file, r_linenr ] = find_in_filelist(re.compile("\\\\bibitem(?:\s*\[.*\])?\s*{"+str(match)+"}"), file_dict)
                        tag="%s\t%s\t%d;\"\tkind:cite" % (match, r_file, r_linenr)
                        tag_dict[str(match)]=[str(r_linenr), r_file, '', 'cite']
                        tags.extend([tag])
            p_line=line

    # From aux file:
    ioerror=None
    try:
        if sys.version_info.major < 3:
            with open(options.auxfile, "r") as file_obj:
                aux_data=file_obj.read().decode(encoding, errors="replace").split("\n")
        else:
            with open(options.auxfile, "r", encoding=encoding, errors="replace") as file_obj:
                aux_data=file_obj.readlines()
        for line in aux_data:
            if re.match('\\\\newlabel{[^}]*}{{[^}]*}', line):
                [label, counter]=re.match('\\\\newlabel{([^}]*)}{{([^}]*)}', line).group(1,2)
                counter=re.sub('{', '', counter)
                if re.search('[0-9.]+', counter):
                    # Arabic Numbered counter:
                    counter=re.search('[0-9.]+', counter).group(0)
                elif re.search('[ivx]+\)?$', counter):
                    # Roman numberd counter:
                    counter=re.search('\(?([ivx]+)\)?$', counter).group(1)
                else:
                    counter=""
                try:
                    [linenr, file, tag_type, kind]=tag_dict[label]
                except KeyError:
                    [linenr, file, tag_type, kind]=["no_label", "no_label", "", ""]
                except ValueError:
                    [linenr, file, tag_type, kind]=["no_label", "no_label", "", ""]
                if linenr != "no_label" and counter != "":
                    tags.extend(["%s\t%s\t%s;\"\tinfo:%s\tkind:%s" % (counter, file, linenr, tag_type, kind)])
    except IOError as e:
        ioerror=e


    # SORT (vim works faster when tag file is sorted) AND WRITE TAGS
    time=strftime("%a, %d %b %Y %H:%M:%S +0000", localtime())
    tags = map(lambda u: u.encode(encoding, errors="replace"), tags)
    tags_sorted=sorted(tags, key=str.lower)
    tags_sorted=['!_TAG_FILE_SORTED\t1\t/'+time]+tags_sorted
    os.chdir(options.directory)
    with open("tags", 'w') as file_obj:
        file_obj.write("\n".join(tags_sorted))

    # Communicate to Vim:
    if not options.silent:
        if options.servername != "":
            vim_remote_expr(options.servername, "atplib#callback#Echo(\"[LatexTags:] tags file written.\",'echo','')")
        if ioerror and options.servername:
            vim_remote_expr(options.servername, "atplib#callback#Echo(\"[LatexTags:] no aux file: '%s'.\",'echomsg', 'WarningMsg')" % ioerror.filename)
except Exception:
    # Send errors to vim is options.servername is non empty.
    error_str=re.sub("'", "''",re.sub('"', '\\"', traceback.format_exc()))
    if options.servername != "":
        vim_remote_expr(options.servername, "atplib#callback#Echo(\"[ATP:] error in latextags.py, catched python exception:\n%s\",'echo','ErrorMsg')" % error_str)
    else:
        print(error_str)
