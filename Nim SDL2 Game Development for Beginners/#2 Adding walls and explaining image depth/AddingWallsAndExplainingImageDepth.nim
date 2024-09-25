#Things to do in order to make it work as of today 25th of September 2024(see -> for the fix):
  #RENAME: import sdl2/sdl, sdl2/sdl_image as img -> import sdl2_nim/sdl, sdl2_nim/sdl_image as img
  #ADD: import std/os
  #RENAME: "img/img1a.png" -> getAppDir() / "img/img1a.png"
  #RENAME: "img/wall.png" -> getAppDir() / "img/wall.png"

import std/os
import sdl2_nim/sdl, sdl2_nim/sdl_image as img #sdl2 -> sdl2_nim for both imports

const 
  Title = "SDL2 App"
  ScreenW = 640 #Window width
  ScreenH = 480 #Window height
  WindowFlags = 0

  #RendererFlags = hardware acceleration or Vsync
    #(syncronizing the Present/current frame with the refresh rate)
  RendererFlags = sdl.RendererAccelerated or sdl.RendererPresentVsync

type
  App = ref AppObj #Pointer to AppObj below
  AppObj = object
    window: sdl.Window #Window pointer
    renderer: sdl.Renderer #Rendering state pointer
    #sdl.Renderer is the object from SDL that will be
      #responsible for drawing our image to the screen inside the window

  Image = ref ImageObj
  ImageObj = object of RootObj
    #Image texture(this is what we call an image stored in the memory)
    texture: sdl.Texture 
    w, h: int # Image dimensions

  Wall = ref WallObj
  WallObj = object of RootObj
    image: Image 
    x, y: float64 #Adding x, y on top of texture and w, h

  Player = ref PlayerObj
  PlayerObj = object of RootObj
    image: Image 
    x, y: float64 #Adding x, y on top of texture and w, h
    speed: float64


####################
# IMAGE PROCEDURES #
####################

#This creates/initializes a new empty Image object
proc newImage(): Image = Image(texture: nil, w: 0, h: 0)

#This frees the given Image object of it's texture -> you should always clean after yourself
proc free(obj: Image) = sdl.destroyTexture(obj.texture)

#Procedure to load an image from a file
#Return true on success or false, if image can't be loaded
proc load(obj: Image, renderer: sdl.Renderer, file: string): bool =
  result = true

  #Load texture from file
  obj.texture = renderer.loadTexture(file)

  if obj.texture == nil: #nil -> nothing -> no image -> error
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't load image %s: %s",
                    file, img.getError())
    return false #Failed to load the image

  #Getting/retrieving image dimensions
  var w, h: cint #cint for interfacing with a C library

  #Getting/retrieving a "texture"'s width and height
  if obj.texture.queryTexture(nil, nil, addr(w), addr(h)) != 0:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't get texture attributes: %s",
                    sdl.getError())
    sdl.destroyTexture(obj.texture)
    return false

  #Here we give our "obj" object the width and height we retrieved above
  obj.w = w
  obj.h = h

#Rendering the texture onto the screen
proc render(obj: Image, renderer: sdl.Renderer, x, y: int): bool =
  #Rendering/drawing rectangle
  var rect = sdl.Rect(x: x, y: y, w: obj.w, h: obj.h)

  #Rendering our image by rendering a copy of it
  if renderer.renderCopy(obj.texture, nil, addr(rect)) == 0: #Error checking
    return true #Texture rendered succesfully
  else:
    return false #Failed rendering

##################################
# SDL boilerplate/necessary code #
##################################

#SDL initialization -> boilerplate code necessary for every SDL application
proc init(app: App): bool =
  #Initialize video AND timer, with error checking and logging
  if sdl.init(sdl.InitVideo or sdl.InitTimer) != 0:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't initialize SDL: %s",
                    sdl.getError())
    return false #This will exit "init" proc and terminate the program

  #Initialize/load SDL_Image dll shared library's .png format image support
  if img.init(img.InitPng) == 0: 
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't initialize SDL_Image: %s",
                    img.getError())

  #Creating our window(in windowed mode(default) -> you can see the borders)
  app.window = sdl.createWindow(
    Title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    ScreenW,
    ScreenH,
    WindowFlags)

  #Error checking for our window
  if app.window == nil:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't create window: %s",
                    sdl.getError())
    return false #On fail terminate the program

  #Creating the renderer that will draw/render our image
  app.renderer = sdl.createRenderer(app.window, -1, RendererFlags)

  #Error checking for the renderer
  if app.renderer == nil:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't create renderer: %s",
                    sdl.getError())
    return false #On fail terminate the program

  #Setting the draw color to black with error checking(colors and alpha must be in hexadecimal system)
  if app.renderer.setRenderDrawColor(0x00, 0x00, 0x00, 0xFF) != 0:
    sdl.logWarn(sdl.LogCategoryVideo,
                "Can't set draw color: %s",
                sdl.getError())
    return false #On fail terminate the program

  sdl.logInfo(sdl.LogCategoryApplication, "SDL initialized successfully")
  return true

#Shutdown proc(cleanup)
proc exit(app: App) =
  app.renderer.destroyRenderer()
  app.window.destroyWindow()
  img.quit()
  sdl.logInfo(sdl.LogCategoryApplication, "SDL shutdown completed")
  sdl.quit()

##############################
# EVENTS/EVENT HANDLING PROC #
##############################

#PARAMETERS: a changable(var keyword) sequence of sdl.Keycode type(raw input)
proc events(pressed: var seq[sdl.Keycode]): bool =
  result = false

  var e: sdl.Event #Variable to store an sdl.Event type data

  if pressed.len > 0: #if pressed.len > 0, then we have pressed a key
    pressed = @[] #Clearing the event sequence of any previous events

  #Process the keys(events) if any
  while sdl.pollEvent(addr(e)) != 0:
    #Pressing the window's X button
    if e.kind == sdl.Quit:
      return true #Terminate the program

    #If key pressed down, add it to the sequence
    elif e.kind == sdl.KeyDown:
      pressed.add(e.key.keysym.sym) #e.rawKey -> .keysym(lookup table).sym(to get the processed key)

    #Exit on ESC/Escape key press
      if e.key.keysym.sym == sdl.K_Escape:
        return true #Terminate

################
# MAIN PROGRAM #
################

var
  app = App(window: nil, renderer: nil)
  done = false #Main loop exit condition
  pressed: seq[sdl.Keycode] = @[] #Pressed keys

if init(app):
  #Player object setup
  var
    playerImage = newImage() #new empty image
    playerX = ScreenW div 2 - (playerImage.w / 2)
    playerY = ScreenH div 2 - (playerImage.h / 2)
    player = Player(image: playerImage, x: playerX, y: playerY, speed: 200.0)

  #Wall object and sequence holding multiple of them setup
  var
    wall = newImage() #For wall's image for rendering
    walls: seq[Wall]

  #Load the image, if not turn off the program
  if not playerImage.load(app.renderer, getAppDir() / "img/img1a.png"):
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't load image: %s",
                    img.getError())
    done = true #No error -> proceed

  #Load the image, if not turn off the program
  if not wall.load(app.renderer, getAppDir() / "img/wall.png"):
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't load image: %s",
                    img.getError())
    done = true #No error -> proceed

  #Horizontal wall placement
  var wallsX: float64 = 0.0

  while wallsX < ScreenW:
    walls.add Wall(image: wall, x: wallsX, y: 0.0) #Top
    walls.add Wall(image: wall, x: wallsX, y: (ScreenH - wall.h).float64) #Bottom
    wallsX += 32 #32 to the right

  #Vertical wall placement
  var wallsY: float64 = 0.0
  
  while wallsY < ScreenH:
    walls.add Wall(image: wall , x: 0.0, y: wallsY) #Left
    walls.add Wall(image: wall , x: (ScreenW - wall.w).float64, y: wallsY) #Right
    wallsY += 32 #32 downwards

  var
    delta = 0.0 #Time passed since last frame in seconds(float is required)
    ticks: uint64 #Ticks counter - empty for now
    #Gets us the high performance counter frequency
      #or in other words, the speed our processor is running at
    freq = sdl.getPerformanceFrequency()

  #We will use arrow keys to move our image
  echo "Use arrow keys to move the image"

  ######################
  # START OF RENDERING #
  ######################
  ticks = getPerformanceCounter()

  #Main loop
  while not done: #if done = false -> we had an error -> terminate

    #Clear screen with draw color
    discard app.renderer.setRenderDrawColor(0x00, 0x00, 0x00, 0xFF) #returns "true" or "false"
    if app.renderer.renderClear() != 0: #Clearing the screen with black color with error checking 
      sdl.logWarn(sdl.LogCategoryVideo,
                  "Can't clear screen: %s",
                  sdl.getError())

    #Rendering/drawing all the Wall objects using shared wall texture
    for w in walls:
      discard wall.render(app.renderer, w.x.int, w.y.int)

    #Rendering/drawing the Player object texture
    discard playerImage.render(app.renderer, player.x.int, player.y.int)

    #Presenting/drawing the changes we have made
    app.renderer.renderPresent()

    #Event handling - Key proccessing
      #if done = false -> we pressed X button or ESC -> exit
    done = events(pressed) 

    #Calculating the delta(frame duration)
    delta = (sdl.getPerformanceCounter() - ticks).float / freq.float

    #Capturing the high performance counter for usage on the next main loop run
    ticks = sdl.getPerformanceCounter()

    #Get a snapshot of the current state of the keyboard.
    let kbd = sdl.getKeyboardState(nil)

    #Player object movement with arrow keys
    if kbd[ScancodeUp]    > 0: player.y -= player.speed * delta 
    if kbd[ScancodeDown]  > 0: player.y += player.speed * delta 
    if kbd[ScancodeLeft]  > 0: player.x -= player.speed * delta 
    if kbd[ScancodeRight] > 0: player.x += player.speed * delta

  #Once the game loop is done we free our image's memory
    #to prevent memory leaks etc 
  free(playerImage)
  free(wall) #Will clear the texture from ALL the walls

#If we press the X button on the SDL window, Escape button 
  #or something goes wrong we end up here, and we cleanup after ourselves
exit(app)