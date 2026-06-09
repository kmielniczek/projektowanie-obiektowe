package main

import (
	"log"
	"net/http"
	"os"

	"app/controllers"
	"app/database"

	"github.com/gorilla/sessions"
	"github.com/labstack/echo-contrib/v5/session"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func main() {
	database.InitDB()

	e := echo.New()

	sessionStore := sessions.NewCookieStore([]byte("zadanie5-session-secret-key"))
	sessionStore.Options = &sessions.Options{
		Path:     "/",
		MaxAge:   86400,
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode,
		Secure:   false,
	}

	e.Use(session.Middleware(sessionStore))

	e.Use(middleware.CSRFWithConfig(middleware.CSRFConfig{
		TokenLookup:    "header:X-CSRF-Token",
		CookieName:     "_csrf",
		CookiePath:     "/",
		CookieSameSite: http.SameSiteLaxMode,
		CookieSecure:   false,
		CookieHTTPOnly: false,
	}))

	allowedOrigin := os.Getenv("ALLOWED_ORIGIN")
	if allowedOrigin == "" {
		allowedOrigin = "http://localhost:5173"
	}

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins:     []string{allowedOrigin},
		AllowMethods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodOptions},
		AllowHeaders:     []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization, "X-CSRF-Token"},
		AllowCredentials: true,
	}))

	e.GET("/api/products", controllers.GetProducts)
	e.GET("/api/csrf", controllers.GetCSRFToken)
	e.POST("/api/carts", controllers.SubmitCart)
	e.POST("/api/payments", controllers.CreatePayment)

	e.POST("/api/register", controllers.Register)
	e.POST("/api/login", controllers.Login)
	e.POST("/api/logout", controllers.Logout)
	e.GET("/api/me", controllers.GetMe)
	e.PUT("/api/account", controllers.UpdateAccount)
	e.POST("/api/account", controllers.UpdateAccount)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := e.Start(":" + port); err != nil {
		log.Fatal(err)
	}
}
