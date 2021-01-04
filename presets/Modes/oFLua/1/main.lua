modeTitle = "Example - 1"		-- name the mode

require("eyesy")

----------------------------------------------------
function setup()
	of.noFill()
	bg = of.Color()
	knob1 = 0.1
	knob2 = 0.0
	knob3 = 0.5
	knob4 = 0.5
end

----------------------------------------------------
function update()
	colorPickHsb( knob5, bg )					-- color for drawings
	of.setBackgroundColor( bg )					-- set the bg color 

	midi.knobs(midi_msg)						-- update knobs with midi input

end

----------------------------------------------------
function draw()
	-- OSD
	osd.osd_button (osd_state,osd_shift) -- draw the on screen display when activated
	
	--print("knob1",knob1)
	cool = knob4*255

	of.setLineWidth(knob1*20+1)
  
	of.setColor(cool, cool, cool, knob5 * 255)
	of.fill()

	of.noFill()
	of.pushMatrix()
	of.translate(of.getWidth() / 2,of.getHeight()/2 - 35)

		len = knob3*of.getWidth()/2
		offsetX = knob2*500+3
	   
		--left line (when offsetX at 0)
		a = glm.vec3(offsetX, 0, 0)
		b = glm.vec3(offsetX-len, 0, 0)
		of.setColor(of.random(255), of.random(255), of.random(255), 255)
		draw3DScope(a,b,1000,2,256)
		
		--right line (when offsetX at 0)
		c = glm.vec3(offsetX*-1, 0,0)
		d = glm.vec3(offsetX*-1+len, 0,0)
		of.setColor(of.random(255), of.random(255), of.random(255), 255)
		draw3DScope(c,d,1000,2,256)

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