import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../../hebrew-mss/authority/places_master.xml")
    let $collection := collection("../collections?select=*.xml;recurse=yes")
    let $places := $doc//tei:place

    for $place in $places
    
        let $id := $place/@xml:id/string()
        let $name := normalize-space($place//tei:placeName[@type = 'index' or (@type = 'variant' and not(preceding-sibling::tei:placeName))][1]/string())
        let $mss := $collection//tei:TEI[.//(tei:placeName)[@key = $id]]/concat('/catalog/', string(@xml:id), '|', (./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text())

        let $variants := $place/tei:placeName[@type="variant"]

        return if (count($mss) gt 0) then
            <doc>
                <field name="type">place</field>
                <field name="pk">{ $id }</field>
                <field name="id">{ $id }</field>
                <field name="title">{ $name }</field>
                <field name="alpha_title">{  bod:alphabetize($name) }</field>
                <field name="pl_name_s">{ $name }</field>
                {
                for $variant in $variants
                    let $vname := normalize-space($variant/string())
                    order by $vname
                    return <field name="pl_variant_sm">{ $vname }</field>
                }
                {
                for $ms in $mss
                    order by $ms
                    return <field name="link_manuscripts_smni">{ $ms }</field>
                }
            </doc>
        else
            ()
}

</add>