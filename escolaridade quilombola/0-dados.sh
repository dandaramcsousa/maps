
dsv2json  -r ',' -n < ../dados/estabelecimentos-ef-quilombo.csv > dado1-ensino-quilombo.ndjson
ndjson-split 'd.features' < ../dados/geo1-br_municipios_projetado.json | ndjson-map 'd.Localidade = d.properties.NOME, d' > geo2-br_municipios.ndjson
ndjson-map 'd.Localidade = d.Localidade.toUpperCase(), d' < dado1-ensino-quilombo.ndjson > dado2-ensino-quilombo-comchave.ndjson

EXP_PROPRIEDADE='d[0].properties = Object.assign({}, d[0].properties, d[1]), d[0]'
ndjson-join --left 'd.Localidade' \
  geo2-br_municipios.ndjson \
  dado2-ensino-quilombo-comchave.ndjson \
  | ndjson-map \
    "$EXP_PROPRIEDADE" \
  > geo3-municipios-e-ensino.ndjson
  
geo2topo -n \
  tracts=- \
< geo3-municipios-e-ensino.ndjson \
| toposimplify -p 1 -f \
| topoquantize 1e5 \
| topo2geo tracts=- \
> geo4-municipios-e-ensino-simplificado.json
