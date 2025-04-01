package utils

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const secretKey = "secret"

func GenerateInvitationToken(restaurantID uint, email string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"restaurant_id": restaurantID,
		"email":         email,
		"invitation":    true,
		"exp":           time.Now().Add(time.Hour * 24 * 7).Unix(),
	})

	return token.SignedString([]byte(secretKey))
}

func VerifyInvitationToken(tokenString string) (uint, string, error) {
	parseToken, err := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		_, ok := token.Method.(*jwt.SigningMethodHMAC)
		if !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(secretKey), nil
	})

	if err != nil {
		return 0, "", err
	}

	if !parseToken.Valid {
		return 0, "", errors.New("invalid invitation token")
	}

	claims, ok := parseToken.Claims.(jwt.MapClaims)
	if !ok {
		return 0, "", errors.New("invalid token claims")
	}

	isInvitation, ok := claims["invitation"].(bool)
	if !ok || !isInvitation {
		return 0, "", errors.New("not an invitation token")
	}

	restaurantID := uint(claims["restaurant_id"].(float64))
	email := claims["email"].(string)

	return restaurantID, email, nil
}

func GenerateUniqueInviteCode() string {
	b := make([]byte, 6) // 6 octets donneront 12 caractères en hexadécimal
	rand.Read(b)
	return hex.EncodeToString(b)
}

// ---------------------------------------------------------------

func GenerateToken(email string, userId uint, isAdmin bool,
	isMerchant bool, staffRestaurantIDs []uint) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email":            email,
		"user_id":          userId,
		"isAdmin":          isAdmin,
		"isMerchant":       isMerchant,
		"staffRestaurants": staffRestaurantIDs,
		"exp":              time.Now().Add(time.Hour * 12).Unix(),
	})

	return token.SignedString([]byte(secretKey))
}

func VerifyToken(tokenString string) (uint, bool, bool, []uint, error) {
	parseToken, err := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		_, ok := token.Method.(*jwt.SigningMethodHMAC)

		if !ok {
			return nil, jwt.ErrSignatureInvalid
		}

		return []byte(secretKey), nil
	})
	if err != nil {
		return 0, false, false, nil, errors.New("could not parse token")
	}

	tokenIsValid := parseToken.Valid

	if !tokenIsValid {
		return 0, false, false, nil, errors.New("invalid token")
	}

	claims, ok := parseToken.Claims.(jwt.MapClaims)

	if !ok {
		return 0, false, false, nil, errors.New("invalid token claims")
	}

	userId := uint(claims["user_id"].(float64))
	isAdmin, _ := claims["isAdmin"].(bool)
	isMerchant, _ := claims["isMerchant"].(bool)

	var staffRestaurantIDs []uint
	if staffRestaurantsIntf, exists := claims["staffRestaurants"]; exists && staffRestaurantsIntf != nil {
		if staffRestaurantsArray, ok := staffRestaurantsIntf.([]interface{}); ok {
			for _, idIntf := range staffRestaurantsArray {
				if idFloat, ok := idIntf.(float64); ok {
					staffRestaurantIDs = append(staffRestaurantIDs, uint(idFloat))
				}
			}
		}
	}

	return userId, isAdmin, isMerchant, staffRestaurantIDs, nil
}
