using GenieFramework
using Genie.Renderer.Html

include("model.jl")
using .Model
using Agents

@genietools

model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10)
@out const min = 0
@out const max = 50

@handlers begin
    @in agents_amount = 20 #default values so UI can be renderen when page loads
    @in alpha = 0.75
    @in auswahl = ["A", "B", "C"]
    @out value_agents = agents_amount
    @out value_alpha = alpha
    @out agents = allagents(model)
    @out list = html("<li> bla </li>") # anscheinend nicht so
    @onchangeany agents_amount, alpha begin
        value_agents = agents_amount
        value_alpha = alpha
        model2 = Model.initialize_model(number_of_agents = agents_amount, α = alpha, c2 = 0.1)
        agents = allagents(model2)
    end
end

@page("/", "app.jl.html")

# Server.isrunning() || Server.up()