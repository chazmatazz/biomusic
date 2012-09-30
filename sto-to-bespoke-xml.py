"""
	convert sto files to bespoke xml
	<sto name="foo">
		<time time="0" data-elt="bar" />
		...
	</sto>
"""

import lxml.etree as et

def sto_to_bespoke_xml(stofile, xmlfile):
	root = et.Element("biomusic")
	root.attrib['xmlns'] = "http://www.charlesdietrich.com/biomusic"
	
	with open(stofile) as f:
		lines = [line for line in f]
		root.attrib['name'] = lines[0]
		
		endheader = -1
		props = {}
		muscles = {}
		activations = {}
		fiber_lengths = {}
		for i in range(1, len(lines)):
			line = lines[i]
			if line.startswith("endheader"):
				endheader = i
			elif endheader == -1:
				kv = str.split(line, "=")
				props[kv[0]] = kv[1]
			elif i == endheader + 1:
				headers = str.split(line)
				for i in range(len(headers)):
					header = headers[i]
					parts = header.split(".")
					if len(parts) > 1:
						muscle = parts[0]
						typ = parts[1]
						left = muscle.endswith("_l")
						m = muscle[:len(muscle)-2]
						if m not in muscles:
							muscles[m] = {}
						muscles[m]["%s_%s" % ("left" if left else "right", typ)] = i
			else:
				data = str.split(line)
				time = et.SubElement(root, "time")
				time.attrib['ms'] = data[0] * 1000
				for (muscle, d) in muscles.items():
					m = et.SubElement(time, "muscle")
					m.attrib["id"] = muscle
					for (k,v) in d.items():
						m.attrib[k] = data[v]
	
	tree = et.ElementTree(root)
	tree.write(xmlfile)

dir ="data\subject01_walk1_states"
stofile = "%s\data.sto" % dir
xmlfile = "%s\data.xml" % dir
sto_to_bespoke_xml(stofile, xmlfile)