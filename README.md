# Knim Samples
## _Kinc in Nim_

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Translated some Kha and Kinc tutorials to Nim

⚠️This repository is still a work in progress⚠️

## Tutorials Translated from:
- [Kinc Samples](https://github.com/Kinc-Samples) - Kinc Samples
- [Lubos Lenco](https://github.com/luboslenco/kha3d_examples/wiki) - Kha 3D Tutorial

## How to get

- ```git clone --recursive https://github.com/IbrahimHindawi/Knim```

## How to run

This library can be ran in two modes:<br>
dynamic: link against a dynamic library and debug Nim directly in VS Code using LLDB.<br>
codegen: inject the C generated from Nim into the target IDE and build/debug from IDE.<br><br>
invoke ```build.nims``` NimScript: ```nim -d:[mode] -d:[backend] Sources/build.nims Sources/tutorial01/prog.nim```<br><br>
- dynamic library mode:
    - You must first generate the dll for your chosen backend.
    - From the Knim root directory, run: ```node Kinc/make --dynlib -g opengl``` or ```node Kinc/make --dynlib -g direct3d11```.
    - Open the solution in the ```build``` directory and build to get ```Kinc.dll```.
    - Rename to ```KincDirect3D11.dll``` or ```KincOpenGL.dll```.
    - Place dll in a folder called ```Deployment``` in the root (Windows).
    - ```nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/prog.nim```

- codegen inject mode:
    - Edit kincfile.js to point to your local nim/lib directory.
    - Customize ```build.nims``` Nimscript file for target compiler/cpu/os.
    - for Android, add ```ndk {abiFilters "arm64-v8a"}``` to the ```gradle.build```
    - ```nim -d:codegen -d:opengl Sources/build.nims Sources/prog.nim```

## Documentation

- Unfortunately there are no docs for [Kinc](https://github.com/Kode/Kinc) yet.
- Minimal Kha docs here: [Kha](http://kha.tech/).

## To do:

- [Lewis Lepton](https://www.youtube.com/playlist?list=PL4neAtv21WOmmR5mKb7TQvEQHpMh1h0po) - Kha Tutorial
