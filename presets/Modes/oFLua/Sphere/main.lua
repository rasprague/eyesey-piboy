require("eyesy")

modeTitle = "Sphere"       -- name the mode

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
w16 = w / 16                  -- width 16th
h16 = h / 16                  -- height 16th
c = glm.vec3( w2, h2, 0 )   -- center in glm vector

num=8

----------------------------------------------------
function setup()
    of.noFill()
	  bg = of.Color()
	  fg = of.Color()

    --------------------- define light
    myLight = of.Light()                -- define a light class
    myLight:setSpotlight(60, 1 )            -- we'll use a point light for this example
    --myLight:setSpotlightCutOff(.1)
  	myLight:setAmbientColor( of.FloatColor( 1, 1, 1 ) ) -- and make the ambient color white
  	myLight:setSpecularColor( of.FloatColor( 255, 255, 255 ) ) 
    myLight:setPosition( c + glm.vec3(-h4,-h2,h) ) -- and set the position in the center with z closer
  
   	knob3 = 0.5
   	knob4 = 0.5
   
end

----------------------------------------------------
function update()
  colorPickHsb( knob5, bg )
  of.setBackgroundColor( bg )
end

----------------------------------------------------
function draw()
    -- OSD
    osd.osd_button (osd_state)
    
    cool = knob4*255
    amplitude = 1000 + knob3*3000   
    --of.setLineWidth(knob1 * 20+1)   
    --of.setColor(cool, cool, cool, knob5 * 255)
    of.noFill()
    
    --of.popMatrix()                              -- recall the 0,0,0 matrix
    of.pushMatrix()

    of.translate(w/2, h/2 - 35)
    of.rotateXDeg(knob1*200)
    of.rotateYDeg(knob2*200)

    of.enableLighting()             -- enable lighting globally
    of.enableDepthTest()            -- enable 3D rendering globally
    of.enableAlphaBlending()
    myLight:enable()                -- begin rendering for myLight
    
    for i=1,num do
        audioR = math.abs(inR[ i * (256/num)] )
        colorPickHsb(  knob4 + audioR*2, fg )
        of.setColor( fg )
        --of.setColor(of.random(255), of.random(255), of.random(255), 225)
        of.noFill()
        loc = glm.vec3(i*(w/num)-w/2, 0, audioR)
        of.setSphereResolution(20);
        --of.drawSphere(loc, inL[i]*amplitude*2)
        --of.drawBox(loc, w/num, inL[i]*amplitude*2, inR[i]*amplitude)
        of.drawSphere(loc, inL[i*10]*amplitude/2)
    end

    myLight:disable()               -- end rendering for myLight
    of.disableLighting()            -- disable lighting globally
    of.popMatrix()

end

----------------------------------------------------
function draw3DScope(a, b, amplitude, axis, vertices)
    local stepx = (b.x - a.x) / vertices--256 max vertices
    local stepy = (b.y - a.y) / vertices--256 max vertices
    local stepz = (b.z - a.z) / vertices--256 max vertices
    of.beginShape()
    for i=1,vertices do
        if axis == 1 then
            of.vertex(a.x + stepx*i + inL[i]*amplitude, a.y + stepy*i, a.z + stepz*i)
        end
        if axis == 2 then
            of.vertex(a.x + stepx*i, a.y + stepy*i + inL[i]*amplitude, a.z + stepz*i)
        end
        if axis == 3 then
            of.vertex(a.x + stepx*i, a.y + stepy*i, a.z + stepz*i + inL[i]*amplitude)
        end
    end
    of.endShape()
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


----------------------------------------------------
function exit()
	print("script finished")
end