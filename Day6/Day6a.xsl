<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:a="https://github.com/yamahito/AdventOfCode_2025"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:param name="inputURL" select="'input.txt'"/>
  <xsl:param name="input" as="xs:string*" select="unparsed-text-lines($inputURL)"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="rows" as="array(xs:integer)*" select="$input[position() ne last()] ! array { tokenize(.) ! xs:integer(.) }"/>
    <xsl:variable name="operations" as="element(*)*">
      <xsl:apply-templates select="$input[position() eq last()] => tokenize()">
        <xsl:with-param name="rows" select="$rows"/>
      </xsl:apply-templates>
    </xsl:variable>
    <homework grand_total="{sum(($operations/@product, $operations/@sum, 0)) => xs:integer()}">
      <xsl:sequence select="$operations"/>
    </homework>
  </xsl:template>
  
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:template match=".[. eq '*']">
    <xsl:param name="rows" as="array(xs:integer)*"/>
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="terms" as="xs:integer*" select="$rows ! .($pos)"/>
    <multiplication product="{a:product($terms)}">
      <xsl:apply-templates select="$terms"/>
    </multiplication>
  </xsl:template>
  
  <xsl:template match=".[. eq '+']">
    <xsl:param name="rows" as="array(xs:integer)*"/>
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="terms" as="xs:integer*" select="$rows ! .($pos)"/>
    <addition sum="{sum($terms)}">
      <xsl:apply-templates select="$terms"/>
    </addition>
  </xsl:template>
  
  <xsl:template match=".[. instance of xs:integer]">
    <term><xsl:value-of select="."/></term>
  </xsl:template>
  
  <xsl:function name="a:product">
    <xsl:param name="terms" as="xs:integer*"/>
    <xsl:sequence select="a:product($terms, 1)"/>
  </xsl:function>
  <xsl:function name="a:product">
    <xsl:param name="terms" as="xs:integer*"/>
    <xsl:param name="product" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="empty($terms)">
        <xsl:sequence select="$product"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="a:product(tail($terms), $product * head($terms))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>