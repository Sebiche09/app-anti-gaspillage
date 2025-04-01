package requests

type CreateMerchantRequest struct {
	BusinessName string `json:"business_name" example:"petit bateau" binding:"required"`
	EmailPro     string `json:"email_pro" example:"merchant@example.com" binding:"required,email"`
	SIRET        string `json:"siret" example:"78467169500087" binding:"required,len=14"`
	PhoneNumber  string `json:"phone_number" example:"+32452101010"`
}

type UpdateMerchantRequest struct {
	BusinessName string `json:"business_name" binding:"required" example:"petit bateau update" gorm:"type:varchar(255);not null"`          // Nom de l'entreprise
	EmailPro     string `json:"email_pro" binding:"required,email" example:"merchantupdate@example.com" gorm:"type:varchar(255);not null"` // Email valide requis
	SIRET        string `json:"siret" binding:"required,len=14" example:"78467169500089" gorm:"type:varchar(14);unique;not null"`          // Numéro SIRET
	PhoneNumber  string `json:"phone_number" example:"+32452101010" gorm:"type:varchar(15)"`
}
