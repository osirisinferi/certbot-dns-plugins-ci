#!/bin/env python

import sys
from portage.dep import Atom

for arg in sys.argv[1:]:
        atom = Atom(arg)
        print(atom.cp.split("/")[1])
