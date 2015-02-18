#!/usr/bin/env python

from __future__ import division
from __future__ import print_function

import os
import sys
import fileinput

for line in fileinput.input("modes.txt"):
    line = line.split()
    if line[0] == "640x480":
        width = int(line[1]) + int(line[3]) + int(line[4]) + int(line[5])
        height = int(line[2]) + int(line[6]) + int(line[7]) + int(line[8])

framecount = 0
linecount = 0
pixelcount = 0

for line in fileinput.input():
    linecount += 1
    tokens = line.split()
    if len(tokens) == 5 and tokens[0] == "##":
        if pixelcount == width * height:
            framecount += 1
            pixelcount = 0
            f.close()
        if pixelcount == 0:
            fn = 'testbench_%03d.ppm' % framecount
            f = open(fn, 'w')
            print('P3\n%d %d %d' % (width, height, 63), file = f)
            print('first line of frame %d (line %d): %s' % (framecount, linecount, line.strip()))
        if tokens[2] == 'X' or tokens[2] == 'x': tokens[2] = 255
        if tokens[3] == 'X' or tokens[3] == 'x': tokens[3] = 255
        if tokens[4] == 'X' or tokens[4] == 'x': tokens[4] = 0
        r = int(tokens[2])
        g = int(tokens[3])
        b = int(tokens[4])
        if tokens[1][1] == '1':
            r = 32
        if tokens[1][2] == '1':
            g = 32
        print('%d %d %d' % (r, g, b), file = f)
        pixelcount += 1

os.remove(fn)

