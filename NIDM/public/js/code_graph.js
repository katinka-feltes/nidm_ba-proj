var svg = d3.select("svg");
width = +svg.node().getBoundingClientRect().width;
height = +svg.node().getBoundingClientRect().height;

svg.append("g").attr("class", "links");
svg.append("g").attr("class", "nodes");

var graph, data1, data2;
var link, node; // svg objects
var simulation = d3.forceSimulation();

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
            .strength(-200)                                     // This adds repulsion between nodes. Play with the -400 for the repulsion strength
            .distanceMin(30)
            .distanceMax(200)
        )         
        .force("center", d3.forceCenter(width / 2, height / 2))     // This force attracts nodes to the center of the svg area
        .on("tick", ticked);
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
                console.log("dbclick agent" + d.id);
                if (d.health_status == "S"){
                    d.health_status = "I";
                    put("{\"infect\" : "+ d.id +"}"); //`{"infect": ` + d.id + `}`);
                    update(graph);
                }
            })
        .merge(u) // get the already existing elements as well
        .transition()
        .duration(1000) 
        .style("fill", function(d){ return color(d.health_status)});
    
    node = svg.select(".nodes").selectAll(".node");
    
    // node tooltip
    node.append("title")
        .text(function(d) { return "Agent-ID: "+d.id+ "\nInfection Duration: " + d.days_infected 
            + "\nRisikowahrnehmung: "+ d.risk_perception });

    initializeSimulation()
}    

function color(status){
    if (status == "S") return "#A4D3EE";
    else if (status == "I") return "#EE2c2c";
    else return "#8fbc8f" //R
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

let interval;
function play(){
    d3.select("#play-btn")
        .text("⏸")
        .attr("onClick", "pause()");

    interval = window.setInterval(() => {
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