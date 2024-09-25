import sdl2_nim/sdl
discard sdl.init(sdl.InitEverything)
discard sdl.createWindow("SDL2 most basic example", 0, 0, 640, 480, 0)
delay(5000) #In miliseconds - 1000 == 1 second #You need a loop for anything other than a frozen window