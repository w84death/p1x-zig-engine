# P1X Zig Engine

![Main window](main.png)

Simple Zig engine project using the [fenster](https://github.com/zserge/fenster) software renderer.

## Run
```
zig build run
```

## Build Small Binary

Host Linux -> **Linux 64**
```
zig build \
  -Doptimize=ReleaseSmall \
  upx
```

Host Linux -> **Windows 32**
``` 
zig build \
  -Dtarget=x86-windows \
  -Doptimize=ReleaseSmall \
  upx
```
