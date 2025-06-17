package models

import (
	"gorm.io/gorm"
)

type Basket struct {
	gorm.Model
	ConfigurationID    int                 `json:"configuration_id" binding:"required" gorm:"not null"`
	StoreID            int                 `json:"store_id" binding:"required" gorm:"not null"`
	Name               string              `json:"name" binding:"required" gorm:"unique;not null"`
	Description        string              `json:"description" gorm:"type:text"`
	DiscountPercentage float64             `json:"discount_percentage" binding:"required" gorm:"not null;default:0"`
	OriginalPrice      float64             `json:"original_price" binding:"required" gorm:"not null"`
	Quantity           int                 `json:"quantity" binding:"required" gorm:"default:0"`
	ExpirationDate     *string             `json:"expiration_date" gorm:"type:date"`
	StatusID           int                 `json:"status_id" binding:"required" gorm:"not null"`
	Status             BasketStatus        `json:"status" gorm:"foreignKey:StatusID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Configuration      BasketConfiguration `json:"configuration" gorm:"foreignKey:ConfigurationID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Store              Store               `json:"store" gorm:"foreignKey:StoreID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
}
type BasketStatus struct {
	ID   int    `json:"id" gorm:"primaryKey"`
	Name string `json:"name" gorm:"unique;not null"`
}
type BasketConfiguration struct {
	gorm.Model
	Name               string  `json:"name" binding:"required" gorm:"unique;not null"`
	Description        string  `json:"description" gorm:"type:text"`
	DiscountPercentage float64 `json:"discount_percentage" binding:"required" gorm:"not null;default:0"`
	Quantity           int     `json:"quantity" binding:"required" gorm:"default:0"`
	StoreID            uint    `json:"store_id" binding:"required" gorm:"not null"`
	Store              Store   `json:"store" gorm:"foreignKey:StoreID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
}
