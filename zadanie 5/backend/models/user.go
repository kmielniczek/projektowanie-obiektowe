package models

type User struct {
	ID           uint   `gorm:"primarykey" json:"id"`
	Name         string `gorm:"not null" json:"name"`
	Email        string `gorm:"not null;uniqueIndex" json:"email"`
	PasswordHash string `gorm:"not null" json:"-"`
}
