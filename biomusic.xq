(: Generate music :)

import module namespace file = "http://expath.org/ns/file";

import schema namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace math = "http://www.zorba-xquery.com/modules/math";

declare namespace biomusic = "http://www.charlesdietrich.com/biomusic";

declare function local:int-to-pitch($n) {
    let $octave := xs:integer($n div 12)
    let $m := $n mod 12
    let $step := if ($m < 2) then "C"
    else if ($m < 4) then "D"
    else if ($m < 5) then "E"
    else if ($m < 7) then "F"
    else if ($m < 9) then "G"
    else if ($m < 11) then "A"
    else "B"
    let $alter := if ($m = 2 or $m = 4 or $m = 7 or $m = 9 or $m = 11) then 1 else 0
    return 
    <pitch>
        <step>{$step}</step>
        <octave>{$octave}</octave>
        <alter>{$alter}</alter>
    </pitch>
};

let $dir := "C:\Users\Charles\Dropbox\biomusic\data\subject01_walk1_states\"
let $data := doc(concat($dir, "data.xml"))
let $instruments := doc(concat($dir, "instruments.xml"))
let $file := concat($dir, "score.xml")

let $ms-per-measure := 20

let $musicxml :=
<score-partwise version="3.0">
  <work>
    <work-title>Biomusic</work-title>
  </work>
  <identification>
    <creator type="composer">Charles Dietrich</creator>
    <rights>Copyright 2012 Charles Dietrich</rights>
    <encoding>
      <encoding-date>2012-09-30</encoding-date>
      <encoder>Charles Dietrich</encoder>
      <software>Biomusic</software>
      <encoding-description>Biomusic</encoding-description>
    </encoding>
    <source>Using data from OpenSIM gait 2354</source>
  </identification>
  <part-list>
    {for $instrument in $instruments//biomusic:instrument
        let $muscle := xs:string($instrument/@muscle)
        let $sound := xs:string($instrument/@sound)
        return
        <score-part id="{$muscle}">
            <part-name>{$muscle}</part-name>
            <instrument-sound>{$sound}</instrument-sound>
        </score-part>
    } 
  </part-list>
  {for $instrument in $instruments//biomusic:instrument
    let $muscle := xs:string($instrument/@muscle)
    let $series := $data//biomusic:time/biomusic:muscle[@id=$muscle]
    let $left_activations := $series/@left_activation
    let $min_left_activation := min($left_activations)
    let $max_left_activation := max($left_activations)
    let $left_fiber_lengths := $series/@left_fiber_length
    let $min_left_fiber_length := min($left_fiber_lengths)
    let $max_left_fiber_length := max($left_fiber_lengths)
    return
    <part id="{$muscle}">
    {for $m at $i in $series
        let $d := floor(400 * ($m/@left_activation - $min_left_activation) div ($max_left_activation - $min_left_activation))
        let $n := floor(88 * ($m/@left_fiber_length - $min_left_fiber_length) div ($max_left_fiber_length - $min_left_fiber_length))
        return
        <measure number="{$i}">
        <attributes>
        <divisions>100</divisions>
        <key>
          <fifths>0</fifths>
        </key>
        <time>
          <beats>4</beats>
          <beat-type>4</beat-type>
        </time>
        <clef>
          <sign>G</sign>
          <line>2</line>
        </clef>
      </attributes>
      <note>
        {local:int-to-pitch($n)}
        <duration>{$d}</duration>
        <type>whole</type>
      </note>
            
        
        </measure>
        
    }
    </part>
  }
</score-partwise>

return
file:write($file, $musicxml, <output:serialization-parameters>
            <output:indent value="yes"/>
            <output:doctype-system value="http://www.musicxml.org/dtds/partwise.dtd" />
            <output:doctype-public value="-//Recordare//DTD MusicXML 3.0 Partwise//EN" />
        </output:serialization-parameters>)