# Nails for NailGun

This repo is for *nails* for [NailGun](https://github.com/facebook/nailgun).

Just Tagsoup and net.sf.saxon.Transform, so far.

## Resources about NailGun and for writing nails

- http://www.martiansoftware.com/nailgun/  
  ([NailGun Quick Start](http://www.martiansoftware.com/nailgun/quickstart.html))
- https://www.javadoc.io/doc/com.facebook/nailgun-server
- https://github.com/facebook/nailgun 

## NailGun can be used with UNIX Domain Sockets

This isn't evident in the documentation or usage messages, but NailGun supports using UNIX Domain Sockets instead of TCP/IP Sockets.

```
./mvnw exec:java -Dexec.mainClass=com.facebook.nailgun.NGServer -Dexec.args="blah blah blah"
[...]
Usage: java NGServer
   or: java NGServer port
   or: java NGServer IPAddress
   or: java NGServer IPAddress:port
   or: java NGServer IPAddress:port timeout
```

```
$ ng 
NailGun v1.0.0

Usage: ng class [--nailgun-options] [args]
          (to execute a class)
   or: ng alias [--nailgun-options] [args]
          (to execute an aliased class)
   or: alias [--nailgun-options] [args]
          (to execute an aliased class, where "alias"
           is both the alias for the class and a symbolic
           link to the ng client)

where options include:
   --nailgun-D<name>=<value>   set/override a client environment variable
   --nailgun-version           print product version and exit
   --nailgun-showversion       print product version and continue
   --nailgun-server            to specify the address of the nailgun server
                               (default is NAILGUN_SERVER environment variable
                               if set, otherwise localhost)
   --nailgun-port              to specify the port of the nailgun server
                               (default is NAILGUN_PORT environment variable
                               if set, otherwise 2113)
   --nailgun-filearg FILE      places the entire contents of FILE into the
                               next argument, which is interpreted as a string
                               using the server's default character set.  May be
                               specified more than once.
   --nailgun-help              print this message and exit
```

This is mentioned in the discussion of issue#108:

-  Limit access to the daemon to the same user #108  
   https://github.com/facebook/nailgun/issues/108

Using a UNIX Domain Socket offers a higher degree of security than using a TCP/IP socket because UNIX file permissions on the UNIX Domain Socket file can retrict access to only the owner. No other users would have access to the NailGun server. Contrast to using the default of `localhost` port `2113`; other users on the system would be able to access the NailGun server running at that localhost port.

To use a UNIX Domain Socket, specify the address like this `local:<path to use for the UNIX Domain Socket file>`. For example, `local:/tmp/ngs`.

**Warning:** Make sure you set a restrictive umask value of 077 before launching the server. See the example `bin/ngs` script included in this project.

**Tip:** Export an environment variable like `NAILGUN_SERVER=local:/tmp/ngs` in your `.bash_profile`. The `ng` client respects this environment variable. This way you don't need to specify `--nailgun-server local:/tmp/ngs` with each client invocation.

## Considerations for writing nails

### Handle relative paths

If you want relative paths to work when invoking a java class through the `ng` client, write a wrapper class that converts any relative path arguments to absolute paths before passing them on to the regular main class. Otherwise, relative paths will resolve relative to the directory you started the NailGun server in!

### Enclose the nail's main logic in a try-catch block

Enclose the nail's main logic in a try-catch block and print a stack trace if a `Throwable` is thrown. Otherwise, the client receives no feedback when an exception occurs! (There's a Pull Request that might address this: https://github.com/facebook/nailgun/pull/162.)

## ng-tagsoup
This is a nail that wraps `org.ccil.cowan.tagsoup.CommandLine`.

Reference links about tagsoup:

- https://central.sonatype.dev/artifact/org.ccil.cowan.tagsoup/tagsoup/1.2.1
- https://www.javadoc.io/doc/org.ccil.cowan.tagsoup/tagsoup/latest/index.html
- https://github.com/jukka/tagsoup  
  (This fork seems to be what gets published to Maven Central. Note the  last commit message, in 2011: *"Add settings for Maven Central deployment"*)

A symbolic link named `ng-tagsoup` should be created:
```
cd ~/.local/bin
ln -s /usr/local/bin/ng ng-tagsoup
```

A `ng-alias` named `ng-tagsoup` should be created:
```
ng-alias ng-tagsoup org.robin_a_meade.nails.Tagsoup
```

Then `ng-tagsoup` should work:

```
curl https://en.wikipedia.org/wiki/XPath | ng-tagsoup
```

Test that relative paths work:
```
cd "$(mktemp -d)"
curl https://en.wikipedia.org/wiki/XPath -o XPath.html
ng-tagsoup XPath.html >XPath.xhtml
```

**PROBLEM:** The main class, [org.ccil.cowan.tagsoup.CommandLine](https://github.com/jukka/tagsoup/blob/master/src/java/org/ccil/cowan/tagsoup/CommandLine.java), is not reentrant. The options are stored in a static Hashtable. Thus the option values will be remembered between runs.

**WORKAROUND:** Luckily, the options Hashtable is *package-private*, not *private*. Thus we are able to create a new class in the `org.ccil.cowan.tagsoup` package that can re-initialize the options Hashtable. See the call to `org.ccil.cowan.tagsoup.CommandLineFix.reinitializeOptions()` in `org.robin_a_meade.nails.Tagsoup`.

## ng-saxon-transform
This is a nail that wraps `net.sf.saxon.Transform`.

Reference links about `net.sf.saxon.Transform`:

- https://www.saxonica.com/documentation11/#!using-xsl/commandline
- https://saxonica.plan.io/projects/saxonmirrorhe/repository/he/revisions/he_mirror_saxon_11_4/entry/src/main/java/net/sf/saxon/Transform.java

A symbolic link named `ng-saxon-transform` should be created:
```
cd ~/.local/bin
ln -s /usr/local/bin/ng ng-saxon-transform
```

A `ng-alias` named `ng-saxon-transform` should be created:
```
ng-alias ng-saxon-transform org.robin_a_meade.nails.SaxonTransform
```

Then `ng-saxon-transform` should work:

```bash
curl https://en.wikipedia.org/wiki/XPath \
  | ng-tagsoup \
  | ng-saxon-transform -s:- -xsl:t.xsl
```

The following `t.xsl` stylesheet can be used for a simple test:

`t.xsl`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="3.0">
  <xsl:output method="xml" omit-xml-declaration="no" indent="yes" />

<xsl:template match="/">
    <html>
      <xsl:apply-templates select="//p/b" />
    </html>
  </xsl:template>
<xsl:template
    match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
```


Test that relative paths work:
```bash
cd "$(mktemp -d)"
curl https://en.wikipedia.org/wiki/XPath -o XPath.html
ng-tagsoup XPath.html >XPath.xhtml
ng-saxon-transform -s:XPath.xhtml -xsl:t.xsl
```

## ng-saxon-query
This is a nail that wraps `net.sf.saxon.Query`.

Reference links about `net.sf.saxon.Query`:

- https://www.saxonica.com/documentation11/#!using-xquery/commandline
- https://saxonica.plan.io/projects/saxonmirrorhe/repository/he/revisions/he_mirror_saxon_11_4/entry/src/main/java/net/sf/saxon/Query.java

A symbolic link named `ng-saxon-query` should be created:
```
cd ~/.local/bin


```

A `ng-alias` named `ng-saxon-query` should be created:
```
ng-alias ng-saxon-query org.robin_a_meade.nails.SaxonQuery
```

Then `ng-saxon-query` should work:

```bash
curl https://en.wikipedia.org/wiki/XPath \
  | ng-tagsoup \
  | ng-saxon-query -s:- -q:q.xquery
```

The following `t.xsl` stylesheet can be used for a simple test:

`q.xquery`
```none
declare boundary-space preserve;
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method 'text';
declare option output:item-separator '&#x0A;';
//p/b
```

Test that relative paths work:
```bash
cd "$(mktemp -d)"
curl https://en.wikipedia.org/wiki/XPath -o XPath.html
ng-tagsoup XPath.html >XPath.xhtml
ng-saxon-query -s:XPath.xhtml -q:q.xquery
```

## Define a user systemd service for the NailGun server

Create the unit file:

```
SYSTEMD_EDITOR=tee systemctl --user edit --full --force ngs.service << 'EOF'
[Unit]
Description=NailGun Server

[Service]
Type=simple
ExecStart=%h/.local/bin/ngs

[Install]
WantedBy=default.target
EOF
```

Check that the unit file was property created:

```
systemctl --user cat ngs.service
```

Enable the service:

```
systemctl enable ngs.service
```

Start the service:

```
systemctl start ngs.service
```

Or, enable and start in one command:

```
systemctl enable --now ngs.service
```

The output can be seen in the journal:

```
journalctl -f
```

Optionally, install the [Systemd Manager](https://extensions.gnome.org/extension/4174/systemd-manager/) Gnome extension. It provides a GUI for controlling systemd services.