<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:android="http://schemas.android.com/apk/res/android">

  <xsl:param name="hasofferskey" />
  <xsl:param name="hasoffersadvid" />

  <xsl:output indent="yes" />
  <xsl:template match="comment()" />

  <xsl:template match="meta-data[@android:name='HASOFFERS_KEY']">
    <meta-data android:name="HASOFFERS_KEY" android:value="{$hasofferskey}"/>
  </xsl:template>

  <xsl:template match="meta-data[@android:name='HASOFFERS_ADV_ID']">
    <meta-data android:name="HASOFFERS_ADV_ID" android:value="\ {$hasoffersadvid}"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
