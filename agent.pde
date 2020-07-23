//Each agent is an object with it's own properties and behaviors
//Behaviors are the same but outcome depends on identity composition

class Agent {

  PVector location;
  float ogyloc;
  color agentColor;
  color originalColor;

  int id;
  float size, ogsize;
  boolean isHighlighted;

  ArrayList <Agent> friends = new ArrayList <Agent>();
  ArrayList <Agent> ingroup = new ArrayList<Agent>();
  ArrayList <Agent> potentialIngroup = new ArrayList<Agent>();

  int agentType;

  //MAJOR VARIABLES FOR EXPERIMENTS
  Identity[] identities;

  float[] attitudesAgent = new float[attitudeNum];//number between 0-1
  float[] certainties = new float[attitudeNum];

  float[] attitudesSimple = new float[attitudeNum];//number between 0-100 (no decimal)

  float differenceTolerance;//how far from their attitude will they accept another agent
  float changeRange;//how far do they change their attitude away from their own if they are uncertain

  float s, b;

  String textInfo = "";
  color typeColor;

  String info, info2;

  boolean influencer = false;
  boolean influencee = true;
  boolean isloner = false;

  float inertia  = 0;

  int generation;
  int switchnum = 0;

  boolean zoom = false;

  //these variabes were for experimentation not documented in the paper
  float [] volatilities = new float[identityCompare];
  float [] saliences = new float[identityCompare];
  float [] prominance = new float[identityCompare];
  float [] salienceProportions = new float[saliences.length];


  Agent(int ID, int[] position, int generationi) {

    id = ID;
    size = (gridWidth/lineNum) - 1;
    location = new PVector((((gridWidth/lineNum) * position[0]) + 1) + size/2 + startLocations, ((gridWidth/lineNum * position[1]) + 1) + size/2);
    generation = generationi;

    ogsize = size;
    ogyloc = location.y;

    //set up the identity values depending on the number of levels of comparison (identityCompare)

    identities = new Identity[identityCompare];

    for (int i = 0; i < identities.length; i++) {
      identities[i] = identitiesGlobal[i];
    }

    //initializes the attitdues of each agent (0-1)

    for (int i = 0; i < attitudesAgent.length; i++) {
      attitudesAgent[i] = random(0, 1);
      attitudesSimple[i] = int(attitudesAgent[identityMode] * 1000)/10;

      //initializes the certainties of each agent: (0-1) if random, .5 if not (.5 is used in the report)

      if (randomCertainties) {
        certainties[i] = random(0, 1);
      } else {
        certainties[i] = .5;
      }
    }

    //sets up basic variables

    differenceTolerance = DT;
    similarityNum = SN;
    changeRange = .4;

    //sets up the prominance of each identity for experimentation

    float total = 1;
    float proportions = 0;

    FloatList ps = new FloatList(identityCompare);

    for (int i = 0; i < identityCompare; i++) {
      ps.set(i, random(0, total));
      total = total - ps.get(i);
      proportions += ps.get(i);
    }
    if (identityCompare > 0) {
      ps.set(identityCompare - 1, (1 - proportions));
    }
    ps.shuffle();

    prominance = ps.array();

    //resets prominance if it is not considered
    if (useProminance == false) {
      for (int i = 0; i < prominance.length; i++) {
        prominance[i] = 1;
      }
    }

    //display values for each agent
    info = str(identities[identityMode].types[id]);
    float certaintiesToDisplay = int(certainties[identityMode]* 1000);
    certaintiesToDisplay = certaintiesToDisplay/1000;
    info2 = str(certaintiesToDisplay);
    textInfo = str(int(attitudesAgent[identityMode] * 1000)/10);


    //initializes color of agent
    b = differenceTolerance;
    s = 1;

    agentColor = color((identities[identityMode].types[id] * identities[identityMode].displayMode), 100 * s, 100 * b);
    originalColor = agentColor;
  }


  boolean drawInfluenceH = false;
  boolean drawIngroupH = false;

  //DISPLAYS AGENTS
  void display() {

    //MAKES THE AGENT LARGER FOR THE INTERFACE
    if (isHighlighted && mousePressed) { 
      zoomAgent = this;
      zoom = true;
    } else if (mousePressed == false) {
      zoom = false;
    }

    if (zoom) {
      size = 150;
      if (location.y + size/2 > height - 1) {
        location.y = height - size/2;
        println("too low");
      }
      if (location.y - size/2 < 0 + 1) {
        location.y = 0 + size/2;
        println("too high");
      }
      println(frameCount, this.id, location.y, "ZOOM");

      noFill();
      stroke(360);
      strokeWeight(2);
    } else if (zoom == false) {
      size = ogsize;
      location.y = ogyloc;
      noStroke();
    }

    fill(agentColor);
    rect(location.x, location.y, size, size);

    //if the simlation is running, and this agent is chosen to broadcast, it will broadcast
    if (runSimulation) {
      if (ba == id) {   
        broadcast();
        getData();
      }
      //for drawing lines of network connections
      if (drawInfluenceH) {
        for (int i = 0; i < influenceGroup.size(); i ++) {
          influenceGroup.get(i).drawInfluenceH = true;
        }
      }
      if (drawIngroupH) {
        for (int i = 0; i < ingroup.size(); i ++) {
          ingroup.get(i).drawIngroupH = true;
        }
      }
    }
  }

  //Draws lines between the agent and the list given to it 
  void drawLines(ArrayList <Agent> toDraw) {
    for (int i = 0; i < toDraw.size(); i ++) {
      strokeWeight(10);
      stroke(color(hue(agentColor), 20, 95));
      line(location.x, location.y, toDraw.get(i).location.x, toDraw.get(i).location.y);
    }
  }

  //DISPLAYS TEXT ON AGENTS
  void displayText() {
    fill(360);

    //for debugging/data purposes
    if (key == 'o') {
      pushStyle();
      text("sn: " + str(similarityNum), location.x, location.y - (size/10)*3);
      //text("pos: " + nf(BAR, 0, 2), location.x, location.y);
      text("DT: " + nf(differenceTolerance, 0, 2), location.x, location.y);

      text("i: " + str(inertia), location.x, location.y + (size/10)*3);
      popStyle();
    } else if (zoom) {
      text("ID: " + str(id), location.x, location.y);
      text("Certianty: " + info2, location.x, location.y  - (size/10) * 4);
      text("Identity Type: " + info, location.x, location.y + (size/10)*2);
      text("Attitude: " + textInfo, location.x, location.y + (size/10)*4);
      float d = round(differenceTolerance * 100);
      text("DT: " + d/100, location.x, location.y - size/10*2);
    } else {
      text(str(id), location.x, location.y - (size/10));
      text(info2, location.x, location.y  - (size/10) * 3);
      text(info, location.x, location.y + (size/10));
      text(textInfo, location.x, location.y + (size/10)*3);
    }
  }

  //CHANGES COLOR AS ATTITUDES CHANGE
  void checkColor() {

    s = differenceTolerance;
    b = 1;

    if (key == 'n') {
      agentColor = color((identities[identityMode].types[id] * identities[identityMode].displayMode), 100 * s, 100 * b);
    } else {
      agentColor = color((attitudesAgent[identityMode] * identities[identityMode].displayMode), 100, certainties[identityMode] * 100);
    }
    originalColor = agentColor;
    info = str(identities[identityMode].types[id]);
    textInfo = str(int(attitudesAgent[identityMode] * 1000)/10);
  }

  //VARIABLES DICTATING DIRECTION AND MAGNITUDE OF CERTAINTY CHANGE DEPENDING ON INTERACTION
  float epsilon = .01;//original

  float broadcastCertaintyIncreaseAttitudeChange = 1;//certainty increase when broadcasting changed attitude
  float broadcastCertaintyIncreaseAttitudeSame = .01; //certainty increase when broadcasting same attitude
  float totalOutgroupCertaintyIncrease = 0;//allows for smaller groups to persist
  float differentAttitudeCertaintyDecrease = 0.001;//decreases certainty when influenced
  // float differentAttitudeCertaintyDecrease = 0.003;//decreases certainty when influenced

  float broadcastingIngroupDisaggreeDecrease = 0;
  float broadcastingIngroupChangeIncrease = 0;

  float certaintyFactorMe = .5;
  int clusterNumber;
  float toSwitch;

  float pInertia = 0;
  int pIngroupSize = 0;
  float pbroadcast = .5;
  float pCertainty = 0;

  //the BroadCasting agent (chosen at random) will execute this code, which initiates all other agents to change their attitude
  void broadcast() {

    broadcastingAgent = this;

    pCertainty = certainties[identityMode];
    pAttitude = attitudesAgent[identityMode];
    pIngroupSize = ingroup.size();
    pInertia = inertia;

    for (int i = 0; i < agents.length; i++) {
      agents[i].findIngroup();
      agents[i].findInfluenceGroup();//only if u wanna know influence!
    }

    //only uncertain agents will change opinions:
    float probabilityOfSwitch = sq(exp(-certainties[identityMode])* (1 - certainties[identityMode]));
    float toss = random(.1, 1);//this is .1 because random will more often give values between 0-.1 which is too low i find

    //this code injects noise
    //it is what keeps simulation from reaching equlibrium if certainties remain low!!
    if (toss < probabilityOfSwitch && useCertainty) { 

      float toswitch = random(-changeRange, changeRange);

      if (attitudesAgent[identityMode] + toswitch > 1 || attitudesAgent[identityMode] + toswitch < 0) {
        toswitch = -toswitch;
      }

      toSwitch = toswitch;
      attitudesAgent[identityMode] += toSwitch;

      certainties[identityMode] += epsilon * broadcastCertaintyIncreaseAttitudeChange * certaintyfactor;
    } else {
      //inertia stops an agent from changing it's opinion too many times
      if (useInertia) {
        inertia ++;
      }
    }

    certainties[identityMode] += epsilon * broadcastCertaintyIncreaseAttitudeSame * certaintyfactor;

    //once this agent has broadcasted, all other agents will respond to this broadcast by adjusting their attitude
    for (int i = 0; i < agents.length; i++) {
      agents[i].adjustAttitude();
    }

    //makes the certainties stay at 100%
    for (int i = 0; i < agents.length; i++) {
      agents[i].checkCertainties();
    }

    //once an agent has broadaste dand all agents have responded, the timestep is done
    timeStep++;

    println("TIME STEP", timeStep);
    println("***********************************************************");
  }


  float[] similarities = new float[agents.length];
  int similarityNum = 0;

  //calculates which agents are considered this agent's ingroup based on the similarity requirements
  void findIngroup() { 

    ingroup.clear();
    potentialIngroup.clear();

    //makes a list of all the similarities between each agent
    calculateDifferencesDiscrete(false);

    //if the similarities are greater than the similarity number, that agent is added to the ingroup list
    for (int i = 0; i < similarities.length; i++) {
      if (similarities[i] > similarityNum) {
        if (i!=id) {
          ingroup.add(agents[i]);
          potentialIngroup.add(agents[i]);
        }
      }
    }

    ArrayList <Agent> toRemove = new ArrayList <Agent>();

    //if the agents in their ingroup lie too far away from their own opinion (difference tolerance), they are removed
    for (int i = 0; i < ingroup.size(); i++) {
      float diffs = 0;
      for (int j = 0; j < attitudeNum; j++) {
        diffs +=  abs(ingroup.get(i).attitudesAgent[j] - this.attitudesAgent[j]);
      }
      if (diffs > differenceTolerance) {
        toRemove.add(ingroup.get(i));
      }
    }

    for (int i= 0; i < toRemove.size(); i ++) {
      for (int j = 0; j < ingroup.size(); j++) {
        if (toRemove.get(i) == ingroup.get(j)) {
          ingroup.remove(j);
        }
      }
    }


    //TEST, adding ideology, does this affect number of extremists?
    if (ideologyIngroup) {
      if (attitudesAgent[identityMode] >= .8) {
        for (int i = 0; i < agents.length; i ++) {
          if (agents[i].attitudesAgent[identityMode] >= .8) {
            if (agents[i] !=this) {
              ingroup.add(agents[i]);
            }
          }
        }
      }
      if (attitudesAgent[identityMode] <= .2) {
        for (int i = 0; i < agents.length; i ++) {
          if (agents[i].attitudesAgent[identityMode] <= .2) {
            if (agents[i] !=this) {
              ingroup.add(agents[i]);
            }
          }
        }
      }
    }
    findIngroupRanking();
  }


  FloatList tried = new FloatList();
  PVector exploredRange = new PVector();
  ArrayList <PVector> explored = new ArrayList <PVector>();
  int switchCount = 0;

  ArrayList <Agent> influenceGroup = new ArrayList <Agent>();
  ArrayList <Agent> potentialInfluenceGroup = new ArrayList <Agent>();

  //finds what other agents this agent is in their ingroup, and therefore able to influence
  void findInfluenceGroup() {

    influenceGroup.clear();
    potentialInfluenceGroup.clear();

    for (int i = 0; i < agents.length; i++) {
      if (agents[i] != this) {
        for (int j = 0; j < agents[i].ingroup.size(); j++) {
          if (agents[i].ingroup.get(j) == this) {
            influenceGroup.add(agents[i]);
          }
        }
        for (int j = 0; j < agents[i].potentialIngroup.size(); j++) {
          if (agents[i].potentialIngroup.get(j) == this) {
            potentialInfluenceGroup.add(agents[i]);
          }
        }
      }
    }
  }

  float[] ingroupRanking;

  //this ranks the ingroup members according to the prominence. more important identities will have more influence. 
  //will be irrelevant if prominance is not used.
  void findIngroupRanking() {

    float[] iweights = new float[ingroup.size()];
    float[] ingroupRankings = new float[ingroup.size()];

    if (ingroupranking) {
      for (int i = 0; i < ingroup.size(); i++) {
        for (int j = 0; j < identities.length; j++) {
          if (identities[j].types[id] == ingroup.get(i).identities[j].types[ingroup.get(i).id]) {
            iweights[i] += prominance[j];
          }
        }
      }

      float max = 0;
      for (int i = 0; i < iweights.length; i++) {
        if (iweights[i] > max) {
          max = iweights[i];
        }
      }

      for (int i = 0; i < iweights.length; i++) {
        ingroupRankings[i] = iweights[i]/max;
      }
    } else if (ingroupranking == false) {
      for (int i = 0; i < ingroupRankings.length; i++) {
        ingroupRankings[i] = 1;
      }
    }
    ingroupRanking = ingroupRankings;
  }

  //orders the agents according to how many traits they share with this agent. 
  void calculateDifferencesDiscrete(boolean shuffle) {

    PVector[] agentSimilarities = new PVector[agents.length];

    int maxSimilarCount = 0;
    for (int i = 0; i < agents.length; i++) {
      int similarCount = 0;
      for (int j = 0; j < identityCompare; j++) {
        if (identities[j].types[id] == agents[i].identities[j].types[agents[i].id]) {
          similarCount ++;
          if (maxSimilarCount < similarCount) {
            maxSimilarCount = similarCount;
          }
        }
      }
      agentSimilarities[i] = new PVector(agents[i].id, similarCount);
      similarities[i] = similarCount;
    }

    ArrayList <PVector> similarAgents = new ArrayList<PVector>();


    for (int j = (maxSimilarCount); j > -1; j--) {
      for (int i = 0; i < agentSimilarities.length; i++) {

        if (agentSimilarities[i].y == j) {
          similarAgents.add(new PVector(agentSimilarities[i].y, agentSimilarities[i].x));
          agentSimilarities[i] = new PVector(100, 100);
        }
      }
    }

    for (int i = 0; i < similarAgents.size(); i++) {

      if (int(similarAgents.get(i).y) == this.id) {

        PVector me = similarAgents.get(i);
        for (int j = i; j > 0; j--) {
          similarAgents.set(j, similarAgents.get(j - 1));
        }
        similarAgents.set(0, me);
      }
    }

    Agent[] typesForOrdering = new Agent[similarAgents.size()];

    for (int i = 0; i < agents.length; i++) {
      for (int j = 0; j < similarAgents.size(); j++) {
        if (agents[i].id == similarAgents.get(j).y) {
          typesForOrdering[j] = agents[i];
        }
      }
    }

    if (shuffle) {
      arrangeAgents(similarAgents);
    }
  }

  //arranges agents according to similarity, with this agent at the first position
  //used for debugging
  void arrangeAgents(ArrayList <PVector> toArrange) {

    println(this.id, "ARRANGING AGENTS");
    ArrayList <PVector> test = toArrange;

    int newyloc = 0;

    for (int i = 0; i < test.size(); i++) {
      if ((i) % lineNum == 0) {
        newyloc ++;
      }
      for (int j = 0; j < agents.length; j++) {
        if (agents[j].id == int(test.get(i).y)) {
          agents[j].location.x = (size/2 + lineSize)+ ((i)% lineNum) * (size + lineSize);
          agents[j].location.y = (-size/2) + newyloc * (size + lineSize);
        }
      }
    }
  }

  boolean baIg = false;
  int influenceCount = 0;

  float BAR = 0;

  //IMPORTANT adjusts attitude according to influence
  void adjustAttitude() { 

    baIg = false;
    float diffsA = abs(attitudesAgent[identityMode] - broadcastingAgent.attitudesAgent[identityMode]);
    float johnsonFactor =  (2 * exp(-pow(lambda * diffsA, 2))) - 1;

    if (broadcastingAgent != this) {
      pAttitude= attitudesAgent[identityMode];
      pIngroupSize = ingroup.size();
      pCertainty = certainties[identityMode];
      pInertia = inertia;
    }

    if (abs(broadcastingAgent.attitudesAgent[identityMode] - attitudesAgent[identityMode]) > .01) {
      if (johnson2) {
        certainties[identityMode] -= .001 * johnsonFactor  * certaintyfactor;
      } else if (useIngroup == false) {
        certainties[identityMode] -= certaintyFactorMe * differentAttitudeCertaintyDecrease * certaintyfactor;
      } else {
        certainties[identityMode] -= epsilon * differentAttitudeCertaintyDecrease * certaintyfactor;
      }
    }

    if (ingroup.size() == 0 && broadcastingAgent != this) {
      if (johnson2) {
        certainties[identityMode] += totalOutgroupCertaintyIncrease * johnsonFactor * certaintyfactor;
      } else {
        certainties[identityMode] += totalOutgroupCertaintyIncrease * certaintyfactor;
      }
    }
    int noBa = 0;
    for (int i =0; i < ingroup.size(); i++) {
      if (ingroup.get(i) != broadcastingAgent) {
        noBa ++;
      }
      if (noBa == ingroup.size() && broadcastingAgent != this) {
        if (johnson2) {
          certainties[identityMode] += totalOutgroupCertaintyIncrease * johnsonFactor * certaintyfactor;
        } else {
          certainties[identityMode] += totalOutgroupCertaintyIncrease * certaintyfactor;
        }
      }

      //the agent will only be affected if the broadcasting agent is a member of their ingroup
      if (ingroup.get(i) == broadcastingAgent) {
        baIg = true;
        float bc = broadcastingAgent.certainties[identityMode] ;
        float mc = certainties[identityMode] ;

        float baAgree = 0;
        float baDisagree = 0;
        for (int j = 0; j < ingroup.size(); j++) {
          if (abs(ingroup.get(j).attitudesAgent[identityMode] - broadcastingAgent.attitudesAgent[identityMode]) < .009) {
            baAgree ++;
          } else {
            baDisagree ++;
          }
        }

        baAgree = baAgree/(ingroup.size());
        baDisagree = baDisagree/(ingroup.size());

        //if the certainty of this agent is less than that of the broadcasting agent, their attitude will be affected by the following code:
        if (mc <= bc)
        {

          float diffsG = abs(attitudesAgent[identityMode] - broadcastingAgent.attitudesAgent[identityMode]);
          float ku = exp(-sq(diffsG/(1-certainties[identityMode])));
          float gu = ku * broadcastingAgent.certainties[identityMode];//PREVIOUS AND NORMAL FUNCTION
          float pu = gu * ingroupRanking[i];//ORIGINAL

          float probabilityOfSwitch = 1;

          if (useInertia) {
            probabilityOfSwitch = exp(-inertia/200)*ingroupRanking[i];
          }

          BAR = probabilityOfSwitch;

          float toss = random(0, 1);

          //unless there is inertia where there is a probability event, the agent will move towards the attitude of the more certain broadcasting agent 
          if (toss < probabilityOfSwitch) {

            float pa = attitudesAgent[identityMode];
            attitudesAgent[identityMode] = attitudesAgent[identityMode] + ((broadcastingAgent.attitudesAgent[identityMode] - attitudesAgent[identityMode]) * pu);
            clusters.update(id, pa, attitudesAgent[identityMode]);

            switchnum ++;

            if (johnson) {
              certainties[identityMode] += baAgree * epsilon * pu * johnsonFactor * certaintyfactor;//prev was +//THIS WAS ORIGINAL
            } else {
              certainties[identityMode] += baAgree * epsilon * pu * certaintyfactor;//prev was +//THIS WAS ORIGINAL
            }
          }

          if (abs(broadcastingAgent.attitudesAgent[identityMode] - attitudesAgent[identityMode]) > .01) {
            if (johnson) {
              certainties[identityMode] -= baAgree * epsilon * pu * johnsonFactor * certaintyfactor;
            } else {
              certainties[identityMode] -= baAgree * epsilon * pu * certaintyfactor;
            }
          } else  if (abs(broadcastingAgent.attitudesAgent[identityMode] - attitudesAgent[identityMode]) < .01) {
            if (johnson) {
              certainties[identityMode] += baAgree * epsilon * pu * johnsonFactor * certaintyfactor;
            } else {
              certainties[identityMode] += baAgree * epsilon * pu * certaintyfactor;
            }
          }
          if (useInertia) {
            inertia ++;
          }

          //if the agent is more certain than the broadcasting agent, this code is executed:
        } else if (mc > bc) {
          //if the difference is large their certainty will decrease
          if (abs(broadcastingAgent.attitudesAgent[identityMode] - attitudesAgent[identityMode]) > .009) {
            if (johnson) {
              certainties[identityMode] -= baAgree * epsilon * ingroupRanking[i] * johnsonFactor * certaintyfactor;
            } else {
              certainties[identityMode] -= baAgree * epsilon * ingroupRanking[i] * certaintyfactor;
            }
            //if the difference is small their certainty will increase (they are in agreement)
          } else if (abs(broadcastingAgent.attitudesAgent[identityMode] - attitudesAgent[identityMode]) < .009) {
            if (johnson) {
              certainties[identityMode] += baAgree * epsilon * ingroupRanking[i] * johnsonFactor * certaintyfactor;
            } else {
              certainties[identityMode] += baAgree * epsilon * ingroupRanking[i] * certaintyfactor;
            }
          }
          if (useInertia) {
            inertia ++;
          }
        }
      }
    }

    float certaintiesToDisplay = int(certainties[identityMode]* 1000);
    certaintiesToDisplay = certaintiesToDisplay/1000;

    info2 = str(certaintiesToDisplay);
    textInfo = str(int(attitudesAgent[identityMode] * 1000)/10);
    checkColor();
  }

  float pAttitude;
  float changeCount = 0;

  //keeps certainties within a range of 0-1
  void checkCertainties() {

    if (abs(pAttitude - attitudesAgent[identityMode]) < .001) {
      //println(this.id, "PREVIOSIS ATTITUDE IS THE SAME");
    } else {
      changeCount ++;
    }
    if (certainties[identityMode]> 1||certainties[identityMode]< 0) {
      certainties[identityMode] = 1/(1+( exp(-10*(certainties[identityMode] - .5))) );
      float c = int(certainties[identityMode]* 1000);
      c = c/1000;
      certainties[identityMode] = c;
    }
  }

  int inertiaDrop = 0;
  float totalChange = 0;

  //for data and debugging
  void calcStats() {

    if (broadcastingAgent == this) {
      println(this.id, "BROADCASTED");
    }
    findIngroup();
    if (ingroup.size() - pIngroupSize < 0) {
      println(this.id, "MY INGROUP IS SMALLER");
    }

    if (baIg) {
      println(this.id, "BA", broadcastingAgent.id, " WAS MY INGROUP");
    }

    if (inertia - pInertia < 0) {
      inertiaDrop ++;
    }
    println(this.id, "inertia drop", inertiaDrop);

    if (attitudesAgent[identityMode] != pAttitude) {

      println(this.id, "ATTITUDE CHANGE", attitudesAgent[identityMode] - pAttitude);
      totalChange += attitudesAgent[identityMode] - pAttitude;
      println("TOTAL CHANGE:", totalChange);
    }
  }
}
