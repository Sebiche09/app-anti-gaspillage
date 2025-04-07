mapboxgl.accessToken = 'pk.eyJ1Ijoic2ViaWNoZTA5IiwiYSI6ImNtOTJxemFpazBlNjkybXB3ampobHl4ZGoifQ.qQWvlmHJ731fIGTgpipoUQ';
let mapInstance = null;
let merchantMarkers = []; 

function initializeMapbox(containerId, lat, lon, zoom) {
    try {        
        if (mapInstance) {
            mapInstance.remove();
            mapInstance = null;
            merchantMarkers = []; 
        }
        
        const container = document.getElementById(containerId);
        if (!container) {
            console.error("Container not found:", containerId);
            return;
        }
        container.style.width = '100%';
        container.style.height = '100%';
        
        mapInstance = new mapboxgl.Map({
            container: containerId,
            style: 'mapbox://styles/mapbox/streets-v11', 
            center: [lon, lat],
            zoom: zoom,
            preserveDrawingBuffer: true,
            failIfMajorPerformanceCaveat: false
        });
        
        mapInstance.on('load', function() {
            
            mapInstance.addControl(new mapboxgl.NavigationControl(), 'bottom-right');
            
            mapInstance.addControl(
                new mapboxgl.GeolocateControl({
                    positionOptions: {
                        enableHighAccuracy: true
                    },
                    trackUserLocation: true,
                    showUserHeading: true,
                    showUserLocation: true
                }),
                'bottom-right'
            );
            
            setTimeout(resizeMap, 200);
        });
        
        mapInstance.on('error', function(e) {
            console.error('Mapbox error:', e);
        });
        
        if (!window.mapResizeListenerAdded) {
            window.addEventListener('resize', function() {
                if (mapInstance) setTimeout(resizeMap, 100);
            });
            window.mapResizeListenerAdded = true;
        }
        
        return mapInstance;
    } catch (error) {
        console.error("Error initializing Mapbox:", error);
    }
}

function resizeMap() {
    try {
        if (mapInstance) {
            console.log(`Resizing map to ${mapInstance.getContainer().clientWidth}x${mapInstance.getContainer().clientHeight}`);
            mapInstance.resize();
        }
    } catch (error) {
        console.error("Error resizing map:", error);
    }
}

function cleanupMapbox() {
    try {
        if (mapInstance) {
            console.log("Removing map instance");
            clearMerchantMarkers(); 
            mapInstance.remove();
            mapInstance = null;
        }
    } catch (error) {
        console.error("Error cleaning up Mapbox:", error);
    }
}

function addMerchants(merchantsJsonString) {
    try {
        if (!mapInstance) {
            console.error("Map not initialized yet");
            return;
        }
        
        clearMerchantMarkers();
        
        const merchants = JSON.parse(merchantsJsonString);
        console.log(`Adding ${merchants.length} merchants to map`);
        
        if (!document.getElementById('merchant-marker-styles')) {
            const style = document.createElement('style');
            style.id = 'merchant-marker-styles';
            style.textContent = `
                .merchant-marker {
                    background-color: transparent;
                    cursor: pointer;
                }
                .marker-container {
                    width: 40px;
                    height: 40px;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                }
                .marker-container img {
                    width: 35px;
                    height: 35px;
                }
                .mapboxgl-popup-content {
                    padding: 12px;
                    border-radius: 8px;
                }
                .merchant-popup {
                    max-width: 200px;
                }
                .merchant-popup h3 {
                    margin: 0 0 8px 0;
                    font-weight: bold;
                }
                .merchant-popup p {
                    margin: 4px 0;
                }
                .price-tag {
                    color: #F9634B;
                    font-weight: bold;
                }
            `;
            document.head.appendChild(style);
        }
        
        // Ajouter chaque marchand sur la carte
        merchants.forEach(merchant => {
            const markerElement = document.createElement('div');
            markerElement.className = 'merchant-marker';
            markerElement.innerHTML = `
                <div class="marker-container">
                    <img src="assets/basket_icon.png" alt="${merchant.name}" onerror="this.src='assets/fallback_basket_icon.png'">
                </div>
            `;
            
            // Créer le marqueur
            const marker = new mapboxgl.Marker(markerElement)
                .setLngLat([merchant.longitude, merchant.latitude])
                .addTo(mapInstance);
            
            // Ajouter un popup sur le marqueur
            const popup = new mapboxgl.Popup({ offset: 25, closeButton: false })
                .setHTML(`
                    <div class="merchant-popup">
                        <h3>${merchant.name}</h3>
                        <p>${merchant.availableBaskets} panier(s) disponible(s)</p>
                        <p class="price-tag">${merchant.price.toFixed(2)} €</p>
                    </div>
                `);
            
            marker.setPopup(popup);
            
            // Ajouter une interaction au survol
            markerElement.addEventListener('mouseenter', () => {
                marker.getPopup().addTo(mapInstance);
            });
            
            markerElement.addEventListener('mouseleave', () => {
                setTimeout(() => {
                    if (!marker.getPopup()._content.matches(':hover')) {
                        marker.getPopup().remove();
                    }
                }, 300);
            });
            
            // Stocker le marqueur pour nettoyage ultérieur
            merchantMarkers.push(marker);
        });
    } catch (error) {
        console.error("Error adding merchants:", error);
    }
}

// Fonction pour nettoyer tous les marqueurs
function clearMerchantMarkers() {
    merchantMarkers.forEach(marker => {
        if (marker && marker.remove) {
            marker.remove();
        }
    });
    merchantMarkers = [];
}

window.initializeMapbox = initializeMapbox;
window.resizeMap = resizeMap;
window.cleanupMapbox = cleanupMapbox;
window.addMerchants = addMerchants;
window.clearMerchantMarkers = clearMerchantMarkers;
