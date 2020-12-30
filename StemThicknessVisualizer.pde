import processing.pdf.*;
PGraphicsPDF pdf;
StringList families;
PFont f;
XML xml;
Table stemThicknessTable = new Table();

void setup(){
  size(1200,600);
  pdf = (PGraphicsPDF)beginRecord(PDF, "StemThicknessVisualization-1.pdf");
  noLoop();
  families = listFileNames(sketchPath() + "/fonts",1);
}

void draw(){
  for(int d = 0; d < families.size(); d++){
    if(d!=0)pdf.nextPage();
    createFontXML(sketchPath() + "/fonts/" + families.get(d) + "/");
    createFamilyStemRelationSheet(families.get(d));
    counter=0;prevstem=20; stemrela=0.0;prev_lsb=0; prev_iw=0;
  }
  endRecord();
  exit();
}

void createFontXML(String ffamilydirectory){
  StringList fonts = listFileNames(ffamilydirectory,2);
  for(int i=0; i < fonts.size(); i++){
    if(!ttxIsExisting(fonts.get(i),ffamilydirectory)){ 
       Process p = exec("/Library/Frameworks/Python.framework/Versions/3.8/bin/ttx", ffamilydirectory + fonts.get(i) + ".otf");
       try {
           //int result = p.waitFor();
           p.waitFor();
           println("Succesfully created the xml font data file: " + fonts.get(i) + ".ttx with fonttools.");
       } catch (InterruptedException e) { }
    } else {println("No file has been generated.");}  
   } 
}

// This function returns all the files in a directory as an array of Strings  
StringList listFileNames(String dir, int listType){
  File file = new File(dir);
  if (file.isDirectory()){
    StringList nameslist = new StringList();
    String names[] = file.list();
    switch(listType){
        //only directories
        case 1:
        for(int i=0; i<names.length; i++){
          if(names[i].equals(".DS_Store")!=true && names[i].substring(names[i].length()-4,names[i].length()).equals(".ttx")!=true){
           nameslist.append(names[i]);
          }
        }
        break;
        //only .otfs no dstore or ttx
        case 2:
        for(int i=0; i<names.length; i++){
          if(names[i].equals(".DS_Store")!=true && names[i].substring(names[i].length()-4,names[i].length()).equals(".ttx")!=true){
           nameslist.append(names[i].substring(0,names[i].length()-4));
          }
        }
        break;
    }
    return nameslist;
  } else {
    //If it's not a directory
    println("Ist kein Ordner!");
    return null;
  } 
}

boolean ttxIsExisting(String fontname, String ffdir){
  fontname = fontname + ".ttx";
  boolean ttxExists = false;
  File file = new File(ffdir);
  if (file.isDirectory()){
    String names[] = file.list();
        int count = 0;
        while(count <= names.length-1){
          if(fontname.equals(names[count])){ ttxExists = true;println("A xml font data file with the name " + fontname + " already exists.");break;}
          else{ttxExists = false;}
          count = count+1;
        }
  } 
  return ttxExists;
}

void createFamilyStemRelationSheet(String fname){
  createTableColumns();
  StringList singleFontFileName = listFileNames(sketchPath() + "/fonts/" + fname +"/",2);
  int colID = 0;
 //iterate singleFontFileName list here
 for(int famMem = 0; famMem < singleFontFileName.size();famMem++){
 //find i-width and save it in table
  String[] ttxfontfilelines = loadStrings(sketchPath() + "/fonts/" + fname + "/" + singleFontFileName.get(famMem) + ".ttx");
  for(int i=0; i< ttxfontfilelines.length-1;i++){
    String p = ttxfontfilelines[i];
    String[] myi = match(p, "<mtx name=\"dotlessi\"");
    if(myi != null){
      println("Match found in line: " + i + ".");
      println(ttxfontfilelines[i]);
      xml = parseXML(ttxfontfilelines[i]);
      int glyphWidth = xml.getInt("width");
      int lsb = xml.getInt("lsb");
      stemThicknessTable.setInt(colID,"lsb",lsb);
      stemThicknessTable.setInt(colID,"i-width",glyphWidth);
      stemThicknessTable.setInt(colID,"stem",glyphWidth-(2*lsb));
      stemThicknessTable.setString(colID,"fontname",singleFontFileName.get(famMem));
      ++colID;
    }    
  }
 }
 //sort-Table
  stemThicknessTable.sort(3);
  for (TableRow row : stemThicknessTable.rows()) {
    println(row.getString("fontname") + ":\t\t\t" + row.getInt("i-width") + ":\t\t" + row.getInt("lsb"));
  }
  //draw i letters and diagram
  drawILetters(fname);
  pushMatrix();translate(300,300);
  drawDiagram(fname);
  popMatrix();
  stemThicknessTable.clearRows();
  stemThicknessTable.removeColumn("fontname"); 
  stemThicknessTable.removeColumn("i-width"); 
  stemThicknessTable.removeColumn("lsb");
  stemThicknessTable.removeColumn("stem");
}

void createTableColumns(){
  stemThicknessTable.addColumn("fontname",Table.STRING);
  stemThicknessTable.addColumn("i-width",Table.INT);
  stemThicknessTable.addColumn("lsb",Table.INT);
  stemThicknessTable.addColumn("stem",Table.INT);
}
   int counter=0,prevstem=20; float stemrela;int prev_lsb; int prev_iw; 

void drawDiagram(String fname_l){

   for (TableRow row : stemThicknessTable.rows()) {
   int iw = row.getInt("i-width");
   int lsb = row.getInt("lsb");//39 62
   int stem = iw-(2*lsb);
   stroke(0); strokeWeight(2.5);
   point(0+counter,0-stem);strokeWeight(0.25);
   line(0+counter,0,0+counter,0-stem);
   line(0+counter,0-stem,0+counter+50,0-stem);
   stemrela = float(stem)/float(prevstem);
   println(stem+"/"+prevstem+"="+stemrela);
   textSize(10);textAlign(LEFT);fill(0);f = createFont("Consolas", 10);textFont(f);
   if(counter!=0)text(stemrela,0+counter-3,14);   
   f = createFont(sketchPath()+"/fonts/"+fname_l+"/"+row.getString("fontname")+".otf",14);
   pushMatrix();
   translate(0+counter,30);
   textSize(10);
   text(stem,0,0);
   rotate(radians(90));fill(0,255);textAlign(LEFT);textFont(f);text(row.getString("fontname"),10,0);
   popMatrix();
   prev_lsb = lsb;
   prev_iw = iw;
   prevstem = stem;
   counter+=50;
   }
}

void drawILetters(String fname_l){
  for (TableRow row : stemThicknessTable.rows()) {
    f = createFont(sketchPath()+"/fonts/"+fname_l+"/"+row.getString("fontname")+".otf",650);
    textSize(650);textFont(f);
    textAlign(CENTER);fill(0,50);stroke(255);strokeWeight(1.0);
    text("i",150,560);
  }
}
