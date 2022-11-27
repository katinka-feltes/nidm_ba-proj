using Agents
using Graphs
using GLMakie
using GraphMakie
using Colors

# SOCIAL BENEFITS
b1 = 1.0 # benefit of direct connections
b2 = 0.5 # benefit of closed triad
α = 0.5 # preferred proportion of closed triads [0, 1]

# SOCIAL COSTS
c1 = 0.2 # cost of direct connections
c2 = 0.55 # marginal cost of direct connections (∈ ℝ_0+)

# DISEASE PROPERTIES
σ = 5 # disease severity (>1)
γ = 0.5 # transmission rate [0, 1]
τ = 10 # recovery time (time steps) (>0)

# NETWORK PROPERTIES
# number of agents to evaluate per time step
function Φ(n)  # n = existing number of agents 
    min(n, 20) 
end
Ψ = 0.4 # proportion of ɸ at distance 1
ξ = 0.2 # proportion of ɸ at distance 2


@agent Human NoSpaceAgent begin
    risk_perception::Real
    days_infected::Int
    health_status::Char
end

graph = SimpleGraph()
model = ABM(Human, nothing)

for i in 1:50
    add_agent!(Human(i, 0.1, 0, 'S'), model)
    add_vertex!(graph) 
end
add_agent!(Human(51, 0.5, 0, 'I'), model)
add_vertex!(graph) 
add_edge!(graph, 6, 2)
add_edge!(graph, 6, 3)

function infected_neighbors(agent) 
    infected = 0
    for id in neighbors(graph, agent.id)
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

function utility(agent, graph)

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

    benefit = b1 * t + b2 * (1 - 2 * abs(x - α)/max(α, 1-α))

    cost = c1 * t + c2 * t^2

    function disease()
        if agent.health_status == 'S'
            return σ^agent.risk_perception * π^(2-agent.risk_perception)
        elseif agent.health_status == 'I'
            return σ
        else
            return 0
        end
    end

    return benefit - cost - disease()
end
    
function disease_dynamics()
    for agent in allagents(model)
        # if i is susceptible, compute whether i gets infected
        if agent.health_status == 'S'  
            infection_probability = 1 - (1 - γ)^infected_neighbors(agent)
            rand() < infection_probability && (agent.health_status = 'I') # rand() returns a number in [0,1)
        # if i is infected, compute whether agent recovers: passed time steps since infection ≥ τ.
        elseif agent.health_status == 'I'
            agent.days_infected += 1
            agent.days_infected >= τ && (agent.health_status = 'R')
        end
    end
end

function network_formation()
    processed_agents = []
    # repeat until all agents have been processed
    while length(processed_agents) < nv(graph)
        # randomly select an unprocessed agent
        agent = random_agent(model, x -> x ∉ processed_agents)
        push!(processed_agents, agent)
        encounters = Set([])
        # add agents to encounters until it consists of Φ agents
        while length(encounters) < Φ(nv(graph))
            # with probability Ψ: a random neighbor of current agent (distance 1)​
            for neighbor in neighbors(graph, agent.id)
                rand() < Ψ && push!(encounters, neighbor)
            end
            # with probability ξ: a random neighbor‘s neighbor of current agent (distance 2)
            for neighbor in distance2_neighbors(graph, agent.id)
                rand() < ξ && push!(encounters, neighbor)
            end
            # with probability 1 – Ψ – ξ: a random agent from the entire population (excluding curent agent)
            for person in allagents(model)
                person != agent && rand() < (1 - Ψ - ξ) && push!(encounters, person.id)
            end
        end
        # repeat until all agents in encounters have been processed
        """ TODO randomize selection of encounter """
        for encounter in encounters
            # if agent is connected to encounter-agent
            if has_edge(graph, agent.id, encounter)
                # terminate agent-encounter tie, if utility for agent without the tie is larger than current utility
                simulated = copy(graph)
                rem_edge!(simulated, agent.id, encounter)
                utility(agent, simulated) > utility(agent, graph) && rem_edge!(graph, agent.id, encounter)
            else
                # create agent-encounter tie, if utility for agent & encounter-agent is larger with tie than current utility
                simulated = copy(graph)
                add_edge!(simulated, agent.id, encounter)
                utility(agent, simulated) > utility(agent, graph) && add_edge!(graph, agent.id, encounter)
            end
        end
    end
end

network_formation()

function color(x)
    if (model[x].health_status == 'I') 
        return colorant"red"
    else return colorant"blue"
    end
end 

graphplot(graph, node_color = map((x) -> color(x), vertices(graph)))