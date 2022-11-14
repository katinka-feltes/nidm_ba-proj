using Agents
using Graphs

@agent Human NoSpaceAgent begin
    risk_perception::Real
    infection_duration::Int
    health_status::Char
end

ABM(Human, nothing)