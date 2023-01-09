import Main.Model as Model
using Agents

model = Model.initialize_model()
model = Model.initialize_model(number_of_agents = 50, α = 1, c2 = 0.1)
model = Model.initialize_model(number_of_agents = 24, α = 0.75, c2 = 0.1, Φ = 10) # Nunners Werte

Model.infect!(random_agent(model))

Model.model_step!(model)



for i in 1:30
  Model.model_step!(model)
end
Model.visualize(model)









"""using Genie, Genie.Router
using Genie.Renderer, Genie.Renderer.Html, Genie.Renderer.Json

route("/") do
    html("Hey friendz!")
end

route("/hello.html") do
  html("Hello friendz! (in html)")
end

route("/hello.json") do
  json("Hi friendz! (in json)")
end

route("/hello.txt") do
   respond("Hiya friendz! (in txt format)", :text)
end

# Launch the server on a specific port, 8002
# Run the task asynchronously
up(8002, async = true)

using Random
testSet = Set([1,2,3,1,4,5])
shuffle(collect(testSet))"""