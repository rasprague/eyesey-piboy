-- on screen display (osd) module

local osd = {}

local w = {} -- a table of widths
local h = {} -- a table of heights
for i=1, 32 do 
  w[i] = of.getWidth()/i
  h[i] = of.getHeight()/i
end

local font_size
if of.getWidth() >= 1280 then
  font_size = 10
else
  font_size = 8
end
osdFont = of.TrueTypeFont()                          -- define font
osdFont:load("arial.ttf", font_size, true, true, true, 80, 200 )                        

if modeTitle == nil then modeTitle = "" end
if sceneName == nil then sceneName = "" end

local avg_in = 0

-- get some system info
local ip_address 
local wifi_network 
os.execute("hostname -I > /tmp/ipaddr.txt")
os.execute("iwgetid -r > /tmp/wifinet.txt")
local f = assert(io.open('/tmp/ipaddr.txt', "r"))
if f ~= nil then
  ip_address = f:read("*all")
  f:close(f)
end
-- i have two ip addresses, so just show the first one
local p = ip_address:find(" ")
ip_address = string.sub (ip_address, 1, p or -1)
local g = assert(io.open('/tmp/wifinet.txt', "r"))
if g ~= nil then
  wifi_network = g:read("*all")
  g:close(g)
end

-- midi
local active_notes = {}
for i=1, 128 do 
  active_notes[i] = 0
end

local trigger_sources = {
    "Audio",
    "LINK Quarter Note",
    "LINK Eighth Note",
    "MIDI Clock Quarter",
    "MIDI Clock Eighth Note",
    "MIDI Notes"
}

----------------------------------------------------
function osd.osd_button (state,shift)

  if state then
    of.pushMatrix()                             -- save 0,0,0 matrix
    of.translate( w[16], h[16] )
    of.setLineWidth( 1 )                        -- set the line width to 1 pixel

    bgc = of.getBackgroundColor()
    textColor = bgc:getInverted()

    if shift then 

      of.setColor( textColor ) 
      modetext = "Mode: " .. modeTitle .. " SHIFT"
      osdFont:drawString( modetext, 0, 0 )

      of.setColor( textColor ) 
      ascalepercent = round(ascale * 100, 2)
      ingaintext = "Input gain: " ..  ascalepercent .. "%"
      osdFont:drawString( ingaintext, 0, h[16] )

      of.setColor( textColor ) 
      trigsrctext = "Input Source: " ..  trigger_sources[trigsource]
      osdFont:drawString( trigsrctext, 0, h[16]*2 )

      of.setColor( textColor ) 
      midichtext = "MIDI Channel: " ..  midi_ch
      osdFont:drawString( midichtext, 0, h[16]*3 )
   
    else
    
    --outlineRect (16,-24, -36, w4 , 54) 
    of.setColor( textColor ) 
    modetext = "Mode: " .. modeTitle
    osdFont:drawString( modetext, 0, 0 )


    --outlineRect (16,-24, 32, w4 , 54) 
    of.setColor(textColor)
    scenetext = "Scene: " .. sceneName
    osdFont:drawString( scenetext, 0, h[16] )

    
    -- Knobs 
    of.setColor(textColor)
    knobstate = "Knobs: " 
    -- .. math.floor(knob1*100) .. " | " .. math.floor(knob2*100) .. " | " .. math.floor(knob3*100) .. " | " .. math.floor(knob4*100) .. " | " .. math.floor(knob5*100) .. " | "
    osdFont:drawString( knobstate, 0, h[16]*2 )
    
    kRectY = h[16]*2     
    -- Knob rectangle outlines
    of.noFill()
    of.drawRectangle( w[16]+20, kRectY, 20, -h[16] )
    of.drawRectangle( w[16]+40, kRectY, 20, -h[16] )
    of.drawRectangle( w[16]+60, kRectY, 20, -h[16] )
    of.drawRectangle( w[16]+80, kRectY, 20, -h[16] )
    of.drawRectangle( w[16]+100, kRectY, 20, -h[16] )

    -- Knob rectangle fills
    of.setColor(192)
    of.fill()
    kBox1 = of.Rectangle ( w[16]+21, kRectY-1, 18, h[16]-1 )
    kBox2 = of.Rectangle ( w[16]+41, kRectY-1, 18, h[16]-1 )
    kBox3 = of.Rectangle ( w[16]+61, kRectY-1, 18, h[16]-1 )
    kBox4 = of.Rectangle ( w[16]+81, kRectY-1, 18, h[16]-1 )
    kBox5 = of.Rectangle ( w[16]+100, kRectY-1, 18, h[16]-1 )
    kBox1:scaleHeight(knob1*-1)
    kBox2:scaleHeight(knob2*-1)
    kBox3:scaleHeight(knob3*-1)
    kBox4:scaleHeight(knob4*-1)
    kBox5:scaleHeight(knob5*-1)

    of.drawRectangle(kBox1)
    of.drawRectangle(kBox2)
    of.drawRectangle(kBox3)
    of.drawRectangle(kBox4)
    of.drawRectangle(kBox5)

    -- Trigger    
    of.setColor(textColor)
    triggerstate = "Trigger: "
    osdFont:drawString( triggerstate, 0, h[16]*3 )
    if trig then
        of.drawRectangle( w[10], h[16]*3 - h[24], h[24], h[24] )
    else
        of.noFill() -- draw just the outline
        of.drawRectangle( w[10], h[16]*3 - h[24] , h[24], h[24] )
    end

    -- Audio Input Level    
    --outlineRect (16,-24, h[16]*3 + 32, w[4] , 54) 
    lRectY = h[16]*4
    inputleveltext = "Input Level: "
    osdFont:drawString( inputleveltext, 0, lRectY )
    of.setColor(0,255,0)
    of.fill()
    lBox1 = of.Rectangle ( w[8]+10, lRectY-25, 1, 25 )
    lBox1:scaleWidth(math.abs(peak*200))
    of.drawRectangle(lBox1)

    -- Persist
    of.setColor(textColor)
    if persist then persistvalue = "Yes" else persistvalue = "No" end
    osdFont:drawString( "Persist: " .. persistvalue, 0, h[16]*5 )

    -- IP Address / wifi
    osdFont:drawString( "IP Address: " .. ip_address, 0, h[16]*6 )
    osdFont:drawString( "Network: " .. wifi_network, 0, h[16]*7 )
    
    -- MIDI notes
    osdFont:drawString( "MIDI Notes: ", 0, h[16]*8 )
    yoff = 0
    mRectY = h[16]*8 - 20
    mRectX = w[16]+60

    if midi_msg[1] ~= nil then
      m = midi.to_midi_msg(midi_msg)
      if m.type == "note_on" then
        active_notes[m.note] = 1
      elseif m.type == "note_off" then
        active_notes[m.note] = 0
      end
    end
    for i=1, 128 do 
        if i <= 32 then 
          xoff = i*10
          yoff = 0
        elseif i > 32 and i <= 64 then 
          xoff = i*10 - 320
          yoff = 1
        elseif i > 64 and i <= 96 then 
          xoff = i*10 - 640
          yoff = 2
        elseif i > 96 and i <= 128 then 
          xoff = i*10 - 960
          yoff = 3
        end
        if active_notes[i] == 1 then
          of.fill() 
        else
          of.noFill()
        end
        of.drawRectangle( mRectX + xoff, (mRectY) + (10*yoff), 10, 10)
    end 
    end
    of.popMatrix()
  end 
end

function outlineRect (c,x,y,w,h)
    of.setColor( c )
    of.fill()
    of.drawRectangle(x, y, w , h)

end

function round(number, quant)
  if quant == 0 then
    return number
  else
    return math.floor(number/(quant or 1) + 0.5) * (quant or 1)
  end
end


return osd