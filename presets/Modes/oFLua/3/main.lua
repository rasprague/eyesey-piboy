require("eyesy")

modeTitle = "Example - 3"       -- name the mode

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

num=256

----------------------------------------------------
function setup()
    of.noFill()
    
end

----------------------------------------------------
function update()
end

----------------------------------------------------
function draw()
    -- OSD
    osd.osd_button (osd_state)
    
    cool = knob4*255
    amplitude = 1000+knob3*3000   
    of.setLineWidth(knob1*20+1)   
    of.setColor(cool, cool, cool, knob5 * 255)
    of.noFill()
    
    --of.popMatrix()                              -- recall the 0,0,0 matrix
    of.pushMatrix()

    of.translate(w/2, h/2 - 35)
    of.rotateXDeg(knob1*600)
    of.rotateYDeg(knob2*600)
    
    for i=1,num do
        of.setColor(of.random(255), of.random(255), of.random(255), 255)
        of.fill()
        loc = glm.vec3(i*(w/num)-w/2, 0, 0)
        of.drawBox(loc, w/num, inL[i]*amplitude*2, inR[i]*amplitude)
    end

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

----------------------------------------------------
function exit()
	print("script finished")
end