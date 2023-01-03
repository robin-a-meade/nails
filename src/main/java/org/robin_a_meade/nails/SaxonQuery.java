package org.robin_a_meade.nails;

import com.facebook.nailgun.NGContext;

public class SaxonQuery {
  public static void nailMain(NGContext context) {
    try {
      String workingDirectory = context.getWorkingDirectory();
      String[] args = context.getArgs();
      for (int i = 0; i < args.length; i++) {
        String arg = args[i];
        if (!arg.startsWith("-"))
          continue;
        String argTemp = arg.substring(1); // The arg without leading hyphen
        int indexOfColon = argTemp.indexOf(":");
        if (indexOfColon == -1)
          continue;
        String opt = argTemp.substring(0, indexOfColon);
        switch (opt) {
          case "s":
          case "q":
            String optval = argTemp.substring(indexOfColon + 1);
            if (optval.equals("-") || optval.startsWith("/") || optval.startsWith("http://")
                || optval.startsWith("https://")) {
            } else {
              args[i] = "-" + opt + ":" + workingDirectory + "/" + optval;
            }
            break;
        }
      }
      net.sf.saxon.Query.main(args);
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
