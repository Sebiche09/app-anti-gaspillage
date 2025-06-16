package models

import (
	"gorm.io/gorm"
)

type Basket struct {
	gorm.Model
	RestaurantID   int        `json:"restaurant_id" gorm:"not null"`
	Name           string     `json:"name" binding:"required" gorm:"unique;not null"`
	TypeBasket     string     `json:"type" binding:"required" gorm:"not null"`
	Description    string     `json:"description" gorm:"type:text"`
	Price          float64    `json:"price" binding:"required" gorm:"not null"`
	OriginalPrice  float64    `json:"original_price" binding:"required" gorm:"not null"`
	Quantity       int        `json:"quantity" binding:"required" gorm:"default:0"`
	ExpirationDate string     `json:"expiration_date" gorm:"type:date"`
	Restaurant     Restaurant `gorm:"foreignKey:RestaurantID"`
}
