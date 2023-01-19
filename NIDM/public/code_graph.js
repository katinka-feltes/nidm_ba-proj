var svg = d3.select("svg"),
width = +svg.node().getBoundingClientRect().width,
height = +svg.node().getBoundingClientRect().height;
var graph, data1, data2;

// svg objects
var link, node;

var simulation = d3.forceSimulation()

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
        .attr("r", 7)
        .style("fill", function(d){ return color(d.health_status)})

    // node tooltip
    node.append("title")
        .text(function(d) { return d.id; });
}


function initializeSimulation() {
    
    simulation.nodes(graph.nodes);

    // Let's list the force we wanna apply on the network
    simulation
        .force("link", d3.forceLink()                               // This force provides links between nodes
            .id(function(d) { return d.id; })                     // This provide  the id of a node
            .links(graph.links)                                    // and this the list of links
        )
        .force("charge", d3.forceManyBody().strength(-200))         // This adds repulsion between nodes. Play with the -400 for the repulsion strength
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

    simulation.nodes(graph.nodes);
    simulation.force("link", d3.forceLink()                       // This force provides links between nodes
            .id(function(d) { return d.id; })                     // This provide  the id of a node
            .links(graph.links)                                   // and this the list of links
        )

    // Create the u variable
    var u = svg.selectAll("line ")
        .data(graph.links)

    // If less group in the new dataset, I delete the ones not in use anymore
    u.exit()
        .transition() // and apply changes to all of them
        .duration(1000)
        .style("opacity", 0)
        .remove()   
    
    u.enter()
        .append("line") // Add a new line for each new elements
        .merge(u) // get the already existing elements as well
        .transition()
        .duration(2000)
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    svg.selectAll("circle")
        .data(graph.nodes)
        .transition()
        .duration(2000)
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; })
        .style("fill", function(d){ return color(d.health_status)});

}    
    


function color(status){
    if (status == "S") return "#A4D3EE";
    else if (status == "I") return "#EE2c2c";
    else return "#8fbc8f" //R
}