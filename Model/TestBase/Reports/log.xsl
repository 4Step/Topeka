<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html"/>

<xsl:key name="gid_key" match="*" use="generate-id()"/>

<xsl:template match="/">
<body vlink="#0000FF" alink="#800000" style="font-family: Tahoma; font-size: 8pt">
    <xsl:call-template name="index"/>
    <xsl:call-template name="content"/>
</body>
</xsl:template>

<xsl:variable name="all-r" select="/TCLog/section"/>

<xsl:template name="index">

    <table cellpadding="3" border="0" width="100%" style="border-collapse: collapse" bordercolor="#111111" cellspacing="0">
        <tr>
           <td align="middle" bgColor="#aaaaff">
           <font style="font-size: 13pt"><b>INDEX</b></font></td>
        </tr>
        <tr>
        <td>
        <table cellSpacing="0" border="0" width="100%" style="border-collapse: collapse" bordercolor="#111111" cellpadding="3">
            <xsl:for-each select="$all-r">
                <xsl:sort select="position()" order="descending" data-type="number"/>  
                <tr>
            <td class="direction" align="right"></td>
                <td class="direction"><a href="#{generate-id()}">
                <xsl:value-of select="@name"/>&#x20;<xsl:value-of select="@string"/>
                </a></td></tr>
            </xsl:for-each>
        </table>
        </td>
      </tr>
    </table>

    <p/>
    <hr/>
</xsl:template>

<xsl:template name="content">
    <xsl:for-each select="TCLog/*"> 
        <xsl:choose>
            <xsl:when test="name()='section'">  
                <xsl:variable name="header_id" select="generate-id()"/>
                <p/>
                <div width="100%" style="background: #AAAAFF; font-size: 13pt; font-weight: 700; padding: 1">
                    <a name="{$header_id}">
                    <xsl:value-of select="@name"/>&#x20;<xsl:value-of select="@string"/>
                    </a>
                </div>
                <p/>
    
                <xsl:for-each select="./*"> 
                    <xsl:call-template name="element">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>  
            <xsl:otherwise>  
                <xsl:variable name="prev-line" select="preceding::*[1]"/>
                <xsl:if test="name(preceding-sibling::*[1]) = 'section'">
                    <hr/>
                </xsl:if>
                <xsl:call-template name="element">
                    <xsl:with-param name="node" select="."/>
                </xsl:call-template>
            </xsl:otherwise>  
        </xsl:choose> 


    </xsl:for-each>
</xsl:template>

<xsl:template name="element">
    <xsl:param name="node"/>

    <xsl:for-each select="$node"> 
        <xsl:choose>
            <xsl:when test="name()='line'">  
                <div>
                    <xsl:attribute name="style">
                        <xsl:if test="@indent!=''">
                                margin-left:<xsl:value-of select="string(number(@indent) * 50)"/>px
                        </xsl:if>
                        <xsl:if test="@bold='true'">
                                <xsl:value-of select="'; font-weight: 700'"/>
                        </xsl:if>
                        <xsl:if test="@bg='dark'">
                                <xsl:value-of select="'; background: #EBECD2'"/>
                        </xsl:if>
                        <xsl:if test="@bg='light'">
                                <xsl:value-of select="'; background: #F9F9EE'"/>
                        </xsl:if>
                        <xsl:if test="@width!=''">
                                ; width:<xsl:value-of select="@width"/>
                        </xsl:if>
                        <xsl:if test="@padding!=''">
                                ; padding:<xsl:value-of select="@padding"/>
                        </xsl:if>
                        <xsl:if test="@border='true'">
                            ; border:1 solid
                        </xsl:if>

                        <xsl:if test="@font-color!=''">
                            <xsl:variable name="fontColorLine" select="concat('; color: ',@font-color,'; ')"/>
                            <xsl:value-of select="$fontColorLine"/>
                        </xsl:if>
                        <xsl:if test="@font-size">
                            <xsl:variable name="fontSizeLine" select="concat('; font-size: ',@font-size,'; ')"/>
                            <xsl:value-of select="$fontSizeLine"/>
                        </xsl:if>

                        <xsl:if test="@background-color">
                            <xsl:variable name="backColorLine" select="concat('; background-color: ',@background-color,'; ')"/>
                            <xsl:value-of select="$backColorLine"/>
                        </xsl:if>


                    </xsl:attribute>
                    <xsl:value-of select="translate(@string,' ','&#xa0;')"/>
                    <xsl:if test="not(@string) or @string=''">
                        <p/>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:when test="name()='table'">  
                <xsl:variable name="next_non_row_id" select="generate-id(following-sibling::*[name()!='row'])"/>
                <xsl:variable name="next_non_row_pos">
                    <xsl:for-each select="following-sibling::*">
                        <xsl:if test="generate-id() = $next_non_row_id">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="$next_non_row_id=''">
                        <xsl:value-of select="count(following-sibling::*) + 1"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:call-template name="table">
                    <xsl:with-param name="lines" select="descendant-or-self::* | following-sibling::*[position() &lt; $next_non_row_pos]"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose> 
    </xsl:for-each>
</xsl:template>

<xsl:template name="table">
    <xsl:param name="lines"/>
    <xsl:variable name="cols" select="$lines[1]/col"/>
    <xsl:variable name="rows" select="$lines[name()='row']"/>

    <xsl:variable name="has_col_headings">
        <xsl:for-each select="$cols"> 
            <xsl:if test="@name!=''">
                true
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
        <xsl:if test="$lines[1]/@indent!=''">
            <td>
            <xsl:attribute name="width">
                <xsl:value-of select="string(number($lines[1]/@indent) * 50)"/>px
            </xsl:attribute>
            </td>
        </xsl:if>
        <td>
        <table border="0" cellpadding="3" cellspacing="0" style="border-collapse: collapse" bordercolor="#EBECD2" width="100%">
        <xsl:for-each select="$lines[1]"> 
            <xsl:if test="@title!=''">
                <tr>
                  <td width="100%" height="1" bgcolor="#EBECD2">
                    <xsl:attribute name="colspan">
                        <xsl:value-of select="count($cols)"/>
                    </xsl:attribute>
                  <div style="font-size: 9pt; font-weight: 700">
                    <xsl:value-of select="@title"/>
                  </div></td>
                </tr>
            </xsl:if>

            <xsl:if test="$has_col_headings!=''">
                <tr>
                <xsl:for-each select="$cols"> 
                  <td bgcolor="#EBECD2" valign="top">
                    <xsl:attribute name="align">
                        <xsl:value-of select="@align"/>
                    </xsl:attribute>
                <font face="Tahoma" style="font-size: 8pt; font-weight: 700">
                        <xsl:value-of select="@name"/>
                </font></td>
                </xsl:for-each>
                </tr>
            </xsl:if>
        </xsl:for-each> 

        <xsl:for-each select="$rows"> 
            <tr>
            <xsl:for-each select="descendant::val"> 
                <xsl:variable name="col_idx" select="position()"/>
                <td valign="top" bgcolor="#F9F9EE">
                    <xsl:attribute name="align">
                        <xsl:value-of select="$cols[$col_idx]/@align"/>
                    </xsl:attribute>
                    <xsl:attribute name="width">
                        <xsl:value-of select="$cols[$col_idx]/@width"/>
                    </xsl:attribute>
                <font style="font-size: 8pt">
                    <div>
                    <xsl:if test="$cols[$col_idx]/@bold='true'">
                        <xsl:attribute name="style">
                            <xsl:value-of select="'font-weight: 700'"/>

                            <xsl:if test="$cols[$col_idx]/@font-color">
                                <xsl:variable name="fontColor" select="concat('color: ',$cols[$col_idx]/@font-color,'; ')"/>
                                <xsl:value-of select="$fontColor"/>
                            </xsl:if>

                            <xsl:if test="$cols[$col_idx]/@font-size">
                                <xsl:variable name="fontSize" select="concat('font-size: ',$cols[$col_idx]/@font-size,'; ')"/>
                                <xsl:value-of select="$fontSize"/>
                            </xsl:if>

                            <xsl:if test="$cols[$col_idx]/@background-color">
                                <xsl:variable name="backColor" select="concat('background-color: ',$cols[$col_idx]/@background-color,'; ')"/>
                                <xsl:value-of select="$backColor"/>
                            </xsl:if>

                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                    </div>
                </font>
                </td>
            </xsl:for-each> 
            </tr>
        </xsl:for-each> 
        </table>
    </td></tr></table>
    <p/>
</xsl:template>

</xsl:stylesheet>
