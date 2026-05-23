package controllers

import (
	"log"
	"net/http"

	"app/database"
	"app/models"

	"github.com/labstack/echo/v5"
)

type CartItemRequest struct {
	ProductID uint    `json:"product_id"`
	Name      string  `json:"name"`
	Price     float64 `json:"price"`
	Quantity  int     `json:"quantity"`
}

type CartRequest struct {
	Items []CartItemRequest `json:"items"`
	Total float64           `json:"total"`
}

func SubmitCart(c *echo.Context) error {
	var req CartRequest

	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request body"})
	}

	if len(req.Items) == 0 || req.Total <= 0 {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "items and total are required"})
	}

	items := make([]models.CartItem, 0, len(req.Items))
	for _, item := range req.Items {
		items = append(items, models.CartItem{
			Name:      item.Name,
			Price:     item.Price,
			Quantity:  item.Quantity,
			ProductID: item.ProductID,
		})
	}

	cart := models.Cart{
		Total: req.Total,
		Items: items,
	}

	if err := database.DB.Create(&cart).Error; err != nil {
		log.Printf("failed to create cart with items: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to create cart: " + err.Error()})
	}

	return c.JSON(http.StatusCreated, cart)
}
