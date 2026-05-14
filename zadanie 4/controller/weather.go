package controller

import (
	"net/http"

	"github.com/labstack/echo/v5"
)

type WeatherController struct{}

func NewWeatherController() *WeatherController {
	return &WeatherController{}
}

func (wc *WeatherController) GetWeather(c *echo.Context) error {
	weatherData := map[string]string{
		"city":        "Cracow",
		"condition":   "Clear sky",
		"temperature": "22",
	}

	return c.JSON(http.StatusOK, weatherData)
}
