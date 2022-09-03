<script setup lang="ts">
import 'mapbox-gl/dist/mapbox-gl.css'
import mapboxgl, { type FeatureIdentifier } from 'mapbox-gl'
import { onMounted } from 'vue'

onMounted(() => {
  const kSourceId = 'src-tracks', kSourceLayerId = 'tracks', kLayerId = 'tracks'
  mapboxgl.accessToken = 'pk.eyJ1Ijoiem9waWV1eCIsImEiOiJjajhvdGUwOXUwN3RqMnFyenZjaW91dXplIn0.1ykwyJVQ-YHR6vgmY2R3Tg'
  const map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/light-v9',
  })
  map.on('load', async () => {
    const metap = await fetch('/tiles/metadata.json')
    const meta = await metap.json()
    const metaj = JSON.parse(meta.json)
    console.log(meta)
    console.log(metaj)
    map.addSource(kSourceId, {
      'type': 'vector',
      'tiles': [
        // This needs to be served with Content-Encoding: gzip.
        window.location.origin + '/tiles/{z}/{x}/{y}.pbf',
      ],
      'maxzoom': 14,
    });
    metaj.vector_layers.forEach((l: any) => {
      map.addLayer({
        id: l.id,
        type: 'line',
        source: kSourceId,
        "source-layer": l.id,
        interactive: true,
        paint: {
          'line-color': ['case', ['boolean', ['feature-state', 'hover'], false], 'red', 'blue'],
          'line-width': ['case', ['boolean', ['feature-state', 'hover'], false], 4, 2],
        }
      })
    })
    const layers = metaj.vector_layers.map(l => l.id)
    let hovered = null;
    map.addControl(new mapboxgl.NavigationControl())
    map.zoomTo(5, { animate: false });
    map.setCenter({ lng: 6.427052609310749, lat: 46.330785652937294 });
    map.on('mouseenter', layers, function (e) {
      hovered = e.features[0].layer
      map.setPaintProperty(hovered.id, 'line-color', 'red')
      map.setPaintProperty(hovered.id, 'line-width', 4)
      console.log(hovered.id)
      // console.log('ki', map.querySourceFeatures(kSourceId, { sourceLayer: hovered.id }))
      // console.log('ke', map.queryRenderedFeatures(undefined, { layers: [hovered.id] }))
    })
    map.on('mouseleave', layers, function (e) {
      map.setPaintProperty(hovered.id, 'line-color', 'blue')
      map.setPaintProperty(hovered.id, 'line-width', 2)
    })
    map.on('mousemove', function (e) {
      const bbox = [
        [e.point.x - 5, e.point.y - 5],
        [e.point.x + 5, e.point.y + 5]
      ]
      const x = map.queryRenderedFeatures(bbox, { layers })
      // map.queryRenderedFeatures(undefined, { layers: ['tracks'] }).forEach(f => map.setFeatureState(f, { hover: false }))
      // x.forEach(f => map.setFeatureState(f, { hover: true }))
    })
  })
})
</script>

<template>
  <div id="map" />
</template>

<style scoped lang="sass">
#map
  width: 100%
  height: 100%
</style>
