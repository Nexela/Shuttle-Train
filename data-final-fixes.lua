--Increase FARL grid to 4x2 to accomadate Farl and Shuttle Modules
local farl_grid = data.raw["equipment-grid"]["farl-equipment-grid"]
if farl_grid then
    farl_grid.equipment_categories[#farl_grid.equipment_categories + 1] = "shuttle-train-equipment"
    farl_grid.width = 4
    farl_grid.height = 2
end
