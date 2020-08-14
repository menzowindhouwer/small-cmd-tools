<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xhtml"/>
    
    <xsl:param name="max-items" select="100"/>
    
    <xsl:template match="text()"/>

    <xsl:template match="/*[self::CMD_ComponentSpec|self::ComponentSpec]">
        <html>
            <head>
                <title>
                    <xsl:choose>
                        <xsl:when test="@isProfile='true'">
                            <xsl:text>CMD Profile: </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>CMD Component: </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="Header/Name"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="Header/ID"/>
                    <xsl:text>)</xsl:text>
                </title>
            </head>
            <body>
                <h1>
                    <xsl:choose>
                        <xsl:when test="@isProfile='true'">
                            <xsl:text>CMD Profile: </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>CMD Component: </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="Header/Name"/>
                    <xsl:text> (</xsl:text>
                    <a href="http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/{Header/ID}/xml">
                        <xsl:value-of select="Header/ID"/>
                    </a>
                    <xsl:text>)</xsl:text>
                </h1>
                <p>
                    <xsl:value-of select="Header/Description"/>
                </p>
                <dl>
                    <xsl:apply-templates/>
                </dl>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="*[self::CMD_Component|self::Component]">
        <dt>
            <xsl:choose>
                <xsl:when test="normalize-space(@ConceptLink)!=''">
                    <a href="{@ConceptLink}">
                        <xsl:value-of select="@name"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text> [</xsl:text>
            <xsl:value-of select="@CardinalityMin"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="@CardinalityMax"/>
            <xsl:text>]</xsl:text>
        </dt>
        <dd>
            <xsl:for-each select="Documentation|@Documentation">
                <p>
                    <xsl:value-of select="."/>
                </p>
            </xsl:for-each>
            <dl>
                <xsl:apply-templates/>
            </dl>
        </dd>
    </xsl:template>
    
    <xsl:template match="*[self::CMD_Element|self::Element]">
        <dt>
            <xsl:choose>
                <xsl:when test="normalize-space(@ConceptLink)!=''">
                    <a href="{@ConceptLink}">
                        <xsl:value-of select="@name"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="@Multilingual='true'">
                    <xsl:text> [</xsl:text>
                    <xsl:value-of select="@CardinalityMin"/>
                    <xsl:text>:multilingual] </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> [</xsl:text>
                    <xsl:value-of select="@CardinalityMin"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="@CardinalityMax"/>
                    <xsl:text>] </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="@ValueScheme"/>
        </dt>
        <dd>
            <xsl:for-each select="Documentation|@Documentation">
                <p>
                    <xsl:value-of select="."/>
                </p>
            </xsl:for-each>
            <dl>
                <xsl:apply-templates/>
            </dl>
        </dd>
    </xsl:template>
    
    <xsl:template match="pattern">
        <dt>
            <xsl:value-of select="."/>
        </dt>
    </xsl:template>
    
    <xsl:template match="item[count(preceding-sibling::item)&lt;$max-items]">
        <dt>
            <xsl:text>"</xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space(@ConceptLink)!=''">
                    <a href="{@ConceptLink}">
                        <xsl:value-of select="."/>
                    </a>
                </xsl:when>                
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>"</xsl:text>
        </dt>
    </xsl:template>
    
    <xsl:template match="item[count(preceding-sibling::item)=$max-items]">
        <dt>
            <xsl:text>... (more then </xsl:text>
            <xsl:value-of select="$max-items"/>
            <xsl:text> items in the enumeration)</xsl:text>
        </dt>
    </xsl:template>
    
    <xsl:template match="Attribute">
        <dt>
            <xsl:text>@</xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space(@ConceptLink)!=''">
                    <a href="{@ConceptLink}">
                        <xsl:value-of select="Name|@name"/>
                    </a>
                </xsl:when>                
                <xsl:otherwise>
                    <xsl:value-of select="Name|@name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="Required='true' or @required='true'">
                    <xsl:text> [1:1]</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> [0:1]</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
            <xsl:value-of select="Type|@ValueScheme"/>
        </dt>
        <dd>
            <dl>
                <xsl:apply-templates/>
            </dl>
        </dd>
    </xsl:template>

</xsl:stylesheet>
