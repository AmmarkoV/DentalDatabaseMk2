#!/bin/bash

PROJDIR="$(dirname "$(realpath "$0")")"
WINEPREFIX="$HOME/.wine32"

cd "$PROJDIR"
WINEPREFIX=$WINEPREFIX wine "Dental Database.exe"

exit 0
