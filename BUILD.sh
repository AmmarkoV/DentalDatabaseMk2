#!/bin/bash

PROJDIR="$(dirname "$(realpath "$0")")"
WINEPREFIX="$HOME/.wine32"
DEVPAS="C:/Dev-Pas"
PROJECT="C:/DDBMK2/DentalDatabaseMk2"
PPC386="$WINEPREFIX/drive_c/Dev-Pas/Bin/ppc386.exe"

# === Setup: create 32-bit Wine prefix and install Dev-Pascal if needed ===
if [ ! -d "$WINEPREFIX" ]; then
  echo "=== Creating 32-bit Wine prefix at $WINEPREFIX ==="
  WINEPREFIX=$WINEPREFIX WINEARCH=win32 wine wineboot
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create Wine prefix."
    exit 1
  fi

  echo "=== Running Dev-Pascal installer (follow the setup wizard) ==="
  WINEPREFIX=$WINEPREFIX wine "$PROJDIR/dev/devpas192.exe"
  if [ $? -ne 0 ]; then
    echo "ERROR: Dev-Pascal installer failed."
    exit 1
  fi
fi

# === Setup: create project symlink in Wine C: drive if needed ===
WINE_DDBMK2="$WINEPREFIX/drive_c/DDBMK2"
WINE_PROJLINK="$WINE_DDBMK2/DentalDatabaseMk2"
if [ ! -L "$WINE_PROJLINK" ] && [ ! -d "$WINE_PROJLINK" ]; then
  echo "=== Creating project symlink at C:\\DDBMK2\\DentalDatabaseMk2 ==="
  mkdir -p "$WINE_DDBMK2"
  ln -s "$PROJDIR" "$WINE_PROJLINK"
  echo "    Linked: $WINE_PROJLINK -> $PROJDIR"
fi

echo "=== Building resource file... ==="
sed "s|C:/DDBMK2/DentalDatabaseMk2|$PROJDIR|g" "$PROJDIR/rsrc.rc" > /tmp/rsrc_build.rc
i686-w64-mingw32-windres /tmp/rsrc_build.rc -o "$PROJDIR/rsrc.o"
rm -f /tmp/rsrc_build.rc

if [ $? -ne 0 ]; then
  echo "ERROR: Resource compilation failed."
  exit 1
fi

echo "=== Compiling Pascal source... ==="
WINEPREFIX=$WINEPREFIX wine "$PPC386" \
  "$PROJECT/ddatabase.pas" \
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
