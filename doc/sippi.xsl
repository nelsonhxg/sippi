<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl/html/chunk.xsl"/>


<xsl:template name="user.footer.content">
  <HR/><TABLE WIDTH="100%"><TR>
  <!--<TD class="copyright">&#x00A9; 2013-2014 Thomas Mejer Hansen.</TD>-->
  <TD class="copyright" ALIGN="right" VALIGN="middlef">This site is hosted by
<A href="http://sourceforge.net/projects/sippi/">
<IMG src="http://sourceforge.net/sflogo.php?group_id=102150" width="88" height="31" border="0" alt="SourceForge Logo"></IMG></A></TD>
  </TR></TABLE>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-401277-6";
urchinTracker();
</script>
</xsl:template>

<xsl:param name="chunk.section.depth" select="3"></xsl:param>

<xsl:param name="use.id.as.filename" select="1"/>

<xsl:param name="xref.with.number.and.title" select="1"/>
<xsl:param name="insert.xref.page.number">yes</xsl:param>

<l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"> 
  <l:l10n language="en"> 
    <l:context name="xref-number-and-title"> 
      <l:template name="appendix" text="Appendix %n: &#8220;%t&#8221;"/> 
      <l:template name="chapter" text="Chapter %n: &#8220;%t&#8221;"/> 
      <l:template name="sect1" text="&#8220;%t&#8221;"/>
    </l:context>    
  </l:l10n>
</l:i18n>

<xsl:param name="html.stylesheet">style.css</xsl:param>

</xsl:stylesheet>
