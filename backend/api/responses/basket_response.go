package responses

type BasketResponse struct {
	ID            string  `json:"id"`
	Name          string  `json:"name"`
	Address       string  `json:"address"`
	Rating        float64 `json:"rating"`
	OriginalPrice float64 `json:"originalPrice"`
	DiscountPrice float64 `json:"discountPrice"`
	TypeBasket    string  `json:"typeBasket"`
	Category      string  `json:"category"`
}
