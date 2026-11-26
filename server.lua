-- KIO Thermite (server): only the test command lives here. The minigame itself is all client side.
-- Permission is checked here because client-side restricted commands are unreliable.
if Config.TestCommand then
    RegisterCommand(Config.TestCommand, function(src, args)
        if src <= 0 then print('[kio_thermite] Run /' .. Config.TestCommand .. ' in game, not in the console.') return end
        TriggerClientEvent(GetCurrentResourceName() .. ':test', src, args[1])
    end, Config.TestRestricted ~= false)
end
