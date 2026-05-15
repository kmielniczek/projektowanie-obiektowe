package model

import "time"

type Weather struct {
	ID          uint      `gorm:"primaryKey" json:"-"`
	City        string    `gorm:"not null;uniqueIndex" json:"city"`
	Condition   string    `gorm:"not null" json:"condition"`
	Temperature float64   `gorm:"not null" json:"temperature"`
	UpdatedAt   time.Time `gorm:"not null" json:"-"`
}
