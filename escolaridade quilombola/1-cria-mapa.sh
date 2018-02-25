            
EXP_ESCALA_CRESC_COLOR='z = d3.scaleThreshold().domain([0,4,8,12, 16]).range(d3.schemeRdYlGn[5]),
            d.features.forEach(f => f.properties.fill = z(f.properties["2016"])),
            d'
  
ndjson-map -r d3 -r d3=d3-scale-chromatic \
  "$EXP_ESCALA_CRESC_COLOR" \
< geo4-municipios-e-ensino-simplificado.json \
| ndjson-split 'd.features' \
| geo2svg -n --stroke none -w 1000 -h 600 \
  > ensino-quilombola-no-br-choropleth.svg
