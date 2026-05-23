package models

type Product struct {
	ID    uint    `gorm:"primarykey" json:"id"`
	Name  string  `gorm:"not null"   json:"name"`
	Price float64 `gorm:"not null"   json:"price"`
}
