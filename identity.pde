//each identity is its own class which each agent belongs to depending on the identity mode
//very simple, mostly done for conceptual understanding of the code

class Identity {

  float[] types = new float[agents.length];
  int id;
  String identitytype;
  float displayMode;
  int identityRange;

  Agent owner;
  Agent [] beholders = new Agent[agents.length];

  int attitudeNum = 1;
  ArrayList <float[]> norms;

  Identity(int initId) {

    id = initId;
    identityRange = IDR;
    displayMode = 270;

    for (int i = 0; i < beholders.length; i ++) {
      beholders[i] = agents[i];
      types[i] = int(random(0, identityRange));
      types[i] = types[i]/10;
    }
  }
}
