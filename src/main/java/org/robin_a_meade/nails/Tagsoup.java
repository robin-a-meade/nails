package org.robin_a_meade.nails;

import com.facebook.nailgun.NGContext;
import org.ccil.cowan.tagsoup.CommandLine;

public class Tagsoup {

  public static void nailMain(NGContext context) {
    try {
      String workingDirectory = context.getWorkingDirectory();
      String[] args = context.getArgs();
      for (int i = 0; i < args.length; i++) {
        String arg = args[i];
        if (!arg.startsWith("/")) {
          args[i] = workingDirectory + "/" + arg;
        }
      }
      CommandLine.main(args);
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
