<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:a="https://github.com/yamahito/AdventOfCode_2025"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="yes"/>
  <xsl:param name="input_url" select="'input.txt'"/>
  <xsl:param name="rotations" as="xs:integer*">
    <xsl:sequence select="a:import_input($input_url)"/>
  </xsl:param>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="rotations" as="element(rotation)*">
      <xsl:iterate select="$rotations">
        <xsl:param name="position" select="50" as="xs:integer"/>
        <xsl:variable name="end" select="a:make-rotation-positive($position + .) mod 100"/>
        <rotation start="{$position}" rotation="{a:integer-to-rotation(.)}" end="{$end}"/>
        <xsl:next-iteration>
          <xsl:with-param name="position" select="$end"/>
        </xsl:next-iteration>
      </xsl:iterate>
    </xsl:variable>
    <dial zeros="{count($rotations[@end = 0])}">
      <xsl:sequence select="$rotations"/>
    </dial>
  </xsl:template>
  
  <xsl:function name="a:import_input" as="xs:integer*" visibility="public">
    <xsl:param name="URL" as="xs:string"/>
    <xsl:if test="not(unparsed-text-available($URL))">
      <xsl:sequence select="error(xs:QName('bad_input'), 'Text not available at supplied URL: '||$URL)"/>
    </xsl:if>
    <xsl:variable name="raw_input" select="unparsed-text-lines($URL)" as="xs:string*"/>
    <xsl:sequence select="$raw_input ! a:rotation-to-integer(.)"/>
  </xsl:function>
  
  <xsl:function name="a:rotation-to-integer" as="xs:integer" visibility="public">
    <xsl:param name="rotation" as="xs:string"/>
    <xsl:variable name="regex" select="'(L|R)(\d+)'"/>
    <xsl:analyze-string select="$rotation" regex="(L|R)(\d+)">
      <xsl:matching-substring>
        <xsl:variable name="sign" select="if (regex-group(1) eq 'L') then -1 else 1" as="xs:integer"/>
        <xsl:variable name="distance" select="regex-group(2) => xs:integer()" as="xs:integer"/>
        <xsl:sequence select="$sign * $distance"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:sequence select="error(xs:QName('not_rotation'), $rotation || ' is not a valid rotation (e.g. L31 or R4)')"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:function>
  
  <xsl:function name="a:integer-to-rotation" as="xs:string" visibility="public">
    <xsl:param name="integer" as="xs:integer"/>
    <xsl:sequence select="(if ($integer lt 0) then 'L' else 'R' )||abs($integer)"/>
  </xsl:function>
  
  <xsl:function name="a:make-rotation-positive" as="xs:integer" visibility="public">
    <xsl:param name="rotation" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$rotation ge 0">
        <xsl:sequence select="$rotation"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="100 + ($rotation mod 100)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>