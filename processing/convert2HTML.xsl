<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei html xs bod"
    version="2.0">
    
    <xsl:import href="../../consolidated-tei-schema/msdesc2html.xsl"/>

    <!-- Only set this variable if you want full URLs hardcoded into the HTML
         on the web site (previewManuscript.xsl overrides this to do so when previewing.) -->
    <xsl:variable name="website-url" as="xs:string" select="''"/>

    <!-- Any templates added below will override the templates in the shared
         imported stylesheet, allowing customization of manuscript display for each catalogue. -->

    
    <xsl:template name="Header">
        <div style="float:right;font-variant:small-caps; margin-left:1em; margin-bottom:2em; padding:0.5em; background-color:#EEEEEE; border:1px #CCCCCC solid; max-width:25%;">
            <p>List of works:</p>
            <table>
                <xsl:apply-templates select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc//msItem[title]" mode="fraglist"/>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="msItem" mode="fraglist">
        <tr style="vertical-align:top;">
            <td style="padding-right:1em;">
                <xsl:variable name="titletext" select="normalize-space(string-join(title[1]//text()[not(ancestor::foreign)], ' '))"/>
                <a href="{ concat('#', @xml:id) }" title="{ $titletext }">
                    <xsl:value-of select="bod:shorten($titletext, 48)"/>
                </a>
            </td>
            <td style="font-size:0.8em; white-space:nowrap;">
                <xsl:if test="ancestor::msPart or .//locus">
                    <xsl:if test="ancestor::msPart and (ancestor::msPart//msItem[title])[1]/@xml:id = @xml:id">
                        <a href="{ concat('#', ancestor::msPart[1]/@xml:id) }">
                            <xsl:text>Part </xsl:text>
                            <xsl:value-of select="ancestor::msPart[1]/@n"/>
                        </a>
                        <xsl:if test=".//locus">
                            <br/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="(.//locus)[1]" mode="fraglist"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="locus" mode="fraglist">
        <xsl:choose>
            <xsl:when test="exists(.//text())">
                <xsl:value-of select="normalize-space(string-join(.//text(), ' '))"/>
            </xsl:when>
            <xsl:when test="@from and @to">
                <xsl:text>fols. </xsl:text>
                <xsl:value-of select="@from"/>
                <xsl:text>–</xsl:text>
                <xsl:value-of select="@to"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    
    <xsl:template name="Footer">
        <div class="footer">
            <h3>Catalogue Images</h3>
            <ul>
                <xsl:for-each select="tokenize(/TEI/teiHeader/fileDesc/sourceDesc/msDesc/additional/adminInfo/tei:recordHist/tei:source/tei:ref/@facs, ' ')">
                    <li>
                        <a href="{ concat('http://genizah-qa.bodleian.ox.ac.uk/images/catalogue/', .) }"><xsl:value-of select="."/></a>
                    </li>
                </xsl:for-each>
            </ul>
            <h3>Fragment Images</h3>
            <ul>
                <xsl:for-each select="/TEI/facsimile/graphic/@url">
                    <xsl:variable name="jpg" select="replace(., '\.tiff*$', '.jpg')"/>
                    <li>
                        <a href="{ concat('http://genizah-qa.bodleian.ox.ac.uk/images/fragments/', $jpg) }"><xsl:value-of select="$jpg"/></a>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>


</xsl:stylesheet>
