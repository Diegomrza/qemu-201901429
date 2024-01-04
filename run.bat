@echo off
start cmd.exe /k "git add . && exit"
start cmd.exe /k "git commit -m \".\" && exit"
start cmd.exe /k "git push && exit"