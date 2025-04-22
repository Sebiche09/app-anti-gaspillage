package models

import "time"

// Configuration globale des paniers pour un restaurant
type BasketConfiguration struct {
	ID           uint       `json:"id" gorm:"primaryKey"`
	RestaurantID uint       `json:"restaurant_id" gorm:"not null"`
	Restaurant   Restaurant `json:"-" gorm:"foreignKey:RestaurantID"`
	Price        float64    `json:"price" gorm:"not null"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`

	// Relations avec les disponibilités quotidiennes
	DailyAvailabilities []DailyBasketAvailability `json:"daily_availabilities" gorm:"foreignKey:ConfigurationID"`
}

type DailyBasketAvailability struct {
	ID              uint `json:"id" gorm:"primaryKey"`
	ConfigurationID uint `json:"configuration_id" gorm:"not null"`
	DayOfWeek       int  `json:"day_of_week" gorm:"not null"` // 1=Lundi, 2=Mardi, etc.
	NumberOfBaskets int  `json:"number_of_baskets" gorm:"not null"`
}
