//this is simply the starting screen with instructions

String title = "Agent-Based Model: Social Identity and Certainty";
boolean intro = true;

void intro() {

  fill(0);
  rect(width/2, height/2, width, height);

  String[] introText = loadStrings("intro.txt");

  String introString = "";

  for (int i = 0; i < introText.length; i++) {
    introString += " " + introText[i];
  }
 
  pushStyle();
  fill(360);
  textSize(50);
  text(title, width/2, 50, width - 100, height);
  textSize(30);
  text(introString, width/2, height/2, width - 200, height);
  popStyle();
  
  pushStyle();
  fill(200,100,100);
  rect(width/2, height - 50, 200,60);
  fill(360);
  textSize(30);
  text("BEGIN", width/2, height - 55);
  popStyle();
  
  if(mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY < height - 50 + 30 && mouseY > height - 50 - 30){
    if(mousePressed){
      intro = false;
    }
  }
}
