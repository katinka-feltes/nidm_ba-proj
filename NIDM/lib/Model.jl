module Model

using Agents, Random
using Graphs
using GLMakie, GraphMakie, Colors

@agent Human NoSpaceAgent begin
    risk_perception::Real
    days_infected::Int
    health_status::Char
end

"""
## SOCIAL BENEFITS
b1 = 1.0 # benefit of direct connections
b2 = 0.5 # benefit of closed triad
alpha = 0.5 # preferred proportion of closed triads [0, 1]

## SOCIAL COSTS
c1 = 0.2 # cost of direct connections
c2 = 0.55 # marginal cost of direct connections (∈ ℝ_0+)

## DISEASE PROPERTIES
sigma = 5 # disease severity (>1)
gamma = 0.5 # transmission rate [0, 1]
tau = 10 # recovery time (time steps) (>0)

## NETWORK PROPERTIES
psi = 0.4 # proportion of ɸ at distance 1
xi = 0.2 # proportion of ɸ at distance 2 """
function initialize_model(; number_of_agents = 30, alpha = 0.5, c2 = 0.55, sigma = 5, gamma = 0.5, tau = 10, r = 0.5, phi = 10, seed=0)

    function calc_phi(p::Number) # number of agents to evaluate per time step
        m = min(p, 20)
        m >= number_of_agents && return number_of_agents-1
        return m
    end

    properties = Dict(
        :graph => SimpleGraph(),
        :b1 => 1.0, 
        :b2 => 0.5, 
        :alpha => alpha, 
        :c1 => 0.2, 
        :c2 => c2, 
        :sigma => sigma,
        :gamma => gamma,
        :tau => tau, 
        :number_of_agents => number_of_agents, # what for
        :r => r,                               # unessecary as well 
        :phi => calc_phi(phi),
        :psi => 0.4,
        :xi => 0.2
    )

    model = ABM(Human, nothing; properties, rng = Random.MersenneTwister(seed))

    for i in 1:number_of_agents
        add_agent!(Human(i, model.r, 0, 'S'), model)
        add_vertex!(model.graph) 
    end

    return model
end

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

function utility(agent, model::ABM; graph = model.graph)

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

    benefit = model.b1 * t + model.b2 * (1 - 2 * abs(x - model.alpha)/max(model.alpha, 1-model.alpha))

    cost = model.c1 * t + model.c2 * t^2

    function disease()
        if agent.health_status == 'S'
            return model.sigma^agent.risk_perception * π^(2-agent.risk_perception)
        elseif agent.health_status == 'I'
            return model.sigma
        else
            return 0
        end
    end

    return benefit - cost - disease()
end
    
function disease_dynamics!(model::ABM)
    for agent in allagents(model)
        # if i is susceptible, compute whether i gets infected
        if agent.health_status == 'S'  
            infection_probability = 1 - (1 - model.gamma)^infected_neighbors(agent, model)
            rand(model.rng) < infection_probability && (agent.health_status = 'I') # rand(model.rng) returns a number in [0,1)
        # if i is infected, compute whether agent recovers: passed time steps since infection ≥ tau.
        elseif agent.health_status == 'I'
            agent.days_infected += 1
            agent.days_infected >= model.tau && (agent.health_status = 'R')
        end
    end
end

function network_formation!(model::ABM)
    processed_agents = []
    # repeat until all agents have been processed
    while length(processed_agents) < nv(model.graph)
        # randomly select an unprocessed agent
        agent = random_agent(model, x -> x ∉ processed_agents)
        push!(processed_agents, agent)
        encounters = Set([])
        # add agents to encounters until it consists of phi agents
        while length(encounters) < model.phi
            # with probability psi: a random neighbor of current agent (distance 1)​
            for neighbor in neighbors(model.graph, agent.id)
                rand(model.rng) < model.psi && push!(encounters, neighbor)
            end
            # with probability xi: a random neighbor‘s neighbor of current agent (distance 2)
            for neighbor in distance2_neighbors(model.graph, agent.id)
                neighbor != agent.id && rand(model.rng) < model.xi && push!(encounters, neighbor)
            end
            # with probability 1 – psi – xi: a random agent from the entire population (excluding current agent)
            for person in allagents(model)
                person != agent && rand(model.rng) < (1 - model.psi - model.xi) && push!(encounters, person.id)
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

function visualize(model::ABM)
    function color(x)
        if (model[x].health_status == 'S') 
            return colorant"blue"
        elseif (model[x].health_status == 'I')
            return colorant"red"
        else 
            return colorant"gray" #R
        end
    end 
    
    graphplot(model.graph, node_color = map((x) -> color(x), vertices(model.graph)))
end

function model_step!(model::ABM) 
    disease_dynamics!(model)
    network_formation!(model)

    #visualize(model)
end

function set_property!(property_name::Symbol, value, model::ABM)
    #number_of_agents adjusable? 
    if property_name == :r
        for agent in allagents(m)
            agent.risk_perception = value
        end
    else
        model.properties[property_name] = value
    end
end

end