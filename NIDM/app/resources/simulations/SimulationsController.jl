module SimulationsController

  using Agents

  import Main.Model as Model
  model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10)

  using Genie.Renderer.Html
  function agents()
    html(:simulations, :agents, agents = allagents(model))
  end

  function showmodel()
    html(:simulations, :model, model = model)
  end

  function newmodel()
    model = Model.initialize_model(number_of_agents = 5, α = 0.75, c2 = 0.1, Φ = 10)

    html(:simulations, :agents, agents = allagents(model))
  end

  function step()
    Model.infect!(random_agent(model))
    html(:simulations, :model, model = model)
  end
  
end