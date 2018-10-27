using Dates
using REPL
using DataStructures
include("classes.jl")
include("loadAnimations.jl")
include("dinogame.jl")
animfiles=["run.json", "jump.json"]
animpaths = String["/home/sigurof/src/julia/projects/scrap/dinogame/gfx/" * filename for filename in animfiles]


term = REPL.Terminals.TTYTerminal(get(ENV, "TERM", @static Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
global keyboard_input = Queue{Char}()
global game = Game(15.0, "run", animpaths)
@async while game.notEnd
	enqueue!(keyboard_input, nextKey(term))
end
playing = play(game)
