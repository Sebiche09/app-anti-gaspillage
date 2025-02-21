// Package docs Code generated by swaggo/swag. DO NOT EDIT
package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "contact": {},
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/api/auth/login": {
            "post": {
                "description": "Authenticate a user using email and password",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Users"
                ],
                "summary": "Authenticate user",
                "parameters": [
                    {
                        "description": "User credentials",
                        "name": "credentials",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/requests.LoginRequest"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "allOf": [
                                    {
                                        "type": "string"
                                    },
                                    {
                                        "type": "object",
                                        "properties": {
                                            "token": {
                                                "type": "string"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    }
                }
            }
        },
        "/api/auth/signup": {
            "post": {
                "description": "Create a user with the provided details",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Users"
                ],
                "summary": "Create a new user",
                "parameters": [
                    {
                        "description": "User data",
                        "name": "user",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/requests.RegisterRequest"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "$ref": "#/definitions/models.User"
                        }
                    }
                }
            }
        },
        "/api/baskets": {
            "get": {
                "description": "Retrieve a list of all baskets",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Baskets"
                ],
                "summary": "Get all baskets",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/models.Basket"
                            }
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    }
                }
            },
            "post": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "Create a new basket with the provided details",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Baskets"
                ],
                "summary": "Create a new basket",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Bearer token",
                        "name": "Authorization",
                        "in": "header",
                        "required": true
                    },
                    {
                        "description": "Basket data",
                        "name": "basket",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/models.Basket"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "$ref": "#/definitions/models.Basket"
                        }
                    },
                    "400": {
                        "description": "Bad request, invalid input",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    }
                }
            }
        },
        "/api/baskets/{id}": {
            "get": {
                "description": "Retrieve a basket by its ID",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Baskets"
                ],
                "summary": "Get a single basket",
                "parameters": [
                    {
                        "type": "integer",
                        "description": "Basket ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/models.Basket"
                        }
                    },
                    "400": {
                        "description": "Invalid basket ID",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "404": {
                        "description": "Basket not found",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    }
                }
            },
            "put": {
                "description": "Update a basket by its ID",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Baskets"
                ],
                "summary": "Update a basket",
                "parameters": [
                    {
                        "type": "integer",
                        "description": "Basket ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    },
                    {
                        "description": "Basket data",
                        "name": "basket",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/models.Basket"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/models.Basket"
                        }
                    },
                    "400": {
                        "description": "Invalid basket ID or input",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "403": {
                        "description": "Not authorized to update this basket",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "404": {
                        "description": "Basket not found",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    }
                }
            },
            "delete": {
                "security": [
                    {
                        "BearerAuth": []
                    }
                ],
                "description": "Delete a basket by its ID",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "Baskets"
                ],
                "summary": "Delete a basket",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Bearer token",
                        "name": "Authorization",
                        "in": "header",
                        "required": true
                    },
                    {
                        "type": "integer",
                        "description": "Basket ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "204": {
                        "description": "No Content"
                    },
                    "400": {
                        "description": "Invalid basket ID",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "403": {
                        "description": "Not authorized to delete this basket",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "404": {
                        "description": "Basket not found",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "type": "object",
                            "additionalProperties": {
                                "type": "string"
                            }
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "gorm.DeletedAt": {
            "type": "object",
            "properties": {
                "time": {
                    "type": "string"
                },
                "valid": {
                    "description": "Valid is true if Time is not NULL",
                    "type": "boolean"
                }
            }
        },
        "models.Basket": {
            "type": "object",
            "required": [
                "name",
                "original_price",
                "price",
                "quantity",
                "type"
            ],
            "properties": {
                "createdAt": {
                    "type": "string"
                },
                "deletedAt": {
                    "$ref": "#/definitions/gorm.DeletedAt"
                },
                "description": {
                    "type": "string"
                },
                "expiration_date": {
                    "type": "string"
                },
                "id": {
                    "type": "integer"
                },
                "name": {
                    "type": "string"
                },
                "original_price": {
                    "type": "number"
                },
                "price": {
                    "type": "number"
                },
                "quantity": {
                    "type": "integer"
                },
                "restaurant": {
                    "$ref": "#/definitions/models.Restaurant"
                },
                "restaurant_id": {
                    "type": "integer"
                },
                "type": {
                    "type": "string"
                },
                "updatedAt": {
                    "type": "string"
                }
            }
        },
        "models.Merchant": {
            "type": "object",
            "required": [
                "business_name",
                "email_pro",
                "siret"
            ],
            "properties": {
                "business_name": {
                    "description": "Nom de l'entreprise",
                    "type": "string"
                },
                "createdAt": {
                    "type": "string"
                },
                "deletedAt": {
                    "$ref": "#/definitions/gorm.DeletedAt"
                },
                "email_pro": {
                    "description": "Email valide requis",
                    "type": "string"
                },
                "id": {
                    "type": "integer"
                },
                "identity_card_file": {
                    "description": "Optionnel : fichier Carte d'identité",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "kbis_file": {
                    "description": "Optionnel : fichier KBIS",
                    "type": "array",
                    "items": {
                        "type": "integer"
                    }
                },
                "phone_number": {
                    "description": "Numéro de téléphone (optionnel, max 15 caractères)",
                    "type": "string"
                },
                "siret": {
                    "description": "Numéro SIRET",
                    "type": "string"
                },
                "updatedAt": {
                    "type": "string"
                },
                "user": {
                    "description": "Relation vers User (clé étrangère avec cascade)",
                    "allOf": [
                        {
                            "$ref": "#/definitions/models.User"
                        }
                    ]
                },
                "user_id": {
                    "description": "Relation 1 à 1 vers User",
                    "type": "integer"
                }
            }
        },
        "models.Restaurant": {
            "type": "object",
            "properties": {
                "address": {
                    "description": "Adresse complète",
                    "type": "string"
                },
                "city": {
                    "description": "Ville",
                    "type": "string"
                },
                "createdAt": {
                    "type": "string"
                },
                "deletedAt": {
                    "$ref": "#/definitions/gorm.DeletedAt"
                },
                "id": {
                    "type": "integer"
                },
                "merchant": {
                    "description": "Relation avec le commerçant",
                    "allOf": [
                        {
                            "$ref": "#/definitions/models.Merchant"
                        }
                    ]
                },
                "merchant_id": {
                    "description": "ID du commerçant (clé étrangère)",
                    "type": "integer"
                },
                "name": {
                    "description": "Nom du restaurant (obligatoire)",
                    "type": "string"
                },
                "phone_number": {
                    "description": "Numéro de téléphone (optionnel, max 15 caractères)",
                    "type": "string"
                },
                "postal_code": {
                    "description": "Code postal (limité à 10 caractères pour compatibilité internationale)",
                    "type": "string"
                },
                "siren": {
                    "description": "SIREN (exactement 9 chiffres, unique)",
                    "type": "string"
                },
                "updatedAt": {
                    "type": "string"
                }
            }
        },
        "models.User": {
            "type": "object",
            "required": [
                "email",
                "full_name",
                "password_hash",
                "phone"
            ],
            "properties": {
                "createdAt": {
                    "type": "string"
                },
                "deletedAt": {
                    "$ref": "#/definitions/gorm.DeletedAt"
                },
                "email": {
                    "description": "Validation d'email",
                    "type": "string"
                },
                "full_name": {
                    "description": "Nom complet requis",
                    "type": "string"
                },
                "id": {
                    "type": "integer"
                },
                "is_admin": {
                    "description": "Est-ce un administrateur ?",
                    "type": "boolean"
                },
                "password_hash": {
                    "description": "Hash du mot de passe",
                    "type": "string"
                },
                "phone": {
                    "description": "Téléphone requis",
                    "type": "string"
                },
                "updatedAt": {
                    "type": "string"
                }
            }
        },
        "requests.LoginRequest": {
            "type": "object",
            "required": [
                "email",
                "password"
            ],
            "properties": {
                "email": {
                    "type": "string",
                    "example": "user@example.com"
                },
                "password": {
                    "type": "string",
                    "example": "password123"
                }
            }
        },
        "requests.RegisterRequest": {
            "type": "object",
            "required": [
                "email",
                "full_name",
                "password",
                "phone"
            ],
            "properties": {
                "email": {
                    "type": "string",
                    "example": "user@example.com"
                },
                "full_name": {
                    "type": "string",
                    "example": "patrick"
                },
                "password": {
                    "type": "string",
                    "minLength": 8,
                    "example": "password123"
                },
                "phone": {
                    "type": "string",
                    "example": "+32460232425"
                }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "",
	Host:             "",
	BasePath:         "",
	Schemes:          []string{},
	Title:            "",
	Description:      "",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
	LeftDelim:        "{{",
	RightDelim:       "}}",
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
