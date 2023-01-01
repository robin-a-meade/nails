# Nails for NailGun

This repo is for *nails* for [NailGun](https://github.com/facebook/nailgun).

Just Tagsoup and net.sf.saxon.Transform, so far.

## Resources about NailGun and for writing nails

- http://www.martiansoftware.com/nailgun/  
  ([NailGun Quick Start](http://www.martiansoftware.com/nailgun/quickstart.html))
- https://www.javadoc.io/doc/com.facebook/nailgun-server
- https://github.com/facebook/nailgun 

## NailGun server supports UNIX domain socket

Instead of specifying an IP address, I recommend specifying a path to use for a UNIX domain socket, like this `local:/tmp/ngs`. This is more secure because UNIX file permissions can restrict read and write access to only  you.

**Tip:** Export an environment variable like `NAILGUN_SERVER=local:/tmp/ngs` in your `.bash_profile`. The `ng` client respects this environment variable. This way you don't need to specify `--nailgun-server local:/tmp/ngs` with each client invocation.

## Considerations for writing nails

### Handle relative paths

If you want relative paths to work when invoking a java class through the `ng` client, write a wrapper class that converts any relative path arguments to absolute paths before passing them on to the regular main class. Otherwise, relative paths will resolve relative to the directory you started the NailGun server in!

### Enclose the nail's main logic in a try-catch block

Enclose the nail's main logic in a try-catch block and print a stack trace if a `Throwable` is thrown. Otherwise, the client receives no feedback when an exception occurs! (There's a Pull Request that might address this: https://github.com/facebook/nailgun/pull/162.)

## ng-tagsoup (nail wrapper for org.ccil.cowan.tagsoup.CommandLine)

- https://central.sonatype.dev/artifact/org.ccil.cowan.tagsoup/tagsoup/1.2.1
- https://www.javadoc.io/doc/org.ccil.cowan.tagsoup/tagsoup/latest/index.html

A symbolic link named `ng-tagsoup` should be created:
```
cd ~/.local/bin
ln -s ng-tagsoup /usr/local/bin/ng
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

## ng-saxon-transform (nail wrapper for net.sf.saxon.Transform)

- https://www.saxonica.com/documentation11/#!using-xsl/commandline
- https://saxonica.plan.io/projects/saxonmirrorhe/repository/he/revisions/he_mirror_saxon_11_4/entry/src/main/java/net/sf/saxon/Transform.java

A symbolic link named `ng-saxon-transform` should be created:
```
cd ~/.local/bin
ln -s ng-saxon-transform /usr/local/bin/ng
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

## Todo: Write a user Systemd service to start the NailGun server
