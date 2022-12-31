package org.robin_a_meade.nails;

import com.facebook.nailgun.NGContext;

public class Nail1 {

  public static void nailMain(NGContext context) {
    context.out.println("context.out");
    System.out.println("System.out");
    System.out.printf("%s: %s\n", "WorkingDirectory", context.getWorkingDirectory());
  }
  
}
