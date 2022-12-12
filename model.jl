using Agents
using Graphs
using GLMakie
using GraphMakie
using Colors
using Random

@agent Human NoSpaceAgent begin
    risk_perception::Real
    days_infected::Int
    health_status::Char
end

"""
## SOCIAL BENEFITS
b1 = 1.0 # benefit of direct connections
b2 = 0.5 # benefit of closed triad
α = 0.5 # preferred proportion of closed triads [0, 1]

## SOCIAL COSTS
c1 = 0.2 # cost of direct connections
c2 = 0.55 # marginal cost of direct connections (∈ ℝ_0+)

## DISEASE PROPERTIES
σ = 5 # disease severity (>1)
γ = 0.5 # transmission rate [0, 1]
τ = 10 # recovery time (time steps) (>0)

## NETWORK PROPERTIES
Ψ = 0.4 # proportion of ɸ at distance 1
ξ = 0.2 # proportion of ɸ at distance 2 """
function initialize_model(; number_of_agents = 30, α = 0.5, c2 = 0.55, σ = 5, γ = 0.5, τ = 10, r = 0.5, seed=0)

    properties = Dict(
        :graph => SimpleGraph(),
        :b1 => 1.0, 
        :b2 => 0.5, 
        :α => α, 
        :c1 => 0.2, 
        :c2 => c2, 
        :σ => σ,
        :γ => γ,
        :τ => τ, 
        :number_of_agents => number_of_agents,
        :r => r,
        :Ψ => 0.4,
        :ξ => 0.2
    )

    model = ABM(Human, nothing; properties, rng = Random.MersenneTwister(seed))

    for i in 1:number_of_agents
        add_agent!(Human(i, model.r, 0, 'S'), model)
        add_vertex!(model.graph) 
    end

    return model
end

# number of agents to evaluate per time step
Φ(n) = min(n-1, 20)  # n = existing number of agents 

infect!(agent) = agent.health_status == 'S' && (agent.health_status = 'I')

function infected_neighbors(agent, model) 
    infected = 0
    for id in neighbors(model.graph, agent.id)
        if model[id].health_status == 'I'
            infected += 1
        end
    end
    return infected
end

function distance2_neighbors(graph, vertex)
    distance2 = Set()
    for neighbor in neighbors(graph, vertex)
        union!(distance2, neighbors(graph, neighbor))
    end
    return distance2
end

function utility(agent, model; graph = model.graph)

    t = length(neighbors(graph, agent.id)) # number of direct connection of agent

    # possible triangles with current neighbors
    function possible_triads(n) # n = number of neighbors
        n < 2 && return 0
        return possible_triads(n-1) + (n-1)
    end
    # proportion of closed triads of agent
    x = 1
    if length(neighbors(graph, agent.id)) > 1 
         x = triangles(graph, agent.id) / possible_triads(length(neighbors(graph, agent.id)))
    end 
    """println(x, "triangle: ", triangles(graph, agent.id), ", possbiel: ", possible_triads(length(neighbors(graph, agent.id))))"""

    benefit = model.b1 * t + model.b2 * (1 - 2 * abs(x - model.α)/max(model.α, 1-model.α))

    cost = model.c1 * t + model.c2 * t^2

    function disease()
        if agent.health_status == 'S'
            return model.σ^agent.risk_perception * π^(2-agent.risk_perception)
        elseif agent.health_status == 'I'
            return model.σ
        else
            return 0
        end
    end

    return benefit - cost - disease()
end
    
function disease_dynamics!(model)
    for agent in allagents(model)
        # if i is susceptible, compute whether i gets infected
        if agent.health_status == 'S'  
            infection_probability = 1 - (1 - model.γ)^infected_neighbors(agent, model)
            rand(model.rng) < infection_probability && (agent.health_status = 'I') # rand(model.rng) returns a number in [0,1)
        # if i is infected, compute whether agent recovers: passed time steps since infection ≥ τ.
        elseif agent.health_status == 'I'
            agent.days_infected += 1
            agent.days_infected >= model.τ && (agent.health_status = 'R')
        end
    end
end

function network_formation!(model)
    processed_agents = []
    # repeat until all agents have been processed
    while length(processed_agents) < nv(model.graph)
        # randomly select an unprocessed agent
        agent = random_agent(model, x -> x ∉ processed_agents)
        push!(processed_agents, agent)
        encounters = Set([])
        # add agents to encounters until it consists of Φ agents
        while length(encounters) < Φ(nv(model.graph))
            # with probability Ψ: a random neighbor of current agent (distance 1)​
            for neighbor in neighbors(model.graph, agent.id)
                rand(model.rng) < model.Ψ && push!(encounters, neighbor)
            end
            # with probability ξ: a random neighbor‘s neighbor of current agent (distance 2)
            for neighbor in distance2_neighbors(model.graph, agent.id)
                rand(model.rng) < model.ξ && push!(encounters, neighbor)
            end
            # with probability 1 – Ψ – ξ: a random agent from the entire population (excluding curent agent)
            for person in allagents(model)
                person != agent && rand(model.rng) < (1 - model.Ψ - model.ξ) && push!(encounters, person.id)
            end
        end
        # repeat until all agents in encounters (randomized) have been processed
        for encounter in shuffle(model.rng, collect(encounters))
            # if agent is connected to encounter-agent
            if has_edge(model.graph, agent.id, encounter)
                # terminate agent-encounter tie, if utility for agent without the tie is larger than current utility
                simulated = copy(model.graph)
                rem_edge!(simulated, agent.id, encounter)
                utility(agent, model, graph=simulated) > utility(agent, model) && rem_edge!(model.graph, agent.id, encounter)
            else
                # create agent-encounter tie, if utility for agent & encounter-agent is larger with tie than current utility
                simulated = copy(model.graph)
                add_edge!(simulated, agent.id, encounter)
                utility(agent, model, graph=simulated) > utility(agent, model) && add_edge!(model.graph, agent.id, encounter)
            end
        end
    end
end

function color(x)
    if (model[x].health_status == 'I') 
        return colorant"red"
    elseif (model[x].health_status == 'S')
        return colorant"blue"
    else 
        return colorant"gray"
    end
end 

model = initialize_model(number_of_agents = 20, α = 1, c2 = 0.1)
infect!(random_agent(model))

disease_dynamics!(model)
network_formation!(model)
graphplot(model.graph, node_color = map((x) -> color(x), vertices(model.graph)))