#!/bin/bash

WINEPREFIX="$HOME/.wine32"

cd "$WINEPREFIX/drive_c/Dev-Pas"
WINEPREFIX=$WINEPREFIX wine "devpas.exe"

exit 0
