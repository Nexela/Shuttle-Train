local gui = {}

gui.enable_main_button = function(event)
    local player = game.players[event.player_index]
    if not player.gui.top["shuttle_train_top_button"] then
        player.gui.top.add{type="button",name="shuttle_train_top_button", style="shuttle_train_top_button", tooltip={"st-tooltip.top-button"}}
    end
end

gui.destroy_left_frame = function(event)
    local player = game.players[event.player_index]
    local left = player.gui.left.shuttle_train_left_frame
    if left then left.destroy() end
end

gui.create_left_frame = function(event)
    local player = game.players[event.player_index]
    local left = player.gui.left.shuttle_train_left_frame
    if not left then

        left = player.gui.left.add{type = "frame", name = "shuttle_train_left_frame", direction = "vertical", style = "shuttle_train_left_frame"}

        left.add{type = "label", name = "shuttle_train_left_label_title", caption = {"st-gui.title"}, style = "shuttle_train_left_label_title"}
        left.add{type = "textfield", name = "shuttle_train_left_filter_textfield", style = "shuttle_train_left_filter_textfield"}

        local frame = left.add{type = "frame", name = "shuttle_train_left_scroll_frame", direction = "vertical", style = "shuttle_train_left_scroll_frame"}
        --frame.add{type = "scroll-pane", name = "shuttle_train_left_scroll_pane", direction = "vertical", style = "shuttle_train_left_scroll_pane", horizontal_scroll_policy = "never"}

        gui.build_station_buttons({player_index = event.player_index})
    end
    return left
end

gui.build_station_buttons = function(event)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    local fdata = global.forces[player.force.name]
    local frame = gui.create_left_frame({player_index = event.player_index})["shuttle_train_left_scroll_frame"]
    table.each(frame.children_names, function(v) frame[v].destroy() end)
    local favorites = frame.add{
        type = "scroll-pane",
        name = "shuttle_train_left_scroll_pane_favorite",
        direction = "vertical",
        style = "shuttle_train_left_scroll_pane",
        horizontal_scroll_policy = "never"
    }
    local scroll = frame.add{
        type = "scroll-pane",
        name = "shuttle_train_left_scroll_pane",
        direction = "vertical",
        style = "shuttle_train_left_scroll_pane",
        horizontal_scroll_policy = "never"
    }
    local filter = event.filter or (event.element and event.element.name == "shuttle_train_left_filter_textfield" and event.element.textfield) or ".*"
    local _filter = function(station) return station.valid and station.backer_name:lower():find(filter:lower()) end
    local _sort = function (a, b) return a.backer_name < b.backer_name end

    local stations = table.filter(fdata.stations, _filter)
    table.sort(stations, _sort)

    for _, station in pairs(stations) do
        if pdata.favorite_stations[station.unit_number] then
            local table = favorites.add{type = "table", name = "shuttle_train_button_row_"..station.unit_number, colspan = 2}
            table.add{type = "button", name = "shuttle_train_station_button_"..station.unit_number, caption = station.backer_name, style = "shuttle_train_station_button"}
            table.add{type = "checkbox", name = "shuttle_train_favorite_"..station.unit_number, state = true}
        else
            local table = scroll.add{type = "table", name = "shuttle_train_button_row_"..station.unit_number, colspan = 2}
            table.add{type = "button", name = "shuttle_train_station_button_"..station.unit_number, caption = station.backer_name, style = "shuttle_train_station_button"}
            table.add{type = "checkbox", name = "shuttle_train_favorite_"..station.unit_number, state = false}
        end
    end
    if not (next(scroll.children_names) or next(favorites.children_names)) then
        scroll.add{type = "label", name = "shuttle_train_no_stations", caption = {"st-gui.no-stations"}, style = "shuttle_train_left_label_title"}
    end
end

Gui.on_checked_state_changed("shuttle_train_favorite", function(event)
        global.players[event.player_index].favorite_stations[tonumber(event.element.name:match("%d+"))] = event.element.state or nil
    end)

Gui.on_text_changed("shuttle_train_left_filter_textfield", gui.build_station_buttons)
return gui
