--Farl adds this is well, lets also add it if not present!
if not (data.raw["custom-input"] and data.raw["custom-input"]["toggle-train-control"]) then
    data:extend{
        {
            type = "custom-input",
            name = "toggle-train-control",
            key_sequence = "J"
        }
    }
end

data:extend{
    {
        type = "custom-input",
        name = "shuttle-train-call-nearest",
        key_sequence = "CONTROL + J"
    }
}
