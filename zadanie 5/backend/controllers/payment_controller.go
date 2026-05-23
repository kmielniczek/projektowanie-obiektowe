package controllers

import (
	"net/http"
	"time"

	"app/database"
	"app/models"

	"github.com/labstack/echo/v5"
)

type PaymentRequest struct {
	Amount float64 `json:"amount"`
	Method string  `json:"method"`
	CartID string  `json:"cart_id"`
}

func CreatePayment(c *echo.Context) error {
	var req PaymentRequest

	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "invalid request body",
		})
	}

	if req.Amount <= 0 || req.Method == "" || req.CartID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "amount, method, and cart_id are required",
		})
	}

	payment := models.Payment{
		Amount: req.Amount,
		Method: req.Method,
		CartID: req.CartID,
	}

	result := database.DB.Create(&payment)
	if result.Error != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "failed to create payment",
		})
	}

	time.AfterFunc(time.Second*15, func() {
		payment.Status = "completed"
		database.DB.Save(&payment)
	})

	return c.JSON(http.StatusCreated, payment)
}
