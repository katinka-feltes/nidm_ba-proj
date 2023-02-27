import Main.Model as Model
using Agents

model = Model.initialize_model()
model = Model.initialize_model(number_of_agents = 50, alpha = 1, c2 = 0.1)
model = Model.initialize_model(number_of_agents = 24, alpha = 0.75, c2 = 0.1, phi = 10) # Nunners Werte

Model.infect!(random_agent(model))

Model.model_step!(model)



for i in 1:30
  Model.model_step!(model)
end
Model.visualize(model)


#JSON EXPORT AND CONVERSION
import JSON
using Graphs

import Main.Model as Model
model = Model.initialize_model(number_of_agents = 10, alpha = 0.75, c2 = 0.1, phi = 5)
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
)

using Random
testSet = Set([1,2,3,1,4,5])
shuffle(collect(testSet))"""

#from rotes.jl
"""route("/", method = POST) do
    enteredData=postpayload(:test, "Placeholder")
    "wuhu, range: dollar(enteredData) xD"
  end"""

"""json(Dict(
    "nodes"=> [
      Dict("id"=> "1", "health_status"=>"S"),
      Dict("id"=> "2", "health_status"=>"I")
    ],
    "links"=> [
      Dict("source"=> "1", "target"=> "2")
]))"""
"""
# Launch the server on a specific port, 8002
# Run the task asynchronously
up(8002, async = true)"""