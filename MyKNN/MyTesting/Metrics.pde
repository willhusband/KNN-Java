static class Metrics //This section is code provided by my lecturer for this topic, John Darby.
{
  public static float accuracy(Table truth, Table predictions)
  {    
    // note: we could check things like: does the column title for the truth match that for the predictions...
    // ...but we don't, and you're not expected to add this kind of thing (e.g., exception handling, etc.). 
    // ...Error handling is purposefully left minimal and the expectation is that the caller (you!) knows what they're doing
    
    // keep track of the number of correct predictions:
    int correct = 0;
     
    // lots of ways to do this, but let's read out whole columns as String arrays, just to show how it works:
    String[] true_labels = truth.getStringColumn(0);
    String[] predicted_labels = predictions.getStringColumn(0);
    // note: you can also read columns as StringLists, IntLists, FloatLists, just as easily, see the Table class documentation...
    // ...you can also read a whole row if you know that all the values are of the same data type, e.g., getFloatRow(), getStringRow(), ...

    // for all of the true labels:
    for (int i=0; i<true_labels.length; i++)
    {
      // if there's a match with the predicted label, then up our counter:
      if (true_labels[i].equals(predicted_labels[i]))
      {
        correct++;
      }
    }
    
    // return the proportion of correct predictions:
    return ((float) correct) / true_labels.length;
  }
  
  public static float loss(Table truth, Table predictions)
  {
    // loss is just (1 - accuracy):
    return 1.0 - accuracy(truth, predictions);
  }
 
  public static void confusion(Table truth, Table predictions)
  {
    // note: we could check things like: do the column titles for the truth match those for the predictions...
    // ...but we don't, and you're not expected to add this kind of thing; onus is on the caller (see also the note up above)
         
    // let's get columns as StringLists this time - it has a useful .getUnique() method
    StringList all_labels = truth.getStringList(0);
    // we need to find unique values across _both_ sets of labels (labels could potentially be absent from either):
    all_labels.append(predictions.getStringList(0));
    // now call .getUnique()
    String[] unique_labels = all_labels.getUnique();
   
    // a 2D array ready to hold our confusion matrix scores:
    int confusion[][] = new int[unique_labels.length][unique_labels.length];
     
    // warning: the columns of debug won't reliably align, and it's not worth going down a rabbit-hole over trying to prettify: 
    for (int i=0; i<unique_labels.length; i++)
    {
      print(unique_labels[i] + " ");
    }
    
    println("");
 
    // for each row of the confusion matrix...
 
    // for each unique label (truth):
    for (int i=0; i<unique_labels.length; i++)
    {
      // find the rows where was this the true label (useful Table method):
      int[] matches = truth.findRowIndices(unique_labels[i], 0);
      
      // write all the columns of the confusion matrix in this row...  
      
      // for each unique label (predictions):
      for(int j=0; j<unique_labels.length; j++)
      {
        // initialise the current confusion matrix entry to zero:
        confusion[i][j] = 0;
          
        // where we have a match between true/predicted labels, add 1:
        for(int k=0; k<matches.length; k++)
        {
          if (predictions.getString(matches[k],0).equals(unique_labels[j]))
          {
            confusion[i][j]++;
          }
        }
        print(confusion[i][j] + "\t");
      }
      print(unique_labels[i] + "\n");
    }
     
  }
  
}
