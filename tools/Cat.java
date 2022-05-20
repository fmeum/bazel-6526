package tools;

import com.google.devtools.build.runfiles.Runfiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public final class Cat {
  private static final boolean DEBUG = "1".equals(System.getenv("DEBUG"));

  private static void checkRunfile() throws IOException {
    Runfiles runfiles = Runfiles.create();
    Path dataRunfile = Paths.get(runfiles.rlocation("path_mapping_example/tools/data.txt"));
    if (!Files.exists(dataRunfile)) {
      throw new IOException("Failed to find data runfile");
    }
  }

  public static void main(String[] args) {
    try {
      checkRunfile();
    } catch (IOException e) {
      e.printStackTrace();
      System.exit(1);
    }
    if (args.length == 1 && args[0].startsWith("@")) {
      Path paramsFile = Paths.get(args[0].substring(1));
      List<String> unquotedArgs = new ArrayList<>();
      StringBuilder quotedArg = new StringBuilder();
      boolean inQuotes = false;
      try {
        for (String line : Files.readAllLines(paramsFile)) {
          if (line.startsWith("'")) {
            line = line.substring(1);
            inQuotes = true;
            quotedArg = new StringBuilder();
          }
          if (line.endsWith("'")) {
            quotedArg.append(line, 0, line.length() - 1);
            unquotedArgs.add(quotedArg.toString().replace("'\\''", "'"));
            inQuotes = false;
            continue;
          }
          if (inQuotes) {
            quotedArg.append(line);
          } else {
            unquotedArgs.add(line);
          }
        }
      } catch (IOException e) {
        e.printStackTrace();
        System.exit(1);
      }
      args = unquotedArgs.toArray(new String[0]);
    }

    File outFile = new File(args[0]);
    try (OutputStream out = Files.newOutputStream(outFile.toPath())) {
      for (int i = 1; i < args.length; i++) {
        String arg = args[i];
        if (arg.startsWith("<")) {
          Path path;
          if (arg.contains("=")) {
            String[] paths = arg.substring(1).split("=", 2);
            String shortPath = paths[0];
            path = Paths.get(paths[1]);
            if (!DEBUG) {
              out.write(String.format("(%s) ", shortPath).getBytes(StandardCharsets.UTF_8));
            }
          } else {
            path = Paths.get(arg.substring(1));
          }
          if (DEBUG) {
            out.write(String.format("(%s) ", path).getBytes(StandardCharsets.UTF_8));
          }
          Files.copy(path, out);
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
