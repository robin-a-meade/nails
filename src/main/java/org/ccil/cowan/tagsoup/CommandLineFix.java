package org.ccil.cowan.tagsoup;

import java.util.Hashtable;

public class CommandLineFix {
    public static void reinitializeOptions() {
        Hashtable options = org.ccil.cowan.tagsoup.CommandLine.options;
        options.put("--nocdata", Boolean.FALSE); // CDATA elements are normal
		options.put("--files", Boolean.FALSE);	// process arguments as separate files
		options.put("--reuse", Boolean.FALSE);	// reuse a single Parser
		options.put("--nons", Boolean.FALSE);	// no namespaces
		options.put("--nobogons", Boolean.FALSE);  // suppress unknown elements
		options.put("--any", Boolean.FALSE);	// unknowns have ANY content model
		options.put("--emptybogons", Boolean.FALSE);	// unknowns have EMPTY content model
		options.put("--norootbogons", Boolean.FALSE);	// unknowns can't be the root
		options.put("--pyxin", Boolean.FALSE);	// input is PYX
		options.put("--lexical", Boolean.FALSE); // output comments
		options.put("--pyx", Boolean.FALSE);	// output is PYX
		options.put("--html", Boolean.FALSE);	// output is HTML
		options.put("--method=", Boolean.FALSE); // output method
		options.put("--doctype-public=", Boolean.FALSE); // override public id
		options.put("--doctype-system=", Boolean.FALSE); // override system id
		options.put("--output-encoding=", Boolean.FALSE); // output encoding
		options.put("--omit-xml-declaration", Boolean.FALSE); // omit XML decl
		options.put("--encoding=", Boolean.FALSE); // specify encoding
		options.put("--help", Boolean.FALSE); 	// display help
		options.put("--version", Boolean.FALSE);	// display version
		options.put("--nodefaults", Boolean.FALSE); // no default attrs
		options.put("--nocolons", Boolean.FALSE); // colon to underscore
		options.put("--norestart", Boolean.FALSE); // no restartable elements
		options.put("--ignorable", Boolean.FALSE);  // return ignorable whitespace
    }
}
