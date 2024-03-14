--- midi test
-- figuring out midi and seamstress


MusicUtil = require "musicutil"
note_display_name = '--'
counter = 0

Midi = midi.connect(1)
m_out = midi.connect()
m_in = midi.connect()

scale_names = {}
notes = {} -- this is the table that holds the scales' notes

s = require 'sequins'

arp = s{50,53,57}
timing = s{1/4,1/4,1/2,1/2,1/2}
transpose = 0

function init()

  for i = 1, #MusicUtil.SCALES do table.insert(scale_names, MusicUtil.SCALES[i].name) end

  params:add_separator('Scale Options')
  -- setting root notes using params
  params:add{
    type = "number", 
    id = "root_note", 
    name = "root note",
    min = 0, max = 127, default = 24, 
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function() build_scale() end
  } -- by employing build_scale() here, we update the scale

  -- setting scale type using params
  params:add{
    type = "option", 
    id = "scale", 
    name = "scale",
    options = scale_names, default = 5,
    action = function() build_scale() end
  } -- by employing build_scale() here, we update the scale

  build_scale() -- builds initial scale

  midi:connect(1)
  
  clock.run(play)
end


function build_scale()
  notes = MusicUtil.generate_scale(params:get("root_note"), params:get("scale"), 6)
  for i = 1, 64 do
    table.insert(notes, notes[i])
  end
end

function play_midi(note, vel, duration, chan)  
	m_out:note_on(note, vel, chan)
	clock.run(midi_note_off, note, duration, chan)
end

function midi_note_off(note, duration, chan)
	local note_time = clock.get_beat_sec() * duration
	clock.sleep(note_time)
	m_out:note_off(note, 0, chan)
end



function play()
	while true do
	  clock.sync(timing())
	  counter = counter + 1
	  play_midi(arp() + transpose,1,1/16,1)
	  redraw()
	end
  end





function redraw()
  screen.clear()
  screen.color(180, 255, 252, 0.8)

  screen.move(20, 20)
  screen.text('hello.')

  screen.move(20,30)
  screen.text('counting: ' .. counter)

  screen.refresh()
end


cleanup = function ()
	g:all(0)
	g:refresh()
end
