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
  <xsl:param name="joltageDigits" as="xs:integer" select="12"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="banks" as="element(bank)*">
      <xsl:apply-templates select="$input"/>
    </xsl:variable>
    <power joltage="{sum($banks/@joltage/xs:integer(.))}">
      <xsl:sequence select="$banks"/>
    </power>
  </xsl:template>
  
  <xsl:template match=".[matches(., '(\d+){2,}')]">
    <xsl:variable name="nums" select="a:string-to-nums(.)" as="xs:integer+"/>
    <xsl:variable name="digits" as="xs:integer*">
      <xsl:iterate select="reverse(1 to $joltageDigits)">
        <xsl:param name="nums" select="$nums" as="xs:integer*"/>
        <xsl:variable name="numSize" select="count($nums)" as="xs:integer"/>
        <xsl:variable name="availableNums" select="subsequence($nums, 1, 1 + $numSize - .)"/>
        <xsl:variable name="thisDigit" select="max($availableNums)[1]" as="xs:integer"/>
        <xsl:variable name="thisPos" select="index-of($nums, $thisDigit)[1]" as="xs:integer"/>
        <xsl:sequence select="$thisDigit"/>
        <xsl:next-iteration>
          <xsl:with-param name="nums" select="subsequence($nums, $thisPos + 1)"/>
        </xsl:next-iteration>
      </xsl:iterate>
    </xsl:variable>
    <bank joltage="{string-join($digits)}"/>
  </xsl:template>
  
  <xsl:function name="a:string-to-nums" as="xs:integer*" visibility="public">
    <xsl:param name="string"/>
    <xsl:variable name="head" select="substring($string, 1, 1)" as="xs:string"/>
    <xsl:variable name="tail" select="(substring($string, 2))[. ne '']" as="xs:string?"/>
    <xsl:sequence select="($head => xs:integer(), if ($tail) then a:string-to-nums($tail) else ())"/>
  </xsl:function>
  
</xsl:stylesheet>