using Dates

function initialize_data(ideas)
    data = Dict{Symbol, Any}()
    data[:ideas] = sort!(ideas)
    data[:choices] = Vector{Vector{String}}()
    data[:dates] = Vector{DateTime}()
    data[:counts] = zeros(Int, length(ideas))
    return data
end

function update_data(result_idxs, ideas)
    if isfile(joinpath(@__DIR__, "data.bson"))
        data = BSON.load("data.bson")
    else
        data = initialize_data(ideas)
    end
    if sort(data[:ideas]) ≠ sort(ideas)
        error("The test was done while the `ideas.txt` file has changed."*
        "We cannot update the results! Start a new project!")
    end
    push!(data[:choices], [ideas[i] for i in result_idxs])
    push!(data[:dates], Dates.now())
    for i in result_idxs
        data[:counts][i] += 1
    end
    BSON.bson(joinpath(@__DIR__, "data.bson"), copy(data))
    return data
end

# Contributed by Lyndon White, Github tag @oxinabox
# on the official Julia Slack.
module Cursor
    # note that  \u1b  is in decimal 033, which is an escape code
    const ERASE_TO_EOL = "\u1b[K"
    const UP1 = "\u1b[A"
    up(n) = "\u1b[$(n)A"
    const MOVE_TO_SOL = "\r" #Carriage Return
end

function move_cursor_up_while_clearing_lines(io, numlinesup)
    for _ in 1:numlinesup
        print(io, "\r" * "\u1b[K" * "\u1b[A")
    end
    print(io, "\r" * "\u1b[K" * "\r")
end
