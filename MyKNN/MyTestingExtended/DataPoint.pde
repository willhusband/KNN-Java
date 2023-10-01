public class dataPoint
{
  public float x;
  public float y;
  public String label;
  public color colour;
  
  dataPoint(float x, float y, String label)
  {
    this.x = x;
    this.y = y;
    this.label = label;
    this.colour = 0;
  }
  
  dataPoint(float x, float y, String label, color colour)
  {
    this.x = x;
    this.y = y;
    this.label = label;
    this.colour = colour;
  }
  
}
