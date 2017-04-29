require("stdlib")

MOD = {}
MOD.name = "ShuttleTrain2"
MOD.if_name = "shuttle"
MOD.fullname = "ShuttleTrain2"
MOD.config = require("config")
MOD.version = "2.0.0"
MOD.logfile = Logger.new(MOD.fullname, "log", MOD.config.DEBUG or false, {log_ticks = true, file_extension = "lua"})
MOD.logfile.file_name = MOD.logfile.file_name:gsub("logs/", "", 1)
MOD.log = require("stdlib.debug.debug")
MOD.interface = require("interface")

local Player = require("stdlib/player")
local Force = require("stdlib/force")

local Changes = require("changes")
Event.register(Event.core_events.configuration_changed, Changes.on_configuration_changed)

local function on_init()
    global._changes = Changes.on_init(game.active_mods[MOD.name] or "0.0.0")
    Player.init()
    Force.init()
end
Event.register(Event.core_events.init, on_init)

require("scripts/shuttle-train")

local interface = MOD.interface
remote.add_interface(MOD.if_name, interface)
