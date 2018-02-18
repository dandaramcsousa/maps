
#npm install shapefile
#../node_modules/shapefile/bin/shp2json  25SEE250GC_SIR.shp  -o  pb.json

#npm install -g d3-geo-projection
geoproject 'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
	< pb.json > pb-ortho.json

geo2svg -w 1000 -h 600 \
	< pb-ortho.json > pb-ortho.svg

#npm install -g ndjson-cli
ndjson-split 'd.features' < pb-ortho.json > pb-ortho.ndjson

#npm install -g d3-dsv
dsv2json  -r ';' -n < ../dados/Pessoa03_PB.csv > pb-censo.ndjson
ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' < pb-ortho.ndjson > saida-ortho-sector.ndjson
ndjson-join 'd.Cod_setor' saida-ortho-sector.ndjson pb-censo.ndjson  > ndjson-join.ndjson
ndjson-map 'd[0].properties = {negro: Number(d[1].V003.replace(",", "."))}, d[0]' < ndjson-join.ndjson > pb-ortho-comdado.ndjson

#npm install -g topojson
geo2topo -n  tracts=pb-ortho-comdado.ndjson  > pb-tracts-topo.json
toposimplify -p 1 -f < pb-tracts-topo.json | topoquantize 1e5 > pb-quantized-topo.json

#npm install -g d3
#npm install -g d3-scale-chromatic

topo2geo tracts=- < pb-quantized-topo.json | ndjson-map -r d3 'z = d3.scaleSequential(d3.interpolateViridis).domain([0, 1e3]), d.features.forEach(f => f.properties.fill = z(f.properties.negro)), d' | ndjson-split 'd.features' | geo2svg -n --stroke none -w 1000 -h 600 > pb-tracts-threshold-light.svg


