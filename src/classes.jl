import Base.==

@enum EventType begin
	KeyPressed
	Nothing
end
mutable struct Event
	type::EventType
	key::Char
end
function ==(lhs::Event, rhs::Event)
	(lhs.type==rhs.type) && (lhs.key==rhs.key)
end
struct Xsection
	content::String
	x::Int
	y::Int
end
struct Frame
	parts::Array{Xsection,1}
end
function ==(lhs::Frame, rhs::Frame)
	return lhs.parts == rhs.parts
end
struct Animation
	frames::Array{Frame,1}
end
mutable struct AnimationInterface
	frameNum::Int # The current frame
	numFrames::Int # The total number of frames
	loopNum::Int # The current loop
	numLoops::Int # The total number of loops
	priority::Int
	finished::Bool # Whether or not the animation is finished
	name::String # The name of the animation
	idleName::String
	animations::Dict{String,Animation}
	priorities::Dict{String,Int}
	#function AnimationInterface(numLoops, idleName, animations)
	#	new(1, 1, 1, numLoops, false, idleName, idleName, animations, [0 for i in 1:length(animations)])
	#end
	#frames::Queue{Frame,1} # The frames of this animation
end
#function copy(a::AnimationInterface)
#	AnimationInterface(a.frameNum, a.numFrames, a.loopNum, a.numLoops, a.finished, a.name, a.priority)
#end
mutable struct BehaviorInterface
	frameNum::Int # The current frame
	numFrames::Int # The total number of frames
	loopNum::Int # The current loop
	numLoops::Int # The total number of loops
	priority::Int # The priority of this behavior
	finished::Bool # Whether or not the behavior is finished
	name::String # The name of the behavior
	idleName::String # Which behavior to do by default
	priorities::Dict{String,Int}
end
mutable struct Character
	x::Int
	y::Int
	#behaviorInterface::BehaviorInterface
	animationInterface::AnimationInterface
	#function Character()
	#	ai =
	#	new(0, 0, ai)
	#end
end
struct World
	y::Int
end
mutable struct Game
	notEnd::Bool
	fps::Number
	character::Character
	world::World
	function Game(fps::Number, idleAnimation::String, animationPaths::Array{String,1})
		animations = loadAnimations(animationPaths)
		priorities = Dict([(key,0) for key in keys(animations)])
		ai = AnimationInterface(1, 1, 1, 1, 0, false, idleAnimation, idleAnimation, animations, priorities)
		c = Character(5, 11, ai)
		w = World(11)
		#println(world.y)
		new(true, fps, c, w)
	end
end
