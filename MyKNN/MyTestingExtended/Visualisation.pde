void createColours(HashMap<String, Integer> labelColours, String[] labels) { //assigns colours to each different label
  for (int i = 0; i < labels.length; i++) {
    String label = labels[i];
    if (!labelColours.containsKey(label)) {
      if (labelColours.size() == 0) {
        labelColours.put(label, color(255, 0, 0));
      } else if (labelColours.size() == 1) {
        labelColours.put(label, color(0, 255, 0));
      } else if (labelColours.size() == 2) {
        labelColours.put(label, color(0, 0, 255)); //goes through red green and blue for first 3, then generates random colours
      } else {
        labelColours.put(label, color(random(255), random(255), random(255)));
      }
    }
  }
}

dataPoint[] createDataPoints(Table examples, Table labels, String visualFeatureX, String visualFeatureY, String target_feature, HashMap<String, Integer> labelColour) { //generates datapoints from table

  dataPoint[] dataPoints = new dataPoint[examples.getRowCount()];

  for (int i=0; i < examples.getRowCount(); i++) {
    dataPoints[i] = new dataPoint(examples.getFloat(i, visualFeatureX), examples.getFloat(i, visualFeatureY), labels.getString(i, target_feature), labelColour.get(labels.getString(i, target_feature)));
  }

  return dataPoints;
}

void adjustXandY(dataPoint[] dataPoints) { //adjusts the x and y points for each data point so that they fill up a 1000 by 1000 box

  float minX = 0;
  float minY = 0;

  float maxX = 0;
  float maxY = 0; //holds the min / max vals of features being examined

  for (int i=0; i < dataPoints.length; i++) { //populates min / max values from dataPoints array
    if (i==0) {
      minX = dataPoints[i].x;
      minY = dataPoints[i].y;
    }
    if (i!=0 && dataPoints[i].x < minX) {
      minX = dataPoints[i].x;
    }
    if (i!=0 && dataPoints[i].y < minY) {
      minY = dataPoints[i].y;
    }
    if (dataPoints[i].x > maxX) {
      maxX = dataPoints[i].x;
    }
    if (dataPoints[i].y > maxY) {
      maxY = dataPoints[i].y;
    }
  }
  
  minXglobal = minX;
  maxXglobal = maxX;
  minYglobal = minY;
  maxYglobal = maxY;

  float rangeX = maxX - minX;
  float rangeY = maxY - minY; //figures out range between min / max
  float midY = rangeY / 2;

  float xMultiplier = 1000/rangeX;
  float yMultiplier = 1000/rangeY; //figures out the multiplier for each feature value being examined, so it fills the graph

  for (int i=0; i < dataPoints.length; i++) {
    dataPoints[i].x = dataPoints[i].x - minX;
    dataPoints[i].y = dataPoints[i].y - minY;//sets the min values as 0 essentially, so that they are on the edge of the graph
    float difFromMidPoint = midY - dataPoints[i].y;
    dataPoints[i].y = dataPoints[i].y + 2*difFromMidPoint; //this bit is done to invert the y values. Processing counts y from 0 from the top down. Graphs are the opposite usually. Helps visualise
    dataPoints[i].x = dataPoints[i].x * xMultiplier;
    dataPoints[i].y = dataPoints[i].y * yMultiplier;
  }
}

void createKey(HashMap<String, Integer> labelColour, String[] labels, String visualFeatureX, String visualFeatureY, float minX, float maxX, float minY, float maxY) {
  textSize(30);
  int y = 100;
  for (int i = 0; i < labelColour.size(); i++) {
    String label = labels[i];
    fill(labelColour.get(label));
    text(label, 850, y);
    y = y + 50;
  }
  textSize(20);
  fill(120);
  text(visualFeatureY + " (y) " + "range = " + minY + " to " + maxY, 50, 50);
  text(visualFeatureX + " (x) " + "range = " + minX + " to " + maxX, 700, 950);
}

void stage1(dataPoint[] trainDataPoints) { //stage 1 just shows the labelled training data
  
  for (int i=0; i < trainDataPoints.length; i++) {
    fill(trainDataPoints[i].colour);
    circle(trainDataPoints[i].x, trainDataPoints[i].y, 10);
  }
  fill(255);
  rect(50,100,750,75);
  textSize(15);
  fill(0);
  text("this is our training data. As you can see, we already know the class of each data point. Usually we take around 75% of our dataset as training data, and the remaining 25% as testing data (press any key to continue)", 50, 100, 750, 75);
}

void stage2(dataPoint[] testDataPoints) {
  //fill(255);
  for (int i = 0; i < testDataPoints.length; i++){
    if (testDataPoints[i].y > 90){
      fill(255);
      circle(testDataPoints[i].x, testDataPoints[i].y, 10);
      break;
    }
  }
  fill(255);
  rect(50,100,750,75);
  textSize(15);
  fill(0);
  text("this is our first test data point, coloured in white. we know it's position in the feature space but not it's class (press any key to continue)", 50, 100, 750, 75);
  
}


void stage3(dataPoint[] trainDataPoints, dataPoint[] testDataPoints) {
  fill(255);
  rect(50,100,750,75);
  
}

double calculateDistance(float testX, float testY, float trainX, float trainY) {
  double distance = 0;
  for (int i = 0; i < 2; i++) { //for every feature
    double diffX = testX - trainX; //find the difference between the test point and training point's feature value
    double diffY = testY - trainY;
    distance += diffX * diffY; //add the square of this difference -> a^2 + b^2 + ... (pythagoras.. but extended)
  }
  return Math.sqrt(distance); //square root the total, like pythagoras
}


private int[] getKClosest(double[] distances, int k) { 
    int[] closestIndices = new int[k]; //create array depending on val of K
    Arrays.fill(closestIndices, -1); //fills array with -1 in case algorithm fails, -1 can't be used as an index so it ensures no false indicies are passed

    for (int i = 0; i < distances.length; i++) { //loops through every distance in distance array
      for (int j = 0; j < k; j++) { //loops k times (number of neighbours in closestIndicies array)
        if (closestIndices[j] == -1 || distances[i] < distances[closestIndices[j]]) { //if current space is empty in closestIndicies is empty, or if current distances val is shorter than the current distance in closestIndicies array
          
          //shift indices along to make room for new closest index
          for (int l = k-1; l > j; l--) {
            closestIndices[l] = closestIndices[l-1];
          }
          closestIndices[j] = i; //set current closestIndicies space as index of current ID
          break;
        }
      }
    }

    return closestIndices;
  }
