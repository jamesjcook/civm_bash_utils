#!/bin/bash

echo \$0 is $0

echo pwdvar is $PWD

echo cwdvar is $CWD

echo DEBUG lvl is $DEBUG
. $PWD/lib/functionscivmscript.bash

whatconfigs $PWD
echo Config returned : $config

