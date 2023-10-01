import java.util.*;
import java.util.HashMap;
import processing.core.*;

Table table;
Table testExample;
Table trainExample; 
Table testLabel;
Table trainLabel; //creating tables


void setup() {
  size(1000,1000);

  table = loadTable("iris.csv", "header"); //copies iris.csv to table
  
  String target_feature = "species"; //input for target feature, used for vertical split
  
  table.addColumn("random"); //adds a random number column for shuffle
  
  testExample = new Table();
  trainExample = new Table(); 
  testLabel = new Table();
  trainLabel = new Table(); //calling test and train tables
  

  //Shuffling
  
  for (TableRow row : table.rows()) {
    float randomVal = random(0,1); //generates random number
    row.setFloat("random",randomVal); //sets the random number to the column    
  }
  
  table.sort("random"); //sorts by the random float, shuffling the entries
  
  //Horizontal Split
  
  for (int i = 0; i < table.getColumnCount(); i++) { //names the columns in test and training data set
    testExample.addColumn(table.getColumnTitle(i));
    trainExample.addColumn(table.getColumnTitle(i));
  }
  
  int testRows = int(table.getRowCount() *0.25); //calculates number of rows for test data, here I am using 25% for testing and 75% for training
  
  for (int i = 0; i < testRows; i++) { //populates test set
    TableRow row = table.getRow(i);
    testExample.addRow(row);
  }
  
  for (int i = testRows; i < table.getRowCount(); i++) { //populates training set
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
  
  for (int i = 0; i < trainExample.getRowCount(); i++) { //populate train labels set
    TableRow row = trainExample.getRow(i);
    String label = row.getString(target_feature);
    trainLabel.setString(i,target_feature,label);
  }
  

  testExample.removeColumn(target_feature);
  trainExample.removeColumn(target_feature); //removes the label column in examples
  
  
  
  saveTable(testExample,"testExample.csv"); 
  saveTable(trainExample,"trainExample.csv"); 
  
  saveTable(testLabel,"testLabel.csv");
  saveTable(trainLabel,"trainLabel.csv"); //saves to files (only done so that I can check the files for debug)
  
    
  //Training and Testing Model

  MyKNN tester = new MyKNN(trainExample, trainLabel); 
  Table predictions = tester.predict(testExample,5);
  
  //Model Evaluation
  
  println("Accuracy was: " + Metrics.accuracy(testLabel, predictions));
  println("Loss was: " + Metrics.loss(testLabel, predictions));
  Metrics.confusion(testLabel, predictions); //evaluation of test run
  
  exit();
}
  
