using Genie
using Genie.Router, Genie.Requests, Genie.Renderer.Json
using .SimulationsController
using .Model

route("/agents", SimulationsController.agents)

route("/g") do 
  serve_static_file("graph.html") 
end 

route("/") do 
  serve_static_file("view.html") 
end 

#API
# POST response from the server
route("/data", method = POST) do
  if(rawpayload() == "step")
    print("step")
    new_model = SimulationsController.step()
    json(create_jsgraph(new_model))
  end
end

# GET response is teh current state of the model from SimulationsController
route("/data", method = GET) do
  json(create_jsgraph(SimulationsController.model))
end

# Function to create a Dict that is in the correct form for javascript
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