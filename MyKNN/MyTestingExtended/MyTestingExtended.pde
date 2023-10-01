import java.util.*;
import java.util.HashMap;
import processing.core.*;

Table table;
Table testExample;
Table trainExample; 
Table testLabel;
Table trainLabel; //creating tables

public dataPoint[] trainDataPoints = null; //array of data points
public dataPoint[] testDataPoints = null; //array of data points

String visualFeatureXglobal;
String visualFeatureYglobal;

float minXglobal;
float maxXglobal;
float minYglobal;
float maxYglobal;

int stage;



//float xMultiplier;
//float yMultiplier;

HashMap<String, Integer> labelColour = new HashMap<String, Integer>(); //hashmap to hold different colours correspomding to different labels

public String[] globalUniqueLabels = null;

void setup() {
  size(1000,1000);

  table = loadTable("iris.csv", "header"); //copies iris.csv to table
  
  stage = 1;
  
  String target_feature = "species"; //input for target feature, used for vertical split
  String visualFeatureX = "sepal_length";
  String visualFeatureY = "sepal_width";
  
  visualFeatureXglobal = visualFeatureX;
  visualFeatureYglobal = visualFeatureY;
  
  
  table.addColumn("random"); //adds a random column for shuffle
  
  testExample = new Table();
  trainExample = new Table(); 
  testLabel = new Table();
  trainLabel = new Table(); //calling test and train tables
  

  //Shuffling
  
  for (TableRow row : table.rows()) {
    float randomVal = random(0,1); //generates random number
    row.setFloat("random",randomVal); //sets the random number to the column    
  }
  
  table.sort("random"); //sorts by rand val
  
  //Horizontal Split
  
  for (int i = 0; i < table.getColumnCount(); i++) { //names the columns in test and training data set
    testExample.addColumn(table.getColumnTitle(i));
    trainExample.addColumn(table.getColumnTitle(i));
  }
  
  int testRows = int(table.getRowCount() *0.25); //calc number of rows for test data
  
  for (int i = 0; i < testRows; i++) { //populate test set
    TableRow row = table.getRow(i);
    testExample.addRow(row);
  }
  
  for (int i = testRows; i < table.getRowCount(); i++) { //populate training set
    TableRow row = table.getRow(i);
    trainExample.addRow(row);
  }
  
  //Vertical Split
  
  testExample.removeColumn("random");
  trainExample.removeColumn("random"); //removes the random number column
  
  testLabel.addColumn(target_feature);
  trainLabel.addColumn(target_feature); //names the column in label csv as the target feature
  
  for (int i = 0; i < testExample.getRowCount(); i++) { //populate test labels set, inc target feature. Removed later
    TableRow row = testExample.getRow(i);
    String label = row.getString(target_feature);
    testLabel.setString(i,target_feature,label);
  }
  
  for (int i = 0; i < trainExample.getRowCount(); i++) { //populate test labels set
    TableRow row = trainExample.getRow(i);
    String label = row.getString(target_feature);
    trainLabel.setString(i,target_feature,label);
  }
  

  testExample.removeColumn(target_feature);
  trainExample.removeColumn(target_feature); //removes the label column in examples
  
  
  
  saveTable(testExample,"testExample.csv"); 
  saveTable(trainExample,"trainExample.csv"); 
  
  saveTable(testLabel,"testLabel.csv");
  saveTable(trainLabel,"trainLabel.csv"); //saves to files (debug)
  
    
  //Training and Testing Model

  MyKNN tester = new MyKNN(trainExample, trainLabel); 
  Table predictions = tester.predict(testExample,5);
  
  //setting up visualisation

  createColours(labelColour,tester.unique_labels);
  
  trainDataPoints = createDataPoints(trainExample,trainLabel,visualFeatureX,visualFeatureY,target_feature,labelColour);
  testDataPoints = createDataPoints(testExample,testLabel,visualFeatureX,visualFeatureY,target_feature,labelColour);
  
  adjustXandY(trainDataPoints);
  adjustXandY(testDataPoints);
  
  globalUniqueLabels = tester.unique_labels;

  
  //Model Evaluation
  
  println("Accuracy was: " + Metrics.accuracy(testLabel, predictions));
  println("Loss was: " + Metrics.loss(testLabel, predictions));
  Metrics.confusion(testLabel, predictions); //evaluation of test run
  
  //exit();
}


void draw()
{
  //int stage = 1;
  createKey(labelColour, globalUniqueLabels,visualFeatureXglobal,visualFeatureYglobal,minXglobal,maxXglobal,minYglobal,maxYglobal);
  
  
  if (mousePressed == true){
    stage++;
  }
  if (stage == 1){
    stage1(trainDataPoints);
  }
  if (stage == 2){
    stage2(testDataPoints);
  }
  if (stage == 3){
    stage3(trainDataPoints,testDataPoints);
  }
  //stage2(testDataPoints);
}
