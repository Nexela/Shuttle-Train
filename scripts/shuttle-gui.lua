local gui = {}

gui.enable_main_button = function(index)
    local player = game.players[index]
    if not player.gui.top["shuttle_train_top_button"] then
        player.gui.top.add{type="button",name="shuttle_train_top_button", style="shuttle_train_top_button", tooltip={"tooltip.shuttle_train_top_frame_button"}}
    end
end

return gui
