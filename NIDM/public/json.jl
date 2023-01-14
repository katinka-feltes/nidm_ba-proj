import JSON
using Graphs

import Main.Model as Model
model = Model.initialize_model(number_of_agents = 10, α = 0.75, c2 = 0.1, Φ = 10)
Model.model_step!(model)

e = model.graph

open("test.json", "w") do f
    write(f, JSON.json(e))
end

input  = JSON.parse(open("test.json")) 

#result with different edges but same amount in total
resultGraph = SimpleGraph(length(input["fadjlist"]), input["ne"])