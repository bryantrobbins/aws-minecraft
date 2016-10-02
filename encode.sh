#!/bin/bash

# Take in file as argument
f=$1

# Check for actual content
if [ -z ${f} ]; then
  exit 0
fi

# Convert line endings to unix
dos2unix $f

# Convert file to base 64
base64 $f
