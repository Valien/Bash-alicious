#!/bin/bash

# Script to list files in a directory and export to a .txt file
# Allen Vailliencourt
# April 22, 2016

dir="/your/file/path/here/"

for f in "$dir"/*; do
  echo `basename "$f"` >> names.txt
done