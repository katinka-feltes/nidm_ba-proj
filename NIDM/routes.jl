using Genie.Router, Genie.Requests
using .SimulationsController
using .Model

route("/", SimulationsController.agents)

route("/", method = POST) do
  enteredData=postpayload(:test, "Placeholder")
  "wuhu, range: $(enteredData) xD"
end

route("/new", SimulationsController.newmodel)

route("/g") do 
  serve_static_file("graph.html") 
end 

route("/new", SimulationsController.newmodel)

route("/api/v1/agents", SimulationsController.API.agents)
