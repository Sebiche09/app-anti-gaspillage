package models

type Category struct {
	ID   uint   `json:"id" gorm:"primaryKey"`
	Name string `json:"name" gorm:"type:varchar(255);not null"`
}

type StoreCategory struct {
	StoreID    uint     `json:"store_id" gorm:"not null;index"`
	CategoryID uint     `json:"category_id" gorm:"not null;index"`
	Store      Store    `gorm:"foreignKey:StoreID;constraint:OnDelete:CASCADE"`
	Category   Category `gorm:"foreignKey:CategoryID;constraint:OnDelete:CASCADE"`
}
