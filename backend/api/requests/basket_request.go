package requests

import "time"

type CreateBasketRequest struct {
	RestaurantID   int     `json:"restaurant_id" example:"1" binding:"required"`
	Name           string  `json:"name" example:"panier surprise" binding:"required"`
	TypeBasket     string  `json:"type" example:"surprise" binding:"required"`
	Description    string  `json:"description" example:"Ceci est un panier suprise" gorm:"type:text"`
	Price          float64 `json:"price" binding:"required" example:"8.99" gorm:"not null"`
	OriginalPrice  float64 `json:"original_price" binding:"required" example:"22" gorm:"not null"`
	Quantity       int     `json:"quantity" binding:"required" example:"2" gorm:"default:0"`
	ExpirationDate string  `json:"expiration_date" example:"2022-12-31" gorm:"type:date"`
}

type UpdateBasketRequest struct {
	RestaurantID   int        `json:"restaurant_id" example:"1" binding:"required"`
	Name           string     `json:"name" example:"panier surprise" binding:"required"`
	TypeBasket     string     `json:"type" example:"surprise" binding:"required"`
	Description    string     `json:"description" example:"Ceci est un panier suprise" gorm:"type:text"`
	Price          float64    `json:"price" binding:"required" example:"8.99" gorm:"not null"`
	OriginalPrice  float64    `json:"original_price" binding:"required" example:"22" gorm:"not null"`
	Quantity       int        `json:"quantity" binding:"required" example:"2" gorm:"default:0"`
	ExpirationDate *time.Time `json:"expiration_date" example:"2022-12-31" gorm:"type:date"`
}
