// everything needed to create a NumPy-like array

// to allow us to do math on our array
public interface MathLambda<T> {
  public T plus(T one, T two);
  public T clone(T original);
}

// to allow us to fill our array with equations
public interface EquationLambda<T> {
  public T calc(int rowA, int colA);
}


// The base array class
class JArray<T> {

  int rows, cols;
  ArrayList<ArrayList<T>> array;
  MathLambda<T> math;

  // constructors

  // give it a size and default value to fill with (plus how to do math on it)
  public JArray(int rows, int cols, T defaultVal, MathLambda<T> math) {
    this.rows = rows;
    this.cols = cols;
    // make an empty arraylist
    array = new ArrayList<ArrayList<T>>();
    // fill it with a bunch of rows
    for (int r = 0; r < this.rows; r++) {
      ArrayList<T> row = new ArrayList<T>();
      // which are then filled with the default value
      for (int c = 0; c < this.cols; c++) {
        row.add(defaultVal);
      }
      array.add(row);
    }
    // and use our math
    this.math = math;
  }

  // give it a size and a function to fill with (plus how to do math on it)
  public JArray(int rows, int cols, EquationLambda<T> function, MathLambda<T> math) {
    this.rows = rows;
    this.cols = cols;
    // make an empty arraylist
    array = new ArrayList<ArrayList<T>>();
    for (int r = 0; r < rows; r++) {
      ArrayList<T> row = new ArrayList<T>();
      for (int c = 0; c < cols; c++) {
        // add cells based on the function's result at that location
        row.add(function.calc(r, c));
      }
      array.add(row);
    }
    // using this type of math
    this.math = math;
  }

  // given an input arraylist to make a copy of (and the math to work on it)
  public JArray(ArrayList<ArrayList<T>> input, MathLambda<T> math) {
    this(input, false, math);
  }

  // given an input arraylist to maybe make a copy of (and the math to work on it)
  public JArray(ArrayList<ArrayList<T>> input, boolean canKeep, MathLambda<T> math) {
    rows = input.size();
    cols = input.get(0).size();
    if ( canKeep ) { // can keep it, just move the reference
      array = input;
    } else { // can't keep it, copy each item
      array = new ArrayList<ArrayList<T>>();
      for (int r = 0; r < rows; r++) {
        ArrayList<T> row = new ArrayList<T>();
        for (int c = 0; c < cols; c++) {
          // clone each item
          T item = input.get(r).get(c);
          row.add( math.clone(item) );
        }
        array.add(row);
      }
    }
    this.math = math;
  }

  // a printable description of the size
  public String getSize() {
    return "(" + rows + ", " + cols + ")";
  }

  // a check if two array have the same size
  public boolean sameSize(JArray<T> two) {
    return (this.rows == two.rows) && (this.cols == two.cols);
  }

  // get an item
  public T get(int row, int col) {
    return array.get(row).get(col);
  }

  // get an item, using decimals as input
  public T get(float row, float col) {
    return get(int(row), int(col));
  }

  // create a new array that's the result of two added together
  public JArray<T> plus(JArray<T> two) {
    return this.plus(two, false);
  }

  // add another array to this one, possibly overwriting the current array or not
  public JArray<T> plus(JArray<T> two, boolean inPlace) {
    // make sure they're the same size
    assert sameSize(two) :
    "The two arrays must be the same size, but they are " + getSize() + " and " + two.getSize();
    // where we're going to build it
    ArrayList<ArrayList<T>> build;
    if ( inPlace ) { // to do it in place, just overwrite this one
      build = array;
    } else { // to not do it in place, copy all of the items over
      build = new ArrayList<ArrayList<T>>();
      for (int r = 0; r < this.rows; r++) {
        ArrayList<T> row = new ArrayList<T>();
        for (int c = 0; c < cols; c++) {
          // clone each item
          T item = array.get(r).get(c);
          row.add( math.clone(item) );
        }
        build.add(row);
      }
    }
    // add the second array to this one using our math
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        build.get(r).set(c, math.plus(build.get(r).get(c), two.get(r, c)) );
      }
    }
    if ( inPlace ) {
      return this;
    } else { // turn the array into a JArray if we need a new one
      return new JArray<T>(build, math);
    }
  }
}
