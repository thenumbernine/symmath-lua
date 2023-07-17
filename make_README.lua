#!/usr/bin/env lua
require 'ext'
local path = require 'ext.path'
path'README.md':write(require 'template'(path'README.contents.md':read()))
