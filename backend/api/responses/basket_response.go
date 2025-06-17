package responses

type BasketResponse struct {
	ID                 uint    `json:"id"`
	Name               string  `json:"name"`
	Address            string  `json:"address"`
	Rating             float64 `json:"rating"`
	OriginalPrice      float64 `json:"originalPrice"`
	DiscountPrice      float64 `json:"discountPrice"`
	DiscountPercentage float64 `json:"discountPercentage"`
	Category           string  `json:"category"`
	Latitude           float64 `json:"latitude"`
	Longitude          float64 `json:"longitude"`
}
type BasketByStoreResponse struct {
	ID                 uint    `json:"id"`
	Name               string  `json:"name"`
	OriginalPrice      float64 `json:"originalPrice"`
	DiscountPercentage float64 `json:"discountPercentage"`
	Category           string  `json:"category"`
	Description        string  `json:"description"`
	Quantity           int     `json:"quantity"`
}
