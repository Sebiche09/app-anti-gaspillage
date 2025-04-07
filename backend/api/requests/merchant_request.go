package requests

type CreateMerchantRequest struct {
	BusinessName string `json:"business_name" example:"petit bateau" binding:"required"`
	EmailPro     string `json:"email_pro" example:"merchant@example.com" binding:"required,email"`
	SIREN        string `json:"siren" example:"78467169500087" binding:"required,len=9"`
	PhoneNumber  string `json:"phone_number" example:"+32452101010"`
}

type UpdateMerchantRequest struct {
	BusinessName string `json:"business_name" binding:"required" example:"petit bateau update" gorm:"type:varchar(255);not null"`          // Nom de l'entreprise
	EmailPro     string `json:"email_pro" binding:"required,email" example:"merchantupdate@example.com" gorm:"type:varchar(255);not null"` // Email valide requis
	SIREN        string `json:"siren" binding:"required,len=14" example:"784671695" gorm:"type:varchar(9);unique;not null"`                // Numéro SIREN
	PhoneNumber  string `json:"phone_number" example:"+32452101010" gorm:"type:varchar(15)"`
}
