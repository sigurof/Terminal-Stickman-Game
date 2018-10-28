#
#
#             o
#           /||\/
#           \||                                ______
#            /\                                |    |
#          \/  \                               |    |
# ______________\______________________________|____|______

using REPL
#include("classes.jl")

function hideCursor()
	# Hides cursor
    write(stdout, "\x1b[?25l")
end
function clear(t::REPL.Terminals.TTYTerminal)
	# Clears the terminal
	if Sys.iswindows() && t.term_type==""
		REPL.Terminals.clear(t)
	else
		Base.run(`clear`);
	end
end
readNextChar(stream::IO=stdin) = Char(read(stream, UInt8)[1])
function nextKey(t::REPL.Terminals.TTYTerminal)
	# Access to the current terminal
	REPL.Terminals.raw!(t, true)
	c = readNextChar()
	#print("Code: $(UInt32(c)), Char: $(Char(c))")
	REPL.Terminals.raw!(t, false)
	return c
end
function pollKeyboard!(inputQ::Queue{Char})
	c = ' '
	t = Nothing::EventType
	if length(inputQ) > 0
		c = dequeue!(inputQ)
		t = KeyPressed::EventType
	end
	Event(t, c)
end
function getCurrentFrame(ai::AnimationInterface)
	ai.animations[ai.name].frames[ai.frameNum]
end
function drawCharacter(c::Character)
    # Draws the character
	frame = getCurrentFrame(c.animationInterface)
	for xsection in frame.parts
		y = repr(-xsection.y + c.y)
		x = repr(xsection.x + c.x)
		write(stdout, "\x1b[" * y * ";" * x * "H", xsection.content)
		#write(stdout, "\x1b[25;25H", x, " ", y)
	end
end
function drawWorld(w::World)
    # Draws the world
	write(stdout, ("\x1b[" * "$(w.y)" * ";1H"), "_____________________________")
	#write(stdout, "\x1b[")
end
function draw(g::Game)
    # Draws the scene
    drawWorld(g.world)
    drawCharacter(g.character)
end
function processKeyboardInput!(event::Event, game::Game)
	if event.type == KeyPressed
		if event.key == 'q'
			println("quitting!")
			game.notEnd = false
		elseif event.key == ' '
			game.character.animationInterface.priorities["jump"]=2
			#println("jumped!")
		end
	end
end
function update!(ai::AnimationInterface)
	ai.frameNum += 1
	if ai.frameNum > ai.numFrames
		ai.frameNum = 1
		ai.loopNum += 1
	end
	if ai.loopNum > ai.numLoops
		ai.finished = true
		ai.priority = 0
	end
end
function attemptIdleAnimation(ai::AnimationInterface)
	# Sets the priorit of the idle animation (run) to 1
	ai.priorities[ai.idleName] = 1
end
function getHighestPriorityAnimationName(priorityByName::Dict{String, Int})
	ks = collect(keys(priorityByName))
	keyOfHighestPriority = ks[1]
	for key in ks
		if priorityByName[key] > priorityByName[keyOfHighestPriority]
			keyOfHighestPriority = key
		end
	end
	keyOfHighestPriority
end
function tryToChangeAnimation!(ai::AnimationInterface)
	# Updates the character's animation each frame
	# by selecting the attempted animation of highest
	# prioriy value. The currently active animation is
	# only changed if the attempted animation has a higher
	# priority value.
	newName = getHighestPriorityAnimationName(ai.priorities)
	newPriority = ai.priorities[newName]
	newNumFrames = length(ai.animations[newName].frames)
	if newPriority > ai.priority
		ai.frameNum = 1
		ai.numFrames = newNumFrames
		ai.loopNum = 1
		ai.numLoops = 1
		ai.finished = false
		ai.name = newName
		ai.priority = newPriority
	end
end
function reset!(priorityByName::Dict{String,Int})
	# Resets the priority of ech animation to zero
	# pa = possible animations
	for key in keys(priorityByName)
		priorityByName[key] = 0
	end
end
function play(game::Game)
	dt = 1.0 / Float64(game.fps)
	lastInstant = now().instant

	# Hide cursor
	hideCursor()

	# Start main loop
	while game.notEnd

	# Check for keyboard input and apply it
		event = pollKeyboard!(keyboard_input)
		processKeyboardInput!(event, game)

	# If time since last draw call is more than dt, update and draw
		timeElapsed = Float64((now().instant - lastInstant).value) / 1000.0
		if timeElapsed > dt
			lastInstant = now().instant

	# Update character behavior
			attemptIdleAnimation(game.character.animationInterface)
			update!(game.character.animationInterface)
			tryToChangeAnimation!(game.character.animationInterface)
			reset!(game.character.animationInterface.priorities)

	# Clear screen and draw
			clear(game.terminal)
        	draw(game)
		end
	end

	# Show cursor again
	write(stdout, "\x1b[?25h]")
end
