#!/bin/sh
set -e
for i in `ls *.lua`; do echo $i; ./$i > output/${i:0:${#i}-4}.html; done
