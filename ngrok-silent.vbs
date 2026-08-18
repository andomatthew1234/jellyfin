' ngrok-silent.vbs
' This script runs ngrok completely invisibly without flashing a console window.

Set objShell = CreateObject("WScript.Shell")

' Get the directory where this script (and hopefully ngrok.exe) lives
strPath = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
objShell.CurrentDirectory = strPath

' Run the command silently (0 means hide window, False means don't wait for it to finish)
objShell.Run "cmd /c ngrok.exe start jellyfin", 0, False