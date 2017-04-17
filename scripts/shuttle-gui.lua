local gui = {}

local Player = require("stdlib/player")

local get_left_gui = function(player)
    return player.gui.left["shuttle_train_left_frame"]
end

local get_shuttle_list = function(player)
    return player.gui.left["shuttle_train_left_frame"]
    and player.gui.left["shuttle_train_left_frame"]["shuttle_train_left_container"]
    and player.gui.left["shuttle_train_left_frame"]["shuttle_train_left_container"]["shuttle_train_shuttle_list"]
end

local get_station_list = function(player)
    return player.gui.left["shuttle_train_left_frame"]
    and player.gui.left["shuttle_train_left_frame"]["shuttle_train_left_container"]
    and player.gui.left["shuttle_train_left_frame"]["shuttle_train_left_container"]["shuttle_train_station_list"]
end

local get_filter = function (player)
    return get_left_gui(player)["shuttle_train_left_header_table"]["shuttle_train_left_header_filter"].text
end

local new_container = function(frame)
    local container = frame["shuttle_train_left_container"]
    if container then
        container.destroy()
    end
    return frame.add{type = "table", name = "shuttle_train_left_container", syle = "shuttle_train_left_frame", style = "shuttle_train_left_container", colspan = 1}
end

local lower, find = string.lower, string.find
local sort = table.sort

local sort_favorites = function(pdata, tab, surface, filter)
    local fav, reg = {}, {}
    --local _filter = function(station) return station.valid and station.backer_name:lower():find(filter) end

    local _sort = function (a, b) return a.backer_name < b.backer_name end

    for _, ent in pairs(tab) do
        --if ent.valid and ent.backer_name:lower():find(filter) then
        if ent.valid and ent.surface == surface and find(lower(ent.backer_name), filter) then
            if pdata.favorite_stations[ent.unit_number] then
                fav[#fav+1] = ent
            else
                reg[#reg+1] = ent
            end
        end
    end
    -- sort(fav, _sort)
    -- sort(reg, _sort)
    return fav, reg
end

-------------------------------------------------------------------------------
--[[Top Button]]--
-------------------------------------------------------------------------------
gui.enable_main_button = function(event)
    local player = game.players[event.player_index]
    if not player.gui.top["shuttle_train_top_button"] then
        player.gui.top.add{type="button",name="shuttle_train_top_button", style="shuttle_train_top_button", tooltip={"st-tooltip.top-button"}}
    end
end

gui.toggle_left_gui = function(event)
    local player = game.players[event.player_index]
    if get_left_gui(player) then
        gui.destroy_left_frame(event)
    else
        gui.get_or_create_left_frame(event)
    end
end

-------------------------------------------------------------------------------
--[[Left Frame Main]]--
-------------------------------------------------------------------------------
gui.destroy_left_frame = function(event)
    local player = game.players[event.player_index]
    local left = get_left_gui(player)
    if left then left.destroy() end
end

gui.get_or_create_left_frame = function(event)
    local player = game.players[event.player_index]
    local left = get_left_gui(player)
    if not left then

        left = player.gui.left.add{
            type = "frame",
            name = "shuttle_train_left_frame",
            style = "shuttle_train_left_frame",
            direction = "vertical"
        }

        local table = left.add{type = "table", name = "shuttle_train_left_header_table", colspan = 1}
        table.add{type = "label", name = "shuttle_train_left_header_label_title", caption = {"st-gui.title"}, style = "shuttle_train_left_label_title"}
        table.add{type = "textfield", name = "shuttle_train_left_header_filter", style = "shuttle_train_left_header_filter"}

        --shuttle_train_station_container
        --shuttle_train_shuttle_container

        -- Default create station buttons on creation
        gui.build_station_buttons(player)
    end
    return left
end

-------------------------------------------------------------------------------
--[[Station Frame]]--
-------------------------------------------------------------------------------
local _create_station_tables = function (list_table, unit_num, backer_name, name, locale, state)
    if not list_table["shuttle_train_station_list_header_label_"..name] then
        list_table.add{
            type = "label",
            name = "shuttle_train_station_list_header_label_"..name,
            caption = locale,
            style="shuttle_train_left_label_simple_text"
        }
    end
    local inner_frame = list_table["shuttle_train_station_list_scroll_frame_"..name]
    if not inner_frame then
        inner_frame = list_table.add{
            type = "frame",
            name = "shuttle_train_station_list_scroll_frame_"..name,
            direction = "vertical",
            style = "shuttle_train_station_list_scroll_frame"
        }
    end
    local scroll = inner_frame["shuttle_train_station_list_scroll_pane_"..name]
    if not scroll then
        scroll = inner_frame.add{
            type = "scroll-pane",
            name = "shuttle_train_station_list_scroll_pane_"..name,
            direction = "vertical",
            style = "shuttle_train_station_list_scroll_pane_"..name,
            horizontal_scroll_policy = "never"
        }
    end
    local table = scroll.add{
        type = "table",
        name = "shuttle_train_button_row_"..unit_num,
        colspan = 2,
        style = "shuttle_train_button_row"
    }
    table.add{
        type = "button",
        name = "shuttle_train_station_button_"..unit_num,
        caption = backer_name,
        style = "shuttle_train_station_button"
    }
    table.add{
        type = "checkbox",
        name = "shuttle_train_favorite_station_"..unit_num,
        state = state
    }
end

gui.build_station_buttons = function(player, next_index)
    local pdata = global.players[player.index]
    local fdata = global.forces[player.force.name]

    local frame = get_left_gui(player)
    if frame then
        local container = new_container(frame)

        local station_table = container.add{
            type = "table",
            name = "shuttle_train_station_list",
            direction = "vertical",
            colspan = 1,
            style = "shuttle_train_button_row"
        }

        -- local quotepattern = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
        -- local quote = function(str)
        -- return str:gsub(quotepattern, "%%%1")
        -- end
        local filter = get_filter(player):lower() or ".*"
        --replace in filter
        -- local _filter = function(station) return station.valid and station.backer_name:lower():find(filter) end

        --local stations = table.filter(fdata.stations, _filter)
        local fav, reg = sort_favorites(pdata, fdata.stations, player.surface, filter)

        local list_table = station_table.add{type = "table", name = "shuttle_train_left_frame_list_table_favorite", colspan = 1, style = "shuttle_train_button_row"}
        for _, station in pairs(fav) do
            _create_station_tables(list_table, station.unit_number, station.backer_name, "favorites", {"st-gui.favorite-stations"}, true)
        end
        list_table = station_table.add{type = "table", name = "shuttle_train_left_frame_list_table_stations", colspan = 1, style = "shuttle_train_button_row"}
        for _, station in pairs(reg) do
            _create_station_tables(list_table, station.unit_number, station.backer_name, "stations", {"st-gui.stations"}, false)
        end
        -- if #stations == 0 then
        -- station_table.add{
        -- type = "label",
        -- name = "shuttle_train_left_list_no_stations",
        -- caption = {"st-gui.no-stations"},
        -- style="shuttle_train_left_label_simple_text"
        -- }
        -- end
    end
end

gui.update_lists = function (event)
    for _, player in pairs(event.shuttle_force.players) do
        if event.list == "stations" and get_station_list(player) then
            gui.build_station_buttons(player)
        elseif event.list == "shuttles" and get_shuttle_list(player) then
            log("ignore this")
            --update for shuttles
        end
    end
end

Gui.on_checked_state_changed("shuttle_train_favorite_station_",
    function(event)
        local player, pdata = Player.get_object_and_data(event.player_index)
        pdata.favorite_stations[tonumber(event.element.name:match("%d+"))] = event.element.state or nil
        gui.build_station_buttons(player)
    end
)
Gui.on_checked_state_changed("shuttle_train_favorite_shuttle_",
    function(event)
        local player, pdata = Player.get_object_and_data(event.player_index)
        pdata.favorite_shuttles[tonumber(event.element.name:match("%d+"))] = event.element.state or nil
        gui.build_shuttle_buttons(player)
    end
)

Gui.on_text_changed("shuttle_train_left_header_filter",
    function(event)
        local player = game.players[event.player_index]
        --update for stations
        if get_station_list(player) then
            gui.build_station_buttons(player)
        elseif get_shuttle_list(player) then
            log("ignore this")
            --update for shuttles
        end
    end
)

Gui.on_click("shuttle_train_top_button", gui.toggle_left_gui)

return gui
