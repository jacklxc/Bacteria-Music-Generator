//step sequencer
class Sequencer {

  boolean[] empty;
  float[] rgb_list;
  int grid_num;
  int grid_size;
  int interval;

  SoundCipher sc;
  boolean select=false;
  int a, b;
  int volume=50;
  boolean on=true;
  float red=0;
  float green=0; 
  float blue=0;
  int[] notes = {
    96, 93, 91, 89, 86, 84, 81, 79, 77, 74, 72, 69, 67, 65, 62, 60
  };
  boolean[] sequence;

  Sequencer(SoundCipher _sc, 
  int _grid_num, int _grid_size, int _interval, int _a, int _b) {
    sc=_sc;
    grid_num=_grid_num;
    grid_size=_grid_size;
    interval=_interval;

    a=_a;
    b=_b;


    sequence=new boolean[grid_num*grid_num];
    for (int i=0; i<sequence.length; i++) {
      sequence[i]=false;
    }

    empty=new boolean[grid_num*grid_num];
    for (int i=0; i<sequence.length; i++) {
      empty[i]=false;
    }
  }

  void get_sequence(boolean[] _sequence) {
    sequence=_sequence;
  }

  void get_color(float[] _rgb_list) {
    rgb_list=_rgb_list;
    red=rgb_list[0];
    green=rgb_list[1];
    blue=rgb_list[2];
  }

  void draw_grid() {
    pushMatrix();
    translate(a, b);
    rectMode(CORNER);
    int x=0;
    int y=0;
    
    //black background
    noStroke();
    fill(0);
    rect(-interval, -interval, (grid_size+interval)*grid_num+interval*2, 
    (grid_size+interval)*grid_num+interval*2);
    
    for (int i=0; i<sequence.length; i++) {
      x=(grid_size+interval)*(i%grid_num);
      y=(grid_size+interval)*(i/grid_num);
      if (sequence[i]) {
        fill(red, green, blue);
      } else {
        if (select){fill(120);}
        else {fill(70);}
      }
      rect(x, y, grid_size, grid_size);
    }

    popMatrix();
  }

  void glow(int n) {
    pushMatrix();
    translate(a, b);
    rectMode(CORNER);
    for (int m=0; m<grid_num; m++) {
      if (sequence[m*grid_num+n]) {
        for (int p=-1; p<2; p++) {
          for (int q=-1; q<2; q++) {
            if (n+p>=0&&n+p<grid_num&&m+q>=0&&
              m+q<grid_num) {
              noStroke();
              fill(255, 255, 255, 20);
              rect((n+p)*(interval+grid_size), (m+q)*(interval+grid_size), 
              grid_size, grid_size);
            }
            if (p==0&&q==0){
              fill(red, green, blue);
              rect(n*(interval+grid_size)-interval/2, m*(interval+grid_size)-interval/2, 
              grid_size+interval, grid_size+interval);
              fill(255, 255, 255, 30);
              rect(n*(interval+grid_size)-interval/2, m*(interval+grid_size)-interval/2, 
              grid_size+interval, grid_size+interval);
            }
          }
        }
      }
    }
    popMatrix();
  }


  void play_sounds(int n) {
    float noteVal;
    float[] noteVals=new float[0];

    for (int i=0; i<grid_num; i++) {

      // if the data text file has a "1" play note
      if (sequence[i*grid_num+n]) {
        noteVal = float(notes[i]);
        noteVals=append(noteVals, noteVal);
      }
    }
    sc.instrument(instrument());
    sc.playChord(noteVals, volume, 0.25);
  }
  
  int instrument(){
    int h=int(hue(color(red,green,blue))%8);
    if (h==0){return 2;}
    else if (h==1){return 3;}
    else if (h==2){return 38;}
    else if (h==3){return 46;}
    else if (h==4){return 47;}
    else if (h==5){return 55;}
    else if (h==6){return 116;}
    else {return 120;}
  }

  void select(boolean _select) {
    select=_select;
  }

  void volume_up() {
    volume=constrain(volume+5, 0, 127);
  }

  void volume_down() {
    volume=constrain(volume-5, 0, 127);
  }

  void delete() {
    sequence=empty;
  }
}

