local Shuttle = {}
Shuttle.gui = require("scripts/shuttle-gui")

local Position = require("stdlib/area/position")

local function is_shuttle(locomotive)
    if locomotive.name == "shuttle-train" then
        return locomotive
    else
        if locomotive.grid and locomotive.grid.equipment then
            return table.find(locomotive.grid.equipment, function(v) return v.name == "shuttle-train-equipment" end)
        end
    end
end

-- function front_mover_is_shuttle(front_movers)
-- return table.find(front_movers, function(v) return is_shuttle(v) end)
-- end

local available_train_states = {
    [defines.train_state.no_schedule] = true,
    [defines.train_state.no_path] = true,
    [defines.train_state.wait_station] = true,
    [defines.train_state.manual_control] = true,
}

local function call_nearest_shuttle(event)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    local locos = global.forces[player.force.name].locomotives
    local stations = global.forces[player.force.name].stations

    local closest_station, closest_train
    local station_distance, train_distance = 150, 2000000
    local filter = {area=Position.expand_to_area(player.position, station_distance) ,type="train-stop",force=player.force}

    for _, station in pairs(player.surface.find_entities_filtered(filter) or {}) do
        local distance = Position.distance(station.position, player.position)
        if distance < station_distance then
            closest_station = station
            station_distance = distance
        end
    end
    if closest_station then
        if player.vehicle and is_shuttle(player.vehicle) then
            closest_train = player.vehicle
            train_distance = Position.distance(closest_station.position, player.vehicle.position)
        else
            for _, loco in pairs(table.filter(locos, function(v) return v.valid and v.surface == player.surface and is_shuttle(v) end)) do
                local distance = Position.distance(loco.position, closest_station.position)
                if distance < train_distance then
                    if available_train_states[loco.train.state] then
                        closest_train = loco
                        train_distance = distance
                    end
                end
            end
        end
        if closest_train then
            if closest_train.train.state == defines.train_state.wait_station and closest_train.train.schedule.records[1].station == closest_station.backer_name then

                player.print("Train is already at the station")
            else
                local schedule = {current = 1, records = {[1] = {time_to_wait = 999, station = closest_station.backer_name}}}
                player.print({"shuttle-train.sending", closest_train.backer_name, closest_station.backer_name, math.ceil(train_distance)})
                closest_train.surface.create_entity{
                    name = "flying-text",
                    text = {"shuttle-train.train-enroute", closest_station.backer_name},
                    position = closest_train.position
                }
                closest_train.train.schedule = schedule
                closest_train.train.manual_mode = false
            end
        else
            player.print({"shuttle-train.no-train-found"})
        end
    else
        player.print({"shuttle-train.no-station-found"})
    end
end
Gui.on_click("shuttle_train_top_button", call_nearest_shuttle)
script.on_event("shuttle-train-call-nearest", call_nearest_shuttle)

local function on_player_driving_changed_state(event)
    local player = game.players[event.player_index]
    if player.vehicle and is_shuttle(player.vehicle) then
        --Spawn Gui

        --Set train to manual
        player.vehicle.train.manual_mode = true
    else
        --Destroy the gui
        --player.gui.left.shuttleTrain.destroy()
    end
end
Event.register(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)

--Charge equipment when it is placed
--Ask for grid to return the owner!
local function on_player_placed_equipment(event)
    if event.equipment.name == "farl-roboport" or event.equipment.name == "shuttle-train-equipment" then
        event.equipment.energy = 5000000000
    end
end
Event.register(defines.events.on_player_placed_equipment, on_player_placed_equipment)

local function death_events(event)
    if event.entity.type == "locomotive" then
        global.forces[event.entity.force.name].locomotives[event.entity.unit_number] = nil
    elseif event.entity.type == "train-stop" then
        global.forces[event.entity.force.name].stations[event.entity.unit_number] = nil
    end
end
Event.register(Event.death_events, death_events)

local function build_events(event)
    local entity = event.created_entity
    if entity.type == "locomotive" then
        global.forces[entity.force.name].locomotives[entity.unit_number] = entity
    elseif entity.type == "train-stop" then
        global.forces[entity.force.name].stations[entity.unit_number] = entity
    end
end
Event.register(Event.build_events, build_events)

local function enable_shuttle_button(event)
    if event.player_index and game.players[event.player_index].force.technologies["shuttle-train"].researched then
        Shuttle.gui.enable_main_button(event.player_index)
    elseif event.research and event.research.name == "shuttle-train" then
        for index in pairs(event.research.force.players) do
            Shuttle.gui.enable_main_button(index)
        end
    end
end
Event.register({defines.events.on_research_finished, defines.events.on_player_created}, enable_shuttle_button)

function Shuttle.init()
    local fdata = global.forces
    for _, surface in pairs(game.surfaces) do
        for _, loco in pairs(surface.find_entities_filtered{type="locomotive"}) do
            fdata[loco.force.name].locomotives[loco.unit_number] = loco
        end
        for _, stop in pairs(surface.find_entities_filtered{type="train-stop"}) do
            fdata[stop.force.name].stations[stop.unit_number] = stop
        end
    end
end

return Shuttle
