package main

import (
	"log"

	"app/controllers"
	"app/database"

	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func main() {
	database.InitDB()

	e := echo.New()

	e.Use(middleware.CORS("http://localhost:5173"))

	e.GET("/api/products", controllers.GetProducts)

	e.POST("/api/carts", controllers.SubmitCart)

	e.POST("/api/payments", controllers.CreatePayment)

	if err := e.Start(":8080"); err != nil {
		log.Fatal(err)
	}
}
