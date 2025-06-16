package models

import (
	"gorm.io/gorm"
)

type RestaurantStaff struct {
	gorm.Model
	RestaurantID uint       `json:"restaurant_id"`
	UserID       uint       `json:"user_id"`
	Restaurant   Restaurant `gorm:"foreignKey:RestaurantID"`
	User         User       `gorm:"foreignKey:UserID"`
}
