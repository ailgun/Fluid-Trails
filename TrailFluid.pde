


PImage imgK;

PShader blur;
      PImage img;
      ArrayList<PVector> trail = new ArrayList<PVector>();
      
      static  float sizex;
      static  float sizey;
      
      final float FLUID_WIDTH = 32;
      final static int maxParticles = 500;
       static int w;
       static int h;
          
      float invWidth, invHeight;    // inverse of screen dimensions
      float aspectRatio, aspectRatio2;
      
      MSAFluidSolver2D fluidSolver;
      ParticleSystem particleSystem;
      
      PImage imgFluid; 
      boolean untouched=true;
       
      public void setup() {
        background(100);
        size(512,424);
        
        
        
        
        w=width;
        h=height;
          textAlign(CENTER,CENTER);
          invWidth = 1.0f/width;
          invHeight = 1.0f/height;
          aspectRatio = width * invHeight;
          aspectRatio2 = aspectRatio * aspectRatio;
      
          // create fluid and set options
          fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * height/width));
          fluidSolver.enableRGB(true).setFadeSpeed(0.003f).setDeltaT(0.5f).setVisc(0.0001f);
      
          // create image to hold fluid picture
          imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), ARGB);
           
 
                
          
          particleSystem = new ParticleSystem();    
      
      }
      
    
      public void mouseMoved() {
        
       
        
          float mouseNormX = mouseX * invWidth;
          float mouseNormY = mouseY * invHeight;
          float mouseVelX = (mouseX - pmouseX) * invWidth;
          float mouseVelY = (mouseY - pmouseY) * invHeight;
      
          addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
          }
 
              
      public void draw() {   
        
           noStroke();
           
           fill(0,0,0,100);
           rect(0,0,width,height);

        
         fluidSolver.update();
              for(int i=0; i<fluidSolver.getNumCells(); i++) {
                  
                  imgFluid.pixels[i] = color(100);
                  
               }           
 
       
       particleSystem.updateAndDraw();
       
      
      }
      
      // add force and dye to fluid, and create particles
      public void addForce(float x, float y, float dx, float dy) {
         
          float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio
      
          if(speed > -0.1) {
              if(x<0) x = 0;
              else if(x>1) x = 0.1;
              if(y<0) y = 0;
              else if(y>1) y = 0.1;
      
              float colorMult = 0;
              float velocityMult = 10.0f;
              
      
              int index = fluidSolver.getIndexForNormalizedPosition(x, y);
      
              int drawColor;
      
              colorMode(HSB, 360, 1, 1);
              float hue = ((x + y) * 180 + frameCount) % 360;
              drawColor = color(hue, 1, 1);
              colorMode(RGB, 1);
      
              fluidSolver.rOld[index]  += red(drawColor) * colorMult;
              fluidSolver.gOld[index]  += green(drawColor) * colorMult;
              fluidSolver.bOld[index]  += blue(drawColor) * colorMult;
      
              particleSystem.addParticles(x * width, y * height, 10);
              fluidSolver.uOld[index] += dx * velocityMult;
              fluidSolver.vOld[index] += dy * velocityMult;
              
          }
      }
      
      
      class Particle {
          final static float MOMENTUM = 0.3f;
          final static float FLUID_FORCE = 0.3f;
          
      
          float x, y;
          float vx, vy;
          float radius;       // particle's size
          float alpha;
          float mass;
          float glow;
      
          public void init(float x, float y) {
            
            
              this.x = x;
              this.y = y;
              vx = 0.2;
              vy = 0.2;
              
              radius = 1;
              
              alpha  = random(0.3f, 1);
              
              
              mass = random(0.1f, 1);
              
          }
      
      
          public void update() {
              // only update if particle is visible
              if(alpha == 0) return;
              
      
              // read fluid info and add to velocity
              int fluidIndex = fluidSolver.getIndexForNormalizedPosition(x * invWidth, y * invHeight);
              vx = fluidSolver.u[fluidIndex] * width * mass * FLUID_FORCE + vx * MOMENTUM;
              vy = fluidSolver.v[fluidIndex] * height * mass * FLUID_FORCE + vy * MOMENTUM;
      
              // update position
              x += vx;
              y += vy;
      
              // bounce of edges
              if(x<0) {
                  x = 0;
                  vx *= -1;
              }
              else if(x > width) {
                  x = width;
                  vx *= -1;
              }
      
              if(y<0) {
                  y = 0;
                  vy *= -1;
              }
              else if(y > height) {
                  y = height;
                  vy *= -1;
                  
              }
      
              // hackish way to make particles glitter when the slow down a lot
              if(vx * vx + vy * vy < 1) {
                  vx = random(-1, 1);
                  vy = random(-1, 1);
                  alpha = 0;
                  mass = -10;
                  
                  
              }
      
              // fade out a bit (and kill if alpha == 0);
              alpha *= 0.999f;
              if(alpha < 0.01f) alpha = 0;
              
              
              
          }
      
      
      
      
      
          public void drawOldSchool() {
            
         


        
              strokeWeight(alpha*1.5f);
              
              stroke(alpha, alpha, alpha,alpha);
              fill( 0xee, 0xee, 0xff, 50);
              
              
              
             
              line(x-vx, y-vy, x, y);
              
              
            
              
          }
      
      }
      
      class ParticleSystem {
       
      
      
          int curIndex;
      
          Particle[] particles;
      
          ParticleSystem() {
              particles = new Particle[maxParticles];
              for(int i=0; i<maxParticles; i++) particles[i] = new Particle();
              curIndex = 0;
      
          }
      
      
          public void updateAndDraw(){
             
                  
      
                  for(int i=0; i<maxParticles; i++) {
                      if(particles[i].alpha > 0) {
                          particles[i].update();
                          particles[i].drawOldSchool();    // use oldschool renderng
                      }
                  }
                  
      
      
          }
      
      
          public void addParticles(float x, float y, int count ){
              for(int i=0; i<count; i++) addParticle(x + random(-15,15), y + random(-15,15));
              
              
            
          }
      
      
          public void addParticle(float x, float y) {
              
              particles[curIndex].init(x, y);
              curIndex++;
              if(curIndex >= maxParticles) curIndex = 0;
              
          }
      
      }
      
  
    
    
    
    
 
    