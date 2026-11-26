-- KIO Thermite (client). Standalone: no framework, no items, no dependencies.
--
--   local result = exports['<this resource>']:Start('normal')
--     true  = the lock melted (open your door)
--     false = it went wrong (the thermite is used up; start your fire)
--     nil   = the player backed out with ESC before lighting it (nothing used)
--
--   exports['<this resource>']:StartAsync(opts, function(result) ... end)   -- same, without blocking
--   exports['<this resource>']:IsOpen()                                     -- true while it is on screen
--
-- opts: a preset name ('easy', 'normal', 'hard', 'vault'), or a table such as
--   { preset = 'hard', meltSeconds = 8, timeLimit = 12 }
local pending

-- ---------- the character: plant the charge, shield the eyes, the real thermite burn ----------
local A = { prop = nil, fx = nil, at = nil, heading = nil, hand = nil, flame = nil }
local function loadDict(d) RequestAnimDict(d) local t = GetGameTimer() + 3000 while not HasAnimDictLoaded(d) and GetGameTimer() < t do Wait(10) end return HasAnimDictLoaded(d) end
local function loadModel(m) local h = joaat(m) if not IsModelInCdimage(h) then return nil end RequestModel(h) local t = GetGameTimer() + 3000 while not HasModelLoaded(h) and GetGameTimer() < t do Wait(10) end return HasModelLoaded(h) and h or nil end
local function loadFx(a) RequestNamedPtfxAsset(a) local t = GetGameTimer() + 3000 while not HasNamedPtfxAssetLoaded(a) and GetGameTimer() < t do Wait(10) end return HasNamedPtfxAssetLoaded(a) end
local function play(dict, clip, flag, dur)
    local ped = PlayerPedId()
    if loadDict(dict) then TaskPlayAnim(ped, dict, clip, 8.0, -8.0, dur or -1, flag or 0, 0, false, false, false) end
end

-- something held in the right hand
local function holdProp(spec)
    if not spec then return nil end
    local m = loadModel(spec.model)
    if not m then return nil end
    local ped = PlayerPedId()
    local o = CreateObject(m, 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(o, false, false)
    AttachEntityToEntity(o, ped, GetPedBoneIndex(ped, Config.Animation.handBone or 57005), spec.pos.x, spec.pos.y, spec.pos.z,
        spec.rot.x, spec.rot.y, spec.rot.z, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(m)
    return o
end
local function dropHand()
    if A.flame then StopParticleFxLooped(A.flame, false) A.flame = nil end
    if A.hand and DoesEntityExist(A.hand) then DeleteEntity(A.hand) end
    A.hand = nil
end

-- the surface straight ahead (a door or a gate): where the charge goes
local function surfaceAhead(C)
    local ped = PlayerPedId()
    local from = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, C.height)
    local to = GetOffsetFromEntityInWorldCoords(ped, 0.0, C.reach or 1.6, C.height)
    local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 1 + 16, ped, 7)
    local tries = 0
    local status, hit, at
    repeat
        status, hit, at = GetShapeTestResult(ray)
        tries = tries + 1
        if status == 1 then Wait(0) end
    until status ~= 1 or tries > 20
    if hit == 1 and at then
        -- a hair in front of the surface, back toward the player
        local dir = to - from
        local len = #dir
        if len > 0 then dir = dir / len end
        return at - dir * 0.04
    end
    return GetOffsetFromEntityInWorldCoords(ped, 0.0, C.forward, C.height)
end

local function animStart(opts)
    local C = Config.Animation
    if not C or not C.enabled then return end
    local ped = PlayerPedId()
    if type(opts) == 'table' and opts.coords then
        A.at = vector3(opts.coords.x, opts.coords.y, opts.coords.z)
        A.heading = tonumber(opts.heading) or GetEntityHeading(ped)
        TaskTurnPedToFaceCoord(ped, A.at.x, A.at.y, A.at.z, 800)
        Wait(800)
    else
        A.at = surfaceAhead(C)
        A.heading = GetEntityHeading(ped)
    end
    -- the charge in hand, working on the door while it goes on
    A.hand = holdProp(C.handProp)
    play(C.placeDict, C.placeClip, 0, -1)
end

-- the charges are on the door
local function animPlaced()
    local C = Config.Animation
    if not C or not C.enabled or A.prop or not A.at then return end
    -- off the hand, onto the door; the lighter comes out
    dropHand()
    A.hand = holdProp(C.lighter)
    local m = loadModel(C.prop)
    if not m then return end
    A.prop = CreateObject(m, A.at.x, A.at.y, A.at.z, false, false, false)
    SetEntityHeading(A.prop, A.heading or 0.0)
    SetEntityCollision(A.prop, false, false)
    FreezeEntityPosition(A.prop, true)
    SetModelAsNoLongerNeeded(m)
end

-- the lighter caught (or went out)
local function animFlame(on)
    local C = Config.Animation
    if not C or not C.enabled or not C.lighter then return end
    if not on then
        if A.flame then StopParticleFxLooped(A.flame, false) A.flame = nil end
        return
    end
    if A.flame or not A.hand or not DoesEntityExist(A.hand) then return end
    local L = C.lighter
    if loadFx(L.fxAsset) then
        UseParticleFxAssetNextCall(L.fxAsset)
        A.flame = StartParticleFxLoopedOnEntity(L.fxName, A.hand, L.fxOffset.x, L.fxOffset.y, L.fxOffset.z, 0.0, 0.0, 0.0, L.fxScale or 0.12, false, false, false)
    end
end

-- the fuse is lit: step back and shield the eyes, the burn starts on the door
local function animIgnite()
    local C = Config.Animation
    if not C or not C.enabled then return end
    if not A.prop then animPlaced() end
    dropHand()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    play(C.placeDict, C.coverIn, 0, 1200)
    SetTimeout(1100, function() if pending then play(C.placeDict, C.coverLoop, 1, -1) end end)
    if A.at and loadFx(C.fxAsset) then
        UseParticleFxAssetNextCall(C.fxAsset)
        A.fx = StartParticleFxLoopedAtCoord(C.fxName, A.at.x, A.at.y, A.at.z + 0.05, 0.0, 0.0, A.heading or 0.0, 1.0, false, false, false, false)
    end
end

local function animEnd(result)
    local C = Config.Animation
    if not C or not C.enabled then return end
    local ped = PlayerPedId()
    dropHand()
    local fx, prop = A.fx, A.prop
    A.fx, A.prop, A.at = nil, nil, nil
    if result == true or result == false then
        play(C.placeDict, C.coverOut, 0, 1500)
        SetTimeout(1500, function() ClearPedTasks(PlayerPedId()) end)
    else
        ClearPedTasks(ped)
    end
    -- a win burns a few more seconds; a fail stops (the caller starts its own fire); backing out just cleans up
    local after = result == true and math.floor((C.burnAfter or 3) * 1000) or 0
    SetTimeout(after, function()
        if fx then StopParticleFxLooped(fx, false) end
        if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    end)
end

local function settings(opts)
    local name = Config.DefaultPreset
    if type(opts) == 'string' then name = opts
    elseif type(opts) == 'table' and type(opts.preset) == 'string' then name = opts.preset end
    local base = Config.Presets[name] or Config.Presets[Config.DefaultPreset] or Config.Presets.normal
    local out = {}
    for k, v in pairs(base) do out[k] = v end
    -- per-call overrides (numbers only; unknown keys are ignored)
    if type(opts) == 'table' then
        for k, v in pairs(opts) do if out[k] ~= nil and type(v) == 'number' then out[k] = v end end
    end
    return out
end

local function open(opts)
    if pending then return nil end
    pending = promise.new()
    animStart(opts)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', cfg = settings(opts), locale = Config.Locale, theme = Config.Theme, volume = Config.Volume })
    local box = Citizen.Await(pending)
    pending = nil
    SetNuiFocus(false, false)
    local r = box and box.r
    animEnd(r)
    return r
end

exports('Start', function(opts) return open(opts) end)
exports('StartAsync', function(opts, cb)
    CreateThread(function()
        local r = open(opts)
        if type(cb) == 'function' then cb(r) end
    end)
end)
exports('IsOpen', function() return pending ~= nil end)

-- the minigame tells the world what just happened on screen
RegisterNUICallback('stage', function(data, cb)
    cb('ok')
    if not pending then return end
    if data and data.stage == 'placed' then animPlaced()
    elseif data and data.stage == 'lit' then animFlame(true)
    elseif data and data.stage == 'out' then animFlame(false)
    elseif data and data.stage == 'ignite' then animIgnite() end
end)

RegisterNUICallback('result', function(data, cb)
    cb('ok')
    if not pending then return end
    local r
    if data and data.won == true then r = true elseif data and data.cancel then r = nil else r = false end
    pending:resolve({ r = r })
end)

-- /thermitetest [preset]: the server checks who may use it (see server.lua), then this runs it
RegisterNetEvent(GetCurrentResourceName() .. ':test', function(preset)
    if pending then return end
    local r = open(preset)
    local word = r == true and Config.Locale.testWin or (r == false and Config.Locale.testLose or Config.Locale.testCancel)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(Config.Locale.testResult:format(word))
    EndTextCommandThefeedPostTicker(false, false)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    dropHand()
    if A.fx then StopParticleFxLooped(A.fx, false) end
    if A.prop and DoesEntityExist(A.prop) then DeleteEntity(A.prop) end
    if pending then
        SetNuiFocus(false, false)
        pending:resolve({ r = nil })
    end
end)
