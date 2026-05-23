package models

type CartItem struct {
	ID        uint    `gorm:"primarykey"     json:"id"`
	Name      string  `gorm:"not null"       json:"name"`
	Price     float64 `gorm:"not null"       json:"price"`
	Quantity  int     `gorm:"not null"       json:"quantity"`
	CartID    uint    `gorm:"not null;index" json:"cart_id"`
	ProductID uint    `gorm:"not null;index" json:"product_id"`
}

type Cart struct {
	ID    uint       `gorm:"primarykey" json:"id"`
	Items []CartItem `gorm:"not null"   json:"items"`
	Total float64    `gorm:"not null"   json:"total"`
}
