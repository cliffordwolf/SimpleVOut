#!/usr/bin/python

from __future__ import division
from __future__ import print_function

# 8x8font.png is the "8x8 Bitmapped Font" by John Hall
# License: This font is free to use for any purpose.
# http://overcode.yak.net/12

from PIL import Image

verbose_output = False

im = Image.open("8x8font.png")
pix = im.load()

print("localparam [8191:0] fontmem = {");

for i in range(127, -1, -1):
    if i != 127: print()
    if verbose_output:
        if i >= 32 and i < 127:
            print("\t// '%c'" % chr(i))
        else:
            print("\t// %d" % i)
    for j in range(7, -1, -1):
        bits = "\t8'b" if verbose_output or j == 7 else " 8'b"
        for k in range(7, -1, -1):
          bits += "0" if pix[i*8+k, j] else "1"
        if i != 0 or j != 0: bits += ","
        if verbose_output:
            print(bits)
        else:
            print(bits, end="")

print("};" if verbose_output else "\n};")

print("function font(input [7:0] c, input [2:0] x, input [2:0] y);")
print("\tfont = fontmem[{c, y, x}];")
print("endfunction")

