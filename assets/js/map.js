// assets/js/map.js
import mlgl from 'maplibre-gl';

export const MapHook = {
  mounted() {
    console.log("Map hook mounted!");
    
    this.map = new mlgl.Map({
      container: this.el, // 'this.el' refers to the div with phx-hook
      style: 'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json', 
      center: [24.941, 60.170], 
      zoom: 12,
      pitch: 45,
      antialias: true
    });
   this.marker = new mlgl.Marker({ color: "#FF0000", draggable: false })
      .setLngLat([24.941, 60.170])
      .addTo(this.map);

    this.map.on('click', (e) => {
      // FIX 1: MapLibre uses e.lngLat
      const { lng, lat } = e.lngLat;

      console.log("Map clicked at:", lat, lng);

      // Send it back to the LiveView
      this.pushEvent("map_clicked", { lat: lat, lng: lng });
    });

this.handleEvent("set_marker", ({ lat, lng }) => {
      this.marker.setLngLat([lng, lat]);
      // Optional: smooth fly to the new location
      this.map.flyTo({ center: [lng, lat] });
    });
  }

};
