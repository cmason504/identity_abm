//these are the buttons which run the simulation in the interface

class button {

  float xloc, yloc;
  float w, h;
  String label;
  String oglabel;

  boolean canPress = false;

  color fill = (200);

  boolean isHighlighted = true;

  boolean on = false;
  boolean lightup = false;

  button(float xloci, float yloci, float wi, float hi, String labeli) {

    xloc = xloci;
    yloc = yloci;
    w = wi;
    h = hi;

    label = labeli;
    oglabel = label;
  }

  void display() {

    fill(fill);
    rect(xloc, yloc, w, h);
    noStroke();

    fill(360);
    text(label, xloc, yloc);

    if (lightup == true) { 
      fill = color(120, 100, 100);
    } else {  
      fill = color(200);
    }

    checkHighlight();

    if (on) {   
      label = "PAUSE";
    } else {
      label = oglabel;
    }

    if (readytorun && label == "START") { 
      lightup = true;
    } else if (readytorun == false && label == "START") {  
      lightup = false;
    }
  }

  void checkHighlight() {

    if (mouseX > xloc - w/2 && mouseX < xloc + w/2 && mouseY > yloc - h/2 && mouseY < yloc + h/2) {    
      //fill = color(100,100,100);
      isHighlighted = true;
    } else {
      isHighlighted = false;
    }
    if (parametersSet) {
      fill(250, 100, 100);
    }
  }
}

void mouseReleased() {//this is where the booleans get switched

  if (highlightedAgent != null && setup==false) {
    println("HA IG BUTTON PRESSED");
    highlightedAgent.findIngroup();
    println(highlightedAgent.id, "ig size", highlightedAgent.ingroup.size());

    for (int i = 0; i < highlightedAgent.ingroup.size(); i++) {
      println(highlightedAgent.id, "HA IG", i, highlightedAgent.ingroup.get(i).id);
    }
  }
  //when the setup button is pressed, agents will be created according to the parameters
  if (parametersSet && setupbutton.isHighlighted && setup) {
    println("PARAMETERSSET");
    if (certainty.isTrue == false && ingroup.isTrue == true) {
      if (SN == 0) {
        createAgents(false);
      } else {
        agentsToDisplay = agents; 
      }
    } else {
      createAgents(false);
    }
    setupbutton.lightup = false;
    readytorun = true;
  }

  //this pauses the simulation
  if (startbutton.on == true && startbutton.isHighlighted) {
    println("PAUSE!!");
    startbutton.on = false;
    runSimulation = false;
  } else if (startbutton.lightup && startbutton.isHighlighted) {
    startbutton.on = true;
    setup = false;
    runSimulation = true;
  }

//turns on and off the booleans
  for (int i = 0; i < booleans.size(); i++) {
    if (booleans.get(i).isHighlighted && setup == true) {
        booleans.get(i).isSwitched = true;
      if (booleans.get(i).isTrue == false) {
        booleans.get(i).isTrue = true;
      } else {
        booleans.get(i).isTrue = false;
      }
      adjustbooleans();
    }
  }
  
  //makes it so dt will be random as in model 3
  if(ingroup.isTrue && certainty.isTrue){
    randomDT = true;
    for(int i = 0; i < agents.length; i++){    
      agents[i].differenceTolerance = random(.1,1);
    }
  }else{
    randomDT = false;
  }

  if (ingroup.isSwitched) {
    parametersSet = false;
    for (int i = 0; i < parameters.size(); i++) {
      parameters.get(i).reset();
    }
    updateParameters();
  }


  if (resetbutton.isHighlighted && setup == false) {
  
    adjustbooleans();
    runSimulation = false;
    setup = true;

    pvalueIC = ic.VALUE;
    pvalueIR = ir.VALUE;
    setup();
  }
}
