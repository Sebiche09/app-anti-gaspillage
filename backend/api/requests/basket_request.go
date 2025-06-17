package requests

import "time"

type CreateBasketRequest struct {
	StoreID            int     `json:"store_id" example:"1" binding:"required"`
	ConfigurationID    *int    `json:"configuration_id" example:"1"`
	Name               string  `json:"name" example:"panier surprise" binding:"required"`
	Description        string  `json:"description" example:"Ceci est un panier suprise" gorm:"type:text"`
	DiscountPercentage float64 `json:"discount_percentage" binding:"required" example:"0.2" gorm:"not null;default:0"` // 20% de réduction
	OriginalPrice      float64 `json:"original_price" binding:"required" example:"22" gorm:"not null"`                 // Prix original avant réduction
	Quantity           int     `json:"quantity" binding:"required" example:"2" gorm:"default:0"`                       // Quantité disponible
	ExpirationDate     *string `json:"expiration_date" example:"2022-12-31" gorm:"type:date"`                          // Date d'expiration du panier, au format YYYY-MM-DD
}

type UpdateBasketRequest struct {
	StoreID        int        `json:"store_id" example:"1" binding:"required"`
	Name           string     `json:"name" example:"panier surprise" binding:"required"`
	TypeBasket     string     `json:"type" example:"surprise" binding:"required"`
	Description    string     `json:"description" example:"Ceci est un panier suprise" gorm:"type:text"`
	Price          float64    `json:"price" binding:"required" example:"8.99" gorm:"not null"`
	OriginalPrice  float64    `json:"original_price" binding:"required" example:"22" gorm:"not null"`
	Quantity       int        `json:"quantity" binding:"required" example:"2" gorm:"default:0"`
	ExpirationDate *time.Time `json:"expiration_date" example:"2022-12-31" gorm:"type:date"`
}
