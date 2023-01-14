using GenieFramework
using Genie.Renderer.Html

include("model.jl")
using .Model
using Agents

@genietools

model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10)
@out const min = 0
@out const min1 = 1
@out const steps_small = 0.1
@out const max_agents = 50
@out const max1 = 1
@out const two = 2
@out const max_σ = 10
@out const max_τ = 50

@handlers begin
    @in agents_amount = 20 #default values so UI can be rendered when page loads
    @in alpha = 0.75
    @in cost2 = 0.1
    @in risk = 0.5
    @in σ = 5
    @in γ = 0.5
    @in τ = 10
    @in Φ = 10
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
    @onchangeany agents_amount, alpha, cost2, risk, σ, γ, τ, Φ  begin
        value_agents = agents_amount
        max_Φ = agents_amount-1
        value_alpha = alpha
        value_cost2 = cost2
        value_risk = risk
        value_σ = σ
        value_γ = γ
        value_τ = τ
        value_Φ = Φ
        model2 = Model.initialize_model(number_of_agents=agents_amount, α=alpha, r=risk)
        agents = allagents(model2)
    end
end

@page("/", "app.jl.html")

# Server.isrunning() || Server.up()