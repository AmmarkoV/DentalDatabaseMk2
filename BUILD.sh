#!/bin/bash

WINEPREFIX=/home/ammar/.wine32/
DEVPAS="C:/Dev-Pas"
PROJECT="C:/DDBMK2/DentalDatabaseMk2"
WINDRES="$HOME/.wine32/drive_c/Dev-Pas/Bin/windres.exe"
PPC386="$HOME/.wine32/drive_c/Dev-Pas/Bin/ppc386.exe"

echo "=== Building resource file... ==="
WINEPREFIX=$WINEPREFIX wine "$WINDRES" \
  -i "$PROJECT/rsrc.rc" \
  -o "$PROJECT/rsrc.o"

if [ $? -ne 0 ]; then
  echo "ERROR: Resource compilation failed."
  exit 1
fi

echo "=== Compiling Pascal source... ==="
WINEPREFIX=$WINEPREFIX wine "$PPC386" \
  "$PROJECT/ddatabase.lpr" \
  "-o$PROJECT/Dental Database.exe" \
  -S2 -Sg -Un -Sh -O1 -Op1 \
  "-Fu$DEVPAS/units/" \
  "-Fu$DEVPAS/units/rtl/" \
  "-Fl$DEVPAS/units/" \
  "-Fl$DEVPAS/units/rtl/" \
  "-FD$DEVPAS/Bin/" \
  -WC \
  "-k$PROJECT/rsrc.o"

if [ $? -ne 0 ]; then
  echo "ERROR: Compilation failed."
  exit 1
fi

echo "=== Build successful! ==="
exit 0
