package main

import (
	"github.com/Sebiche09/app-anti-gaspillage.git/api/handlers"
	"github.com/Sebiche09/app-anti-gaspillage.git/db"
	_ "github.com/Sebiche09/app-anti-gaspillage.git/docs"
	"github.com/Sebiche09/app-anti-gaspillage.git/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	db := db.Init()
	h := handlers.NewHandlers(db)
	server := gin.Default()
	routes.RegisterRoutes(server, db, h)
	server.Run(":8080")
}
