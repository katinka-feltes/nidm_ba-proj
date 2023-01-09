using Genie.Router

route("/") do
  serve_static_file("NIDM.html")
end