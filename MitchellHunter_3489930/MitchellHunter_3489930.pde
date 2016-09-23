ArduinoInput input; // Import our ArduinoInput Class 
SoundInput sound;

// Create shader objects
PShader shaderToy;
PShader rgbShiftShader;

PGraphics shaderToyFBO;
PGraphics rgbShiftFBO;


//-------------------------------------
void setup() {
  size(640, 480, P3D);
  //fullScreen(P3D);
  noStroke();
  background(0);
  
  input = new ArduinoInput(this); // call the constructor of ArduinoInput
  sound = new SoundInput(this);
   
  shaderToy = loadShader("mShader.glsl"); // Load our .glsl shader from the /data folder
  shaderToy.set("iResolution", float(width), float(height), 0); // Pass in our xy resolution to iResolution uniform variable in our shader
  shaderToyFBO = createGraphics(width, height, P3D);
  shaderToyFBO.shader(shaderToy);

  rgbShiftShader = loadShader("chromaticAbberation.glsl");
  rgbShiftShader.set("iResolution", float(width), float(height), 0);
  rgbShiftFBO = createGraphics(width, height, P3D);
  rgbShiftFBO.shader(rgbShiftShader); 
}

//-------------------------------------
void updateShaderParams() {
  float[] sensorValues = input.getSensor(); 

  rgbShiftShader.set("offset",map(sound.getVolume(),0.0,1.0,0.0,0.5));
  shaderToy.set("pan", map(sensorValues[0],0.0,1024.0,0.0,1.5));
  shaderToy.set("light",map(sound.getVolume(),0.0,1.0,0.0003,0.0025));
  shaderToy.set("swivel", map(sensorValues[1],0.0,1024.0,0.0,1.5));
  shaderToy.set("wideSpeed", map(sensorValues[2],0.0,1024.0,1.0,0.0));
}


//-------------------------------------
void draw() {
  updateShaderParams();

  shaderToyFBO.beginDraw();
  shaderToy.set("iGlobalTime", millis() / 1000.0); // pass in a millisecond clock to enable animation 
  shader(shaderToy); 
  shaderToyFBO.rect(0, 0, width, height); // We draw a rect here for our shader to draw onto
  shaderToyFBO.endDraw();

  rgbShiftFBO.beginDraw();
  rgbShiftShader.set("iGlobalTime", millis() / 1000.0); 
  rgbShiftShader.set("tex", shaderToyFBO);
  shader(rgbShiftShader); 
  rgbShiftFBO.rect(0, 0, width, height); 
  rgbShiftFBO.endDraw();

  image(rgbShiftFBO, 0, 0, width, height);
}