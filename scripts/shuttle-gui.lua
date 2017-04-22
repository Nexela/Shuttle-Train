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
Gui.on_click("shuttle_train_top_button", gui.toggle_left_gui)
-------------------------------------------------------------------------------
--[[Left Frame Main]]--
-------------------------------------------------------------------------------
gui.destroy_left_frame = function(event)
    local left = get_left_gui(game.players[event.player_index])
    if left then left.destroy() end
end

gui.get_or_create_left_flow = function(event)
    --[[
    pdata.gui["container-type"]["container-gui-obj"]
    ]]
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

        --Hide empties
        pdata.gui.stations.fav.style.visible = false
        pdata.gui.stations.fav_scroll.parent.style.visible = false
        pdata.gui.stations.reg_scroll.parent.style.visible = #pdata.gui.stations.reg_scroll.children_names > 0

        pdata.gui.shuttles.fav.style.visible = false
        pdata.gui.shuttles.fav_scroll.parent.style.visible = false
        pdata.gui.shuttles.reg_scroll.parent.style.visible = #pdata.gui.stations.reg_scroll.children_names > 0

        --Populate existing stations
        table.each(fdata.stations,
            function(station)
                gui.add_list_row(pdata.gui.stations["reg_scroll"], station.unit_number, station.backer_name, false)
            end
        )
        local function _is_shuttle(locomotive)
            if locomotive and locomotive.grid then
                return table.find(locomotive.grid.equipment, function(v) return v.name == "shuttle-train-equipment" end)
            end
        end
        table.each(fdata.locomotives,
            function(loco)
                if _is_shuttle(loco) then
                    gui.add_list_row(pdata.gui.shuttles["reg_scroll"], loco.unit_number, loco.backer_name, false)
                end
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
        caption = name,
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
        style = "shuttle_train_left_container_table",
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
        --vertical_scroll_policy = "always",
        caption = name
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
    row.style.visible = backer_name:lower():find(global.players[scroll.player_index].gui.filter.text:lower()) or false
    scroll.parent.style.visible = #scroll.children_names > 0 and row.style.visible or scroll.parent.style.visible
    if scroll.caption == "favorites" then
        scroll.parent.parent.style.visible = scroll.parent.style.visible
    end
    return row
end

gui.remove_list_row = function(pdata, unit_number)
    for _, container in pairs(pdata.gui) do
        if container.container then --shuttles, stations
            for name, scroll in pairs(container) do
                if name:find("%_scroll") then
                    if scroll.valid then
                        local tab = scroll["shuttle_train_button_row_"..unit_number]
                        if tab then
                            tab.destroy()
                            if #scroll.children_names == 0 then
                                scroll.parent.style.visible = false
                                if scroll.caption == "favorites" then
                                    scroll.parent.parent.style.visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

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

--Get reg/favorite delete and add
Gui.on_checked_state_changed("shuttle_train_favorite_station_",
    function(event)
        local _, pdata = Player.get_object_and_data(event.player_index)

        --Get container table caption
        local type = event.element.parent.parent.parent.parent.parent.caption
        local unit_number = event.element.name:match("%d+")
        local backer_name = event.element.parent.caption
        local state = event.element.state

        local add_to_scroll = pdata.gui[type][state and "fav_scroll" or "reg_scroll"]

        gui.remove_list_row(pdata, unit_number)

        gui.add_list_row(add_to_scroll, unit_number, backer_name, state)
    end
)

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

return gui
