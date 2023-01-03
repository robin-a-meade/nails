package org.robin_a_meade.nails;

import com.facebook.nailgun.NGContext;
import org.ccil.cowan.tagsoup.CommandLine;
import org.ccil.cowan.tagsoup.CommandLineFix;

public class Tagsoup {

  public static void nailMain(NGContext context) {
    try {
      CommandLineFix.reinitializeOptions();
      String workingDirectory = context.getWorkingDirectory();
      String[] args = context.getArgs();
      for (int i = 0; i < args.length; i++) {
        String arg = args[i];
        if (arg.startsWith("/")) {
          // Is an absolute path. Pass it through.
        } else if (arg.startsWith("--")) {
          // Is an option. Pass it through.
        } else {
          args[i] = workingDirectory + "/" + arg;
        }
      }
      CommandLine.main(args);
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
