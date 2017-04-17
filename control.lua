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

Event.death_events = {defines.events.on_entity_died, defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined}
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}

local Shuttle = require("scripts/shuttle-train")

local changes = require("changes")
Event.register(Event.core_events.configuration_changed, changes.on_configuration_changed)

local function on_init()
    global._changes = changes.on_init(game.active_mods[MOD.name] or MOD.version)
    Shuttle.init()
    MOD.log("Shuttle Train is now installed", 2)
end
Event.register(Event.core_events.init, on_init)

local interface = require("interface")
remote.add_interface(MOD.if_name, interface)
