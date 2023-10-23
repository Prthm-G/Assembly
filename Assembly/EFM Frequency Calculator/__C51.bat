@echo off
::This file was created automatically by CrossIDE to compile with C51.
C:
cd "\Users\241pr\Downloads\"
"C:\Users\241pr\Downloads\call51\call51\Bin\c51.exe" --use-stdout  "C:\Users\241pr\Downloads\FreqEFM8 (1).c"
if not exist hex2mif.exe goto done
if exist FreqEFM8 (1).ihx hex2mif FreqEFM8 (1).ihx
if exist FreqEFM8 (1).hex hex2mif FreqEFM8 (1).hex
:done
echo done
echo Crosside_Action Set_Hex_File C:\Users\241pr\Downloads\FreqEFM8 (1).hex
