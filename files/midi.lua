--  midi module

local Midi = {}

function Midi.hello() 
    print("hi midi")
end

function Midi.to_midi_msg(data)
    -- data table structure
      -- (1, message.status);
      -- (2, message.channel);
      -- (3, message.pitch);
      -- (4, message.velocity);
      -- (5, message.control);
      -- (6, message.value);
      -- (7, message.portNum);
      -- (8, message.portName);

  local msg = {}
  -- note on
  if data[1] == 144 then
    msg = {
      note = data[3],
      vel = data[4],
      ch = data[2],
      --type = "note_on"
    }
    if data[4] == 0 then -- if velocity is zero then send note-off
      msg.type = "note_off"
    else 
      msg.type = "note_on" -- otherwise its a note-on
    end
  -- note off
  elseif data[1] == 128 then
    msg = {
      type = "note_off",
      note = data[3],
      vel = data[4],
      ch = data[2]
    }
  -- cc
  elseif data[1] + (data[2] - 1) == 176 then
    msg = {
      type = "cc",
      cc = data[5],
      val = data[6],
      ch = data[2]
    }
  -- program change
  elseif data[1] + (data[2] - 1) == 192 then
    msg = {
      type = "program_change",
      val = data[6],
      ch = data[2]
    }
  -- start
  elseif data[1] == 250 then
    msg.type = "start"
  -- stop
  elseif data[1] == 252 then
     msg.type = "stop"
  -- continue
  elseif data[1] == 251 then
    msg.type = "continue"
  -- clock
  elseif data[1] == 248 then
    msg.type = "clock"
  -- song position pointer
  elseif data[1] == 242 then
    msg = {
        type = "song_position",
        -- not sure how lsb/msb are sent
        --lsb = data[2],
        --msb = data[3]
    }
  -- song select
  elseif data[1] == 243 then
    msg = {
        type = "song_select",
        val = data[6]
    }
  end
  return msg
end

-- Get MIDI Data and set knob values
function Midi.knobs(msg_data)
    if msg_data[1] ~= nil then
      m = Midi.to_midi_msg(msg_data)
      --tab.print(m)
      if m.type == "cc" then
        if m.cc == 21 then
          knob1 = m.val/127
        end
        if m.cc == 22 then
          knob2 = m.val/127
        end
        if m.cc == 23 then
          knob3 = m.val/127
        end
        if m.cc == 24 then
          knob4 = m.val/127
        end
        if m.cc == 7 then
          knob5 = m.val/127
        end
      end

      --midi_msg = {} -- do I need to reset?
    end
end 

return Midi