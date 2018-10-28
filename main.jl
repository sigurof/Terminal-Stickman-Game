using Dates
using REPL
using DataStructures
# TODO: check if user has these and suggest to install by Pkg.add

include("src/classes.jl")
include("src/loadAnimations.jl")
include("src/dinogame.jl")
animfiles=["run.json", "jump.json"]
animpaths = String["./gfx/" * filename for filename in animfiles]


term = REPL.Terminals.TTYTerminal(get(ENV, "TERM", @static Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)

global keyboard_input = Queue{Char}()
global game = Game(15.0, "run", animpaths, term)
@async while game.notEnd
	enqueue!(keyboard_input, nextKey(term))
end
playing = play(game)
