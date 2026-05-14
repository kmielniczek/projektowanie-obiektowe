package proxy

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"
	"zadanie4/model"
)

const (
	openMeteoGeocodingURL = "https://geocoding-api.open-meteo.com/v1/search"
	openMeteoForecastURL  = "https://api.open-meteo.com/v1/forecast"
)

type OpenMeteoProxy struct {
	httpClient *http.Client
}

func NewOpenMeteoProxy() *OpenMeteoProxy {
	return &OpenMeteoProxy{
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

type geocodingResponse struct {
	Results []struct {
		Latitude  float64 `json:"latitude"`
		Longitude float64 `json:"longitude"`
	} `json:"results"`
}

type forecastResponse struct {
	CurrentWeather struct {
		Temperature float64 `json:"temperature"`
		WeatherCode int     `json:"weathercode"`
	} `json:"current_weather"`
}

func (p *OpenMeteoProxy) GetCurrentWeather(city string) (*model.Weather, error) {
	lat, lon, err := p.getCityCordinates(city)
	if err != nil {
		return nil, err
	}

	forecastURL := fmt.Sprintf("%s?latitude=%f&longitude=%f&current_weather=true&timezone=auto", openMeteoForecastURL, lat, lon)

	resp, err := p.httpClient.Get(forecastURL)
	if err != nil {
		return nil, fmt.Errorf("failed to reach weather service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("weather service returned status %d", resp.StatusCode)
	}

	var forecastData forecastResponse
	if err := json.NewDecoder(resp.Body).Decode(&forecastData); err != nil {
		return nil, fmt.Errorf("failed to decode weather response: %w", err)
	}

	return &model.Weather{
		City:        city,
		Temperature: forecastData.CurrentWeather.Temperature,
		Condition:   weatherCodeDescription(forecastData.CurrentWeather.WeatherCode),
	}, nil
}

func (p *OpenMeteoProxy) getCityCordinates(city string) (float64, float64, error) {
	coordinatesURL := fmt.Sprintf("%s?name=%s&count=1&countryCode=PL", openMeteoGeocodingURL, url.QueryEscape(city))

	resp, err := p.httpClient.Get(coordinatesURL)
	if err != nil {
		return 0, 0, fmt.Errorf("failed to reach geocoding service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return 0, 0, fmt.Errorf("geocoding service returned status %d", resp.StatusCode)
	}

	var geoData geocodingResponse
	if err := json.NewDecoder(resp.Body).Decode(&geoData); err != nil {
		return 0, 0, fmt.Errorf("failed to decode geocoding response: %w", err)
	}

	if len(geoData.Results) == 0 {
		return 0, 0, fmt.Errorf("city %q not found", city)
	}

	lat := geoData.Results[0].Latitude
	lon := geoData.Results[0].Longitude

	return lat, lon, nil
}

func weatherCodeDescription(code int) string {
	switch code {
	case 0:
		return "Clear sky"
	case 1:
		return "Mainly clear"
	case 2:
		return "Partly cloudy"
	case 3:
		return "Overcast"
	case 45:
		return "Fog"
	case 48:
		return "Depositing rime fog"
	case 51:
		return "Light drizzle"
	case 53:
		return "Moderate drizzle"
	case 55:
		return "Dense drizzle"
	case 56:
		return "Light freezing drizzle"
	case 57:
		return "Dense freezing drizzle"
	case 61:
		return "Slight rain"
	case 63:
		return "Moderate rain"
	case 65:
		return "Heavy rain"
	case 66:
		return "Light freezing rain"
	case 67:
		return "Heavy freezing rain"
	case 71:
		return "Slight snow fall"
	case 73:
		return "Moderate snow fall"
	case 75:
		return "Heavy snow fall"
	case 77:
		return "Snow grains"
	case 80:
		return "Slight rain showers"
	case 81:
		return "Moderate rain showers"
	case 82:
		return "Violent rain showers"
	case 85:
		return "Slight snow showers"
	case 86:
		return "Heavy snow showers"
	case 95:
		return "Thunderstorm"
	case 96:
		return "Thunderstorm with slight hail"
	case 99:
		return "Thunderstorm with heavy hail"

	default:
		return "Undefined weather code"
	}
}
