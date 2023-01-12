module SimulationsController

  using Agents

  import Main.Model as Model
  model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10)
  const all_agents = allagents(model)

  using Genie.Renderer.Html
  function agents()
    html(:simulations, :agents, agents = all_agents)
  end

  function newmodel()
    model = Model.initialize_model(number_of_agents = 5, α = 0.75, c2 = 0.1, Φ = 10)

    html(:simulations, :agents, agents = all_agents)
  end

  module API

    using ..SimulationsController
    using Genie.Renderer.Json

    function agents()
      json(:simulations, :agents, agents = SimulationsController.all_agents)
    end

  end
  
end