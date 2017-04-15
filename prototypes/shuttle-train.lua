local Proto = require("stdlib/data/protohelpers")
--Don't need a train, just equipment! or do we clone the train anyway?

local equipment_category = {
    type = "equipment-category",
    name = "shuttle-train-equipment"
}

local grid = {
    type = "equipment-grid",
    name = "shuttle-train-equipment-grid",
    width = 4,
    height = 2,
    equipment_categories = {"shuttle-train-equipment"},
}

local recipe = {
    type = "recipe",
    name = "shuttle-train-equipment",
    enabled = false,
    energy_required = 30,
    ingredients =
    {
        {"electronic-circuit", 10},
        {"iron-gear-wheel", 40},
        {"steel-plate", 20},
    },
    result = "shuttle-train-equipment"
}

local item = {
    type = "item",
    name = "shuttle-train-equipment",
    icon = "__ShuttleTrain2__/graphics/icons/shuttle-train-equipment.png",
    placed_as_equipment_result = "shuttle-train-equipment",
    flags = {"goes-to-main-inventory"},
    subgroup = "transport",
    order = "a[train-system]-fc[shuttle-train]",
    stack_size = 1
}

local shuttle_train = {
    type = "roboport-equipment",
    name = "shuttle-train-equipment",
    take_result = "shuttle-train-equipment",
    sprite =
    {
        filename = "__ShuttleTrain2__/graphics/equipment/shuttle-train-equipment.png",
        width = 64,
        height = 64,
        priority = "medium"
    },
    shape =
    {
        width = 2,
        height = 2,
        type = "full"
    },
    energy_source =
    {
        type = "electric",
        buffer_capacity = "35MJ",
        input_flow_limit = "3500KW",
        usage_priority = "secondary-input"
    },
    charging_energy = "0W",
    energy_consumption = "0W",

    robot_limit = 0,
    construction_radius = 0,
    spawn_and_station_height = 0.4,
    charge_approach_distance = 2.6,

    recharging_animation = Proto.empty_animation,
    categories = {"shuttle-train-equipment"}
}

local technology = {
    type = "technology",
    name = "shuttle-train",
    icon = "__ShuttleTrain2__/graphics/technology/shuttle-train.png",
    icon_size = 128,
    effects =
    {
        {
            type = "unlock-recipe",
            recipe = "shuttle-train-equipment"
        }
    },
    prerequisites = {"automated-rail-transportation"},
    unit =
    {
        count = 70,
        ingredients =
        {
            {"science-pack-1", 2},
            {"science-pack-2", 1},
        },
        time = 20
    },
    order = "c-g-b-a"
}

data:extend{equipment_category, grid, recipe, item, shuttle_train, technology}
