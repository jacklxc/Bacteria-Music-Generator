class Rack {
  Capture video;
  int tube_number=8;
  int space_height;
  float[][] colors;
  SoundCipher sc;
  int white=150;
  float bright=1.5;
  int volume=100;
  int rack_width;
  int rack_height;
  int window_size;
  int window_height;
  int tube_height;
  int tube_width;
  int rack_x;
  int rack_y;
  int margin;

  Rack(Capture _video, SoundCipher _sc, int _window_size, 
  int _window_height, int _space_height) {
    video=_video;
    window_size=_window_size;
    window_height=_window_height;
    space_height=_space_height;
    sc=_sc;
    rack_width=int(window_size*0.75);
    rack_height=space_height/2;
    tube_height=int(space_height*0.6);
    tube_width=int(rack_width/(tube_number*3));
    rack_x=(window_size-rack_width)/2;
    rack_y=int(space_height*0.3);
    margin=(rack_width-tube_number*tube_width)/(tube_number+1);
  }

  void play(int n) {
    get_color();
    draw_rack();
    glow(n);
    play_sounds(n);
  }
  
  void get_color() {
    if (video.available()) {
      video.read();
      video.loadPixels();
      colors=new float[tube_number][3];
      float[] loc_x = {0.1,0.215,0.333,0.45,0.569,0.705,0.823,0.941};
      for (int i = 0; i < tube_number; i++) {
        // Begin loop for rows

        // Where are we, pixel-wise?
        int x = int(width*loc_x[i]) ;
        int y = int(video.height*0.7);
        int loc = x + y*video.width; 

        colors[i][0] = red(video.pixels[loc]);
        colors[i][1]= green(video.pixels[loc]);
        colors[i][2]= blue(video.pixels[loc]);
      }
    }
  }
  
  
  void draw_rack() {
    if (colors!=null) {
      pushMatrix();
      translate(0, window_height-space_height);
      noFill();
      stroke(255);
      strokeWeight(3);
      rect(rack_x, rack_y, 
      rack_width, rack_height, rack_height/10);
      pushMatrix();
      translate(rack_x, rack_y);
      for (int i = 0; i < tube_number; i++) {
        pushMatrix();
        translate(margin*(i+1)+tube_width*i, -rack_y*0.6);
        if ((colors[i][0]+colors[i][1]+colors[i][2])/3<white) {
          noStroke();
          fill(constrain(colors[i][0]*1.1,0,255),
         constrain(colors[i][1]*1.1,0,255), 
         constrain(colors[i][2]*1.1,0,255));
          rect(0, 0, tube_width, tube_height,tube_width/2);
        } else {
          noFill();
          stroke(255);
          strokeWeight(3);
          rect(0, 0, tube_width, tube_height,tube_width/2);
        }
        
        popMatrix();
      }
      popMatrix();
      popMatrix();
    }
  }

  void glow(int n) {
    n=n%tube_number;
    if (colors!=null) {
      pushMatrix();
      translate(0, window_height-space_height);
      if ((colors[n][0]+colors[n][1]+colors[n][2])/3<white) {
        pushMatrix();
        translate(rack_x, rack_y);
        pushMatrix();
        translate(margin*(n+1)+tube_width*n, -rack_y*0.6);
        fill(255, 255, 255, 40);
        noStroke();
        rect(0, 0, tube_width, tube_height,tube_width/2);
        popMatrix();
        popMatrix();
      }
      popMatrix();
    }
  }

    void play_sounds(int n) {
      n=n%tube_number;
      if (colors!=null) {
        float noteVal;
        float[] noteVals=new float[0];
        boolean play;
        if ((colors[n%tube_number][0]+colors[n%tube_number][1]
          +colors[n%tube_number][2])/3<white) {
          play=true;
        } else {
          play=false;
        }
        if (play) {
          noteVal = noteVal(n);
          noteVals=append(noteVals, noteVal);
        }
        sc.instrument(instrument(n));
        println(instrument(n));
        sc.playChord(noteVals, volume, 0.25);
      }
    }

  int instrument(int n){
    int h=int(hue(color(colors[n][0],colors[n][1],
    colors[n][2]))%6);
    if (h==0){return 38;}
    else if (h==1){return 103;}
    else if (h==2){return 112;}
    else if (h==3){return 113;}
    else if (h==4){return 117;}
    else {return 124;}
  }
  
  int noteVal(int n){
    int h=int(hue(color(colors[n][0],colors[n][1],
    colors[n][2]))%6);
    if (h==0){return 14;}
    else if (h==1){return 20;}
    else if (h==2){return 24;}
    else if (h==3){return 60;}
    else if (h==4){return 96;}
    else {return 60;}
  }

    void volume_up() {
      volume=constrain(volume+5, 0, 127);
    }

    void volume_down() {
      volume=constrain(volume-5, 0, 127);
    }
  }

