package controller

import (
	"net/http"
	"zadanie4/proxy"

	"github.com/labstack/echo/v5"
	"gorm.io/gorm"
)

type WeatherController struct {
	db           *gorm.DB
	weatherProxy *proxy.OpenMeteoProxy
}

func NewWeatherController(db *gorm.DB, weatherProxy *proxy.OpenMeteoProxy) *WeatherController {
	return &WeatherController{db: db, weatherProxy: weatherProxy}
}

func (wc *WeatherController) GetWeather(c *echo.Context) error {
	city := c.QueryParam("city")
	if city == "" {
		city = "Krakow"
	}

	weatherData, err := wc.weatherProxy.GetCurrentWeather(city)
	if err != nil {
		return c.JSON(http.StatusBadGateway, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, weatherData)
}
