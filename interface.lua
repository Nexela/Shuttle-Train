local interface = {}

interface.console = require("stdlib/debug/console")

function interface.print_global(name)
    if name and type(name) == "string" then
        --game.print(name.."="..serpent.block(global[name], {comment=false, sparse=true, nocode=true}))
        game.write_file("/ShuttleTrain2/global.lua", name.."="..serpent.block(global[name], {comment=false, sparse=true}))
    else
        --game.print(serpent.block(global, {comment=false, sparse=true, nocode=true}))
        game.write_file("/ShuttleTrain2/global.lua", serpent.block(global, {comment=false, sparse=true}))
    end
end

if remote.interfaces["creative-mode"] and remote.interfaces["creative-mode"]["register_remote_function_to_modding_ui"] then
    log("Shuttle Train - Registering with Creative Mode")
    remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.if_name, "print_global")
    remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.if_name, "console")
end

return interface
