<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cue="http://www.clarin.eu/cmd/cues/1"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="text()"/>
    
    <xsl:variable name="NS_CMD" select="'http://www.clarin.eu/cmd/1'"/>
    <xsl:variable name="NS_CMDP" select="concat('http://www.clarin.eu/cmd/1/profiles/',/ComponentSpec/Header/ID)"/>
    
    <xsl:template match="ComponentSpec">
        <sch:schema queryBinding="xslt2">
            <sch:ns uri="{$NS_CMD}" prefix="cmd"/>
            <sch:ns uri="{$NS_CMDP}" prefix="cmdp"/>
            
            <xsl:apply-templates/>
            
        </sch:schema>
    </xsl:template>
    
    <xsl:template match="Component[exists(*/(@cue:inclusive-or|@cue:exclusion|@cue:exclusive-or))]">
        <xsl:variable name="ctxt" select="current()"/>
        <sch:pattern id="{generate-id(.)}-{@name}">
            <sch:rule role="error" context="cmd:Components/cmdp:{string-join(ancestor-or-self::Component/@name,'/cmdp:')}">
                <!-- inclusive-or -->
                <xsl:for-each-group select="*[exists(@cue:inclusive-or)]" group-by="@cue:inclusive-or">
                    <xsl:comment>inclusive-or(<xsl:value-of select="current-grouping-key()"/>)=[<xsl:value-of select="string-join(current-group()/@name,',')"/>]</xsl:comment>
                    <xsl:variable name="tests" as="xs:string+">
                        <xsl:for-each select="current-group()">
                            <xsl:sequence select="concat('exists(cmdp:',@name,')')"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <sch:assert test="{string-join($tests,' or ')}">
                        <xsl:text>{</xsl:text>
                        <xsl:value-of select="$NS_CMDP"/>
                        <xsl:text>}</xsl:text>
                        <xsl:value-of select="$ctxt/@name"/>
                         <xsl:text> should contain </xsl:text>
                        <xsl:value-of select="string-join(for $i in current-group() return(concat('{',$NS_CMDP,'}',$i/@name)),' or ')"/>
                        <xsl:text>!</xsl:text>
                    </sch:assert>     
                </xsl:for-each-group>
                <!-- exclusive-or -->
                <xsl:for-each-group select="*[exists(@cue:exclusive-or)]" group-by="@cue:exclusive-or">
                    <xsl:comment>exclusive-or(<xsl:value-of select="current-grouping-key()"/>)=[<xsl:value-of select="string-join(current-group()/@name,',')"/>]</xsl:comment>
                    <xsl:variable name="tests" as="xs:string+">
                        <xsl:for-each select="current-group()">
                            <xsl:sequence select="concat('exists(cmdp:',@name,')')"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <sch:assert test="{string-join($tests,' != ')}">
                        <xsl:text>{</xsl:text>
                        <xsl:value-of select="$NS_CMDP"/>
                        <xsl:text>}</xsl:text>
                        <xsl:value-of select="$ctxt/@name"/>
                        <xsl:text> should contain </xsl:text>
                        <xsl:value-of select="string-join(for $i in current-group() return(concat('{',$NS_CMDP,'}',$i/@name)),' or ')"/>
                        <xsl:text>, but only one!</xsl:text>
                    </sch:assert>     
                </xsl:for-each-group>
                <!-- exclusion -->
                <xsl:for-each-group select="*[exists(@cue:exclusion)]" group-by="@cue:exclusion">
                    <xsl:comment>exclusion(<xsl:value-of select="current-grouping-key()"/>)=[<xsl:value-of select="string-join(current-group()/@name,',')"/>]</xsl:comment>
                    <xsl:variable name="tests" as="xs:string+">
                        <xsl:for-each select="current-group()">
                            <xsl:sequence select="concat('exists(cmdp:',@name,')')"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <sch:assert test="not({string-join($tests,' and ')})">
                        <xsl:text>{</xsl:text>
                        <xsl:value-of select="$NS_CMDP"/>
                        <xsl:text>}</xsl:text>
                        <xsl:value-of select="$ctxt/@name"/>
                        <xsl:text> may contain </xsl:text>
                        <xsl:value-of select="string-join(for $i in current-group() return(concat('{',$NS_CMDP,'}',$i/@name)),' or ')"/>
                        <xsl:text>, but if so only one!</xsl:text>
                    </sch:assert>     
                </xsl:for-each-group>
            </sch:rule>
        </sch:pattern>
    </xsl:template>
    
</xsl:stylesheet>