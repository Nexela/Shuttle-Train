local interface = {}

function interface.print_global(name)
    if name and type(name) == "string" then
        game.print(name.."="..serpent.block(global[name], {comment=false, sparse=true, nocode=true}))
        game.write_file("/ShuttleTrain2/global.lua", name.."="..serpent.block(global[name], {comment=false, sparse=true}))
    else
        game.print(serpent.block(global, {comment=false, sparse=true, nocode=true}))
        game.write_file("/ShuttleTrain2/global.lua", serpent.block(global, {comment=false, sparse=true}))
    end
end

return interface
