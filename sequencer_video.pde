class Sequencer_video {
  Capture video;
  SoundCipher sc;
  BlobDetection theBlobDetection;
  boolean newFrame=false;
  PImage img;
  int a, b;
  int grid_size;
  int grid_num;
  int interval;
  int block_size;
  int volume=50;
  float[][] blob_color;
  float[] avg_color=new float[3];
  float[][] blobs;
  float[][][] raw_color; 
  float threshold=0.5;
  boolean draw_grid=false;
  boolean[] sequence;
  int[] notes = {
    96, 93, 91, 89, 86, 84, 81, 79, 77, 74, 72, 69, 67, 65, 62, 60
  };

  Sequencer_video(Capture _video, SoundCipher _sc, int _grid_num, 
  int _grid_size,int _interval) {
    colorMode(RGB, 255, 255, 255, 100);
    video=_video;
    sc=_sc;
    grid_num=_grid_num;
    grid_size=_grid_size;
    interval=_interval;
    block_size=(interval+grid_size)*grid_num;
    
    sequence=new boolean[grid_num*grid_num];
    img = new PImage(grid_num*(grid_size+interval)-interval,
    grid_num*(grid_size+interval)-interval);
    theBlobDetection = new BlobDetection(img.width, img.height);
    theBlobDetection.setPosDiscrimination(true);
  }

  void threshold_up() {
    threshold=constrain(threshold+0.02, 0, 1);
    println(threshold);
  }

  void threshold_down() {
    threshold=constrain(threshold-0.02, 0, 1);
    println(threshold);
  }

  void position(int _a, int _b) {
    a=_a;
    b=_b;
  }

  void grid() {
    draw_grid=!draw_grid;
  }
  
  void grid_off(){
    draw_grid=false;
  }

  void bd() {
    if (video.available()) {
      theBlobDetection.setThreshold(threshold);
      video.read();
      img.copy(video, (video.width-video.height)/2, 0, video.height,
      video.height, 0, 0, img.width, img.height);
      image(img, a, b, img.width+interval, img.height+interval);
      fastblur(img, 2);
      theBlobDetection.computeBlobs(img.pixels);
      save_blob();
      blob_color();
      convert();
    }
  }

  void bd_draw(int n) {
    if (draw_grid) {
      
      draw_grid();
      glow(n);
      play_sounds(n);
    } else {
      drawBlobsAndEdges(true, false);
    }
  }

  void blob_color() {
    float red=0;
    float blue=0;
    float green=0;
    int total=theBlobDetection.getBlobNb ();
    for (int n=0; n<total; n++) {

      //get the color
      blob_color=new float[total][3];
      int centerX = int(blobs[n][0]+0.5*blobs[n][2]);
      int centerY = int(blobs[n][1]+0.5*blobs[n][3]);

      color c = get(centerX+a, centerY+b);
      blob_color[n][0] = red(c);
      blob_color[n][1] = green(c);
      blob_color[n][2] = blue(c);
  
      red+=blob_color[n][0];
      green+=blob_color[n][1];
      blue+=blob_color[n][2];
          

    }
    avg_color[0]=constrain(red/total*1.3,0,255);
    avg_color[1]=constrain(green/total*1.3,0,255);
    avg_color[2]=constrain(blue/total*1.3,0,255);

  }

  void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges) {
    pushMatrix();
    translate(a, b);
    noFill();
    rectMode(CORNER);
    Blob b;
    EdgeVertex eA, eB;
    for (int n=0; n<theBlobDetection.getBlobNb (); n++)
    {
      b=theBlobDetection.getBlob(n);
      if (b!=null)
      {
        // Edges
        if (drawEdges)
        {
          strokeWeight(3);
          stroke(0, 255, 0);
          for (int m=0; m<b.getEdgeNb (); m++)
          {
            eA = b.getEdgeVertexA(m);
            eB = b.getEdgeVertexB(m);
            if (eA !=null && eB !=null)
              line(
              eA.x*block_size, eA.y*block_size, 
              eB.x*block_size, eB.y*block_size
                );
          }
        }

        // Blobs
        if (drawBlobs&&b.w*block_size>5&&b.w*block_size<25&&
        b.h*block_size>5&&b.h*block_size<25)
        {
          strokeWeight(1);
          stroke(255, 0, 0);
         
          rect(
          b.xMin*block_size, b.yMin*block_size, 
          b.w*block_size, b.h*block_size
            );
        }
      }
    }
    popMatrix();
  }

  void fastblur(PImage img, int radius)
  {
    if (radius<1) {
      return;
    }
    int w=img.width;
    int h=img.height;
    int wm=w-1;
    int hm=h-1;
    int wh=w*h;
    int div=radius+radius+1;
    int r[]=new int[wh];
    int g[]=new int[wh];
    int b[]=new int[wh];
    int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
    int vmin[] = new int[max(w, h)];
    int vmax[] = new int[max(w, h)];
    int[] pix=img.pixels;
    int dv[]=new int[256*div];
    for (i=0; i<256*div; i++) {
      dv[i]=(i/div);
    }

    yw=yi=0;

    for (y=0; y<h; y++) {
      rsum=gsum=bsum=0;
      for (i=-radius; i<=radius; i++) {
        p=pix[yi+min(wm, max(i, 0))];
        rsum+=(p & 0xff0000)>>16;
        gsum+=(p & 0x00ff00)>>8;
        bsum+= p & 0x0000ff;
      }
      for (x=0; x<w; x++) {

        r[yi]=dv[rsum];
        g[yi]=dv[gsum];
        b[yi]=dv[bsum];

        if (y==0) {
          vmin[x]=min(x+radius+1, wm);
          vmax[x]=max(x-radius, 0);
        }
        p1=pix[yw+vmin[x]];
        p2=pix[yw+vmax[x]];

        rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
        gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
        bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
        yi++;
      }
      yw+=w;
    }

    for (x=0; x<w; x++) {
      rsum=gsum=bsum=0;
      yp=-radius*w;
      for (i=-radius; i<=radius; i++) {
        yi=max(0, yp)+x;
        rsum+=r[yi];
        gsum+=g[yi];
        bsum+=b[yi];
        yp+=w;
      }
      yi=x;
      for (y=0; y<h; y++) {
        pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
        if (x==0) {
          vmin[y]=min(y+radius+1, hm)*w;
          vmax[y]=max(y-radius, 0)*w;
        }
        p1=x+vmin[y];
        p2=x+vmax[y];

        rsum+=r[p1]-r[p2];
        gsum+=g[p1]-g[p2];
        bsum+=b[p1]-b[p2];

        yi+=w;
      }
    }
  }

  void save_blob() {

    Blob b;
    blobs=new float[theBlobDetection.getBlobNb ()][4];
    for (int n=0; n<theBlobDetection.getBlobNb (); n++)
    {
      b=theBlobDetection.getBlob(n);
      if (b.w*block_size>5&&b.w*block_size<25&&
      b.h*block_size>5&&b.h*block_size<25){
      blobs[n][0]=b.xMin*block_size;
      blobs[n][1]=b.yMin*block_size;
      blobs[n][2]=b.w*block_size;
      blobs[n][3]=b.h*block_size;
    }
    }
  }

  void convert() {
    int row, col, i;
    for (int n=0; n<sequence.length; n++) {
      sequence[n]=false;
    }
    for (int n=0; n<blobs.length; n++) {
      row=int(blobs[n][0]+blobs[n][2]*0.5)/grid_size;
      col=int(blobs[n][1]+blobs[n][3]*0.5)/grid_size;
      i=row+col*grid_num;
      if (i>=0&&i<grid_num*grid_num) {
        sequence[i]=true;
      }
    }
  }

  void draw_grid() {
    pushMatrix();
    translate(a, b);
    rectMode(CORNER);
    int x=0;
    int y=0;
    noStroke();
    fill(0);
    rect(-interval,-interval,(grid_size+interval)*grid_num+interval*2,
    (grid_size+interval)*grid_num+interval*2);
    for (int i=0; i<sequence.length; i++) {
      x=(grid_size+interval)*(i%grid_num);
      y=(grid_size+interval)*(i/grid_num);

        noStroke();
      
      if (sequence[i]) {
        fill(avg_color[0], avg_color[1], avg_color[2]);
      } else {
        fill(100);
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
              fill(255, 255, 255, 30);
              rect(n*(interval+grid_size), m*(interval+grid_size), 
              grid_size, grid_size);
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
      if (sequence[i*grid_num+n]) {
        noteVal = float(notes[i]);
        noteVals=append(noteVals, noteVal);
      }
    }
   sc.instrument(instrument());
   sc.playChord(noteVals, volume, 0.25);
  }

  float[] grid_color() {
    float[] color_return=new float[3];
    arrayCopy(avg_color, color_return);
    return color_return;
  }

  boolean[] sequence() {
    boolean[] to_return=new boolean[sequence.length];
    arrayCopy(sequence, to_return);
    return to_return;
  }

  int instrument(){
    int h=int(hue(color(avg_color[0],avg_color[1],
    avg_color[2]))%8);
    if (h==0){return 2;}
    else if (h==1){return 3;}
    else if (h==2){return 38;}
    else if (h==3){return 46;}
    else if (h==4){return 47;}
    else if (h==5){return 55;}
    else if (h==6){return 116;}
    else {return 120;}
  }
  
  void volume_up() {
    volume=constrain(volume+5, 0, 127);
  }

  void volume_down() {
    volume=constrain(volume-5, 0, 127);
  }
}

