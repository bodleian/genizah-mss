import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/works_master.xml")
    let $collection := collection("../collections?select=*.xml;recurse=yes")
    let $works := $doc//tei:listBibl/tei:bibl[@xml:id]
   
    for $work in $works
        let $id := $work/@xml:id/string()
        let $title := normalize-space($work//tei:title[@type="uniform"][1]/string())
        let $variants := $work//tei:title[@type="variant"]
        let $targetids := (for $i in $work/tei:ref/@target/string() return $i)
        let $mss := $collection/tei:TEI[.//tei:msItem[@xml:id = $targetids]]
        let $mssids := (
            for $j in $mss
                return $j/@xml:id/string()
            )
        let $msitemids := (
            for $k in $mss//tei:msItem[@xml:id = $targetids and not(preceding::tei:msItem[@xml:id = $targetids])]
                return $k/@xml:id
            )
        let $mssclassmarks := (
            for $j in $mss
                return ($j//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text()
            )
        let $msitems := $mss//tei:msItem[@xml:id = $targetids]

        return if (count($mssids) > 0) then
        <doc>
            <field name="type">work</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $title }</field>
            <field name="wk_title_s">{ $title }</field>
            { for $variant in $variants
                let $vname := normalize-space($variant/string())
                order by $vname
                return <field name="wk_variant_sm">{ $vname }</field>
            }
            <field name="alpha_title">{ 
                if (contains($title, ':')) then
                    bod:alphabetize($title)
                else
                    bod:alphabetizeTitle($title)
            }</field>
            { bod:languages($work/tei:textLang, 'wk_lang_sm') }
            {
            for $msid at $pos in $mssids
                let $url := concat("/catalog/", $msid) (:, '#', $msitemids[$pos]) :)
                return <field name="link_manuscripts_smni">{ concat($url, "|", $mssclassmarks[$pos]) }</field>
            }
            {
            for $beg in $msitems/tei:note//tei:quote[@type='beg']
                return <field name="wk_fragment_begins_sm">{ normalize-space(string-join($beg//text(), ' ')) }</field>
            }
        </doc>
        else
            (
            (: NOTE: Because Genizah is using the authority files for Hebrew as well, it will contain many works not in this collection, so no point logging them :)
            (: bod:logging('info', 'Skipping work in works.xml but not in any manuscript', ($id, $title)) :)
            )
}


</add>