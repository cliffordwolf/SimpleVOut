#!/usr/bin/python

from __future__ import division
from __future__ import print_function

import fileinput

data = dict()
fields = set()
state = 0

for line in fileinput.input():
    line = line.strip()

    if line.startswith("# synth_design"):
        current_mod = line.split()[3]
        data[current_mod] = dict()
        data[current_mod]["."] = current_mod
        data[current_mod]["_total"] = 0
        continue

    if line.startswith("Report Cell Usage:"):
        state = 1
        continue

    if state == 1 and line.startswith("|"):
        state = 2
        continue

    if state == 2 and line.startswith("|"):
        cell = line.split('|')[2].strip()
        count = line.split('|')[3].strip()
        if cell != "IBUF" and cell != "OBUF" and cell != "BUFG":
            data[current_mod][cell] = count
            data[current_mod]["_total"] += int(count)
        continue

    if state == 2 and line == "":
        state = 0
        continue

    if line.startswith("Data Path Delay:"):
        data[current_mod][".delay"] = line.split()[3]
        continue

for mod in data:
    for field in data[mod]:
        fields.add(field)

for field in sorted(fields):
    print("%-10s" % field, end="")
    for mod in data:
        print("%15s" % (data[mod][field] if field in data[mod] else "0"), end="")
    print()

