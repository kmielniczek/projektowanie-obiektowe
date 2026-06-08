package database

import (
	"log"

	"app/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() error {
	var err error
	DB, err = gorm.Open(sqlite.Open("shop.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("failed to connect to database:", err)
		return err
	}

	err = DB.AutoMigrate(&models.Product{}, &models.Payment{}, &models.Cart{}, &models.CartItem{}, &models.User{})
	if err != nil {
		log.Fatal("failed to migrate database:", err)
		return err
	}

	// seed database with mocks
	var count int64
	DB.Model(&models.Product{}).Count(&count)
	if count == 0 {
		products := []models.Product{
			{Name: "Laptop", Price: 4000.00},
			{Name: "Mouse", Price: 50.49},
			{Name: "Keyboard", Price: 129.99},
			{Name: "Monitor", Price: 899.99},
			{Name: "Headphones", Price: 255.19},
		}
		DB.Create(products)
	}

	return nil
}
