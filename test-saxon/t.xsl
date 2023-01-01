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