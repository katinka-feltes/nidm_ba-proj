using Genie
using Genie.Router, Genie.Requests, Genie.Renderer.Json
#using .SimulationsController
using .Model
import JSON

#route("/agents", SimulationsController.agents)

m = Model.initialize_model(number_of_agents = 24, alpha = 0.75, c2 = 0.1, phi = 10)

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
    Model.model_step!(m)
    return json(create_jsgraph(m))
  end

  # else create a new model
  dict = JSON.parse(rawpayload())
  try 
    global m = Model.initialize_model(number_of_agents = dict["number_of_agents"], alpha = dict["alpha"], c2 = dict["c2"], 
                     sigma = dict["sigma"], gamma = dict["gamma"], tau = dict["tau"], r = dict["r"], phi = dict["phi"],)
  catch
    global m = Model.initialize_model()
    println("Error while creating the model")
  end
  return json(create_jsgraph(m))
end

# PUT response from the server
route("/data", method = PUT) do
  dict = JSON.parse(rawpayload())
  # infect the given agent
  agentToInfect = get(dict, "infect", false)
  agentToInfect != false && Model.infect!(m[agentToInfect]) == 'I' && return json("infected")


  print(keys(dict))
  # else change the property
  for prop in keys(dict)
    Model.set_property!(Symbol(prop), dict[prop], m)
    return json("Set $prop to  $(dict[prop])")
  end
  json("nothing done")
end

# GET response is the current state of the model from SimulationsController
route("/data", method = GET) do
  #global m = Model.initialize_model()
  json(create_jsgraph(m))
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

up()