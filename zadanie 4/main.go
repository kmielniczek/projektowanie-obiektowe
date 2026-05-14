package main

import (
	"log"
	"zadanie4/controller"

	"github.com/labstack/echo/v5"
)

func main() {
	e := echo.New()
	weatherController := controller.NewWeatherController()

	e.GET("/weather", weatherController.GetWeather)

	if err := e.Start(":8080"); err != nil {
		log.Fatal(err)
	}
}
