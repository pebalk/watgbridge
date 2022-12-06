package main

import (
	"log"
	"os"
	"time"

	"watgbridge/database"
	"watgbridge/state"
	"watgbridge/telegram"
	"watgbridge/utils"
	"watgbridge/whatsapp"
)

func main() {
	// Load config file
	cfg := state.State.Config
	if len(os.Args) > 1 {
		cfg.Path = os.Args[1]
	} else {
		cfg.Path = "config.yaml"
	}
	cfg.LoadConfig()

	if cfg.TimeZone == "" {
		cfg.TimeZone = "Asia/Kolkata"
	}

	localLoc, err := time.LoadLocation(cfg.TimeZone)
	if err != nil {
		log.Fatalln("Couldn't set timezone to " + cfg.TimeZone + ": " + err.Error())
	}
	state.State.LocalLocation = localLoc

	db, err := database.Connect()
	if err != nil {
		log.Fatalln("Couldn't connect to the database : " + err.Error())
	}
	state.State.Database = db

	err = database.AutoMigrate()
	if err != nil {
		log.Fatalln("Couldn't migrate the database tables : " + err.Error())
	}

	err = telegram.NewClient()
	if err != nil {
		panic(err)
	}
	log.Printf(
		"[telegram] logged in as : %s [ @%s ]\n",
		state.State.TelegramBot.FirstName,
		state.State.TelegramBot.Username,
	)

	err = whatsapp.NewClient()
	if err != nil {
		panic(err)
	}
	log.Printf(
		"[whatsapp] logged in as : %s [ %s ]\n",
		state.State.WhatsAppClient.Store.PushName,
		state.State.WhatsAppClient.Store.ID.User,
	)

	state.State.StartTime = time.Now()

	waClient := state.State.WhatsAppClient
	waClient.AddEventHandler(whatsapp.WhatsAppEventHandler)

	telegram.AddHandlers()
	utils.RegisterBotCommand(state.State.TelegramBot, state.State.TelegramCommands...)

	state.State.TelegramUpdater.Idle()
}
