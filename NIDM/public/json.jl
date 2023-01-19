import JSON
using Graphs

import Main.Model as Model
model = Model.initialize_model(number_of_agents = 10, α = 0.75, c2 = 0.1, Φ = 5)
Model.model_step!(model)
Model.infect!(model.agents[5])

function create_jsgraph(model)
    links = []
    for i in 1:length(model.graph.fadjlist)
        for target in model.graph.fadjlist[i]
            push!(links, Dict(
                "source" => i,
                "target" => target
            ))
        end
    end

    return Dict(
        "nodes" => [a for a in values(model.agents)],
        "links" => links
    )
end

#agents test 
open("test.json", "w") do f
    write(f, JSON.json(create_jsgraph(model)))
end

"""
e = model.graph

open("test.json", "w") do f
    write(f, JSON.json(e.fadjlist))
end

input  = JSON.parse(open("test.json")) 

#result with different edges but same amount in total
resultGraph = SimpleGraph(length(input["fadjlist"]), input["ne"]
)"""