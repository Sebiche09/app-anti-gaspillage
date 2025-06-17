package models

type StoreStaff struct {
	StoreID uint  `json:"store_id"`
	UserID  uint  `json:"user_id"`
	Store   Store `gorm:"foreignKey:StoreID"`
	User    User  `gorm:"foreignKey:UserID"`
}
