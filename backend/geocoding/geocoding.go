package geocoding

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
)

// Structure pour parser la réponse de l'API Geoapify
type GeoapifyResponse struct {
	Features []struct {
		Properties struct {
			Lat float64 `json:"lat"`
			Lon float64 `json:"lon"`
		} `json:"properties"`
	} `json:"features"`
}

// GeoCoordinates représente une paire de coordonnées géographiques
type GeoCoordinates struct {
	Latitude  float64
	Longitude float64
}

// Config contient les paramètres de configuration pour le service de géocodage
type Config struct {
	APIKey string
}

// Service fournit des méthodes pour interagir avec les services de géocodage
type Service struct {
	config Config
	client *http.Client
}

// NewService crée une nouvelle instance de Service
func NewService(config Config) *Service {
	return &Service{
		config: config,
		client: &http.Client{},
	}
}

// GetCoordinatesFromAddress récupère les coordonnées géographiques à partir d'une adresse
func (s *Service) GetCoordinatesFromAddress(address, city, postalCode string) (*GeoCoordinates, error) {

	fullAddress := fmt.Sprintf("%s, %s %s", address, postalCode, city)

	encodedAddress := url.QueryEscape(fullAddress)

	apiURL := fmt.Sprintf("https://api.geoapify.com/v1/geocode/search?text=%s&apiKey=%s",
		encodedAddress, s.config.APIKey)

	req, err := http.NewRequest("GET", apiURL, nil)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de la création de la requête: %w", err)
	}

	res, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de l'exécution de la requête: %w", err)
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de la lecture de la réponse: %w", err)
	}

	var geoResponse GeoapifyResponse
	if err := json.Unmarshal(body, &geoResponse); err != nil {
		return nil, fmt.Errorf("erreur lors de l'analyse de la réponse JSON: %w", err)
	}

	if len(geoResponse.Features) == 0 {
		return nil, fmt.Errorf("aucune coordonnée trouvée pour cette adresse")
	}

	coordinates := &GeoCoordinates{
		Latitude:  geoResponse.Features[0].Properties.Lat,
		Longitude: geoResponse.Features[0].Properties.Lon,
	}

	return coordinates, nil
}
