package tools;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

class Cat {
  private static final boolean DEBUG = "1".equals(System.getenv("DEBUG"));

  public static void main(String[] args) {
    if (args.length == 1 && args[0].startsWith("@")) {
      Path paramsFile = Paths.get(args[0].substring(1));
      try {
        args = Files.readAllLines(paramsFile).toArray(new String[0]);
      } catch (IOException e) {
        e.printStackTrace();
        System.exit(1);
      }
    }

    File outFile = new File(args[0]);
    try (OutputStream out = new FileOutputStream(outFile)) {
      for (int i = 1; i < args.length; i++) {
        String arg = args[i];
        if (arg.startsWith("<")) {
          Path path = Paths.get(arg.substring(1));
          Files.copy(path, out);
          if (DEBUG) {
            out.write(String.format(" (%s)", path).getBytes(StandardCharsets.UTF_8));
          }
        } else {
          out.write(arg.getBytes(StandardCharsets.UTF_8));
        }
      }
    } catch (IOException e) {
      e.printStackTrace();
      System.exit(1);
    }
  }
}
