using Genie.Router, Genie.Requests, Genie.Renderer.Json
using .SimulationsController
using .Model

route("/", SimulationsController.agents)

route("/", method = POST) do
  enteredData=postpayload(:test, "Placeholder")
  "wuhu, range: $(enteredData) xD"
end

route("/g") do 
  serve_static_file("graph.html") 
end 

route("/api/v1/agents", SimulationsController.API.agents)

route("/data", method = POST) do
  print(rawpayload())

  json("yay, id: $(rawpayload())")
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

