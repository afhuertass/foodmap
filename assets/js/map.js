// assets/js/map.js
import mlgl from 'maplibre-gl';

export const MapHook = {
  mounted() {
    console.log("Map hook mounted!");

    this.map = new mlgl.Map({
      container: this.el,
      style: 'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json',
      center: [24.941, 60.170],
      zoom: 12,
      pitch: 45,
      antialias: true
    });

    // 1. Storage for permanent markers (the ones from the database)
    this.markers = {};

    // 2. The Form Marker (your current red pin for selecting a location)
    this.marker = new mlgl.Marker({ color: "#FF0000", draggable: false })
      .setLngLat([24.941, 60.170])
      .addTo(this.map);

	// click event
    this.map.on('click', (e) => {
      const { lng, lat } = e.lngLat;
	if (window.location.pathname === "/places/new" ||  /^\/places\/[^\/]+\/edit\/?$/.test(window.location.pathname)   ) {
	    console.log("Map clicked on /places/new at:", lat, lng);
	    this.pushEvent("map_clicked", { lat: lat, lng: lng });
	  } else {
	    console.log("Map clicked, but ignored (not on /places/new)");
	  }
    });

/// event handlers
   this.handleEvent("upsert_marker", (place) => {
      this.addPlaceMarker(place);
    });

    // REMOVE
    this.handleEvent("remove_marker", ({ id }) => {
      if (this.markers[id]) {
        this.markers[id].remove();
        delete this.markers[id];
        console.log(`Marker ${id} removed.`);
      }
    });
    // Update the FORM marker position
    this.handleEvent("set_marker", ({ lat, lng }) => {
      this.marker.setLngLat([lng, lat]);
      this.map.flyTo({ center: [lng, lat] });
    });

    // NEW: Load all existing markers on mount
    this.handleEvent("init_markers", ({ places }) => {
      console.log("Initializing markers:", places);
      places.forEach(place => this.addPlaceMarker(place));
    });
	// Friend markers
    this.handleEvent("friend_markers", ({ places }) => {
      console.log("Initializing markers:", places);
      places.forEach(place => this.addPlaceMarker(place, "#71f58a"));
    });
    // NEW: Add a single marker (called after a successful save)
    this.handleEvent("add_marker", (place) => {
      console.log("Adding new marker:", place);
      this.addPlaceMarker(place);
    });
  },
addPlaceMarker(place, color = "#3b82f6") {
  if (!place.lat || !place.lng) return;

  // Check if marker already exists to avoid duplicates
  if (this.markers[place.id]) {
      this.markers[place.id].remove();
  }

  // Use the color variable passed into the function
  const marker = new mlgl.Marker({ color: color }) 
    .setLngLat([place.lng, place.lat])
    .setPopup(new mlgl.Popup().setHTML(`<b>${place.name}</b>`))
    .addTo(this.map);

  this.markers[place.id] = marker;
}
  // Helper function to keep things DRY
};
