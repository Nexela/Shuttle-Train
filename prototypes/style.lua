-------------------------------------------------------------------------------
--[[FONTS]]--
-------------------------------------------------------------------------------
data:extend(
    {
        {
            type = "font",
            name = "shuttle-train-font",
            from = "default",
            size = 12
        },
        {
            type = "font",
            name = "shuttle-train-font-bold",
            from = "default-bold",
            size = 16
        }
    }
)

-------------------------------------------------------------------------------
--[[TOP FRAME]]--
-------------------------------------------------------------------------------
--shuttle_train_top_button

data.raw["gui-style"].default["shuttle_train_top_button"] = {
    type = "button_style",
    parent = "button_style",
    font = "shuttle-train-font",
    width = 33,
    height = 33,
    left_padding = 0,
    right_padding = 0,
    top_padding = 6,
    bottom_padding = 0,
    left_click_sound = {
        {
            filename = "__core__/sound/gui-click.ogg",
            volume = 1
        }
    },
    default_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__ShuttleTrain2__/graphics/shuttle-buttons.png",
            --priority = "extra-high-no-scale",
            width = 32,
            height = 32,
            x = 32 * 2
        }
    },
    hovered_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__ShuttleTrain2__/graphics/shuttle-buttons.png",
            width = 32,
            height = 32,
            x = 32 * 3
        }
    },
    clicked_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__ShuttleTrain2__/graphics/shuttle-buttons.png",
            width = 32,
            height = 32,
            x = 32 * 3
        }
    },
    disabled_graphical_set = {
        type="monolith",
        monolith_image = {
            filename = "__ShuttleTrain2__/graphics/shuttle-buttons.png",
            width = 32,
            height = 32,
            x = 32 * 4
        }
    }
}

-------------------------------------------------------------------------------
--[[LEFT FRAME]]--
-------------------------------------------------------------------------------
--shuttle_train_left_frame
--shuttle_train_left_label_title
--shuttle_train_left_label_simple_text
--shuttle_train_left_header_filter
data.raw["gui-style"].default["shuttle_train_left_frame"] =
{
    type = "frame_style",
    parent = "frame_style",
    maximal_width = 220,
    minimal_width = 200,
    right_padding = 0,
    left_padding = 0,
    bottom_padding = 0,
}

data.raw["gui-style"].default["shuttle_train_left_label_title"] =
{
    type = "label_style",
    parent = "label_style",
    --width = 190,
    align = "center",
    font = "shuttle-train-font-bold",
    font_color = {r = 1, g = 1, b = 1}
}

data.raw["gui-style"].default["shuttle_train_left_label_simple_text"] =
{
    type = "label_style",
    parent = "label_style",
    --width = 170,
    left_padding = 15,
    right_padding = 5,
    align = "left",
    font = "shuttle-train-font-bold",
    font_color = {r = 0, g = 1, b = 0}
}

data.raw["gui-style"].default["shuttle_train_left_header_filter"] =
{
    type = "textfield_style",
    left_padding = 5,
    right_padding = 5,
    minimal_width = 200,
    --maximal_width = 185,
    font = "shuttle-train-font",
    font_color = {},
    graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {16, 0}
    },
    selection_background_color= {r=0.66, g=0.7, b=0.83}
}

-------------------------------------------------------------------------------
--[[Station List]]--
-------------------------------------------------------------------------------
--shuttle_train_left_container
--shuttle_train_left_container_frame
data.raw["gui-style"].default["shuttle_train_left_container"] =
{
    type = "table_style",
    parent = "table_style",
    vertical_spacing = 0,
    horizontal_spacing = 5,
    cell_spacing = 0,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
}

data.raw["gui-style"].default["shuttle_train_left_container_frame"] =
{
    type = "frame_style",
    parent = "frame_style",
    minimal_width = 190,
    right_padding = 0,
    left_padding = 0,
    bottom_padding = 5,
}

data.raw["gui-style"].default["shuttle_train_left_container_scroll"] =
{
    type = "scroll_pane_style",
    parent = "scroll_pane_style",
    minimal_height = 0,
    maximal_height = 300,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
}
data.raw["gui-style"].default["shuttle_train_left_container_scroll_favorites"] =
{
    type="scroll_pane_style",
    parent = "shuttle_train_left_container_scroll",
    maximal_height = 90,
    minamal_height = 90
}

data.raw["gui-style"].default["shuttle_train_left_container_scroll_stations"] =
{
    type="scroll_pane_style",
    parent = "shuttle_train_left_container_scroll",
    maximal_height = 215,
    minimal_height = 215,
}

data.raw["gui-style"].default["shuttle_train_button_row"] =
{
    type = "table_style",
    parent = "table_style",
    vertical_spacing = 0,
    horizontal_spacing = 5,
    cell_spacing = 0,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
}

data.raw["gui-style"].default["shuttle_train_list_button"] =
{
    type = "button_style",
    parent = "button_style",
    font = "shuttle-train-font",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    minimal_width = 130,
    maximal_width = 130,
    top_padding = 0,
    right_padding = 5,
    bottom_padding = 0,
    left_padding = 5,
    default_graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 0}
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 8}
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 16}
    },
    disabled_font_color = {r = 0.5, g = 0.5, b = 0.5},
    disabled_graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 0}
    },
    pie_progress_color = {r = 1, g = 1, b = 1},
    left_click_sound =
    {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
    }
}
