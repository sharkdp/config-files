#!/usr/bin/env python

import vim
import re
import glob
import os.path
import subprocess

__all__ = [ 'newcmd_pattern', 'scan_preambule', 'addext', 'kpsewhich_find' ]

newcmd_pattern = re.compile(r'''
        ^(?:[^%]|\\%)*                      # comment lines
        (?:
            \\definecolor\s*{|
            \\(?:re)?newcommand\s*{|
            \\providecommand\s*{|
            \\(?:re)?newenvironment\s*{|
            \\(?:re)?newtheorem\s*{|
            \\def)
        ([^#{}]*)                           # are necessary for \def statemnt
        ''', re.VERBOSE)

def scan_preambule(file, pattern):
    """Scan_preambule for a pattern

    file is list of lines"""

    for line in file:
        ret=re.search(pattern, line)
        if ret:
            return True
        elif re.search(r'\\begin\s*{\s*document\s*}', line):
            return False
    return False

def addext(string, ext):
    "The pattern is not matching .tex extension read from file."

    if not re.search("\.%s$" % ext, string):
        return "%s.%s" % (string, ext)
    else:
        return string

def kpsewhich_find(file, path_list):

    results=[]
    for path in path_list:
        found=glob.glob(os.path.join(path, file))
        results.extend(found)
        found=glob.glob(os.path.join(path, file))
        results.extend(found)
    return results

def kpsewhich_path(format):
    """Find fname of format in path given by kpsewhich,"""

    kpsewhich=subprocess.Popen(['kpsewhich', '-show-path', format], stdout=subprocess.PIPE)
    kpsewhich.wait()
    path=kpsewhich.stdout.read()
    path=re.sub("!!", "",path)
    path=re.sub("\/\/+", "/", path)
    path=re.sub("\n", "",path)
    path_list=path.split(":")
    return path_list
