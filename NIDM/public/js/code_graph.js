var svg = d3.select("svg");
width = +svg.node().getBoundingClientRect().width;
height = +svg.node().getBoundingClientRect().height;

svg.append("g").attr("class", "links");
svg.append("g").attr("class", "nodes");

var graph, data1, data2;
var link, node; // svg objects
var simulation = d3.forceSimulation();

var timestep = 0;
var susceptible = 0;
var infected = 0;
var recovered = 0;

// load the data
d3.json("model.json", function(error, _graph) {
if (error) throw error;
data1 = _graph;
graph = data1;
initializeDisplay();
initializeSimulation();
});

// preload the extra data
d3.json("model_new.json", function(error, _graph) {
    if (error) throw error;
    data2 = _graph;
});

function initializeDisplay() {
    update(graph)
    /*
    //add the links
    link = svg.append("g")
        .style("stroke", "#aaa")
    .selectAll("line")
        .data(graph.links)
    .enter().append("line")

    //add the nodes
    node = svg.append("g")
        .attr("class", "nodes")
    .selectAll("nodes")
        .data(graph.nodes)
    .enter().append("circle")
        .attr("r", 10)
        .style("fill", function(d){ return color(d.health_status)})
    .call(d3.drag() // call specific function when circle is dragged
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended));

    // node tooltip
    node.append("title")
        .text(function(d) { return "Agent-ID: "+d.id+ "\nInfection Duration: " + d.days_infected 
        + "\nRisikowahrnehmung: "+ d.risk_perception });*/
}

function initializeSimulation() {
    
    simulation.nodes(graph.nodes);

    // Let's list the force we wanna apply on the network
    simulation
        .force("link", d3.forceLink()                               // This force provides links between nodes
            .id(function(d) { return d.id; })                       // This provide  the id of a node
            .links(graph.links)  
            .distance(100)                                      // and this the list of links
        )
        .force("charge", d3.forceManyBody()
            .strength(-20)                                     // This adds repulsion between nodes. Play with the -400 for the repulsion strength
            .distanceMin(30)
            .distanceMax(100)
        )        
        .force("center", d3.forceCenter(width / 2, height / 2))     // This force attracts nodes to the center of the svg area
        .force("collide", d3.forceCollide().radius(11))
        .on("tick", ticked)
        .alphaMin(0.01)
        .alphaDecay(0.0001)
        .velocityDecay(0.3);
}

// update the display positions after each simulation tick
function ticked() {
    link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
    
    node
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
}

// Create a function that takes a dataset as input and update the plot:
function update(data) {

    graph = data;

    // Create the u variable for the links
    var u = svg.select(".links").selectAll(".link")
        .data(graph.links)

    // delete the links not in use anymore
    u.exit()
        .transition() // and apply changes to all of them
        .duration(500)
        .style("opacity", 0)
        .remove()   
    
    u.enter()
        .append("line") // Add a new line for each new elements
            .style("stroke", "#aaa")
            .attr("class", "link")
        .merge(u) // get the already existing elements as well
        .transition()
        .duration(1000);

    link = svg.select(".links").selectAll(".link");

    // Create the u variable for the nodes
    var u = svg.select(".nodes").selectAll(".node")
        .data(graph.nodes)

    // delete the links not in use anymore
    u.exit()
        .transition() // and apply changes to all of them
        .duration(500)
        .style("opacity", 0)
        .remove()   
    
    u.enter()
        .append("circle") // Add a new line for each new elements
            .attr("r", 10)
            .style("fill", "#fff")
            .attr("class", "node")
            .call(d3.drag() // call specific function when circle is dragged
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended))
            .on("dblclick",function(d){ //on double click
                document.getElementById('info').style.display = "none";
                document.getElementById('emptiness-left').style.display = "block";
                console.log("dbclick agent" + d.id);
                if (d.health_status == "S"){
                    susceptible=0; 
                    infected=0; 
                    recovered=0;
                    d.health_status = "I";
                    put("{\"infect\" : "+ d.id +"}"); //`{"infect": ` + d.id + `}`);
                    update(graph);
                }
            })
        .merge(u) // get the already existing elements as well
        .transition()
        .duration(1000) 
        .style("fill", function(d){ return color(d.health_status)});
        document.getElementById('susceptible').textContent = susceptible;
        document.getElementById('infected').textContent = infected;
        document.getElementById('recovered').textContent = recovered;
    
    node = svg.select(".nodes").selectAll(".node");
    
    // node tooltip
    node.append("title")
        .text(function(d) { return "Agent-ID: "+d.id+ "\nInfection Duration: " + d.days_infected 
            + "\nRisikowahrnehmung: "+ d.risk_perception });

    initializeSimulation()
}    

function color(status){
    if (status == "S") {
        susceptible += 1;
        return "#A4D3EE";
    }
    else if (status == "I") {
        infected += 1;
        return "#EE2c2c";
    }
    else {
        recovered += 1;
        return "#8fbc8f" //R
    }
}

//Dragn Drop
function dragstarted(d) {
    if (!d3.event.active) simulation.alphaTarget(.03).restart();
    d.fx = d.x;
    d.fy = d.y;
}
function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
}
function dragended(d) {
    if (!d3.event.active) simulation.alphaTarget(.03);
    d.fx = null;
    d.fy = null;
}


// API
//request for the change named in the content e.g. "step"
//response is the model after the change
async function post(content){
    fetch('http://127.0.0.1:8000/data', {
        method: 'POST',
        headers: {},
        body: content
    })
    .then(response => response.json())
    .then(response => {
        //console.log(JSON.stringify(response));
        update(response)
    })
}

// request to change some param of the model 
// content example {"infect": 5} or {param: value}
// no response model expected
async function put(content){
    fetch('http://127.0.0.1:8000/data', {
        method: 'PUT',
        headers: {},
        body: content//JSON.stringify(content)
    })
    .then(response => response.json())
    .then(response => console.log(JSON.stringify(response)))
}

//request for the current model
async function get(){
    await fetch('http://127.0.0.1:8000/data')
    .then((response) => response.json())
    .then((data) => {console.log(data); update(data)});
}

//method calls from html
function changeVar(value, name){
    put("{\""+name+"\" : "+ value +"}");
}

function newModel(){
    var content = "{\"number_of_agents\" : "+ document.getElementById("agent-slider").value
                + ",\"alpha\" : "+ document.getElementById("alpha-slider").value
                + ",\"c2\" : "+ document.getElementById("c2-slider").value 
                + ",\"sigma\" : "+ document.getElementById("sigma-slider").value 
                + ",\"gamma\" : "+ document.getElementById("gamma-slider").value 
                + ",\"tau\" : "+ document.getElementById("tau-slider").value
                + ",\"r\" : "+ document.getElementById("risk-slider").value  
                + ",\"phi\" : "+ document.getElementById("phi-slider").value +"}"
    post(content)
}

let interval;
function play(){
    d3.select("#play-btn")
        .text("⏸")
        .attr("onClick", "pause()");

    interval = window.setInterval(() => {
        susceptible = 0; 
        infected = 0; 
        recovered = 0;
        updateTimestep();
        post("step");
        console.log("Timeout: step")
    }, 3000)
}
function pause(){
    window.clearInterval(interval)
    console.log("stopped")

    d3.select("#play-btn")
        .text("▶")
        .attr("onClick", "play()");
}
function updateTimestep() {
    timestep += 1;
    document.getElementById('timestep').textContent = timestep; 
}
function show_infotext() {
    var info = document.getElementById("info");
    if (info.style.display === "none") {
      info.style.display = "flex";
      document.getElementById('emptiness-left').style.display = "none";
    }
}