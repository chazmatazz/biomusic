(: Generate instruments :)

declare default element namespace "http://www.charlesdietrich.com/biomusic";

import module namespace file = "http://expath.org/ns/file";

import schema namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace r = "http://www.zorba-xquery.com/modules/random";

declare namespace biomusic = "http://www.charlesdietrich.com/biomusic";

let $datadir := "C:\Users\Charles\Dropbox\biomusic\data\"
let $dir := concat($datadir, "subject01_walk1_states\")
let $data := doc(concat($dir, "data.xml"))
let $sounds := doc(concat($datadir, "common\sounds.xml"))
let $file := concat($dir, "instruments.xml")

let $instruments :=
<instruments>
{
let $random-numbers := r:random-between(1, count($sounds//*:sound), count($data//biomusic:time[1]/*))
for $type-elt at $i in $data//biomusic:time[1]/*
    let $muscle := name($type-elt)
    let $sound := $sounds//*:sound[$random-numbers[$i]]/@id
    return
    <instrument sound="{$sound}" muscle="{$muscle}" />
}
</instruments>

return
file:write($file, $instruments, <output:serialization-parameters>
            <output:indent value="yes"/>
        </output:serialization-parameters>)