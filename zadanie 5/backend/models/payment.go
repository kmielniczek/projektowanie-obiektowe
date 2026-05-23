package models

import (
	"time"
)

type Payment struct {
	ID        uint      `gorm:"primarykey"                 json:"id"`
	Amount    float64   `gorm:"not null"                   json:"amount"`
	Method    string    `gorm:"not null"                   json:"method"`
	Status    string    `gorm:"not null;default:'pending'" json:"status"`
	CartID    string    `gorm:"not null"                   json:"cart_id"`
	CreatedAt time.Time `form:"not null"                   json:"created_at"`
}
