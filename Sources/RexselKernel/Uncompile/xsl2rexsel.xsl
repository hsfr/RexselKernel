<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" id="xsl-rexsel"
    xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:a="http://relaxng.org/ns/annotation/1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:sch="http://www.ascc.net/xml/schematron">
    <xsl:output method="text"/>

    <xsl:variable name="doubleQuote" select="'&#34;'"/>

    <xsl:variable name="space" select="' '"/>

    <xsl:variable name="ampersand" select="'&#38;'"/>

    <xsl:variable name="openCurlyBracket" select="'&#123;'"/>

    <xsl:variable name="closeCurlyBracket" select="'&#125;'"/>

    <xsl:variable name="solidus" select="'&#47;'"/>

    <xsl:variable name="revSolidus" select="'&#92;'"/>

    <xsl:variable name="lessThan" select="'&#60;'"/>

    <xsl:variable name="greaterThan" select="'&#62;'"/>

    <xsl:variable name="identSpaces" select="'    '"/>

    <xsl:variable name="return">
        <xsl:text>
</xsl:text>

    </xsl:variable>
    <xsl:template match="/">
        <xsl:text>stylesheet {</xsl:text>
        <xsl:value-of select="$return"/>

        <xsl:apply-templates select="//xsl:stylesheet/@*" mode="prefix">
            <xsl:with-param name="spaces" select="$identSpaces"/>


        </xsl:apply-templates>
        <xsl:call-template name="outputNamespaces"/>

        <xsl:apply-templates select="//xsl:stylesheet/*">
            <xsl:with-param name="spaces" select="$identSpaces"/>


        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$return"/>


    </xsl:template>
    <xsl:template name="outputNamespaces">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:for-each select="//xsl:stylesheet/namespace::*">
            <xsl:variable name="namespaceName" select="name(.)"/>

            <xsl:variable name="namespaceValue" select="."/>

            <xsl:value-of select="concat($newSpaces, 'xmlns ', $doubleQuote, $namespaceName, $doubleQuote)"/>

            <xsl:value-of select="concat($space, $doubleQuote, $namespaceValue, $doubleQuote, $return)"/>


        </xsl:for-each>

    </xsl:template>
    <xsl:template match="@version" mode="prefix">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'version ', $doubleQuote, ., $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="@id" mode="prefix">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'id ', $doubleQuote, ., $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="@lang" mode="prefix">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'lang ', $doubleQuote, ., $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template name="replaceStrings">
        <xsl:param name="txt"/>

        <xsl:choose>
            <xsl:when test="contains($txt, $revSolidus)">
                <xsl:value-of select="substring-before($txt, $revSolidus)"/>

                <xsl:value-of select="concat($revSolidus, $revSolidus)"/>

                <xsl:call-template name="replaceStrings">
                    <xsl:with-param name="txt" select="substring-after($txt, $revSolidus)"/>


                </xsl:call-template>

            </xsl:when>
            <xsl:when test="contains($txt, $doubleQuote)">
                <xsl:value-of select="substring-before($txt, $doubleQuote)"/>

                <xsl:value-of select="concat($revSolidus, $doubleQuote)"/>

                <xsl:call-template name="replaceStrings">
                    <xsl:with-param name="txt" select="substring-after($txt, $doubleQuote)"/>


                </xsl:call-template>

            </xsl:when>
            <xsl:when test="contains($txt, $lessThan)">
                <xsl:value-of select="substring-before($txt, $lessThan)"/>

                <xsl:value-of select="'&lt;'"/>

                <xsl:call-template name="replaceStrings">
                    <xsl:with-param name="txt" select="substring-after($txt, $lessThan)"/>


                </xsl:call-template>

            </xsl:when>
            <xsl:when test="contains($txt, $greaterThan)">
                <xsl:value-of select="substring-before($txt, $greaterThan)"/>

                <xsl:value-of select="'&gt;'"/>

                <xsl:call-template name="replaceStrings">
                    <xsl:with-param name="txt" select="substring-after($txt, $greaterThan)"/>


                </xsl:call-template>

            </xsl:when>
            <xsl:when test="contains($txt, $ampersand)">
                <xsl:value-of select="substring-before($txt, $ampersand)"/>

                <xsl:value-of select="'&#38;'"/>

                <xsl:call-template name="replaceStrings">
                    <xsl:with-param name="txt" select="substring-after($txt, $ampersand)"/>


                </xsl:call-template>

            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$txt"/>


            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>
    <xsl:template name="pvwOutput">
        <xsl:param name="inName"/>

        <xsl:param name="inValue"/>

        <xsl:param name="inKeyword"/>

        <xsl:param name="spaces"/>

        <xsl:variable name="conditionedValue">
            <xsl:call-template name="replaceStrings">
                <xsl:with-param name="txt" select="$inValue"/>


            </xsl:call-template>

        </xsl:variable>
        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="plainText" select="text()"/>

        <xsl:variable name="conditionedPlainText">
            <xsl:call-template name="replaceStrings">
                <xsl:with-param name="txt" select="$plainText"/>


            </xsl:call-template>

        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$inValue">
                <xsl:value-of
                    select="concat($spaces, $inKeyword, $space, $inName, $space, $doubleQuote, $conditionedValue, $doubleQuote, $return)"/>


            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($spaces, $inKeyword, $space, $inName)"/>

                <xsl:choose>
                    <xsl:when test="not(*[1])">
                        <xsl:if test="count($plainText) > 0">
                            <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

                            <xsl:value-of
                                select="concat($spaces, 'text ', $doubleQuote, $conditionedPlainText, $doubleQuote)"/>

                            <xsl:value-of select="concat($space, $closeCurlyBracket)"/>


                        </xsl:if>

                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

                        <xsl:apply-templates select="./*">
                            <xsl:with-param name="spaces" select="$newSpaces"/>


                        </xsl:apply-templates>
                        <xsl:value-of select="concat($space, $closeCurlyBracket)"/>


                    </xsl:otherwise>

                </xsl:choose>
                <xsl:value-of select="$return"/>


            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>
    <xsl:template match="xsl:apply-imports">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'apply-imports', $return)"/>


    </xsl:template>
    <xsl:template match="xsl:apply-templates">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($spaces, 'apply-templates ')"/>

        <xsl:if test="@select">
            <xsl:value-of select="concat(' using ', $doubleQuote, @select, $doubleQuote)"/>


        </xsl:if>
        <xsl:if test="@mode">
            <xsl:value-of select="concat(' scope ', $doubleQuote, @mode, $doubleQuote)"/>


        </xsl:if>
        <xsl:if test="./*">
            <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

            <xsl:apply-templates select="./*">
                <xsl:with-param name="spaces" select="$newSpaces"/>


            </xsl:apply-templates>
            <xsl:value-of select="concat($spaces, $closeCurlyBracket)"/>


        </xsl:if>
        <xsl:value-of select="$return"/>


    </xsl:template>
    <xsl:template match="xsl:attribute">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="plainText" select="text()"/>

        <xsl:value-of select="concat($spaces, 'attribute ', $doubleQuote, @name, $doubleQuote)"/>

        <xsl:if test="@namespace">
            <xsl:value-of select="concat(' namespace', $doubleQuote, @namespace, $doubleQuote)"/>


        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(*[1])">
                <xsl:if test="count($plainText) > 0">
                    <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

                    <xsl:value-of select="concat($newSpaces, 'text ', $doubleQuote, $plainText, $doubleQuote, $return)"/>

                    <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


                </xsl:if>

            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

                <xsl:apply-templates select="./*">
                    <xsl:with-param name="spaces" select="$newSpaces"/>


                </xsl:apply-templates>
                <xsl:value-of select="concat($spaces, $closeCurlyBracket)"/>


            </xsl:otherwise>

        </xsl:choose>
        <xsl:value-of select="$return"/>


    </xsl:template>
    <xsl:template match="xsl:attribute-set">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="attributeName" select="@name"/>

        <xsl:variable name="useAttributeSets" select="@use-attribute-sets"/>

        <xsl:variable name="keyword" select="'attribute-set'"/>

        <xsl:value-of select="concat($spaces, $keyword, $space, $doubleQuote, $attributeName, $doubleQuote)"/>

        <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, '}')"/>

        <xsl:value-of select="$return"/>


    </xsl:template>
    <xsl:template match="xsl:call-template">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="nameValue" select="@name"/>

        <xsl:choose>
            <xsl:when test="./*">
                <xsl:value-of select="concat($spaces, 'call ', $nameValue, $space, $openCurlyBracket, $return)"/>

                <xsl:apply-templates select="./*">
                    <xsl:with-param name="spaces" select="$newSpaces"/>


                </xsl:apply-templates>
                <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($spaces, 'call ', $nameValue, $return)"/>


            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>
    <xsl:template match="xsl:choose">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($spaces, 'choose {', $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:comment">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="keyword" select="'comment'"/>

        <xsl:value-of select="concat($spaces, 'comment {', $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:copy">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="useAttributeSets" select="@use-attribute-sets"/>

        <xsl:choose>
            <xsl:when test="$useAttributeSets">
                <xsl:value-of
                    select="concat($spaces, 'copy use-attribute-sets', $useAttributeSets, $space, $openCurlyBracket, $return)"/>


            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($spaces, 'copy {', $return)"/>


            </xsl:otherwise>

        </xsl:choose>
        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:copy-of">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="selectValue" select="@select"/>

        <xsl:value-of select="concat($spaces, 'copy ', $doubleQuote, $selectValue, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:decimal-format">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($return, $spaces, 'decimal-format ', $openCurlyBracket, $return)"/>

        <xsl:if test="@name">
            <xsl:value-of select="concat($newSpaces, 'name ', $doubleQuote, @name, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@decimal-separator">
            <xsl:value-of
                select="concat($newSpaces, 'decimal-separator ', $doubleQuote, @decimal-separator, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@grouping-separator">
            <xsl:value-of
                select="concat($newSpaces, 'grouping-separator ', $doubleQuote, @grouping-separator, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@infinity">
            <xsl:value-of select="concat($newSpaces, 'infinity ', $doubleQuote, @infinity, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@minus-sign">
            <xsl:value-of select="concat($newSpaces, 'minus-sign ', $doubleQuote, @minus-sign, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@NaN">
            <xsl:value-of select="concat($newSpaces, 'NaN ', $doubleQuote, @NaN, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@percent">
            <xsl:value-of select="concat($newSpaces, 'percent ', $doubleQuote, @percent, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@per-mille">
            <xsl:value-of select="concat($newSpaces, 'per-mille ', $doubleQuote, @per-mille, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@zero-digit">
            <xsl:value-of select="concat($newSpaces, 'zero-digit ', $doubleQuote, @zero-digit, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@digit">
            <xsl:value-of select="concat($newSpaces, 'digit ', $doubleQuote, @digit, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@pattern-separator">
            <xsl:value-of
                select="concat($newSpaces, 'pattern-separator ', $doubleQuote, @pattern-separator, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:value-of select="concat($return, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:element">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="nameValue" select="@name"/>

        <xsl:value-of
            select="concat($spaces, 'element ', $doubleQuote, $nameValue, $doubleQuote, $space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:for-each">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="selectValue" select="@select"/>

        <xsl:value-of
            select="concat($spaces, 'foreach ', $doubleQuote, $selectValue, $doubleQuote, $space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:if">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="testValue" select="@test"/>

        <xsl:variable name="conditionedValue">
            <xsl:call-template name="replaceStrings">
                <xsl:with-param name="txt" select="$testValue"/>


            </xsl:call-template>

        </xsl:variable>
        <xsl:value-of
            select="concat($spaces, 'if ', $doubleQuote, $conditionedValue, $doubleQuote, $space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:include">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'include ', $doubleQuote, @href, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:import">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'import ', $doubleQuote, @href, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:key">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($return, $spaces, 'key')"/>

        <xsl:value-of select="concat(' name ', $doubleQuote, @name, $doubleQuote)"/>

        <xsl:value-of select="concat(' using ', $doubleQuote, @match, $doubleQuote)"/>

        <xsl:value-of select="concat(' keyNodes ', $doubleQuote, @use, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:message">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($spaces, 'message')"/>

        <xsl:if test="@terminate">
            <xsl:value-of select="concat(' terminate', $doubleQuote, @terminate, $doubleQuote)"/>


        </xsl:if>
        <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:namespace-alias">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($return, $spaces, 'namespace-alias')"/>

        <xsl:value-of select="concat(' map-from ', $doubleQuote, @stylesheet-prefix, $doubleQuote)"/>

        <xsl:value-of select="concat(' to ', $doubleQuote, @result-prefix, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:number">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($return, $spaces, 'number ', $openCurlyBracket, $return)"/>

        <xsl:if test="@count">
            <xsl:value-of select="concat($newSpaces, 'count ', $doubleQuote, @count, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@level">
            <xsl:value-of select="concat($newSpaces, 'level ', @level, $return)"/>


        </xsl:if>
        <xsl:if test="@from">
            <xsl:value-of select="concat($newSpaces, 'from ', $doubleQuote, @from, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@value">
            <xsl:value-of select="concat($newSpaces, 'value ', $doubleQuote, @value, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@format">
            <xsl:value-of select="concat($newSpaces, 'format ', $doubleQuote, @format, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@lang">
            <xsl:value-of select="concat($newSpaces, 'lang ', $doubleQuote, @lang, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@letter-value">
            <xsl:value-of select="concat($newSpaces, 'letter-value ', @letter-value, $return)"/>


        </xsl:if>
        <xsl:if test="@grouping-separator">
            <xsl:value-of
                select="concat($newSpaces, 'grouping-separator ', $doubleQuote, @grouping-separator, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@grouping-size">
            <xsl:value-of
                select="concat($newSpaces, 'grouping-size ', $doubleQuote, @grouping-size, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:value-of select="concat($return, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:otherwise">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($spaces, 'otherwise {', $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:output">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($return, $spaces, 'output ', $openCurlyBracket, $return)"/>

        <xsl:if test="@method">
            <xsl:value-of select="concat($newSpaces, 'method ', @method, $return)"/>


        </xsl:if>
        <xsl:if test="@version">
            <xsl:value-of select="concat($newSpaces, 'version ', $doubleQuote, @version, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@encoding">
            <xsl:value-of select="concat($newSpaces, 'encoding ', $doubleQuote, @encoding, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@omit-xml-declaration">
            <xsl:value-of select="concat($newSpaces, 'omit-xml-declaration ', @omit-xml-declaration, $return)"/>


        </xsl:if>
        <xsl:if test="@standalone">
            <xsl:value-of select="concat($newSpaces, 'standalone ', @standalone, $return)"/>


        </xsl:if>
        <xsl:if test="@doctype-public">
            <xsl:value-of
                select="concat($newSpaces, 'doctype-public ', $doubleQuote, @doctype-public, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@doctype-system">
            <xsl:value-of
                select="concat($newSpaces, 'doctype-system ', $doubleQuote, @doctype-system, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@cdata-section-elements">
            <xsl:value-of
                select="concat($newSpaces, 'cdata-section-elements ', $doubleQuote, @cdata-section-elements, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:if test="@indent">
            <xsl:value-of select="concat($newSpaces, 'indent ', @indent, $return)"/>


        </xsl:if>
        <xsl:if test="@media-type">
            <xsl:value-of select="concat($newSpaces, 'media-type ', $doubleQuote, @media-type, $doubleQuote, $return)"/>


        </xsl:if>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:param">
        <xsl:param name="spaces"/>

        <xsl:call-template name="pvwOutput">
            <xsl:with-param name="inName" select="@name"/>

            <xsl:with-param name="inValue" select="@select"/>

            <xsl:with-param name="inKeyword" select="'parameter'"/>

            <xsl:with-param name="spaces" select="$spaces"/>


        </xsl:call-template>

    </xsl:template>
    <xsl:template match="xsl:preserve-space">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($spaces, 'preserve-space ', $doubleQuote, @elements, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:processing-instruction">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="nameValue" select="@name"/>

        <xsl:value-of
            select="concat($spaces, 'processing-instruction ', $doubleQuote, $nameValue, $doubleQuote, $space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:sort">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'sort ')"/>

        <xsl:if test="@select">
            <xsl:value-of select="concat(' using ', $doubleQuote, @select, $doubleQuote)"/>


        </xsl:if>
        <xsl:if test="@order">
            <xsl:value-of select="concat($space, @order)"/>


        </xsl:if>
        <xsl:if test="@case-order">
            <xsl:value-of select="concat($space, @case-order)"/>


        </xsl:if>
        <xsl:if test="@lang">
            <xsl:value-of select="concat(' lang ', $doubleQuote, @lang, $doubleQuote)"/>


        </xsl:if>
        <xsl:if test="@data-type">
            <xsl:value-of select="concat($space, @data-type)"/>


        </xsl:if>
        <xsl:value-of select="$space"/>


    </xsl:template>
    <xsl:template match="xsl:strip-space">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:value-of select="concat($spaces, 'strip-space ', $doubleQuote, @elements, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:template">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:choose>
            <xsl:when test="@name">
                <xsl:value-of select="concat($return, $spaces, 'function  ', @name, $space, $openCurlyBracket, $return)"/>

                <xsl:apply-templates select="./*">
                    <xsl:with-param name="spaces" select="$newSpaces"/>


                </xsl:apply-templates>
                <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($return, $spaces, 'match ')"/>

                <xsl:if test="@match">
                    <xsl:value-of select="concat(' using ', $doubleQuote, @match, $doubleQuote)"/>


                </xsl:if>
                <xsl:if test="@mode">
                    <xsl:value-of select="concat(' scope ', $doubleQuote, @mode, $doubleQuote)"/>


                </xsl:if>
                <xsl:if test="@priority">
                    <xsl:value-of select="concat(' priority ', $doubleQuote, @priority, $doubleQuote)"/>


                </xsl:if>
                <xsl:value-of select="concat($space, $openCurlyBracket, $return)"/>

                <xsl:apply-templates select="./*">
                    <xsl:with-param name="spaces" select="$newSpaces"/>


                </xsl:apply-templates>
                <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>
    <xsl:template match="xsl:text">
        <xsl:param name="spaces"/>

        <xsl:variable name="conditionedText">
            <xsl:call-template name="replaceStrings">
                <xsl:with-param name="txt" select="."/>


            </xsl:call-template>

        </xsl:variable>
        <xsl:value-of select="concat($spaces, 'text')"/>

        <xsl:if test="@disable-output-escaping">
            <xsl:value-of
                select="concat(' disable-output-escaping', $doubleQuote, @disable-output-escaping, $doubleQuote)"/>


        </xsl:if>
        <xsl:value-of select="concat($space, $doubleQuote, $conditionedText, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:value-of">
        <xsl:param name="spaces"/>

        <xsl:value-of select="concat($spaces, 'value ', $doubleQuote, @select, $doubleQuote, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:variable">
        <xsl:param name="spaces"/>

        <xsl:call-template name="pvwOutput">
            <xsl:with-param name="inName" select="@name"/>

            <xsl:with-param name="inValue" select="@select"/>

            <xsl:with-param name="inKeyword" select="'variable'"/>

            <xsl:with-param name="spaces" select="$spaces"/>


        </xsl:call-template>

    </xsl:template>
    <xsl:template match="xsl:when">
        <xsl:param name="spaces"/>

        <xsl:variable name="newSpaces" select="concat($spaces, $identSpaces)"/>

        <xsl:variable name="conditionedValue">
            <xsl:call-template name="replaceStrings">
                <xsl:with-param name="txt" select="@test"/>


            </xsl:call-template>

        </xsl:variable>
        <xsl:value-of
            select="concat($spaces, 'when ', $doubleQuote, $conditionedValue, $doubleQuote, $space, $openCurlyBracket, $return)"/>

        <xsl:apply-templates select="./*">
            <xsl:with-param name="spaces" select="$newSpaces"/>


        </xsl:apply-templates>
        <xsl:value-of select="concat($spaces, $closeCurlyBracket, $return)"/>


    </xsl:template>
    <xsl:template match="xsl:with-param">
        <xsl:param name="spaces"/>

        <xsl:call-template name="pvwOutput">
            <xsl:with-param name="inName" select="@name"/>

            <xsl:with-param name="inValue" select="@select"/>

            <xsl:with-param name="inKeyword" select="'with'"/>

            <xsl:with-param name="spaces" select="$spaces"/>


        </xsl:call-template>

    </xsl:template>
    <xsl:template match="node() | @*"/>


</xsl:stylesheet>
