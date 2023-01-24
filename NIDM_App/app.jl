using GenieFramework
import JSON
using Graphs
include("model.jl")
using .Model
using Agents

@genietools

model = Model.initialize_model(number_of_agents = 20)
@out const red = "red"
@out const green = "green"
@out const min = 0
@out const min1 = 1
@out const steps_small = 0.1
@out const max_agents = 50
@out const max1 = 1
@out const two = 2
@out const max_σ = 10
@out const max_τ = 50
@out const step_button_label = "Step"
@out const reset_button_label = "Reset"

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

function amount_health_status(c::Char, model)
    amount = 0
    for agent in allagents(model)
        if agent.health_status == c
            amount += 1
        end
    end
    return amount
end

"""
# doesn't work yet because sigma is reactive Int (:
function how_severe(s)
    sigma = convert(Int64, s)
    sigma >= 8 && return "sehr ansteckend - z.B. Covid-19"
    sigma >= 5 && return "mittelmäßig ansteckend - z.B. Windpocken"
    return "leicht ansteckend - z.B. Grippe"
end """

@handlers begin
    
    model = Model.initialize_model(number_of_agents = 20)

    # all variables
    @in agents_amount = 20 #default values so UI can be rendered when page loads
    @in alpha = 0.75
    @in cost2 = 0.1
    @in risk = 0.5
    @in sigma = 5
    @in gamma = 0.5
    @in tau = 10
    @in Phi = 10
    @in step = 0
    @in reset = 0
    @out value_agents = agents_amount
    @out value_alpha = alpha
    @out value_cost2 = cost2
    @out value_risk = risk
    @out value_σ = sigma
    @out value_γ = gamma
    @out value_τ = tau
    @out value_Φ = Phi
    @out max_Φ = 50
    @out agents = allagents(model)
    @out susceptible = agents_amount
    @out infected = 0
    @out recovered = 0
    @out timestep = 0

    # buttons
    @onchange step begin
        @info "step_button pressed"
        timestep += 1
        Model.infect!(random_agent(model))
        Model.model_step!(model)
        agents = allagents(model)
        susceptible = amount_health_status('S', model)
        infected = amount_health_status('I', model)
        recovered = amount_health_status('R', model)
    end
    @onchange reset begin
        @info "reset_button pressed"
        model = Model.initialize_model(number_of_agents=20)
        agents = allagents(model)
        agents_amount = 20
    end

    # parameter changes
    @onchangeany isready, agents_amount, alpha, cost2, risk, sigma, gamma, tau, Phi  begin
        print("Bla")
        timestep = 0
        value_agents = agents_amount
        max_Φ = agents_amount-1
        value_alpha = alpha
        value_cost2 = cost2
        value_risk = risk
        value_σ = sigma
        value_γ = gamma
        value_τ = tau
        value_Φ = Phi
        model = Model.initialize_model(number_of_agents=agents_amount, α=alpha, c2=cost2, σ=sigma, γ=gamma, τ=tau, Φ=Phi) #(number_of_agents=30, α=0.5, c2=0.55, σ=5, γ=0.5, τ=10, r=0.5, Φ=10, seed=0)
        agents = allagents(model)
        susceptible = amount_health_status('S', model)
        infected = amount_health_status('I', model)
        recovered = amount_health_status('R', model)
    end
end

# GET response is teh current state of the model from SimulationsController
route("/data", method = GET) do
    json(create_jsgraph(model))
end
  
# PUT response
route("/data", method = PUT) do
    if(rawpayload() == "step")
        print("yay", jsonpayload())
        new_model = SimulationsController.step()
        json(create_jsgraph(new_model))
    end
end

@page("/", "app.jl.html")

# Server.isrunning() || Server.up()