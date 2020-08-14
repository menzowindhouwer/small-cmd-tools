<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xhtml"/>

    <xsl:param name="id" select="()"/>

    <xsl:param name="max-items" select="100"/>

    <xsl:param name="cr-uri" select="'https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry'"/>
    <xsl:variable name="cmd-version" select="'1.x'"/>
    <xsl:variable name="cr-extension-xml" select="'/xml'"/>

    <!-- CR REST API -->
    <!-- clarin.eu:cr1:c_* -->
    <xsl:variable name="cr-components" select="concat($cr-uri, '/', $cmd-version, '/components/')"/>
    <!-- clarin.eu:cr1:p_* -->
    <xsl:variable name="cr-profiles" select="concat($cr-uri, '/', $cmd-version, '/profiles/')"/>

    <xsl:template name="main">
        <xsl:variable name="spec">
            <xsl:choose>
                <xsl:when test="empty($id)">
                    <xsl:message terminate="yes">ERR: please provide a valid profile or component id!</xsl:message>
                </xsl:when>
                <xsl:when test="starts-with($id, 'clarin.eu:cr1:c_')">
                    <xsl:sequence select="doc(concat($cr-components, $id, $cr-extension-xml))"/>
                </xsl:when>
                <xsl:when test="starts-with($id, 'clarin.eu:cr1:p_')">
                    <xsl:sequence select="doc(concat($cr-profiles, $id, $cr-extension-xml))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">ERR: id[<xsl:value-of select="$id"/>] is invalid!</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="$spec"/>
    </xsl:template>

    <xsl:template match="text()"/>

    <xsl:template match="/*[self::CMD_ComponentSpec | self::ComponentSpec]">
        <html>
            <head>
                <title>
                    <xsl:choose>
                        <xsl:when test="@isProfile = 'true'">
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
                        <xsl:when test="@isProfile = 'true'">
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
                <ul style="list-style-type:none;">
                    <xsl:apply-templates/>
                </ul>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="*[self::CMD_Component | self::Component]">
        <li>
            <details>
                <xsl:if test="parent::CMD_ComponentSpec | parent::ComponentSpec">
                    <xsl:attribute name="open" select="'open'"/>
                </xsl:if>
                <summary>
                    <xsl:choose>
                        <xsl:when test="normalize-space(@ConceptLink) != ''">
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
                </summary>
                <p>
                    <xsl:for-each select="Documentation | @Documentation">
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:for-each>
                    <ul style="list-style-type:none;">
                        <xsl:apply-templates/>
                    </ul>
                </p>
            </details>
        </li>
    </xsl:template>

    <xsl:template match="*[self::CMD_Element | self::Element]">
        <li>
            <details>
                <summary>
                    <xsl:choose>
                        <xsl:when test="normalize-space(@ConceptLink) != ''">
                            <a href="{@ConceptLink}">
                                <xsl:value-of select="@name"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="@Multilingual = 'true'">
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
                </summary>
                <p>
                    <xsl:for-each select="Documentation | @Documentation">
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:for-each>
                    <ul style="list-style-type:none;">
                        <xsl:apply-templates/>
                    </ul>
                </p>
            </details>
        </li>
    </xsl:template>

    <xsl:template match="pattern">
        <li>
            <details>
                <summary>
                    <xsl:value-of select="."/>
                </summary>
            </details>
        </li>
    </xsl:template>

    <xsl:template match="item[count(preceding-sibling::item) &lt; $max-items]">
        <li>
            <details>
                <summary>
                    <xsl:text>"</xsl:text>
                    <xsl:choose>
                        <xsl:when test="normalize-space(@ConceptLink) != ''">
                            <a href="{@ConceptLink}">
                                <xsl:value-of select="."/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>"</xsl:text>
                </summary>
            </details>
        </li>
    </xsl:template>

    <xsl:template match="item[count(preceding-sibling::item) = $max-items]">
        <li>
            <details>
                <summary>
                    <xsl:text>... (more then </xsl:text>
                    <xsl:value-of select="$max-items"/>
                    <xsl:text> items in the enumeration)</xsl:text>
                </summary>
            </details>
        </li>
    </xsl:template>

    <xsl:template match="Attribute">
        <li>
            <details>
                <summary>
                    <xsl:text>@</xsl:text>
                    <xsl:choose>
                        <xsl:when test="normalize-space(@ConceptLink) != ''">
                            <a href="{@ConceptLink}">
                                <xsl:value-of select="Name | @name"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="Name | @name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="Required = 'true' or @required = 'true'">
                            <xsl:text> [1:1]</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> [0:1]</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="Type | @ValueScheme"/>
                </summary>
            </details>
        </li>
        <p>
            <ul style="list-style-type:none;">
                <xsl:apply-templates/>
            </ul>
        </p>
    </xsl:template>

</xsl:stylesheet>
