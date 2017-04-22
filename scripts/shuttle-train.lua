-------------------------------------------------------------------------------
--[[Shuttle Trains]]--
-------------------------------------------------------------------------------
local Shuttle = {}
Shuttle.gui = require("scripts/shuttle-gui")

local Player = require("stdlib/player")
local Force = require("stdlib/force")

local Position = require("stdlib/area/position")
--local Trains = require("stdlib.trains.trains")

-------------------------------------------------------------------------------
--[[Helpers]]--
-------------------------------------------------------------------------------

--vehicle.train errors if vehicle is not a train type.
local function get_train(entity)
    local ok, result = pcall(function(e) return e.train end, entity)
    if ok then return result end
end

--return object carriage if shuttle
local function is_shuttle(locomotive)
    if locomotive and locomotive.grid then
        return table.find(locomotive.grid.equipment, function(v) return v.name == "shuttle-train-equipment" end)
    end
end

--return object carriage if shuttle, checks all carriages
local function is_shuttle_train(locomotive)
    if locomotive then
        local train = get_train(locomotive)
        return train and table.find(train.carriages, is_shuttle)
    end
end

-- Return a table of all passengers on a train, or nil if no passengers
local function get_passengers(train)
    local passengers = table.filter(train.carriages, function(carriage) return carriage.passenger end)
    return passengers[1] and passengers
end

local available_train_states = {
    [defines.train_state.no_schedule] = true,
    [defines.train_state.no_path] = true,
    [defines.train_state.wait_station] = true,
    [defines.train_state.manual_control] = true,
}
local finished_train_states = {
    [defines.train_state.no_schedule] = true,
    [defines.train_state.manual_control] = true,
    [defines.train_state.wait_station] = true,
    [defines.train_state.manual_control_stop] = true,
    [defines.train_state.manual_control] = true,
}

-------------------------------------------------------------------------------
--[[Call shuttle]]--
-------------------------------------------------------------------------------
local function call_nearest_shuttle(event)
    local player, pdata = Player.get_object_and_data(event.player_index)
    local locos = global.forces[player.force.name].locomotives
    --local stations = global.forces[player.force.name].stations

    local closest_station = event.station and event.station.valid and event.station
    local closest_shuttle = event.shuttle and event.shuttle.valid and event.shuttle
    local schedule = event.schedule

    local station_distance, train_distance = 150, 2000000
    local filter = {area=Position.expand_to_area(player.position, station_distance), type="train-stop", force=player.force}

    if not closest_station then
        if player.selected and player.selected.type == "train-stop" then
            closest_station = player.selected
        else
            for _, station in pairs(player.surface.find_entities_filtered(filter) or {}) do
                local distance = Position.distance(station.position, player.position)
                if distance < station_distance then
                    closest_station = station
                    station_distance = distance
                end
            end
        end
    end

    local find_shuttle = function(v)
        local busy = global.shuttles[v.unit_number]
        local lost = global.lost_shuttles[v.unit_number]
        return v.valid and v.surface == player.surface and is_shuttle(v)
        and not busy and (not lost or game.tick >= lost)
    end

    if closest_station then

        if not closest_shuttle then
            if player.vehicle and is_shuttle_train(player.vehicle) then
                closest_shuttle = player.vehicle
                train_distance = Position.distance(closest_station.position, player.vehicle.position)
            else
                for _, loco in pairs(table.filter(locos, find_shuttle)) do
                    local distance = Position.distance(loco.position, closest_station.position)
                    if distance < train_distance then
                        if available_train_states[loco.train.state] then
                            closest_shuttle = loco
                            train_distance = distance
                        end
                    end
                end
            end
        end

        if closest_shuttle then
            if closest_shuttle.train.state == defines.train_state.wait_station and closest_shuttle.train.station == closest_station then
                player.print({"shuttle-train.already-at-station", closest_station.backer_name})
            else
                schedule = schedule or {current = 1, records = {[1] = {time_to_wait = 999, station = closest_station.backer_name}}}
                player.print({"shuttle-train.sending", closest_shuttle.backer_name, closest_station.backer_name, math.ceil(train_distance)})
                pdata.last_shuttle = closest_shuttle
                closest_shuttle.surface.create_entity{
                    name = "flying-text",
                    text = {"shuttle-train.train-enroute", closest_station.backer_name},
                    position = closest_shuttle.position
                }
                closest_station.surface.create_entity{
                    name = "flying-text",
                    text = {"shuttle-train.train-enroute-station", closest_shuttle.backer_name},
                    position = closest_shuttle.position
                }
                closest_shuttle.train.schedule = schedule
                closest_shuttle.train.manual_mode = false
                global.lost_shuttles[closest_shuttle.unit_number] = nil
                global.shuttles[closest_shuttle.unit_number] = {
                    player_index = player.index,
                    shuttle = closest_shuttle,
                    shuttle_name = closest_shuttle.backer_name,
                    station = closest_station,
                    station_name = closest_station.backer_name,
                    schedule = schedule,
                    scheduled_tick = game.tick
                }
            end
        else
            player.print({"shuttle-train.no-train-found"})
        end
    else
        player.print({"shuttle-train.no-station-found"})
    end
end

script.on_event({"shuttle-train-call-nearest"}, call_nearest_shuttle)
Event.register(Event.call_shuttle, call_nearest_shuttle)

local function on_train_changed_state(event)
    local train = event.train
    if train.state == (defines.train_state.no_path or defines.train_state.path_lost) and #train.schedule.records == 1 then
        local shuttle = table.find(train.carriages, function(v) return global.shuttles[v.unit_number] end)
        if shuttle then
            local shuttle_data = global.shuttles[shuttle.unit_number]
            if shuttle_data then
                local player = game.players[shuttle_data.player_index] or shuttle.force
                player.print({"shuttle-train.no-route-retrying", shuttle_data.shuttle_name, shuttle_data.station_name})
            end
            shuttle.surface.create_entity{
                name = "flying-text",
                text = {"shuttle-train.no-route"},
                color = defines.colors.red,
                position = {shuttle.position.x, shuttle.position.y + .25}
            }
            global.shuttles[shuttle.unit_number].shuttle = nil
            if not get_passengers(train) then
                call_nearest_shuttle(global.shuttles[shuttle.unit_number])
            end
            --Free up the train
            train.manual_mode = true
            global.shuttles[shuttle.unit_number] = nil
            --Ignore this shuttle for the next 60 ticks.
            global.lost_shuttles[shuttle.unit_number] = game.tick + 60
        end
    elseif finished_train_states[train.state] then
        local shuttle = table.find(train.carriages, function(v) return global.shuttles[v.unit_number] end)
        if shuttle then
            global.shuttles[shuttle.unit_number] = nil
            shuttle.surface.create_entity{
                name = "flying-text",
                text = {"shuttle-train.arrived"},
                color = defines.colors.green,
                position = shuttle.position
            }
        end
    end
end
Event.register(defines.events.on_train_changed_state, on_train_changed_state)

-------------------------------------------------------------------------------
--[[Spawn GUIs]]--
-------------------------------------------------------------------------------
local function enable_shuttle_button(event)
    --Shuttle.gui.toggle_left_gui(event)
    if event.name == defines.events.on_player_created and event.player_index then
        Shuttle.gui.get_or_create_left_flow(event).style.visible = false
        if game.players[event.player_index].force.technologies["shuttle-train"].researched then
            Shuttle.gui.enable_main_button(event)
        end
    elseif event.research and event.research.name == "shuttle-train" then
        for index in pairs(event.research.force.players) do
            Shuttle.gui.enable_main_button({player_index = index})
        end
    end
end
---
Event.register({defines.events.on_research_finished, defines.events.on_player_created}, enable_shuttle_button)

local function on_player_driving_changed_state(event)
    local player = game.players[event.player_index]
    if player.vehicle and is_shuttle_train(player.vehicle) then
        Shuttle.gui.get_or_create_left_flow(event).style.visible = true
        --Set train to manual
        if not global.shuttles[player.vehicle.unit_number] then
            player.vehicle.train.manual_mode = true
        end
    else
        Shuttle.gui.get_or_create_left_flow(event).style.visible = false
        --Shuttle.gui.destroy_left_frame(event)
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

-------------------------------------------------------------------------------
--[[on_built/removed]]--
-------------------------------------------------------------------------------
local function death_events(event)
    local entity = event.entity
    if entity.type == "locomotive" then
        global.forces[entity.force.name].locomotives[entity.unit_number] = nil
        global.shuttles[entity.unit_number] = nil
        table.each(entity.force.players,
            function(p)
                Shuttle.gui.remove_list_row(global.players[p.index], entity.unit_number)
            end
        )
    elseif event.entity.type == "train-stop" then
        global.forces[entity.force.name].stations[entity.unit_number] = nil
        table.each(entity.force.players,
            function(p)
                Shuttle.gui.remove_list_row(global.players[p.index], entity.unit_number)
            end
        )
    end
end
Event.register(Event.death_events, death_events)

local function build_events(event)
    local entity = event.created_entity
    if entity.type == "locomotive" then
        global.forces[entity.force.name].locomotives[entity.unit_number] = entity
    elseif entity.type == "train-stop" then
        global.forces[entity.force.name].stations[entity.unit_number] = entity
        table.each(entity.force.players,
            function(p)
                local filter = global.players[p.index].gui.filter.text:lower()
                local scroll = global.players[p.index].gui.stations.reg_scroll
                if scroll and scroll.valid then
                    local row = Shuttle.gui.add_list_row(scroll, entity.unit_number, entity.backer_name, false)
                    row.style.visible = row.caption:lower():find(filter) and true or false
                end
            end
        )
    end
end
Event.register(Event.build_events, build_events)

-------------------------------------------------------------------------------
--[[Init]]--
-------------------------------------------------------------------------------
function Shuttle.migrate()
    local fdata = global.forces
    for _, surface in pairs(game.surfaces) do
        for _, loco in pairs(surface.find_entities_filtered{type="locomotive"}) do
            fdata[loco.force.name].locomotives[loco.unit_number] = loco
            log(loco.force.name)
        end
        for _, stop in pairs(surface.find_entities_filtered{type="train-stop"}) do
            fdata[stop.force.name].stations[stop.unit_number] = stop
        end
    end
end

function Shuttle.init()
    global.shuttles = {}
    global.lost_shuttles = {}
    Force.add_data_all{
        locomotives = {},
        stations = {}
    }

    Shuttle.migrate()
    table.each(game.players, function(v) enable_shuttle_button({player_index=v.index}) end)
end

return Shuttle
