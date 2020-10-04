<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cue="http://www.clarin.eu/cmdi/cues/1"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="text()"/>
    
    <xsl:template match="ComponentSpec">
        <sch:schema queryBinding="xslt2">
            <sch:ns uri="http://www.clarin.eu/cmd/1" prefix="cmd"/>
            <sch:ns uri="http://www.clarin.eu/cmd/1/profiles/{Header/ID}" prefix="cmdp"/>
            
            <xsl:apply-templates/>
            
        </sch:schema>
    </xsl:template>
    
    <xsl:template match="Component[exists(*/(@cue:inclusive-or|@cue:exclusion|@cue:exclusive-or))]">
        <sch:pattern id="{generate-id(.)}-{@name}">
            <sch:rule role="error" context="cmd:Components/cmdp:{string-join(ancestor-or-self::Component/@name,'/cmdp:')}">
                <sch:assert test="false()">...</sch:assert>
            </sch:rule>
        </sch:pattern>
    </xsl:template>
    
</xsl:stylesheet>