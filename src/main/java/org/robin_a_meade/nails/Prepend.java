package org.robin_a_meade.nails;

/**
 * Copy lines from stdin to stdout while prepending the first argument to each line
 *
 * @author <a href="https://robin-a-meade.org">Robin A. Meade</a>
 */

 import java.util.Scanner;

 public class Prepend {
 
   public static void main(String[] args) throws Exception {
     String prepend = "";
 
     if (args.length > 0) {
       prepend = args[0];
     }
 
     Scanner input = new Scanner(System.in);
     while (input.hasNextLine()){
       System.out.print(prepend);
       System.out.println(input.nextLine());
     }
   }
 }
 