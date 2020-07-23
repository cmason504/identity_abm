
boolean printdata = true;
boolean useCertainty = false;
boolean useIngroup = false;
boolean ingroupranking = true;
boolean johnson = false;//find difference between these please!!
boolean johnson2 = false;
boolean useProminance = true;
boolean useInertia = true;

//this booelean sets up the user interface
boolean useInterface = true;

float certaintyfactor;
float startLocations = 200;

//display variables
int lineNum = 10;
int agentNum = lineNum * lineNum;
int lineSize = 1;
static int sizew = 1300;
float gridWidth = 600;
float spacing = gridWidth/lineNum;

int identityMode = 0;
int attitudeNum = 1;

int identityCompare = 9;
float identityProportion = 1/float(identityCompare);
int identityRange = 360/identityCompare;

int IDR = 2;
int SN = 0;
float DT = 1;

float lambda = 3;

Agent[] agents;

int[][] positions = new int[agentNum][2];
Identity[] identitiesGlobal;


//static variables
int timeStep = 0;
boolean start = true;
boolean runSimulation = false;
boolean redistribute = true;
PrintWriter output;
int runCount = 0;

int avgPIsize = 0;
float PIstd = 0;

Graph Graph;
Graph Graph2;
Graph Graph3;

barGraph clusters;
int graphHeight = 200;

Agent broadcastingAgent;
Agent highlightedAgent;
Agent zoomAgent;

boolean restrictAttitudes = false;
boolean randomCertainties = false;//if they are random, certainties are initialized between 0-1 instead of .5
boolean ideologyIngroup = false;
boolean randomDT = false;

int equal = 0;
int typeNumber = 0;
float clusterNumStart;

ArrayList <IntList> types = new ArrayList <IntList>(1);

int ba;
int epochs = 0;

//INTERFACE VARIABLES

button startbutton;
button setupbutton;
button resetbutton;
ArrayList <button> buttons = new ArrayList <button>();

parameter ic;
parameter ir;
ArrayList <parameter> parameters = new ArrayList <parameter>();

booleanParameter certainty;
booleanParameter ingroup;
ArrayList <booleanParameter> booleans = new ArrayList <booleanParameter>();

boolean parametersSet, readytorun, setup;

int creationNum = 0;

float clusterStatus;
String status;

void settings() {
  size(sizew, 601);
}

float pvalueIC = 1;
float pvalueIR = 1;

void setup() {

  DT = 1;
  SN = 0;

  broadcastingAgent = null;
  println("SETUP!", creationNum);
  status = "SETUP";
  parametersSet = false;
  setup = true;
  readytorun = false;

  keyCount = 0;

  if (useInterface == false) {
    parametersSet = true;
  }

  rectMode(CENTER);

  textAlign(CENTER, CENTER);
  colorMode(HSB, 360, 100, 100);
  frameRate(180);

  runCount ++;

  float sbw = 100;
  float sbh = 30;

  //initializes buttons
  buttons.clear();
  setupbutton = new button(10 + sbw/2, 500 + sbh/2, sbw, sbh, "SETUP");
  buttons.add(setupbutton);
  startbutton = new button(10 + sbw/2, setupbutton.yloc + sbh, sbw, sbh, "START");
  buttons.add(startbutton);
  resetbutton = new button (10 + sbw/2, startbutton.yloc + sbh, sbw, sbh, "RESET");
  buttons.add(resetbutton);

  //initializes booleans

  booleans.clear();

  certainty = new booleanParameter(30, 150, "Certainty");
  booleans.add(certainty);
  ingroup = new booleanParameter(30, 200 + certainty.totalHeight, "Ingroup");
  booleans.add(ingroup);

  //initializes parameters
  parameters.clear();

  ic = new parameter(10, 200 + certainty.totalHeight + ingroup.totalHeight + 20, "Identity Compare");
  parameters.add(ic);
  println("IC YLOC", ic.yloc);
  ir = new parameter(10, ic.yloc + ic.totalHeight + 10, "Identity Range");
  parameters.add(ir);

  updateParameters();

  println("SN", SN, "IDR", IDR, "IDC", identityCompare);
  createAgents(false);

  if (start) {
    //output = createWriter("data" + hour() +":" + minute()+ ".txt"); 
    start = false;
  }
}

void draw() {

  //some status checks for debugging purposes
  if (setup == false) { 
    // println("SETUP FALSE!", frameCount);
  }
  if (readytorun == false) {
    //println("NOT ReADY", frameCount);
  }
  if (runSimulation) {
    println("RUN", timeStep);
  }

  background(0);

  stroke(300);

  strokeWeight(lineSize);

  //DISPLAY METHODS

  //draws the grid
  for (int i = 0; i < lineNum + 1; i ++)
  { 
    line(i*spacing + startLocations, 0, i*spacing + startLocations, 600);
    for (int j = 0; j < lineNum + 1; j ++) {
      line(0 + startLocations, j*spacing, 600 + startLocations, j*spacing);
    }
  }

  //DISPLAYS USER INTERFACE
  if (useInterface) {

    for (int i = 0; i < parameters.size(); i++) {
      parameters.get(i).display();
    }
    for (int i = 0; i < booleans.size(); i++) {
      booleans.get(i).display();
    }
    for (int i = 0; i < buttons.size(); i++) {
      buttons.get(i).display();
    }
  }
  
  //displays agents
  for (int i = 0; i < agents.length; i ++) {  
    agentsToDisplay[i].display();
    agentsToDisplay[i].displayText();
  }
  if (zoomAgent != null) {
    zoomAgent.display();
    zoomAgent.displayText();
  }

  //displays simulation information

  text("Identity Compare: " + str(identityCompare), startLocations + gridWidth + 150, 10);
  text("Identity Range: " + str(IDR), startLocations + gridWidth + 150, 25);
  text("Similarity Number: " + str(SN), startLocations + gridWidth + 150, 55);

  text("Number of Types: " + str(typeNumber), startLocations + gridWidth + 350, 10);
  text("Average Inroup Size: " + str(avgPIsize), startLocations + gridWidth + 350, 25);
  text("Loners: " + str(loners), startLocations + gridWidth + 350, 40);
  text("Time Step: " + str(timeStep), startLocations + gridWidth + 350, 55);

  if (randomDT) {
    text("Difference Tolerence: Random", startLocations + gridWidth + 150, 40);
  } else {
    text("Difference Tolerence: " + str(DT), startLocations + gridWidth + 150, 40);
  }

  //HIGHLIGHTS
  //determines if one agent is highlighted by the mouse
  for (int i = 0; i < agents.length; i ++) {
    if (mouseX > agents[i].location.x - (gridWidth/lineNum)/2  && mouseX < agents[i].location.x + (gridWidth/lineNum)/2 && mouseY  > agents[i].location.y- (gridWidth/lineNum)/2 && mouseY  < agents[i].location.y + (gridWidth/lineNum)/2) {
      agents[i].isHighlighted = true;
      highlightedAgent = agents[i];
    } else {
      agents[i].isHighlighted = false;
    }
  }

  if (mouseX < startLocations || mouseX > startLocations + gridWidth) {
    highlightedAgent = null;
    zoomAgent = null;
  }

  //RUNS SIMULATION
  if (runSimulation) {
    run();
  }


  Graph.display();
  Graph2.display();

  //highlights the agent's INGROUP
  if (key == 'i') {
    if (highlightedAgent != null) {
      for (int i = 0; i < highlightedAgent.potentialIngroup.size(); i++) {
        noFill();
        strokeWeight(10);
        stroke(0, 100, 100);
        rect(highlightedAgent.potentialIngroup.get(i).location.x, highlightedAgent.potentialIngroup.get(i).location.y, highlightedAgent.potentialIngroup.get(i).size, highlightedAgent.potentialIngroup.get(i).size);
      }

      highlightedAgent.drawLines(highlightedAgent.ingroup);
    }
  }
  //highlights the agent's INFLUENCE GROUP
  if (key == 'u') {
    if (highlightedAgent != null) {
      for (int i = 0; i < highlightedAgent.potentialInfluenceGroup.size(); i++) {
        noFill();
        strokeWeight(10);
        stroke(0, 100, 100);
        rect(highlightedAgent.potentialInfluenceGroup.get(i).location.x, highlightedAgent.potentialInfluenceGroup.get(i).location.y, highlightedAgent.potentialInfluenceGroup.get(i).size, highlightedAgent.potentialInfluenceGroup.get(i).size);
      }
      highlightedAgent.drawLines(highlightedAgent.influenceGroup);
    }
  }

  //DISPLAYS STATUS BOX
  pushStyle();
  noFill();
  stroke(360);
  strokeWeight(10);
  rect(gridWidth + startLocations + 50 + 200, height - 30, width -(gridWidth + startLocations + 50) -50, 50);
  fill(360);
  textAlign(LEFT, CENTER);
  text("STATUS: " + status, gridWidth + startLocations + 100, height - 30);
  text("NUM CLUSTERS: " + clusterNums[identityMode], gridWidth + startLocations + 300, height - 30);
  popStyle();
  
  //DISPLAYS MODEL CHOICE INTERFACE (added at the end)
  drawModelInterface();
  
  //clusters.display();
  
   //changes the color if the 'identity mode' changes //BUG find a way to make this work?

  //int pIDM = identityMode;

  //if (key == '0'||key == '1'||key == '2'||key == '3'||key == '4'||key == '5'||key == '6'||key == '7'||key == '8'||key == '9') {

  //  identityMode = key - 48;
  //  if (identityMode != pIDM) {
  //  println("Identity Mode", identityMode);

  //  for (int i = 0; i < agents.length; i++) {
  //    //agents[i].checkColor();//CHECK WHAT COLOR IT ASSIGNS>>ATTITUDE OR "IDENTITY" MAKE MODULAR???
  //  }
  //  }
  //}
  
    fill(0,100,100);

 if(intro){
    intro();
  }
}


//redistributes agent ingroups so that no agents have no ingroup and therefore cannot be influenced

int loners, samers;
int ingroupmin = 2;

//recursive function that redistributes ingroups so no agent has less than the ingroup minimum (at least one in all models)
void redistribute() {

  loners = 0;
  samers = 0;

  for (int i = 0; i < agents.length; i++) {
    agents[i].calculateDifferencesDiscrete(false);

    float maxs = 0;

    for (int j = 0; j < agents[i].similarities.length; j++) {
      if (j != agents[i].id) {
        if (agents[i].similarities[j] > maxs) {
          maxs = agents[i].similarities[j];
        }
      }
    }

    if (maxs <= agents[i].similarityNum) {
      loners ++;
    }
    if (maxs > identityCompare - 1) {
      samers ++;
    }
  }

  if (printdata) {
    println("LONERS", loners);
    println("SAMERS", samers);
  }
  for (int i = 0; i <agents.length; i++) {
    agents[i].findIngroup();

    //if (agents[i].potentialIngroup.size() == 0) {
    if (agents[i].potentialIngroup.size() < ingroupmin) {//TEST!!!!!!!

      agents[i].similarityNum -= 1;
    }
  }
  if (loners > 0) {
    redistribute();
  }
}

//FIND CLUSTERS
ArrayList <PVector> clustersAgents = new ArrayList <PVector>();
FloatList clusterAttitudes = new FloatList();
int[] clusterNums = new int[attitudeNum];


//identifies the number of clusters at the timestep when it is called
void findClusters() {

  clustersAgents.clear();
  clusterAttitudes.clear();

  clusterNums[identityMode] = 0;

  clustersAgents.add(new PVector(agents[0].attitudesSimple[identityMode], 0));

  clusterAttitudes.append(agents[0].attitudesAgent[identityMode]);

  for (int i = 0; i < agents.length; i++) {

    agents[i].clusterNumber = int(agents[i].attitudesAgent[identityMode]*1000)/10;
    int cexists = 0;
    for (int j = 0; j < clustersAgents.size(); j++) {

      if (agents[i].clusterNumber == clustersAgents.get(j).x) {
        clustersAgents.get(j).y ++;
      } else {
        cexists ++;
      }
    }
    if (cexists == clustersAgents.size()) {
      clustersAgents.add(new PVector(int(agents[i].attitudesAgent[identityMode]*1000)/10, 1));
      clusterAttitudes.append(agents[i].attitudesAgent[identityMode]);
    }
  }

  for (int i = 0; i < clustersAgents.size(); i++) {
    if (clustersAgents.get(i).y > 0) {
      clusterNums[identityMode] ++;
    }
  }
  println("CLUSTER NUMMMMMMMM", identityMode, clusterNums[identityMode]);
}


//identifies the "types" of agents and the number of types
void findTypes(Agent[] toOrder) {

  types.clear();
  types.add(0, new IntList());

  for (int i = 0; i < identityCompare; i++) {
    types.get(0).set(i, int(toOrder[0].identities[i].types[toOrder[0].id] * 10));
  }

  for (int i = 0; i < toOrder.length; i++) {
    int typeCount = 0;
    IntList temp = new IntList();

    for (int j = 0; j < identityCompare; j++) {
      temp.append(int(toOrder[i].identities[j].types[toOrder[i].id] * 10));
    }

    int diffCount = 0;

    for (int j = 0; j < types.size(); j++) {
      int sameCount = 0;
      int cCount = 0;

      for (int k = 0; k < temp.size(); k++) {

        if (temp.get(k) == types.get(j).get(k)) {

          sameCount ++;
          cCount ++;

          if (sameCount == identityCompare) {
            toOrder[i].agentType = typeCount;
            //println("TYPECOUNT", typeCount);
            break;
          }
        } 
        if (temp.get(k) != types.get(j).get(k)) {
          cCount ++;
        }
        if (cCount == identityCompare) {
          diffCount++;
          typeCount ++;
        }
        if (diffCount == types.size()) {
          types.add(temp); 
        }
      }
    }
  }

  ArrayList <PVector> byType = new ArrayList <PVector>();

  //println("TYPES SIZE", types.size());

  for (int j = 0; j < types.size(); j++) {
    for (int i = 0; i < toOrder.length; i++) {

      if (toOrder[i].agentType == j) {
        byType.add(new PVector(toOrder[i].agentType, toOrder[i].id));
      }
    }
  }
}

//runs the simulation
void run() { 
  ba = int(random(0, agents.length));
  epochs ++;
}

void getData() {

  float[] certaintiesToGraph = new float[agents.length];
  float[] attitudesToGraph = new float[agents.length];
  float[] clustersToGraph = new float[1];

  float [] c = new float[1];
  float[] hs = new float[agents.length];
  int[] is = new int[agents.length];

  for (int i = 0; i < agents.length; i ++) {
    if (agents[i].isloner == false) {
      attitudesToGraph[i] = (1 - agents[i].attitudesAgent[identityMode]);
      certaintiesToGraph[i] = (1- agents[i].certainties[identityMode]);
      hs[i] = hue(agents[i].agentColor);
      is[i] = agents[i].id;
    }
  }

  findClusters();

  c[0] = 0;
  clustersToGraph[0] = (1 - float(clusterNums[identityMode])/100);
  //println("CTGF", (float(clusterNums[identityMode])/100));

  Graph.update(timeStep, attitudesToGraph, hs, is);
  Graph2.update(timeStep, certaintiesToGraph, hs, is);

  Graph3.update(timeStep, clustersToGraph, c, int(c));
  if (clusterNums[identityMode] == 1) {
    status = "CONSENSUS";
  } else if (clusterNums[identityMode] < clusterNumStart) {  
    status = "CLUSTERS";
  } else if (clusterNums[identityMode] >= clusterNumStart) {
    status = "ANOMIE";
  }
}

FloatList certainties = new FloatList();

//calculates certainties for data collection
void calculateAverageCertainties() {

  float avgc = 0;

  for (int i = 0; i < agents.length; i ++) {
    avgc += agents[i].certainties[identityMode];
  }
  avgc = avgc/agents.length;

  certainties.append(avgc);
}

Agent[] agentsToDisplay = new Agent[agentNum];

//creates a new set of agents every time the simulation is reset
void createAgents(boolean hypothetical) {

  agents = new Agent[agentNum];

  println("CREATE AGENTS", creationNum, "********************************");

  if (useCertainty) {
    certaintyfactor = 1;
  } else {
    certaintyfactor = 0;
  }

  println("identityCompare", identityCompare);
  
  //initializes identities (number of identities on which to compare agents)
  identitiesGlobal = new Identity[identityCompare];
  for (int i = 0; i < identitiesGlobal.length; i++) {
    identitiesGlobal[i] = new Identity(i);
  }
  
  //initializes agents
  for (int i = 0; i < agentNum; i ++) {
    positions[i][0] = i % lineNum;
    positions[i][1] = i / lineNum;
  }
  for (int i = 0; i < agentNum; i ++) {
    agents[i] = new Agent(i, positions[i], creationNum);
  }
  creationNum ++;

  //REDISTRIBUTES AGENTS ON CREATION
  if (redistribute) {
    redistribute();
  }

  //PRINTS DATA FOR DATA/DEBUGGING PURPOSES
  if (printdata) { 
    println("IDC", identityCompare);
    println("identity proportion", identityProportion);
    println("IDENtity MODE:", identityMode);

    avgPIsize = 0;

    for (int i = 0; i < agents.length; i++) {
      agents[i].findIngroup();
      avgPIsize += agents[i].potentialIngroup.size();
    }
    avgPIsize = avgPIsize/agents.length;
    println("AVG POTENTIAL INGROUP SIZE", avgPIsize);

    PIstd = 0;
    for (int i = 0; i < agents.length; i++) {
      PIstd += sq(agents[i].potentialIngroup.size() - avgPIsize);
    }
    PIstd = PIstd/agents.length;
    PIstd = sqrt(PIstd);

    println("standard deviation PI size", PIstd);


    findClusters();
    clusterNumStart = clustersAgents.size();
    println("CNS: clusters to start:", clusterNumStart);

    findTypes(agents);
    typeNumber = types.size();

    println("TYPE NUMBER START", typeNumber);

    equal = 0;

  if (hypothetical == false) {
    for (int i = 0; i < agents.length; i++) {
      agentsToDisplay[i] = agents[i];
    }
  }
  Graph = new Graph((gridWidth + startLocations) + (sizew - (gridWidth + startLocations))/2, height/2 - 100, 400, graphHeight, "Attitudes");
  Graph2 = new Graph((gridWidth + startLocations) + (sizew -(gridWidth + startLocations))/2, height/2 + 120, 400, graphHeight, "Certainties");
  Graph3 = new Graph((gridWidth + startLocations) + (sizew -(gridWidth + startLocations))/2, height/2 + 120, 400, graphHeight, "Clusters");

  clusters = new barGraph((gridWidth + startLocations) + (sizew -(gridWidth + startLocations))/2, height/2 + 150);
}
}
