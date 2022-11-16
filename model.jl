using Agents
using Graphs

γ = 0.5 #transmission rate
τ = 10 #recovery time (time steps)

@agent Human NoSpaceAgent begin
    risk_perception::Real
    infection_duration::Int
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
        # If i is susceptible, compute whether i gets infected
        if agent.health_status == 'S'  
            infection_probability = 1 - (1 - γ)^infected_neighbours(agent)
            if rand() < infection_probability #rand() returns a number in [0,1)
                agent.health_status = 'I'
            end
        #If i is infected, compute whether agent recovers: passed time steps since infection ≥ τ.
        elseif agent.health_status == 'I'
            agent.infection_duration += 1
            if agent.infection_duration >= τ
                agent.health_status = 'R'
            end
        end
    end
end

disease_dynamics()


