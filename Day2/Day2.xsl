<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:a="https://github.com/yamahito/AdventOfCode_2025"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:param name="input" as="xs:string"
    select="'52-75,71615244-71792700,89451761-89562523,594077-672686,31503-39016,733-976,1-20,400309-479672,458-635,836793365-836858811,3395595155-3395672258,290-391,5168-7482,4545413413-4545538932,65590172-65702074,25-42,221412-256187,873499-1078482,118-154,68597355-68768392,102907-146478,4251706-4487069,64895-87330,8664371543-8664413195,4091-5065,537300-565631,77-115,83892238-83982935,6631446-6694349,1112-1649,7725-9776,1453397-1493799,10240-12328,15873-20410,1925-2744,4362535948-4362554186,3078725-3256936,710512-853550,279817-346202,45515-60928,3240-3952'"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="ranges" as="element(range)*">
      <xsl:apply-templates select="tokenize($input, ',')" mode="range"/>
    </xsl:variable>
    <ranges sum="{sum($ranges/@sum) => xs:integer()}">
      <xsl:sequence select="$ranges"/>
    </ranges>
  </xsl:template>
  
  <xsl:template match=".[. instance of xs:string]" mode="range" as="element(range)">
    <xsl:variable name="start" select="replace(., '(\d+)-\d+', '$1') => xs:integer()" as="xs:integer"/>
    <xsl:variable name="end"   select="replace(., '\d+-(\d+)', '$1') => xs:integer()" as="xs:integer"/>
    <xsl:variable name="invalids" as="element(invalid)*">
      <xsl:apply-templates select="$start to $end" mode="invalid"/>
    </xsl:variable>
    <range start="{$start}" end="{$end}" sum="{sum($invalids/@code) => xs:integer()}">
      <xsl:sequence select="$invalids"/>
    </range>
  </xsl:template>
  
  <xsl:template match=".[. instance of xs:integer]" mode="invalid"/>
  <xsl:template match=".[. instance of xs:integer][xs:string(.) => matches('^(\d+)(\1)$')]" priority="2" as="element(invalid)" mode="invalid">
    <invalid code="{.}"/>
  </xsl:template>
  
</xsl:stylesheet>