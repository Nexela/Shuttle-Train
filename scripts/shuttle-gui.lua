local gui = {}

local Player = require("stdlib/player")

local get_left_gui = function(player)
    return player.gui.left["shuttle_train_left_flow"]
end

-- local get_filter = function (player)
-- return get_left_gui(player)["shuttle_train_left_header_table"]["shuttle_train_left_header_filter"].text
-- end
--
-- local sort_favorites = function(pdata, tab, surface, filter)
-- local fav, reg = {}, {}
-- local _filter = function(station) return station.valid and station.backer_name:lower():find(filter) end
--
-- local _sort = function (a, b) return a.backer_name < b.backer_name end
--
-- for _, ent in pairs(tab) do
-- --if ent.valid and ent.backer_name:lower():find(filter) then
-- if ent.valid and ent.surface == surface and ent.backer_name:lower():find(filter) then
-- if pdata.favorite_stations[ent.unit_number] then
-- fav[#fav+1] = ent
-- else
-- reg[#reg+1] = ent
-- end
-- end
-- end
-- sort(fav, _sort)
-- sort(reg, _sort)
-- return fav, reg
-- end

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
    gui.get_or_create_left_flow(event).style.visible = not gui.get_or_create_left_flow(event).style.visible
end

-------------------------------------------------------------------------------
--[[Left Frame Main]]--
-------------------------------------------------------------------------------
gui.destroy_left_frame = function(event)
    local left = get_left_gui(game.players[event.player_index])
    if left then left.destroy() end
end

gui.get_or_create_left_flow = function(event)
    local player, pdata = Player.get_object_and_data(event.player_index)
    local fdata = global.forces[player.force.name]
    local left = get_left_gui(player)
    if not left then
        pdata.gui = {}
        --Create the main flow
        left = player.gui.left.add{
            type = "flow",
            name = "shuttle_train_left_flow",
            direction = "horizontal"
        }

        --Create the main frame window
        local frame = left.add{
            type = "frame",
            name = "shuttle_train_left_frame",
            style = "shuttle_train_left_frame",
            direction = "vertical"
        }

        --Create the header tables
        local tab = frame.add{type = "table", name = "shuttle_train_left_header_table", colspan = 1}
        tab.add{type = "label", name = "shuttle_train_left_header_label_title", caption = {"st-gui.title"}, style = "shuttle_train_left_label_title"}
        local filter = tab.add{type = "textfield", name = "shuttle_train_left_header_filter", style = "shuttle_train_left_header_filter"}
        pdata.gui.filter = filter

        --Create station and shuttle containers
        gui._create_list_container(frame, "stations", pdata) --shuttle_train_station_container
        gui._create_list_container(frame, "shuttles", pdata).style.visible = false --shuttle_train_shuttle_container

        --Set up favorites tables
        pdata.favorite_stations = {}
        pdata.favorite_shuttles = {}

        --Hide empty favorites
        pdata.gui.stations.fav.style.visible = false

        --Populate existing stations
        table.each(fdata.stations,
            function(station)
                gui.add_list_row(pdata.gui.stations["reg_scroll"], station.unit_number, station.backer_name, false)
            end
        )
    end
    return left
end

-------------------------------------------------------------------------------
--[[Station Frame]]--
-------------------------------------------------------------------------------
gui._create_list_container = function(frame, name, pdata)
    --Create main container for "name"
    local container = frame.add{
        type = "table",
        name = "shuttle_train_left_container_"..name,
        style = "shuttle_train_left_container",
        colspan = 1
    }

    pdata.gui[name] = {}
    pdata.gui[name].container = container
    pdata.gui[name]["fav"], pdata.gui[name]["fav_scroll"] = gui._create_list_tables(container, "favorites", {"st-gui.favorite-stations"}, true)
    pdata.gui[name]["reg"], pdata.gui[name]["reg_scroll"] = gui._create_list_tables(container, "stations", {"st-gui.stations"}, true)

    return container
end

gui._create_list_tables = function (container, name, locale)
    local list_table = container.add{
        type = "table",
        name = container.name.."_list_header_table_"..name,
        style = "shuttle_train_button_row",
        colspan = 1
    }
    list_table.add{
        type = "label",
        name = container.name.."_list_header_label_"..name,
        caption = locale,
        style="shuttle_train_left_label_simple_text"
    }
    local inner_frame = list_table.add{
        type = "frame",
        name = container.name.."_list_frame_"..name,
        direction = "vertical",
        style = "shuttle_train_left_container_frame"
    }
    local scroll = inner_frame.add{
        type = "scroll-pane",
        name = container.name.."_list_frame_scroll_"..name,
        direction = "vertical",
        style = "shuttle_train_left_container_scroll_"..name,
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "always"
    }
    return list_table, scroll
end

gui.add_list_row = function(scroll, unit_num, backer_name, state)
    local row = scroll.add{
        type = "table",
        name = "shuttle_train_button_row_"..unit_num,
        caption = backer_name,
        colspan = 2,
        style = "shuttle_train_button_row"
    }
    row.add{
        type = "button",
        name = "shuttle_train_station_button_"..unit_num,
        caption = backer_name,
        style = "shuttle_train_list_button"
    }
    row.add{
        type = "checkbox",
        name = "shuttle_train_favorite_station_"..unit_num,
        state = state
    }
    return row
end

gui.remove_list_row = function(pdata, unit_number)
    for _, container in pairs(pdata.gui) do
        if container.container then --shuttles, stations
            for name, scroll in pairs(container) do
                if name:find("%_scroll") then
                    if scroll.valid then
                        local tab = scroll["shuttle_train_button_row_"..unit_number]
                        local _ = tab and tab.destroy()
                    end
                end
            end
        end
    end
end

Event.call_shuttle = script.generate_event_name()
Gui.on_click("shuttle_train_station_button_",
    function(event)
        local player = game.players[event.player_index]
        event.station = global.forces[player.force.name].stations[tonumber(event.element.name:match("%d+"))]
        if event.station and event.station.valid then
            event.element.caption = event.station.backer_name
            event.element.parent.caption = event.station.backer_name
            game.raise_event(Event.call_shuttle, event)
        else
            --LOCALE
            --game.print({"st-gui.invalid", event.element.caption})
            event.element.parent.destroy()
        end
    end
)

-- Gui.on_checked_state_changed("shuttle_train_favorite_station_",
-- function(event)
-- local player, pdata = Player.get_object_and_data(event.player_index)
-- pdata.favorite_stations[tonumber(event.element.name:match("%d+"))] = event.element.state or nil
-- end
-- )
-- Gui.on_checked_state_changed("shuttle_train_favorite_shuttle_",
-- function(event)
-- local player, pdata = Player.get_object_and_data(event.player_index)
-- pdata.favorite_shuttles[tonumber(event.element.name:match("%d+"))] = event.element.state or nil
-- end
-- )
--
Gui.on_text_changed("shuttle_train_left_header_filter",
    function(event)
        local player, pdata = Player.get_object_and_data(event.player_index)
        local fdata = global.forces[player.force.name]
        local filter = event.element.text:lower()
        for type_name, container in pairs(pdata.gui) do
            if container.container and container.container.valid then --and container.container.style.visible then --shuttles, stations
                for name, scroll in pairs(container) do
                    if name:find("%_scroll") then
                        if scroll.valid then
                            local total, on, off = 0, 0, 0
                            for _, tabname in pairs(scroll.children_names) do

                                local ent = fdata[type_name][tonumber(tabname:match("%d+"))]
                                if ent and ent.valid then
                                    total = total + 1
                                    scroll[tabname].caption = ent.backer_name
                                    scroll[tabname]["shuttle_train_station_button_"..ent.unit_number].caption = ent.backer_name
                                    if scroll[tabname].caption:lower():find(filter) then
                                        scroll[tabname].style.visible = true
                                        on = on + 1
                                    else
                                        scroll[tabname].style.visible = false
                                        off = off + 1
                                    end
                                else
                                    scroll[tabname].destroy()
                                end
                            end
                            --container.container.style.visible = off ~= total and true or false
                            scroll.parent.style.visible = off ~= total and true or false
                        end
                    end
                end
            end
        end
    end
)

Gui.on_click("shuttle_train_top_button", gui.toggle_left_gui)

return gui
