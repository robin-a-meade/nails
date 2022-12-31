package org.robin_a_meade.nails;

import com.facebook.nailgun.NGContext;
import net.sf.saxon.Transform;

public class SaxonTransform {
  public static void nailMain(NGContext context) {
    try {
      String workingDirectory = context.getWorkingDirectory();
      String[] args = context.getArgs();
      // System.err.printf("args.length: %d\n", args.length);

      for (int i = 0; i < args.length; i++) {
        String arg = args[i];
        // System.err.printf("%d: %s\n", i, arg);
        if (!arg.startsWith("-"))
          continue;
        String argTemp = arg.substring(1); // The arg without leading hyphen
        int indexOfColon = argTemp.indexOf(":");
        if (indexOfColon == -1)
          continue;
        String opt = argTemp.substring(0, indexOfColon);
        // System.err.printf("opt: %s\n", opt);
        switch (opt) {
          case "s":
          case "xsl":
            String optval = argTemp.substring(indexOfColon + 1);
            // System.err.printf("optval: %s\n", optval);
            if (optval.equals("-") || optval.startsWith("/") || optval.startsWith("http://")
                || optval.startsWith("https://")) {
            } else {
              args[i] = "-" + opt + ":" + workingDirectory + "/" + optval;
            }
            break;
        }

      }
      /*
       * for (int i = 0; i < args.length; i++) {
       * System.out.printf("%d: %s\n", i, args[i]);
       * }
       */
      new Transform().doTransform(args, "Dummy string arg for backwards compatibility");
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
