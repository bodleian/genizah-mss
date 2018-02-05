import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";


<add>
{
    let $doc := doc("../../hebrew-mss/authority/persons_master.xml")
    let $collection := collection("../collections?select=*.xml;recurse=yes")
    let $people := $doc//tei:person

    for $person in $people
    
        let $id := $person/@xml:id/string()
        let $name := normalize-space($person//tei:persName[@type = 'display' or (@type = 'variant' and not(preceding-sibling::tei:persName))][1]/string())
        let $isauthor := boolean($collection//tei:author[@key = $id or .//persName/@key = $id])
        (: This doesn't work in Genizah because most are also authors but not catalogued as such: let $issubject := boolean($collection//tei:msItem/tei:title//tei:persName[not(@role) and @key = $id]) :)
        
        let $mss1 := $collection//tei:TEI[.//(tei:persName)[@key = $id]]/concat('/catalog/', string(@xml:id), '|', (./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text())
        let $mss2 := $collection//tei:TEI[.//(tei:author)[@key = $id]]/concat('/catalog/', string(@xml:id), '|', (./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text())
        let $mss := distinct-values(($mss1, $mss2))
        
        let $variants := $person/tei:persName[@type="variant"]

        return 
        <doc>
            <field name="type">person</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $name }</field>
            <field name="alpha_title">{  bod:alphabetize($name) }</field>
            <field name="pp_name_s">{ $name }</field>
            {
            for $variant in $variants
                let $vname := normalize-space($variant/string())
                order by $vname
                return <field name="pp_variant_sm">{ $vname }</field>
            }
            {
            let $roles := distinct-values(
                                (
                                $collection//tei:persName[@key = $id]/ancestor::editor[1]/@role/tokenize(., ' '),
                                $collection//tei:persName[@key = $id]/@type/tokenize(., ' '), 
                                if ($isauthor) then 'author' else ()
                                )
                            )[not(. = ('alt','standard','unknown','desc','ment','wit','par','heb','beg','head','end','acr','ara','col'))]      (: TODO: Find out what these mean and map them to something? :)
            for $role in $roles
                order by $role
                return <field name="pp_roles_sm">{ bod:personRoleLookup($role) }</field>

            }
            {
            for $ms in $mss
                order by $ms
                return <field name="link_manuscripts_smni">{ $ms }</field>
            }
        </doc>
}

</add>

