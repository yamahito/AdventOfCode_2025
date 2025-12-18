<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:a="https://github.com/yamahito/AdventOfCode_2025"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:import href="Day5a.xsl"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:template name="xsl:initial-template">
    <fresh total="{a:sumRanges($ranges)}"/>
  </xsl:template>
  
  <xsl:function name="a:sumRanges" as="xs:integer" visibility="public">
    <xsl:param name="ranges" as="array(xs:integer)*"/>
    <xsl:variable name="simplifiedRanges" select="a:simplifyRanges($ranges)" as="array(xs:integer)*"/>
    <xsl:variable name="countsInRange" as="xs:integer*">
      <xsl:apply-templates select="$simplifiedRanges" mode="a:sumRanges"/>
    </xsl:variable>
    <xsl:sequence select="sum($countsInRange)"/>
  </xsl:function>
  
  <xsl:mode name="a:sumRanges" on-no-match="deep-skip"/>
  
  <xsl:template match=".[. instance of array(*)][.(2) instance of xs:integer][.(1) instance of xs:integer]" mode="a:sumRanges" as="xs:integer?">
    <xsl:sequence select=".(2) - .(1) + 1"/>
  </xsl:template>
  
  <xsl:function name="a:simplifyRanges" as="array(xs:integer)*" visibility="public">
    <xsl:param name="ranges" as="array(xs:integer)*"/>
    <xsl:sequence select="a:simplifyRanges($ranges,())"/>
  </xsl:function>
  
  <xsl:function name="a:simplifyRanges" as="array(xs:integer)*" visibility="public">
    <xsl:param name="ranges" as="array(xs:integer)*"/>
    <xsl:param name="newRanges" as="array(xs:integer)*"/>
    <xsl:variable name="thisRange" as="array(xs:integer)?" select="$ranges[1]"/>
    <xsl:variable name="thisMin" as="xs:integer?" select="$thisRange(1)"/>
    <xsl:variable name="thisMax" as="xs:integer?" select="$thisRange(2)"/>
    <xsl:variable name="nextRanges" as="array(xs:integer)*" select="tail($ranges)"/>
    <xsl:choose>
      <xsl:when test="empty($ranges)">
        <xsl:sequence select="$newRanges"/>
      </xsl:when>
      <xsl:when test="empty($newRanges)">
        <xsl:sequence select="a:simplifyRanges($nextRanges, $thisRange)"/>
      </xsl:when>
      <xsl:when test="$thisMin lt a:findMinRange($newRanges)">
        <xsl:variable name="nextMax" select="max(($thisMax, $newRanges[a:isInRange($thisMax, .)]! .(2)))[1]"/>
        <xsl:variable name="nextNewRanges" as="array(xs:integer)*">
          <xsl:sequence select="[$thisMin, $nextMax]"/>
          <xsl:sequence select="$newRanges[not(.(1) ge $thisMin and .(2) le $nextMax)]"/>
        </xsl:variable>
        <xsl:sequence select="a:simplifyRanges($nextRanges, $nextNewRanges)"/>
      </xsl:when>
      <xsl:when test="$thisMin gt a:findMaxRange($newRanges)">
        <xsl:sequence select="a:simplifyRanges($nextRanges, ($newRanges, $thisRange))"/>
      </xsl:when>
      <!--<xsl:when test="a:isInRange($thisMin - 1 , $newRanges) or a:isInRange($thisMax + 1, $newRanges)">-->
      <xsl:otherwise>
        <xsl:variable name="nextMin" select="min(($thisMin, $newRanges[a:isInRange($thisMin - 1, .)] ! .(1)))[1]"/>
        <xsl:variable name="nextMax" select="max(($thisMax, $newRanges[a:isInRange($thisMax + 1, .)] ! .(2)))[1]"/>
        <xsl:variable name="nextNewRanges" as="array(xs:integer)*">
          <xsl:sequence select="$newRanges[.(2) lt $nextMin]"/>
          <xsl:sequence select="[$nextMin, $nextMax]"/>
          <xsl:sequence select="$newRanges[.(1) gt $nextMax]"/>
        </xsl:variable>
        <xsl:sequence select="a:simplifyRanges($nextRanges, $nextNewRanges)"/>
      </xsl:otherwise>
      <!--</xsl:when>-->
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="a:findMaxRange" as="xs:integer?" visibility="public">
    <xsl:param name="ranges" as="array(xs:integer)*"/>
    <xsl:sequence select="((array:flatten($ranges)) => max())[1]"/>
  </xsl:function>
  
  <xsl:function name="a:findMinRange" as="xs:integer?" visibility="public">
    <xsl:param name="ranges" as="array(xs:integer)*"/>
    <xsl:sequence select="((array:flatten($ranges)) => min())[1]"/>
  </xsl:function>
  
</xsl:stylesheet>