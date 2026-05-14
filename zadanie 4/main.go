package main

import (
	"log"

	"zadanie4/controller"
	"zadanie4/model"

	"github.com/labstack/echo/v5"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	db, err := gorm.Open(sqlite.Open("weather.db"), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	if err := db.AutoMigrate(&model.Weather{}); err != nil {
		log.Fatal(err)
	}

	seedDatabase(db)

	e := echo.New()
	weatherController := controller.NewWeatherController(db)

	e.GET("/weather", weatherController.GetWeather)

	if err := e.Start(":8080"); err != nil {
		log.Fatal(err)
	}
}

func seedDatabase(db *gorm.DB) {
	weatherMocks := []model.Weather{
		{
			City:        "Cracow",
			Condition:   "Clear sky",
			Temperature: 22,
		},
		{
			City:        "Warsaw",
			Condition:   "Partly Cloud",
			Temperature: 19,
		},
		{
			City:        "Gdansk",
			Condition:   "Overcast",
			Temperature: 18,
		},
	}

	for _, weatherData := range weatherMocks {
		if err := db.Where("city = ?", weatherData.City).FirstOrCreate(&weatherData).Error; err != nil {
			log.Fatal(err)
		}
	}
}
