#!/bin/bash

rm ../working.sfc
cp ../alttp.sfc ../working.sfc
./bin/linux/asar --symbols=wla --fix-checksum=off LTTP_RND_GeneralBugfixes.asm ../working.sfc
