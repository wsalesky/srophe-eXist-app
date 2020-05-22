<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
    <sch:ns uri="https://srophe.app" prefix="srophe"/>
    <sch:pattern>
        
        
        <sch:rule context="//tei:place/tei:placeName">
            <sch:let name="langsOfHW" value="//tei:place/tei:placeName[@srophe:tags='#syriaca-headword']/@xml:lang"/>
            <sch:assert test="count(./parent::tei:place/tei:placeName[@xml:lang='en' and @srophe:tags='#syriaca-headword']) = 1">
                There can be one and only one &lt;placeName&gt; element with the combination of @srophe:tags="#syriaca-headword" and @xml:lang="en".
            </sch:assert>
            <sch:assert test="count(distinct-values($langsOfHW)) = count($langsOfHW)">
                There cannot be more than one headword (@srophe:tags="#syriaca-headword") per &lt;placeName&gt; with the same language (@xml:lang).
            </sch:assert>
        </sch:rule>
        

        
        
    </sch:pattern>
</sch:schema>