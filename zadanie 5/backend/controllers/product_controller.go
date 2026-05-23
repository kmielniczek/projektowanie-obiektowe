package controllers

import (
	"net/http"

	"app/database"
	"app/models"

	"github.com/labstack/echo/v5"
)

func GetProducts(c *echo.Context) error {
	var products []models.Product
	result := database.DB.Find(&products)
	if result.Error != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "failed to fetch products",
		})
	}
	return c.JSON(http.StatusOK, products)
}
