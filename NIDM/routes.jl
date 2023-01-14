using Genie.Router, Genie.Requests
using .SimulationsController

route("/", SimulationsController.agents)
route("/", method = POST, SimulationsController.step)

"""route("/", method = POST) do
  enteredData=postpayload(:test, "Placeholder")
  "wuhu, range: in dollar klammern enteredData xD"
end"""

route("/model", SimulationsController.showmodel)
route("/", method = POST, SimulationsController.step)

route("/new", SimulationsController.newmodel)

