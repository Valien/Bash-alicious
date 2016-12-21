
# This script is designed to go through a bunch of folders and get a file count and dumping it to a .txt file
# Allen vailliencourt
# April 7, 2016
# License: Have fun.
# Instructions: Change the folders and file path to match your environment.

$fso = New-Object -com "Scripting.FileSystemObject"
$f = $fso.GetFolder("<SOME FILE PATH>")
foreach ($folder in $f.subfolders)
    { $($folder.Path) + " " +
      $((get-childitem $folder.path -Recurse -File).count) | Out-File -FilePath <SOME FILE PATH>\filecount.txt -Append

    } 
