---- Video Example
require("eyesy")                    -- include the eyesy library
modeTitle = "Example - Video"       -- name the mode
print(modeTitle)                    -- print the mode title

---------------------------------------------------------------------------
-- helpful global variables 
w = of.getWidth()           -- global width  
h = of.getHeight()          -- global height of screen
w2 = w / 2                  -- width half 
h2 = h / 2                  -- height half
w4 = w / 4                  -- width quarter
h4 = h / 4                  -- height quarter
w8 = w / 8                  -- width 8th
h8 = h / 8                  -- height 8th
c = glm.vec3( w2, h2, 0 )   -- center in glm vector



---------------------------------------------------------------------------
-- the setup function runs once before the update and draw loops
function setup() 
	  fg = of.Color()

    startTime = of.getElapsedTimeMillis()
    bTimerReached = false
    position = 0.1
    speed = 60
    colorspeed = 120
    start = 0
    knob1 = 0.25
    knob5 = 0.5
    
    ---------------- get the path to this directory
--    myDirect = of.Directory()                       -- define the Directory Class
--    thePath = myDirect:getAbsolutePath()            -- get current path
    thePath = "/home/pi/Eyesy/presets/Modes/oFLua/VIDEO/example_1_compressed.mp4"
    print("thePath", thePath )

    --------------------- video grabber
    vidGrabber = of.VideoGrabber()
    
    vidGrabber:setDeviceID(0)
    vidGrabber:setDesiredFrameRate(30)
    vidGrabber:setup(640, 480) --  ,width=1024,height=768,framerate=30/1
    grabW = vidGrabber:getWidth()
    grabH = vidGrabber:getHeight()
--    print(vidGrabber:listDevices())
    
--    myVid:load( thePath )
--    myVid:load( thePath .. "/example_1_compressed.mp4" )
--    myVid:setLoopState(1)
--    myVid:play()                   
    
   
--    of.enableBlendMode( of.BLENDMODE_ALPHA )
    --------------------- define light
--    myLight = of.Light()                                  -- define a light class
--    myLight:setPointLight( )                        -- we'll use a point light for this example
--    myLight:setAmbientColor( of.FloatColor( 1, 1, 1 ) ) -- and make the ambient color white
--    myLight:setPosition( c + glm.vec3(0,0,h2) )     -- and set the position in the center with z closer
    
  
    -- so we know that the setup was succesful
    print("done setup") 
end
---------------------------------------------------------------------------
-- update function runs on loop
function update()
    vidGrabber:update() -- update cam input

    elapsed = of.getElapsedTimeMillis() - startTime;
    if (elapsed >= speed and not bTimerReached) then
        bTimerReached = true       
        startTime = of.getElapsedTimeMillis()
        position = position + 0.01;
--        colorCycle( start, saturation, fg ) 
         
        if position > 1 then
          position = 0
        end
    else 
      bTimerReached = false
    end

--    myVid:update()
    
end

---------------------------------------------------------------------------
-- the main draw function also runs on loop
function draw()
    
    
    of.setBackgroundColor( 0 )        -- set background color to black
    of.setColor( 255, 255, 255, 255 )
        
    -------------------- enable modes for the scene
--    of.enableLighting()                         -- enable lighting globally
--    of.enableDepthTest()                        -- enable 3D rendering globally
--    myLight:enable()                            -- begin rendering for myLight
    
    --------------------- draw video
    of.pushMatrix()                             -- save (0,0,0) matrix
    of.translate( 0, 0 )                      -- move to top left, center
    scaleKnob = (knob1*2) + 0.1                 -- define a scale knob
    scaleX = scaleKnob * w2                     -- scale width
    scaleY = scaleKnob * h2                     -- scale height
    
    of.translate( -scaleX/2, -scaleY/2 )        -- translate to center
    
--    of.translate( 0, h2 ) 
    of.rotateDeg( knob2*360, 0,1,0 )            -- rotate on Y axis

    vidGrabber:draw(0, 0, grabW*2, grabH*2)
    of.popMatrix()                              -- recall matrix
    
    --------------------- bind to box
--    colorPickHsb( knob5  + position/4, fg )
    of.setColor( fg )
    fg:invert()

    of.pushMatrix()                             -- save (0,0,0) matrix
    of.translate( w2, h2 )                   -- top right, center

    of.rotateXDeg(position*2*180)
    of.rotateYDeg(position*180 + peak)
--    of.rotateDeg( knob3*360, 0,1,0 )            -- rotate on y axis
--    of.rotateDeg( knob4*360, 1,0,0 )            -- rotate on y axis
--    of.noFill()
--    of.drawBox(h4+10 + (h4 * peak * 2) )

    of.fill()
    vidGrabber:bind()                                -- bind the video texture to following shapes
--    of.setColor(255,255,0)
    of.drawBox(h4 + h4 * peak )                            -- draw the 3d box
    vidGrabber:unbind()                              -- unbind
    
    ------------------------ disable lighting and depth
--    myLight:disable()                           -- end rendering for myLight
--    of.disableLighting()                        -- disable lighting globally
--    of.disableDepthTest()                       -- enable 3D rendering globally
    of.popMatrix()                              -- recall last matrix
end

------------------------------------ Color Function
-- this is how the knobs pick color
function colorPickHsb( knob, name )
	-- middle of the knob will be bright RBG, far right white, far left black
	
	k6 = (knob * 5) + 1						-- split knob into 8ths
	hue = (k6 * 255) % 255 
	kLow = math.min( knob, 0.49 ) * 2		-- the lower half of knob is 0 - 1
	kLowPow = math.pow( kLow, 2 )
	kH = math.max( knob, 0.5 ) - 0.5	
	kHigh = 1 - (kH*2)						-- the upper half is 1 - 0
	kHighPow = math.pow( kHigh, 0.5 )
	
	bright = kLow * 255						-- brightness is 0 - 1
	sat = kHighPow * 255					-- saturation is 1 - 0
	
	name:setHsb( hue, sat, bright )			-- set the ofColor, defined above
end


---------------------------------------------------------------------------
------ function for audio average, takes the whole 100 pt audio buffer and averages.
function avG()  
    a = 0
    for i = 1, 100 do
        aud = math.abs( inL[i])
        a = a + aud
    end
    x = a / 100
    if( x <= 0.001 ) then
        x = 0
    else
        x = x
    end
    return  x
end  
-- the exit function ends the update and draw loops
function exit()

    vidGrabber:close()                        -- free the memory space

    -- so we know the script is done
    print("script finished")
end