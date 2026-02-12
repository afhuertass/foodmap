
// assets/js/map.js
import mlgl from 'maplibre-gl';

// Use 'export' so app.js can see it
export const MapHook = {
  mounted() {
    console.log("Map hook mounted!"); // Good for debugging
    
this.map = new mlgl.Map({
  container: this.el,
  // Using CartoDB Voyager style - it's clean and professional
  style: 'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json', 
  center: [24.941, 60.170], // Helsinki coordinates [lng, lat]
  zoom: 12, // Zoomed in enough to see the city layout
  pitch: 45, // Adds a slight 3D perspective
  antialias: true
});


  }
  }
;
