using Genie.Router
using .SimulationsController
using .Model

route("/") do
  serve_static_file("NIDM.html")
end

route("/agents", SimulationsController.agents)

route("/new", SimulationsController.newmodel)

route("/api/v1/agents", SimulationsController.API.agents)