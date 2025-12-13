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
  
  <xsl:output indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="startGrid" select="a:makeGrid($input) => a:findAvailable()"/>
    <xsl:variable name="grids" select="a:remove_all_rolls($startGrid)"/>
    <job removed="{sum($grids/@available-rolls) => xs:integer()}">
      <xsl:sequence select="$grids"/>
    </job>
  </xsl:template>
  
  <xsl:function name="a:remove_all_rolls" as="element(grid)*">
    <xsl:param name="inGrid" as="element(grid)"/>
    <xsl:sequence select="$inGrid"/>
    <xsl:if test="($inGrid/@available-rolls => xs:integer()) ne 0">
      <xsl:sequence select="a:remove_all_rolls($inGrid => a:clearGrid() => a:findAvailable())"/>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="a:clearGrid" as="element(grid)*">
    <xsl:param name="inGrid" as="element(grid)"/>
    <xsl:apply-templates select="$inGrid" mode="a:clearGrid"/>
  </xsl:function>
  
  <xsl:mode name="a:clearGrid" on-no-match="shallow-copy"/>
  
  <xsl:template match="roll[@available eq 'yes']" mode="a:clearGrid">
    <empty/>
  </xsl:template>
  
  <xsl:function name="a:findAvailable" as="element(grid)">
    <xsl:param name="inGrid" as="element(grid)"/>
    <xsl:apply-templates select="$inGrid" mode="findAvailable"/>
  </xsl:function>
  
  <xsl:mode name="findAvailable" on-no-match="shallow-copy" use-accumulators="#all"/>
  
  <xsl:accumulator name="adjacent_rolls" initial-value="0" as="xs:integer">
    <xsl:accumulator-rule match="roll">
      <xsl:variable name="seq_in_row" select="index-of(../*/generate-id(.), current()/generate-id(.))" as="xs:integer"/>
      <xsl:variable name="total_in_row" select="count(../*)" as="xs:integer"/>
      <xsl:variable name="start_position" select="if ($seq_in_row eq 1) then 1 else $seq_in_row - 1" as="xs:integer"/>
      <xsl:variable name="end_position" select="if ($seq_in_row eq $total_in_row) then $total_in_row else $seq_in_row + 1" as="xs:integer"/>
      <xsl:sequence select="count(((
          preceding-sibling::*[1],
          following-sibling::*[1],
          ../preceding-sibling::row[1]/*[position() = ($start_position to $end_position)],
          ../following-sibling::row[1]/*[position() = ($start_position to $end_position)]
        )[self::roll]))"/>
    </xsl:accumulator-rule>
  </xsl:accumulator>
  
  <xsl:template match="grid" mode="findAvailable">
    <xsl:copy>
      <xsl:attribute name="available-rolls" select="sum(.//roll[accumulator-after('adjacent_rolls') lt 4]/count(.)) => xs:integer()"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="roll" mode="findAvailable">
    <xsl:variable name="adjacent" select="accumulator-after('adjacent_rolls')"/>
    <xsl:copy>
      <xsl:if test="$adjacent lt 4">
        <xsl:attribute name="available" select="'yes'"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="a:makeGrid" as="element(grid)">
    <xsl:param name="rows" as="xs:string*"/>
    <grid>
      <xsl:apply-templates select="$rows" mode="a:makeGrid"/>
    </grid>
  </xsl:function>
  
  <xsl:mode name="a:makeGrid" on-no-match="shallow-skip"/>
  
  <xsl:template mode="a:makeGrid" match=".[. instance of xs:string]">
    <row>
      <xsl:analyze-string select="." regex="\.">
        <xsl:matching-substring>
          <empty/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:analyze-string select="." regex="@">
            <xsl:matching-substring>
              <roll/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </row>
  </xsl:template>
  
</xsl:stylesheet>