using Genie.Router, Genie.Requests, Genie.Renderer.Json
using .SimulationsController
using .Model

route("/", SimulationsController.agents)
route("/", method = POST, SimulationsController.infect)

"""route("/", method = POST) do
  enteredData=postpayload(:test, "Placeholder")
  "wuhu, range: dollar(enteredData) xD"
end"""

route("/g") do 
  serve_static_file("graph.html") 
end 

route("/api/v1/agents", SimulationsController.API.agents)

route("/data", method = POST) do
  print(rawpayload())

  json("yay, id: $(jsonpayload())")
end

route("/data", method = GET) do
  print(payload())

  json(Dict(
    "nodes"=> [
      Dict("id"=> "1", "health_status"=>"S"),
      Dict("id"=> "2", "health_status"=>"I")
    ],
    "links"=> [
      Dict("source"=> "1", "target"=> "2")
    ]))
end

route("/data", method = PUT) do
  if(rawpayload() == "step")
    print("yay", jsonpayload())
    new_model = SimulationsController.step()
    json(create_jsgraph(new_model))
  end
end

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