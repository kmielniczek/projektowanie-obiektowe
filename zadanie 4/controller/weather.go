package controller

import (
	"net/http"
	"zadanie4/model"

	"github.com/labstack/echo/v5"
	"gorm.io/gorm"
)

type WeatherController struct {
	db *gorm.DB
}

func NewWeatherController(db *gorm.DB) *WeatherController {
	return &WeatherController{db: db}
}

func (wc *WeatherController) GetWeather(c *echo.Context) error {
	city := c.QueryParam("city")
	if city == "" {
		city = "Cracow"
	}

	var weatherData model.Weather

	if err := wc.db.Where("city = ?", city).First(&weatherData).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "failed to load weather data for " + city})
	}

	return c.JSON(http.StatusOK, weatherData)
}
