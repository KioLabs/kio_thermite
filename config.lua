Config = {}

-- ============================================================
--  KIO Thermite: place the charges, light the fuse, control the burn.
--  Standalone. No framework needed. One export:
--    local result = exports['<resource name>']:Start('normal')   -- or a table of overrides
--      true  = the lock melted (open your door)
--      false = it went wrong (thermite used up; start your fire)
--      nil   = the player backed out with ESC before lighting it (nothing used)
-- ============================================================

-- Difficulty presets. Pass a preset name to Start(), or a table of numbers to override any of them:
--   exports.kio_thermite:Start({ preset = 'hard', meltSeconds = 8 })
Config.Presets = {
    easy = {
        rise = 0.28, fall = 0.20, band = 0.17, drift = 0.03,
        hotLimit = 1.8, coldLimit = 3.5, meltSeconds = 4, timeLimit = 20, catchChance = 0.7,
    },
    normal = {
        rise = 0.32,        -- how fast the heat climbs while held (per second)
        fall = 0.22,        -- how fast it cools when released
        band = 0.13,        -- half the height of the green band (0..1 scale)
        drift = 0.05,       -- how fast the green band wanders
        hotLimit = 1.2,     -- seconds above the band before it blows out
        coldLimit = 2.5,    -- seconds below the band before the burn dies
        meltSeconds = 5,    -- seconds in the green needed to melt the lock
        timeLimit = 14,     -- seconds to place the charges and light the fuse
        catchChance = 0.5,  -- chance each lighter strike catches
    },
    hard = {
        rise = 0.40, fall = 0.28, band = 0.10, drift = 0.08,
        hotLimit = 0.9, coldLimit = 1.8, meltSeconds = 7, timeLimit = 11, catchChance = 0.4,
    },
    vault = {
        rise = 0.45, fall = 0.32, band = 0.08, drift = 0.11,
        hotLimit = 0.7, coldLimit = 1.4, meltSeconds = 9, timeLimit = 10, catchChance = 0.35,
    },
}
Config.DefaultPreset = 'normal'

-- What the player's character does while the minigame is on screen: plants the charge (the Pacific
-- Standard thermal charge animation), a thermite prop appears on the door, and once the fuse is lit
-- they shield their eyes while the real thermite burn plays on the door. Set enabled = false for UI only.
-- Callers can pass where the charge goes: Start({ preset = 'hard', coords = vec3(...), heading = 90.0 })
-- (otherwise it goes on whatever is in front of the player).
Config.Animation = {
    enabled = true,
    placeDict = 'anim@heists@ornate_bank@thermal_charge', placeClip = 'thermal_charge',
    coverIn = 'cover_eyes_intro', coverLoop = 'cover_eyes_loop', coverOut = 'cover_eyes_exit',
    prop = 'hei_prop_heist_thermite',
    fxAsset = 'scr_ornate_heist', fxName = 'scr_heist_ornate_thermal_burn',
    reach = 1.6,          -- how far ahead to look for the door/gate surface (no coords given)
    forward = 0.55,       -- if nothing is hit: how far in front of the player the charge sits
    height = 0.15,        -- height above the player's root where the charge goes (about chest height)
    burnAfter = 3.5,      -- seconds the burn keeps going after a win (covers a heist script's countdown)
    -- held in the right hand: the charge while placing, then the lighter
    handBone = 57005,
    handProp = { model = 'hei_prop_heist_thermite', pos = vec3(0.12, 0.03, -0.02), rot = vec3(-80.0, 0.0, 0.0) },
    lighter = { model = 'p_cs_lighter_01', pos = vec3(0.13, 0.02, -0.02), rot = vec3(-90.0, 0.0, 0.0),
                fxAsset = 'core', fxName = 'ent_amb_torch_fire', fxScale = 0.12, fxOffset = vec3(0.0, 0.0, 0.06) },
}

-- Sound effects (made in the browser, no audio files). 0 = off, 1 = full.
Config.Volume = 0.6

-- The look. Colors are any CSS color.
Config.Theme = {
    accent = '#ffd27a',     -- titles and highlights
    good = '#8fe07a',
    bad = '#ff6a55',
    scale = 0.45,           -- size on screen (share of the screen width, max 1120 px)
    dim = 0.15,             -- how dark the world behind it gets (0..1)
    position = 'right',     -- 'center', 'left' or 'right': off to the side so you can watch your character work
}

-- Test command for admins and developers: /thermitetest [preset]. Set to false to remove it.
Config.TestCommand = 'thermitetest'
-- true: only players with the ACE 'command.thermitetest'. Admins on most servers already have it
-- (server.cfg: add_ace group.admin command allow). false: anyone can use it.
Config.TestRestricted = true

-- Every word the player sees. Translate freely.
Config.Locale = {
    step1 = 'STEP 1: PLACE THE CHARGES',
    step1Help = 'Drag each thermite charge onto a glowing spot',
    step2 = 'STEP 2: LIGHT IT',
    step2Strike = 'Click the lighter to strike it',
    step2Drag = 'Drag the lit lighter to the fuse',
    fuseBurning = 'THE FUSE IS BURNING',
    fuseHelp = 'Get ready: hold SPACE or RIGHT CLICK to heat',
    step3 = 'STEP 3: CONTROL THE BURN',
    hold = 'Hold',
    orWord = 'or',
    space = 'SPACE',
    rightClick = 'RIGHT CLICK',
    heating = 'heating up',
    toHeat = 'to heat',
    keepGreen = 'Keep the needle in the green',
    heat = 'HEAT',
    tooHot = 'TOO HOT',
    tooCold = 'TOO COLD',
    good = 'GOOD',
    melting = 'Melting the lock',
    fuse = 'FUSE',
    caught = 'It caught',
    sparks = 'Just sparks. Try again',
    flameOut = 'The flame went out',
    slowPlace = 'Too slow placing the charges',
    slowLight = 'Too slow lighting it',
    melted = 'The lock melted through',
    blewOut = 'Too hot. It blew out into fire',
    died = 'Too cold. The burn died',
    win = 'Gate open',
    lose = 'It went wrong',
    escHint = 'back out (keeps your thermite)',
    testResult = 'Thermite test: %s',
    testWin = 'gate open',
    testLose = 'failed',
    testCancel = 'backed out',
}
