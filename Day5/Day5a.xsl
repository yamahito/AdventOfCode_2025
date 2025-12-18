<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:a="https://github.com/yamahito/AdventOfCode_2025"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:param name="inputURL" select="'input.txt'"/>
  <xsl:param name="input" as="xs:string*" select="unparsed-text-lines($inputURL)"/>
  <xsl:variable name="ranges" select="a:getRanges($input)"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="ingredients" as="element()*">
      <xsl:apply-templates select="$input"/>
    </xsl:variable>
    <ingredients fresh="{count($ingredients[self::fresh])}">
      <xsl:sequence select="$ingredients"/>
    </ingredients>
  </xsl:template>
  
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:template match=".[. castable as xs:integer][xs:integer(.) => a:isInRange($ranges)]">
    <fresh id="{.}"/>
  </xsl:template>
  
  <xsl:template match=".[. castable as xs:integer][not(xs:integer(.) => a:isInRange($ranges))]">
    <spoiled id="{.}"/>
  </xsl:template>
  
  <xsl:function name="a:isInRange" as="xs:boolean?" visibility="public">
    <xsl:param name="number" as="xs:integer"/>
    <xsl:param name="ranges" as="array(xs:integer)*"/>
    <xsl:sequence select="some $range in $ranges satisfies ($number ge $range(1) and $number le $range(2))"/>
  </xsl:function>
  
  <xsl:function name="a:getRanges" visibility="public" as="array(xs:integer)*">
    <xsl:param name="in" as="xs:string*"/>
    <xsl:apply-templates mode="a:getRanges" select="$in"/>
  </xsl:function>
  
  <xsl:mode name="a:getRanges" on-no-match="shallow-skip"/>
  
  <xsl:template match=".[. instance of xs:string][matches(., '^\d+-\d+$')]" as="array(xs:integer)" mode="a:getRanges">
    <xsl:variable name="start" select="replace(., '(\d+)-(\d+)', '$1') => xs:integer()"/>
    <xsl:variable name="end" select="replace(., '(\d+)-(\d+)', '$2') => xs:integer()"/>
    <xsl:sequence select="[$start, $end]"/>
  </xsl:template>
  
</xsl:stylesheet>