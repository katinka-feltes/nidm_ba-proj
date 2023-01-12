using GenieFramework

include("model.jl")
using .Model
using Agents

@genietools

model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10)
const agents = allagents(model)

@handlers begin
  
end

@page("/", "app.jl.html")

# Server.isrunning() || Server.up()