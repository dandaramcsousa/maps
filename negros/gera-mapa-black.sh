#!/bin/bash

# a expressão javascript que cria a variável a plotar
EXP_PROPRIEDADE='d[0].properties = {negro: Number(d[1].V003.replace(",", "."))}, d[0]'

# a expressão js que decide os fills baseados em uma escala
#EXP_ESCALA='z = d3.scaleSequential(d3.interpolateViridis).domain([0, 1e3]), d.features.forEach(f => f.properties.fill = z(f.properties.negro)), d'
EXP_ESCALA='z = d3.scaleThreshold().domain([0, 100, 400, 700,1000]).range(d3.schemeReds[5]), d.features.forEach(f => f.properties.fill = z(f.properties.negro)), d'

# !! Começamos já com a geometria projetada

# Prepara geometrias para o join
ndjson-map 'd.Cod_setor = d.properties.CD_GEOCODI, d' \
  < ../dados/pb-ortho.ndjson \
  > pb-ortho-sector.ndjson

# Transforma dados do IBGE para ndjson
dsv2json \
  -r ';' \
  -n \
  < ../dados/Pessoa03_PB.csv \
  > pb-censo.ndjson

# Join geometrias + IBGE
ndjson-join 'd.Cod_setor' \
  pb-ortho-sector.ndjson \
  pb-censo.ndjson \
  > pb-ortho-censo.ndjson

# Cria propriedade e plota
ndjson-map \
  "$EXP_PROPRIEDADE" \
  < pb-ortho-censo.ndjson \
  | geo2topo -n \
    tracts=- \
  | toposimplify -p 1 -f \
  | topoquantize 1e5 \
  | topo2geo tracts=- \
  | ndjson-map -r d3 -r d3=d3-scale-chromatic \
    "$EXP_ESCALA" \
  | ndjson-split 'd.features' \
  | geo2svg -n --stroke none -w 1000 -h 600 \
    > pb-chroropleth-blackpeople.svg
