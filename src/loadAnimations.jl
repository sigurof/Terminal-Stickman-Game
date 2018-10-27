import JSON
include("classes.jl")
function firstWord(line, separators::Array{Char,1})
    # Takes a string and returns the first word of the
    # sentence, where the word separator is taken to be
    # any Char in the separators input variable

    # Find start of word
    sow = -1
    i=1
    notFoundStartOfWord = true
    while notFoundStartOfWord && (i<=length(line))
        if !(line[i] in separators)
            notFoundStartOfWord=false
            sow = i
        end
        i+=1
    end
    if sow==-1
        return ""
    end
    # Find end of word
    i = 2
    notFoundEndOfWord = true
    while i <= length(line) && notFoundEndOfWord
        letter = line[i]
        if letter in separators
            notFoundEndOfWord = false
        else
            i += 1
        end
    end
    eow = i-1

    # return
    line[sow:eow]
end

firstWord(line::String, separator::Char) = firstWord(line, [separator])
firstWord(line::String) = firstWord(line, [' ', '\t'])

function wordsStartEnd(line::String, separators::Array{Char,1})
    lastLetterWasSeparator = true
    i = 1
    wse = Array{Tuple{String,Int64,Int64},1}()
    while i <= length(line)
        if !(line[i] in separators)
            if lastLetterWasSeparator
                sow = i # start of word
                word = firstWord(line[sow:length(line)], separators)
                eow = sow + length(word) - 1 # end of word
                i = eow
                push!(wse,(word,sow,eow))
            end
        else
            lastLetterWasSeparator = true
        end
        i+=1
    end
    wse
end

wordsStartEnd(line::String, separator::Char) = wordsStartEnd(line,[separator])
wordsStartEnd(line::String) = wordsStartEnd(line,[' ','\t'])


function makeXsections(l::String, xoff::Int64, yoff::Int64)
    [Xsection(word_begin_end[1], word_begin_end[2] + xoff - 1, yoff) for word_begin_end in wordsStartEnd(l)]::Array{Xsection,1}
end

function makeFrame(fd::Dict{String,Any})
    # Takes a dict with the stick figure as a string and
    # its x, y position and returns a Frame object

    # stick figure lines
    sflines = [String(line) for line in split(fd["string"],"\n")]
    x = fd["x"]::Int64
    y = fd["y"]::Int64
    # For each separate line in the stick figure
    xsections = Array{Xsection,1}()
    for line in sflines
        append!(xsections, makeXsections(line, x, y))
        y-=1
    end
    Frame(xsections)
end

function loadAnimation(path::String)
    # Takes a path and returns a name
    # and an Animation
    anim = JSON.parsefile(path::String)
    @assert length(anim["times"]) == length(anim["frames"])
    frames = Array{Frame,1}()
    i = 1
    for frameData in anim["frames"]
        frame = makeFrame(frameData)
        for j in 1:anim["times"][i]
            push!(frames, frame)
        end
    end
    anim["name"], Animation(frames)
end


function loadAnimations(paths)
    # Loads animations to a dictionary by animation name
    tuples = Array{Tuple{String,Animation},1}()
    for path in paths
        name, animation = loadAnimation(path)
        push!(tuples,(name,animation))
    end
    Dict(tuples)
end
