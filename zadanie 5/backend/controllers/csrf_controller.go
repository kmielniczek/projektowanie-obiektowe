package controllers

import (
	"net/http"

	"github.com/labstack/echo/v5"
)

func GetCSRFToken(c *echo.Context) error {
	tokenValue := c.Get("csrf")
	token, ok := tokenValue.(string)
	if !ok || token == "" {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "csrf token unavailable",
		})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"token": token,
	})
}
