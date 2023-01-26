#!/usr/bin/env lua
require 'ext'
local file = require 'ext.file'
file'README.md':write(require 'template'(file'README.contents.md':read()))
