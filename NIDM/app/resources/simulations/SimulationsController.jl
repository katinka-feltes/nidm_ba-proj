module SimulationsController

  using Agents
  import Main.Model as Model
  
  model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10)
  Model.infect!(random_agent(model))

  using Genie.Renderer.Html
  function agents()
    html(:simulations, :agents, agents = allagents(model))
  end

  function infect()
    Model.infect!(random_agent(model))
    html(:simulations, :model, model = model)
  end

  function step()
    Model.model_step!(model)
    return model
  end

end