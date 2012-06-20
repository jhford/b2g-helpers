#!/usr/bin/env python

import xml.dom.minidom
import subprocess
import sys
import os
from optparse import OptionParser

class GitFailure(Exception): pass
class MissingRepositoryException(GitFailure): pass

def git_cmd(arguments, workdir):
    if not os.path.isdir(workdir):
        raise MissingRepositoryException("%s is not a git directory" % workdir)
    try:
        print "I would be running arguments \"%s\" in \"%s\"" % (arguments, workdir)
    except None:
        raise GitFailure("Git command '%s' failed in directory '%s'" % (arguments, workdir))

def git_tag(path, tag, annotated=False, force=False, git="git", git_args=[], git_cmd_args=[]):
    command = [git] + git_args + ["tag"]
    if annotated:
        command.append("--annotate")
    if force:
        command.append("--force")
    command.extend(git_cmd_args)
    command.append(tag)
    git_cmd

def git_describe(path, object=HEAD, exact_match=True
