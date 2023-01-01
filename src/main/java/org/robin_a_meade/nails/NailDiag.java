package org.robin_a_meade.nails;

import com.facebook.nailgun.NGContext;

/**
 * Nail diagnostics
 */
public class NailDiag {

  public static void nailMain(NGContext context) throws Exception {
    // System.out and context.out seem to be functionally identitical.
    // I'm not sure what the difference is. Why do we need both?
    context.out.println("This is written to context.out");
    System.out.printf("%s: %s\n", "context.out", context.out.toString());
    System.out.println("This is written to System.out");
    System.out.printf("%s: %s\n", "System.out", System.out.toString());
    System.out.printf("%s: %s\n", "WorkingDirectory", context.getWorkingDirectory());
    // The client does not receive a report of the following exception!
    // There is a pull request that, I think, addresses this problem: https://github.com/facebook/nailgun/pull/162 
    // In the mean time, it is important to always wrap your nail's logic within a try catch block
    // so you can give the user feedback when an exception occurs.
    if (true) {
      throw new Exception("dummy exception"); // The user never gets informed of this exception!
    }
    System.out.println("Reached end of nail");
  }
}
