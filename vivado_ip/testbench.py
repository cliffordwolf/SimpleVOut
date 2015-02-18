#!/usr/bin/env python

from __future__ import division
from __future__ import print_function

import os
import sys
import fileinput

width = 64 + 2 + 4 + 2
height = 48 + 1 + 2 + 1

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
            print('P3\n%d %d %d' % (width, height, 255), file = f)
            print('first line of frame %d (line %d): %s' % (framecount, linecount, line.strip()))
        r = int(tokens[2])
        g = int(tokens[3])
        b = int(tokens[4])
        if tokens[1][1] == '1':
            r = 128
        if tokens[1][2] == '1':
            g = 128
        print('%d %d %d' % (r, g, b), file = f)
        pixelcount += 1

os.remove(fn)

