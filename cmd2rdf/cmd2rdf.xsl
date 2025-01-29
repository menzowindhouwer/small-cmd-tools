<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:cmd="http://www.clarin.eu/cmd/"
    xmlns:cue="http://www.clarin.eu/cmd/cues/1" 
    xmlns:trix="http://www.w3.org/2004/03/trix/trix-1"
    exclude-result-prefixes="xs math" version="3.0">

    <xsl:param name="registry"
        select="'https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/'"/>

    <xsl:variable name="rec" select="/"/>
    <xsl:variable name="prof-uri"
        select="concat($registry, /cmd:CMD/cmd:Header/cmd:MdProfile, '/xml')"/>
    <!--<xsl:param name="prof-uri" select="'./CIDOCexample.xml'"/>-->
    <xsl:param name="prof-doc" select="doc($prof-uri)"/>
    <xsl:variable name="A" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'"/>
    <xsl:variable name="NL" select="system-property('line.separator')"/>

    <xsl:template match="cmd:CMD">
        <trix:trix>
            <trix:graph>
                <xsl:comment expand-text="yes">
                    # record : {base-uri($rec)}
                    # profile: {$prof-uri}
                </xsl:comment>
                <trix:uri xsl:expand-text="yes">{/cmd:CMD/cmd:Header/cmd:MdSelfLink}</trix:uri>
                <xsl:apply-templates select="$prof-doc/ComponentSpec/Component/*">
                    <xsl:with-param name="cursor" select="$rec/cmd:CMD/cmd:Components/*" tunnel="yes"/>
                </xsl:apply-templates>
            </trix:graph>
        </trix:trix>
    </xsl:template>
    
    <xsl:function name="cmd:rdf_subject">
        <xsl:param name="c"/>
        <xsl:param name="i"/>
        <xsl:choose>
            <xsl:when test="starts-with($c/@cue:rdf_subject,'xpath:')">
                <xsl:evaluate context-item="$i" xpath="substring-after($c/@cue:rdf_subject,'xpath:')"/>
            </xsl:when>
            <xsl:when test="normalize-space($c/@cue:rdf_subject)='_'">
                <xsl:sequence select="concat('id:',generate-id($i))"/>
            </xsl:when>
            <!--<xsl:when test="$c/@cue:rdf_subject='uuid'"/>-->
            <xsl:otherwise>            
                <xsl:sequence select="$i/*[local-name()=$c/@cue:rdf_subject]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="Component(:[normalize-space(@ConceptLink)!='' or normalize-space(@rdf_subject)!='']:)">
        <xsl:param name="cursor"  tunnel="yes" select="()"/>
        <xsl:param name="subject" tunnel="yes" select="()"/>
        <xsl:variable name="c" select="."/>
        <xsl:variable name="instances" select="$cursor/*[local-name()=$c/@name]"/>
        <xsl:for-each select="$instances">
            <xsl:variable name="i" select="."/>
            <!-- 
            1. subject
            2. property
            -->
            <xsl:choose>
                <xsl:when test="normalize-space($c/@cue:rdf_subject)!=''">
                    <xsl:variable name="sub" select="cmd:rdf_subject($c,$i)"/>
                    <xsl:if test="normalize-space($c/@ConceptLink)!=''">
                        <trix:triple>
                            <xsl:choose>
                                <xsl:when test="starts-with($sub,'id:')">
                                    <trix:id xsl:expand-text="yes">{substring-after($sub,'id:')}</trix:id>
                                </xsl:when>
                                <xsl:otherwise>
                                    <trix:uri xsl:expand-text="yes">{$sub}</trix:uri>
                                </xsl:otherwise>
                            </xsl:choose>
                            <trix:uri xsl:expand-text="yes">{$A}</trix:uri>
                            <trix:uri xsl:expand-text="yes">{$c/@ConceptLink}</trix:uri>
                        </trix:triple>
                    </xsl:if>
                    <xsl:apply-templates select="$c/*">
                        <xsl:with-param name="cursor"  select="$i"   tunnel="yes"/>
                        <xsl:with-param name="subject" select="$sub" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="normalize-space($c/@ConceptLink)!=''">
                    <xsl:variable name="o" select="$c/Component[normalize-space(@cue:rdf_subject)!='']"/>
                    <xsl:comment expand-text="yes">
                        # subject: {$subject}
                        # object : {$c/@name}/{$o/@name}/{$o/@cue:rdf_subject}
                    </xsl:comment>
                    <xsl:variable name="object" select="cmd:rdf_subject($o,$i/*[local-name()=$o/@name])"/>
                    <trix:triple>
                        <xsl:choose>
                            <xsl:when test="starts-with($subject,'id:')">
                                <trix:id xsl:expand-text="yes">{substring-after($subject,'id:')}</trix:id>
                            </xsl:when>
                            <xsl:otherwise>
                                <trix:uri xsl:expand-text="yes">{$subject}</trix:uri>
                            </xsl:otherwise>
                        </xsl:choose>
                        <trix:uri xsl:expand-text="yes">{$c/@ConceptLink}</trix:uri>
                        <trix:uri xsl:expand-text="yes">{$object}</trix:uri>
                    </trix:triple>
                    <xsl:apply-templates select="$c/*">
                        <xsl:with-param name="cursor"  select="$i" tunnel="yes"/>
                        <xsl:with-param name="subject" select="$o" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$c/*">
                        <xsl:with-param name="cursor"  select="$i" tunnel="yes"/>
                        <xsl:with-param name="subject" select="concat('id:',generate-id($i))" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="Element[normalize-space(@ConceptLink)!='']">
        <xsl:param name="cursor" tunnel="yes"/>
        <xsl:param name="subject" tunnel="yes" select="()"/>
        <xsl:variable name="e" select="."/>
        <xsl:variable name="instances" select="$cursor/*[local-name()=$e/@name]"/>
        <xsl:for-each select="$instances">
            <xsl:variable name="i" select="."/>
            <trix:triple>
                <xsl:choose>
                    <xsl:when test="starts-with($subject,'id:')">
                        <trix:id xsl:expand-text="yes">{substring-after($subject,'id:')}</trix:id>
                    </xsl:when>
                    <xsl:otherwise>
                        <trix:uri xsl:expand-text="yes">{$subject}</trix:uri>
                    </xsl:otherwise>
                </xsl:choose>
                <trix:uri xsl:expand-text="yes">{$e/@ConceptLink}</trix:uri>
                <xsl:choose>
                    <xsl:when test="$e/@Multilingual='true'">
                        <trix:plainLiteral>
                            <xsl:if test="normalize-space($i/@xml:lang)!=''">
                                <xsl:attribute name="xml:lang" select="$i/@xml:lang"/>
                            </xsl:if>
                            <xsl:value-of select="$i"/>
                        </trix:plainLiteral>
                    </xsl:when>
                    <xsl:when test="$e/ValueScheme/Vocabulary//item[string(.)=string($i)][normalize-space(@ConceptLink)!='']">
                        <trix:uri xsl:expand-text="yes">{$e/ValueScheme/Vocabulary//item[.=string($i)]/@ConceptLink}</trix:uri>
                    </xsl:when>
                    <xsl:otherwise>
                        <trix:typedLiteral>
                            <xsl:choose>
                                <xsl:when test="normalize-space($e/@ValueScheme)!=''">
                                    <xsl:attribute name="datatype" select="concat('http://www.w3.org/2001/XMLSchema#',normalize-space($e/@ValueScheme))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="datatype" select="'http://www.w3.org/2001/XMLSchema#string'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="$i"/>
                        </trix:typedLiteral>
                    </xsl:otherwise>
                </xsl:choose>
            </trix:triple>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
