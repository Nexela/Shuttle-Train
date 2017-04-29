--[[
ConfigurationChangedData
Table with the following fields:
old_version :: string (optional): Old version of the map. Present only when loading map version other than the current version.
new_version :: string (optional): New version of the map. Present only when loading map version other than the current version.
mod_changes :: dictionary string → ModConfigurationChangedData: Dictionary of mod Changes. It is indexed by mod name.
ModConfigurationChangedData
Table with the following fields:
old_version :: string: Old version of the mod. May be nil if the mod wasn't previously present (i.e. it was just added).
new_version :: string: New version of the mod. May be nil if the mod is no longer present (i.e. it was just removed).
--]]
local mod_name = MOD.name or "not-set"
local migrations = {}
local Changes = {}

--Mark all migrations as complete during Init.
function Changes.on_init(version)
    local list = {}
    for _, migration in ipairs(migrations) do
        list[migration] = version
    end
    return list
end

function Changes.on_configuration_changed(event)
    Changes["map-change-always-first"]()
    if event.data.mod_changes then
        Changes["any-change-always-first"]()
        if event.data.mod_changes[mod_name] then
            local this_mod_changed = event.data.mod_changes[mod_name]
            Changes.on_mod_changed(this_mod_changed)
            log("Changed from ".. tostring(this_mod_changed.old_version) .. " to " .. tostring(this_mod_changed.new_version))
        end
        Changes["any-change-always-last"]()
    end
    Changes["map-change-always-last"]()
end

function Changes.on_mod_changed(this_mod_changed)
    global._changes = global._changes or {}
    local migration_index = 1
    -- Find the last installed version
    for i, ver in ipairs(migrations) do
        if global._changes[ver] then
            migration_index = i + 1
        end
    end
    Changes["mod-change-always-first"]()
    for i = migration_index, #migrations do
        if Changes[migrations[i]] then
            Changes[migrations[i]](this_mod_changed)
            global._changes[migrations[i]] = this_mod_changed.old_version or "0.0.0"
            log("Migration complete for ".. migrations[i])
        end
    end
    Changes["mod-change-always-last"]()
end

-------------------------------------------------------------------------------
--[[Always run these before any migrations]]
Changes["map-change-always-first"] = function()
end

Changes["any-change-always-first"] = function()
end

Changes["mod-change-always-first"] = function()
end

-------------------------------------------------------------------------------
--[[Version change code make sure to include the version in
--migrations table above.]]--

-------------------------------------------------------------------------------
--[[Always run these at the end ]]--

Changes["mod-change-always-last"] = function()
end

Changes["any-change-always-last"] = function()
end

Changes["map-change-always-last"] = function()
end

-------------------------------------------------------------------------------
return Changes
