#!/bin/bash

WINEPREFIX="$HOME/.wine32"

cd "$WINEPREFIX/drive_c/DDBMK2/DentalDatabaseMk2"
WINEPREFIX=$WINEPREFIX wine "Dental Database.exe"

exit 0
