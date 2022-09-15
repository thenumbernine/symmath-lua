#!/usr/bin/env lua
require 'ext'
file'README.md':write(require 'template'(file'README.contents.md':read()))
