interface ObserverTermination {
  public boolean shouldEnd();
}

public class Recording {

  boolean isRecording;
  int frameNumber;
  ObserverTermination whenToEnd;

  final String DIRECTORY_NAME = "frames/";
  final int FRAME_LIMIT = 200;

  public Recording() {
    isRecording = false;
    frameNumber = 0;
  }

  public void startRecording(Satellite movieStar) {
    isRecording = true;
    frameNumber = 0;
    whenToEnd = new ObserverTermination() {
      public boolean shouldEnd() {
        return movieStar != null && movieStar.toBeDeleted;
      }
    };
    cleanDirectory(DIRECTORY_NAME);
    println("Starting recording");
  }

  public void stopRecording() {
    isRecording = false;
    println("Stopped recording, recorded", frameNumber, "frames");
  }

  public void tryRecord() {
    if (isRecording) {
      recordFrame();
      if (whenToEnd.shouldEnd() || frameNumber >= FRAME_LIMIT) {
        stopRecording();
      }
    }
  }

  public void recordFrame() {
    String frameName = String.format("%30d.tif", frameNumber);
    saveFrame(DIRECTORY_NAME + frameName);
    frameNumber++;
  }

  public void cleanDirectory(String directoryName) {
    File dir = new File(sketchPath(directoryName));
    if (!dir.isDirectory()) {
      println(dir, "is not a directory!");
      println(dir.listFiles()[0]);
      return;
    }
    File[] frames = dir.listFiles();
    if (frames == null) {
      return;
    }
    for (File frame : frames) {
      frame.delete();
    }
  }
}
