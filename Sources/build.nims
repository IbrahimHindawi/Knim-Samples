
import os
import strutils

mode = ScriptMode.Verbose 

proc echoYellow*(phrase: string) =
  echo "\e[33m", "[Build] ", phrase, "\e[0m "

proc echoError*(phrase: string) =
  echo "\e[31m", "[Build] ", phrase, "\e[0m "

proc cleanBuildAndCache( buildDir:string, nimCacheDir:string ) = 
  #rmDir(buildDir)
  rmDir(nimCacheDir)

proc makeDir(dirName:string) =
  if dirExists(dirName):
    echoYellow dirName & " directory found in root."
  else:
    mkdir(dirName)
    echoYellow dirName & " directory not found, creating in root."

echoYellow "Executing NimScript . . ."

#[
  TODO(ibrahim): make nimnble package
]#

const
  progName = "prog"
  
  dynamic = "dynamic"
  codegen = "codegen"

  Direct3D11 = "Direct3D11"
  OpenGL     = "OpenGL"

  pathcmd  = " --path:../Knim-Standalone/Knim "
  nimcache = "NimCache"

var
  clargs = commandLineParams()

if clargs.len < 4:
  echoError "Fatal Error: bad build command."
  echoError "nim -d:[backend] -d:[mode] Sources/build.nims [programfile]"
  echoError "Build Terminated."
  
var  
  target = clargs[3]
  
  genPath = target

  cwd = getCurrentDir()
  dynPath = relativePath(cwd & "/" & target, cwd & "/" & "Deployment")

cleanBuildAndCache("build", nimcache)

var
  backend = ""

if defined(Direct3D11):
  echoYellow "Backend: " & Direct3D11
  backend = Direct3D11
  switch("define", Direct3D11)

elif defined(OpenGL):
  echoYellow "Backend: " & OpenGL
  backend = OpenGL
  switch("define", OpenGL)

else:
  echoError "Backend: Unknown!"
  echoError "Please choose a backend:"
  echoError "direct3d11 or opengl"
  echoError "Build Terminated."
  exec "nim c -r BUILDFAILED_NO_BACKEND.nim"

#[
  SHARED VARIABLES
]#
var
  runmode = ""

#[
  DYNAMIC:
    Depends on having a dynamic library in the Deployment directory!
    Generate dynamic library using `node kinc\make --dynlib <backendname>
]#

if defined(dynamic):
  let
    deploymentDir = "Deployment"
    deploymentCmd = " --outdir:. "

  runmode = dynamic
  echoYellow "Dynamic Mode Selected"

  makeDir(deploymentDir)
  
  exec "node Kinc/make.js" & " --graphics " & backend.toLower()

  cd(deploymentDir)

  echoYellow "Dynamic Mode Command:"
  exec "nim c -r " & deploymentCmd & pathcmd & " -g --debugger:native " &
    " -d:" & backend & 
    " -d:" & runmode & 
    " " & dynPath
  
  echoYellow "Finished NimScript Build"

#[
  CODEGEN:
    Codegen injection into target IDE. 
    You need to setup the correct variables!
    https://nim-lang.github.io/Nim/nimc.html#crossminuscompilation

]#

elif defined(codegen):

  let
    compiler = "vcc"
    opersyst = "windows"
    cpuarchi = "amd64"
    # androidNDK = "androidNDK"

  runmode  = codegen
  echoYellow "Codegen Mode Selected"

  echoYellow "Codegen Injection Command: "
  exec "nim "     & "c "     & "--noMain " & "--compileOnly " & pathcmd &
    "--cc:"       & compiler & " " &
    "--os:"       & opersyst & " " &
    "--cpu:"      & cpuarchi & " " &
    "--nimcache:" & nimcache & " " &
    "--header:"   & progName & ".h " &
    "-d:"         & backend  & " " &
    "-d:"         & runmode  & " " &
    genPath

  echoYellow "Building With External IDE "
  exec "node Kinc/make.js" & " --graphics " & backend.toLower() & " --compile " & " --run "

  echoYellow "Finished NimScript"

#[
  EXAMPLE CROSS COMPILATION COMMANDS
  android
    nim compile --cc:clang --os:android --cpu:arm64 --d:androidNDK --compileOnly --nimcache:Knim-Standalone\cache -d:OpenGL -d:codegen --noMain --header:prog.h Knim-Standalone\Knim\prog.nim
    ndk {abiFilters "arm64-v8a"}
  windows
    nim compile --cc:vcc --compileOnly --nimcache:NimCache --noMain --header:prog.h -d:Direct3D11 -d:codegen Sources\prog.nim
]#

else:
  echoError "Mode: Unknown!"
  echoError "Please choose a Mode"
  echoError "dynamic or codegen"
  echoError "Build Terminated."
  exec "nim c -r BUILDFAILED_NO_MODE.nim"