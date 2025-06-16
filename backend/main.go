package main

import (
	"log"
	"time"

	"github.com/Sebiche09/app-anti-gaspillage.git/api/handlers"
	"github.com/Sebiche09/app-anti-gaspillage.git/db"
	_ "github.com/Sebiche09/app-anti-gaspillage.git/docs"
	"github.com/Sebiche09/app-anti-gaspillage.git/routes"
	"github.com/joho/godotenv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("⚠️ Fichier .env non trouvé. Les variables d'environnement ne seront pas chargées.")
	}
	db := db.Init()
	h := handlers.NewHandlers(db)
	server := gin.Default()

	server.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	routes.RegisterRoutes(server, db, h)
	server.Run(":8080")
}
