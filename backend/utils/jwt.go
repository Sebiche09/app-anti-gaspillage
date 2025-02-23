package utils

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const secretKey = "secret"

func GenerateToken(email string, userId uint, isAdmin bool, isMerchant bool) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email":      email,
		"user_id":    userId,
		"isAdmin":    isAdmin,
		"isMerchant": isMerchant,
		"exp":        time.Now().Add(time.Hour * 12).Unix(),
	})

	return token.SignedString([]byte(secretKey))
}

func VerifyToken(tokenString string) (uint, bool, bool, error) {
	parseToken, err := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		_, ok := token.Method.(*jwt.SigningMethodHMAC)

		if !ok {
			return nil, jwt.ErrSignatureInvalid
		}

		return []byte(secretKey), nil
	})
	if err != nil {
		return 0, false, false, errors.New("could not parse token")
	}

	tokenIsValid := parseToken.Valid

	if !tokenIsValid {
		return 0, false, false, errors.New("invalid token")
	}

	claims, ok := parseToken.Claims.(jwt.MapClaims)

	if !ok {
		return 0, false, false, errors.New("invalid token claims")
	}

	userId := uint(claims["user_id"].(float64))
	isAdmin := claims["isAdmin"].(bool)
	isMerchant := claims["isMerchant"].(bool)
	return userId, isAdmin, isMerchant, nil
}
