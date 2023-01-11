using Genie.Router

route("/") do
  serve_static_file("NIDM.html")
end

route("/agents", SimulationsController.agents)

route("/new", SimulationsController.newmodel)