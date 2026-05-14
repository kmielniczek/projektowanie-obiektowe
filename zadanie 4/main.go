package main

import (
	"log"

	"zadanie4/controller"
	"zadanie4/model"
	"zadanie4/proxy"

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

	e := echo.New()
	weatherProxy := proxy.NewOpenMeteoProxy()
	weatherController := controller.NewWeatherController(db, weatherProxy)

	e.GET("/weather", weatherController.GetWeather)

	if err := e.Start(":8080"); err != nil {
		log.Fatal(err)
	}
}
