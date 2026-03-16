nasm -f win64 "$Args.asm"
lld-link  /subsystem:console "$Args.obj" kernel32.lib User32.lib /entry:main
#powershell "./$Args.exe"