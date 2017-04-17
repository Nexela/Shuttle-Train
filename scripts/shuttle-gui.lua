local gui = {}

local get_left_gui = function(player)
    return player.gui.left["shuttle_train_left_frame"]
end

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
        gui.create_left_frame(event)
    end
end

gui.destroy_left_frame = function(event)
    local player = game.players[event.player_index]
    local left = get_left_gui(player)
    if left then left.destroy() end
end

gui.create_left_frame = function(event)
    local player = game.players[event.player_index]
    local left = get_left_gui(player)
    if not left then

        left = player.gui.left.add{type = "frame", name = "shuttle_train_left_frame", direction = "vertical", style = "shuttle_train_left_frame"}

        left.add{type = "label", name = "shuttle_train_left_label_title", caption = {"st-gui.title"}, style = "shuttle_train_left_label_title"}
        left.add{type = "textfield", name = "shuttle_train_left_filter_textfield", style = "shuttle_train_left_filter_textfield"}

        left.add{type = "table", name = "shuttle_train_left_frame_list", direction = "vertical", colspan = 1}
        --style = "shuttle_train_left_scroll_frame"

        gui.build_station_buttons({player_index = event.player_index})
    end
    return left
end

gui.build_station_buttons = function(event)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    local fdata = global.forces[player.force.name]

    local frame = gui.create_left_frame(event)["shuttle_train_left_frame_list"]
    table.each(frame.children_names, function(v) frame[v].destroy() end)

    local filter = event.filter or (event.element and event.element.name == "shuttle_train_left_filter_textfield" and event.element.text) or ".*"
    local _filter = function(station) return station.valid and station.backer_name:lower():find(filter:lower()) end

    local _favorite = function(station) return pdata.favorite_stations[station.unit_number] end
    local _stations = function(station) return not pdata.favorite_stations[station.unit_number] end
    local _sort = function (a, b) return a.backer_name < b.backer_name end

    local _create_station_tables = function (list_table, station, name, locale, state)
        if not list_table["shuttle_train_left_list_header_label_"..name] then
            list_table.add{
                type = "label",
                name = "shuttle_train_left_list_header_label_"..name,
                caption = locale,
                style="shuttle_train_left_label_simple_text"
            }
        end
        local inner_frame = list_table["shuttle_train_left_list_scroll_frame_"..name]
        if not inner_frame then
            inner_frame = list_table.add{
                type = "frame",
                name = "shuttle_train_left_list_scroll_frame_"..name,
                direction = "vertical",
                style = "shuttle_train_left_list_scroll_frame"
            }
        end
        local scroll = inner_frame["shuttle_train_left_list_scroll_pane_"..name]
        if not scroll then
            scroll = inner_frame.add{
                type = "scroll-pane",
                name = "shuttle_train_left_list_scroll_pane_"..name,
                direction = "vertical",
                style = "shuttle_train_left_list_scroll_pane_"..name,
                horizontal_scroll_policy = "never"
            }
        end
        local table = scroll.add{
            type = "table",
            name = "shuttle_train_button_row_"..station.unit_number,
            colspan = 2,
            style = "shuttle_train_button_row"
        }
        table.add{
            type = "button",
            name = "shuttle_train_station_button_"..station.unit_number,
            caption = station.backer_name,
            style = "shuttle_train_station_button"
        }
        local test = table.add{
            type = "checkbox",
            name = "shuttle_train_favorite_"..station.unit_number,
            state = state
        }
        -- test.style.top_padding = 0
        -- test.style.bottom_padding = 0
    end

    local stations = table.filter(fdata.stations, _filter)
    table.sort(stations, _sort)
    local list_table = frame.add{type = "table", name = "shuttle_train_left_frame_list_table_favorite", colspan = 1, style = "shuttle_train_button_row"}
    for _, station in pairs(table.filter(stations, _favorite)) do
        _create_station_tables(list_table, station, "favorites", {"st-gui.favorite-stations"}, true)
    end
    list_table = frame.add{type = "table", name = "shuttle_train_left_frame_list_table_stations", colspan = 1, style = "shuttle_train_button_row"}
    for _, station in pairs(table.filter(stations, _stations)) do
        _create_station_tables(list_table, station, "stations", {"st-gui.stations"}, false)
    end
end

Gui.on_checked_state_changed("shuttle_train_favorite", function(event)
        global.players[event.player_index].favorite_stations[tonumber(event.element.name:match("%d+"))] = event.element.state or nil
    end)

Gui.on_text_changed("shuttle_train_left_filter_textfield", gui.build_station_buttons)
return gui
