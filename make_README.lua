#!/usr/bin/env lua
require 'ext'
file['README.md'] = require 'template'(file['README.contents.md'])
