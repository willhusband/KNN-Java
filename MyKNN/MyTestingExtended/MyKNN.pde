import java.util.*;

class MyKNN
{
  public Table examples;
  public Table labels;
  public String[] unique_labels;

  public int examples_count;
  public int features_count;
  public int classes_count;

  // constructor + the training phase

  MyKNN(Table train_examples, Table train_labels) 
  {
    // store the training data ('training the model'):
    this.examples = train_examples;
    this.labels = train_labels;

    // and some useful details (that shouldn't change):
    this.examples_count = train_examples.getRowCount();
    this.features_count = train_examples.getColumnCount();

    // find the classes in this problem (thanks to another useful Table class method):
    this.unique_labels = train_labels.getUnique(0);
    this.classes_count = this.unique_labels.length;


    // see some debug:
    this.summary();
  }


  //testing phase


  public Table predict(Table test_examples, int k) {
    
    //create new table for predictions
    
    Table predictions = new Table();
    predictions.addColumn(this.labels.getColumnTitle(0), Table.STRING); 

    for (int i = 0; i < test_examples.getRowCount(); i++) { //for every test example
      
      // calculate distance from current test point to each training point and store in array
      
      double[] distances = new double[this.examples_count]; 
      for (int j = 0; j < this.examples_count; j++) {
        distances[j] = calculateDistance(test_examples, i, this.examples, j); 
      }

      // find K closest training examples
      
      int[] closest_examples = getKClosest(distances, k);

      // count occurrences of each label in the k nearest neighbors
      
      HashMap<String, Integer> labelCounts = new HashMap<String, Integer>();
      for (int j = 0; j < k; j++) {
        String label = this.labels.getString(closest_examples[j], 0); //for every closest label..
        if (labelCounts.containsKey(label)) { //if the label already exists in the hashmap
          labelCounts.put(label, labelCounts.get(label) + 1); //increment the value held in hash table (value is frequency)
        } else {
          labelCounts.put(label, 1); //if it hasnt been entered into hashmap yet, make frequency 1
        }
      }

      // Predict label with most occurrences
      String predictedLabel = "";
      int maxCount = -1; //set to -1 so that predictedlabel never = ""
      for (String label : labelCounts.keySet()) { //for every label in hashmap
        int count = labelCounts.get(label); //get the frequency
        if (count > maxCount) {
          predictedLabel = label;
          maxCount = count; //if it's freq is larger than the current highest frequency, make that label the prediction
        }
      }

      predictions.setString(i, 0, predictedLabel); //add prediction for current test point to predictions table
    }

    return predictions;
  }


  //function for finding Euclidean distance
  private double calculateDistance(Table example1, int index1, Table example2, int index2) { 
    double distance = 0;
    for (int i = 0; i < this.features_count; i++) { //for every feature
      double diff = example1.getDouble(index1, i) - example2.getDouble(index2, i); //find the difference between the test point and training point's feature value
      distance += diff * diff; //add the square of this difference -> a^2 + b^2 + ... (pythagoras.. but extended)
    }
    return Math.sqrt(distance); //square root the total, like pythagoras
  }


  //function for finding indicies of the K nearest neighbours
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


  //summary section

  public void summary()
  {
    // just give some basic information about the model:

    println("----- Model details start -----");
    println("Number of training examples/labels = " + examples_count);
    println("Number of features = " + features_count);
    println("Number of unique classes = " + classes_count);
    println("Unique class labels are: ");

    for (int i=0; i<unique_labels.length; i++)
    {
      print(unique_labels[i] + "; ");
    }
    println("\n----- Model details stop  -----");
  }
}
