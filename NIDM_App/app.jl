using GenieFramework
using Genie.Renderer.Html
using Stipple, StippleUI

include("model.jl")
using .Model
using Agents

@genietools

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

@handlers begin
    
    model = Model.initialize_model(number_of_agents = 20)

    # all variables
    @in agents_amount = 20 #default values so UI can be rendered when page loads
    @in alpha = 0.75
    @in cost2 = 0.1
    @in risk = 0.5
    @in σ = 5
    @in γ = 0.5
    @in τ = 10
    @in Φ = 10
    @in but = 0
    @in reset = 0
    @out value_agents = agents_amount
    @out value_alpha = alpha
    @out value_cost2 = cost2
    @out value_risk = risk
    @out value_σ = σ
    @out value_γ = γ
    @out value_τ = τ
    @out value_Φ = Φ
    @out max_Φ = 50
    @out agents = allagents(model)

    # buttons
    @onchange but begin
        @info "step_button pressed"
        Model.infect!(random_agent(model))
        Model.model_step!(model)
        agents = allagents(model)
    end
    @onchange reset begin
        @info "reset_button pressed"
        model = Model.initialize_model(number_of_agents=20)
        agents = allagents(model)
    end

    # parameter changes
    @onchangeany agents_amount, alpha, cost2, risk, σ, γ, τ, Φ  begin
        print("Bla")
        value_agents = agents_amount
        max_Φ = agents_amount-1
        value_alpha = alpha
        value_cost2 = cost2
        value_risk = risk
        value_σ = σ
        value_γ = γ
        value_τ = τ
        value_Φ = Φ
        model = Model.initialize_model(number_of_agents=agents_amount, α=alpha, r=risk)
        agents = allagents(model)
    end
end

@page("/", "app.jl.html")

# Server.isrunning() || Server.up()