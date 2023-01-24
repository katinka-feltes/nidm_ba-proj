function updateTextInput(val, id) {
    if (id == 'gamma' ) {
        document.getElementById(id).textContent = val*100 + "%";
    } else {
        document.getElementById(id).textContent = val; 
    }
}

function updateMaxValue(val) {
    document.getElementById('phi-slider').max = val-1;
    document.getElementById('phi').textContent = document.getElementById('phi-slider').value;
}

/* doesnt work yet
function updateTimestep() {
    document.getElementById('timestep').textContent = document.getElementById('timestep').textContent+1; 
} */

function reset() {
    document.getElementById('agent-slider').value = 20;
    document.getElementById('agents-amount').textContent = 20;
    document.getElementById('risk-slider').value = 0.5;
    document.getElementById('risk').textContent = 0.5;
    document.getElementById('sigma-slider').value = 5;
    document.getElementById('sigma').textContent = 5;
    document.getElementById('tau-slider').value = 10;
    document.getElementById('tau').textContent = 10;
    document.getElementById('phi-slider').value = 10;
    document.getElementById('phi').textContent = 10;
    document.getElementById('alpha-slider').value = 0.75;
    document.getElementById('alpha').textContent = 0.75;
    document.getElementById('c2-slider').value = 0.1;
    document.getElementById('c2').textContent = 0.1;
    document.getElementById('gamma-slider').value = 0.5;
    document.getElementById('gamma').textContent = 0.5;
}