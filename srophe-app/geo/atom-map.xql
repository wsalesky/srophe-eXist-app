xquery version "3.0";

declare namespace xslt="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $id {request:get-parameter('id', '')};
declare variable $start {request:get-parameter('start', 1) cast as xs:integer};

declare option exist:serialize "method=xml media-type=application/rss+xml omit-xml-declaration=no indent=yes";

(:Not complete, need to work on responsible persons function and add in contributors:)
declare function local:build-entry($rec){
    let $place-id := substring-after($rec/descendant::tei:place/@xml:id,'place-')
    let $place-title := $rec/descendant::tei:titleStmt/tei:title[1]/text()
    let $date := $rec/descendant::tei:publicationStmt[1]/tei:date[1]/text()
    let $res-pers :=  
                let $author-name := distinct-values($rec/descendant::tei:titleStmt/tei:editor) 
                for $author in $author-name
                return <author xmlns="http://www.w3.org/2005/Atom"><name>{$author}</name></author>
   let $summary := 
        if($rec/descendant::tei:place/tei:desc[contains(@xml:id,'abstract')] and string-length($rec/descendant::tei:place/tei:desc[contains(@xml:id,'abstract')]) gt 1) then
            <summary xmlns="http://www.w3.org/2005/Atom">
                {
                for $sum in $rec/descendant::tei:place/tei:desc[contains(@xml:id,'abstract')]/descendant-or-self::text()
                return
                    $sum
                  }
            </summary>
        else ''
    return    
    <entry xmlns:georss="http://www.georss.org/georss" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
        <title>{$place-title}</title>
        <link rel="alternate" type="text/html" href="http://syriaca.org/place/{$place-id}" />
        <link rel="self" type="application/atom+xml" href="http://syriaca.org/places/atom.xql?id={$place-id}"/>
        <id>tag:syriaca.org,2013:{$place-id}</id>
        {if(exists($rec//tei:geo)) then
            (<georss:point>{string($rec//tei:geo)}</georss:point>,
            <geo:lat>{substring-before($rec//tei:geo,' ')}</geo:lat>,
            <geo:long>{substring-after($rec//tei:geo,' ')}</geo:long>)
          else ''  
        }
        <updated>{local:format-dates($date)}</updated>
        {($summary, $res-pers)}
    </entry>   

};

declare function local:get-place-entry(){
    let $placeid := concat('place-',$id)
    for $item in collection("/db/apps/srophe/data/places/tei")/id($placeid)
    let $rec := $item/ancestor::tei:TEI
    let $date := $rec/tei:teiHeader/tei:fileDesc/tei:publicationStmt[1]/tei:date[1]/text()
    return 
    (
    <updated xmlns="http://www.w3.org/2005/Atom">{local:format-dates($date)}</updated>,
    local:build-entry($rec)
    )
};
               
declare function local:get-feed(){
   for $recs in collection("/db/apps/srophe/data/places/tei")//tei:title[@level='a']
   let $rec := $recs/ancestor::tei:TEI
   let $date := $rec[1]/tei:teiHeader[1]/tei:fileDesc/tei:publicationStmt[1]/tei:date[1]/text()
   where $rec//tei:geo
   order by $rec/tei:teiHeader[1]/tei:fileDesc/tei:publicationStmt[1]/tei:date[1]/text()
   return 
    (
       <updated xmlns="http://www.w3.org/2005/Atom">{local:format-dates($date)}</updated>,
       local:build-entry($rec)
    )
};

(:2013-11-07  to 2013-11-07T15:00:00Z:)
declare function local:format-dates($date){
    if($date) then 
        if(string-length($date) = 10) then concat($date,'T12:00:00Z')
        else if(string-length($date) = 4) then concat($date,'01-01T12:00:00Z')
        else if(string-length($date) gt 10) then concat(substring($date,1,10),'T12:00:00Z')
        else ''
    else ''
};

<feed xmlns="http://www.w3.org/2005/Atom" xmlns:georss="http://www.georss.org/georss" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"> 
    <title>The Syriac Gazetteer: Latest Updates</title>
    <link rel="self" type="application/atom+xml" href="http://syriaca.org/geo/atom.xql"/>
    <id>tag:syriaca.org,2013:gazetteer-latest</id>
       {
       if(exists($id) and $id !='') then local:get-place-entry()
       else local:get-feed()
       }
</feed>
