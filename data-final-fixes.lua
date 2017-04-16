require("stdlib/table")

--Increase FARL grid to 4x2 to accomadate Farl and Shuttle Modules
local farl_grid = data.raw["equipment-grid"]["farl-equipment-grid"]
if farl_grid then
    farl_grid.width = 4
    farl_grid.height = 2
end

--Add grid to locomotives if they don't have one. Add category to that locos grid if not present.
for _, loco in pairs(data.raw["locomotive"]) do
    if not loco.equipment_grid then
        loco.equipment_grid = "shuttle-train-equipment-grid"
    end
    local grid = data.raw["equipment_grid"][loco.equipment_grid]
    if grid then
        if not table.any(grid.equipment_categories, function(v) return v == "shuttle-train-equipment" end) then
            grid.equipment_categories[#grid.equipment_categories+1] = "shuttle-train-equipment"
        end
    else
        log("Grid not found")
    end
end
