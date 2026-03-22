#!/bin/bash

for f in *.pas; do
  python3 -c "
import sys
with open('$f', 'rb') as fh:
    data = fh.read()
try:
    data.decode('utf-8')
    sys.exit(0)  # already UTF-8, skip
except UnicodeDecodeError:
    pass
text = data.decode('windows-1253')
with open('$f', 'w', encoding='utf-8') as fh:
    fh.write(text)
print('Converted: $f')
"
done

exit 0
