###########################################################################
# Configuration
###########################################################################
D = 2 # pair length to decide from
final = 3 # I want to have approximatelly 3 ideas in the end


###########################################################################
# Actual Program
###########################################################################
include("tools.jl")
using Pkg
Pkg.activate(@__DIR__)
using Statistics, BSON, DelimitedFiles, Random
using REPL.TerminalMenus

function main(D, final)

    ideas = sort!(vec(readdlm("ideas.txt", '\n', String)))
    N = length(ideas)

    rounds = round(Int, log2(N/3))

    remaining = copy(ideas)
    original_idxs = collect(1:N)

    for r in 1:rounds
        println("Round n. $r. Choose your ideas...")
        rp = randperm(length(remaining))
        RN = length(remaining)
        todel = Int[]
        c = 0
        while c < RN
            j = min(RN - c, D)
            if j > 1
                selection = [remaining[rp[i+c]] for i in 1:j]
                si = request(RadioMenu(selection))
                if si == -1
                    error("Selection cancelled.")
                end
                selected = selection[si]
                append!(todel, [rp[c+sj] for sj in 1:j if sj ≠ si])
            else
                println("Only option remaining is: $(remaining[rp[j+c]]). "*
                "Accepted automatically.")
            end
            c += j
            move_cursor_up_while_clearing_lines(stdout, D)
        end
        deleteat!(remaining, sort!(todel))
    end

    println("Your final selections are:")
    println(remaining)
    result_idxs = [findfirst(isequal(res), ideas) for res in remaining]

    println("\nUpdating statistics now...")
    data = update_data(result_idxs, ideas)

    println("\nCurrent frequencies of your ideas:")
    sp = sortperm(data[:counts], rev = true)
    maxl = maximum(length(i) for i in ideas)
    for s ∈ sp
        idea = data[:ideas][s]
        cou = data[:counts][s]
        println(rpad(idea*":", maxl + 3), cou)
    end
    return data
end

main(D, final)
