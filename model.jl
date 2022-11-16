using Agents
using Graphs

# SOCIAL BENEFITS
b1 = 1.0 # benefit of direct connections
b2 = 0.5 # benefit of closed triad
α = 0.5 # preferred proportion of closed triads [0, 1]

# SOCIAL COSTS
c1 = 0.2 # cost of direct connections
c2 = 1.55 # marginal cost of direct connections (∈ ℝ_0+)

# DISEASE PROPERTIES
σ = 5 # disease severity (>1)
γ = 0.5 # transmission rate [0, 1]
τ = 10 # recovery time (time steps) (>0)

# NETWORK PROPERTIES
# number of agents to evaluate per time step
function Φ(n)  # n = existing number of agents 
    min(nv(n), 20) 
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



for i in 1:5
    add_agent!(Human(i, 0.5, 0, 'S'), model)
    add_vertex!(graph) 
end
add_agent!(Human(6, 0.5, 0, 'I'), model)
add_vertex!(graph) 
add_edge!(graph, 6, 2)
add_edge!(graph, 6, 3)

function infected_neighbours(agent) 
    infected = 0
    for id in neighbors(graph, agent.id)
        if model[id].health_status == 'I'
            infected += 1
        end
    end
    return infected
end
    
function disease_dynamics()
    for agent in allagents(model)
        # if i is susceptible, compute whether i gets infected
        if agent.health_status == 'S'  
            infection_probability = 1 - (1 - γ)^infected_neighbours(agent)
            if rand() < infection_probability # rand() returns a number in [0,1)
                agent.health_status = 'I'
            end
        # if i is infected, compute whether agent recovers: passed time steps since infection ≥ τ.
        elseif agent.health_status == 'I'
            agent.days_infected += 1
            agent.days_infected >= τ && (agent.health_status = 'R')
        end
    end
end

disease_dynamics()

function network_formation()
    for agent in allagents(model)
        encounters = Set([])
        while length(encounters) < Φ(nv(graph))
            for neighbor in neighbors(grapgh, agent.id)
                rand() < Ψ && push!(encounters, neighbor)
            end
            #...
        end
    end
end


