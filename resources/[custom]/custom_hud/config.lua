Config = {}

Config.Debug = false

-- ── Top-right identity block ────────────────────────────────────────────────
Config.ServerName = 'PURPLE HAVOC'
-- What the [ID] shows:  'account' = users.id (matches chat)   |  'server' = server id
Config.IdSource = 'account'
Config.MaxSlots = 40 -- qb-inventory Config.MaxSlots
Config.ClockUnit = 'ingame' -- 'ingame' = GTA clock  |  'real' = wall clock

-- Personal paycheck timer: counts down from PaycheckSeconds, is saved on
-- disconnect (users.paycheck) and resumed on reconnect. At 00:00 it fires the
-- `custom_hud:server:payday` / `custom_hud:client:payday` hooks (payday reward is
-- added later) and resets.
Config.PaycheckSeconds = 3599 -- 59:59

-- On every server join
Config.FullHpOnJoin = true      -- restore the ped to full health
Config.ClearArmorOnJoin = true  -- wipe body armor (armor is never persisted)

-- Persist hunger/thirst to users.food / users.water so they don't reset on rejoin
Config.PersistFoodWater = true

-- ── Which blocks to show ───────────────────────────────────────────────────
Config.ShowVitals = true        -- health / armor / hunger / thirst / stress / oxygen
Config.ShowStaffShield = true   -- bottom-right shield tinted by staff rank
Config.ShowVehicleHud = true    -- speedometer + fuel + belt + gear ...
Config.SpeedUnit = 'kmh'        -- 'kmh' | 'mph'
Config.HideDefaultCash = true   -- hide GTA's built-in cash counters (we draw our own)

-- ── Money / points animations ─────────────────────────────────────────────
Config.CountUpDuration = 600    -- ms the number rolls from old -> new value
Config.FloatDuration = 1400     -- ms the "+123 / -123" pill stays on screen

-- ── Stress (re-implemented here since qb-hud is disabled) ──────────────────
Config.Stress = {
    enable = true,
    shootChance = 0.10,          -- chance to gain stress per shot
    shootAmount = { min = 1, max = 3 },
    minSpeedBuckled = 100,       -- over this speed (kmh) buckled -> stress
    minSpeedUnbuckled = 50,      -- over this speed (kmh) unbuckled -> stress
    speedAmount = { min = 1, max = 3 },
    shakeAt = 50,                -- stress >= this -> subtle screen shake
    blurAt = 80,                 -- stress >= this -> gusto blur pulse
    whitelistedJobTypes = { ['leo'] = true },
    whitelistedJobs = {},
}

-- ── Keys ─────────────────────────────────────────────────────────────────
Config.ToggleKey = 'F7'         -- show / hide the whole HUD

-- ── Staff shield: rank -> colour.  Falls back to custom_chat's RankColor
--    export; only used if that resource is missing. Keep in sync if you edit it.
Config.StaffColorsFallback = {
    owner = '#5100FF', developer = '#DA9DFF', manager = '#FF0000', headstaff = '#00E1FF',
    leadadmin = '#8F2AD1', headadmin = '#FF6A00', generaladmin = '#FF6A00',
    junioradmin = '#FF6A00', trialadmin = '#FF6A00', headhelper = '#37FF00',
    helper = '#37FF00', trialhelper = '#37FF00',
}

Config.ManageRank = 'owner' -- rank allowed to use /setpp in-game (console always allowed)
