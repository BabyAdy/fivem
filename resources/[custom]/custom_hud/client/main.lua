local QBCore = exports['qb-core']:GetCoreObject()

local hudVisible = true
local loaded = false
local playerName = '—'
local playerId = nil
local pp = 0
local staff = { rank = 'none', color = nil, label = nil }

-- cached "needs" (event-driven for instant updates; loop reads them)
local hunger, thirst, stress = 100, 100, 0

local function nui(data) SendNUIMessage(data) end
local function dbg(...) if Config.Debug then print('^3[custom_hud]^7', ...) end end

-- ── init / lifecycle ─────────────────────────────────────────────────────
RegisterNetEvent('custom_hud:client:init', function(d)
    playerName = d.name or playerName
    playerId = d.id
    pp = d.pp or 0
    staff = d.staff or staff
    loaded = true
    nui({
        action = 'init',
        name = playerName,
        id = playerId,
        serverName = Config.ServerName,
        pp = pp,
        staff = staff,
        cfg = {
            showVitals = Config.ShowVitals,
            showShield = Config.ShowStaffShield,
            showVehicle = Config.ShowVehicleHud,
            speedUnit = Config.SpeedUnit,
            floatMs = Config.FloatDuration,
        },
    })
    nui({ action = 'visible', state = hudVisible })
    dbg('init', playerName, 'pp', pp, 'staff', staff.rank)
end)

local function requestInit()
    loaded = false
    Wait(600)
    TriggerServerEvent('custom_hud:server:requestInit')
end

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    if LocalPlayer.state.isLoggedIn then requestInit() end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    requestInit()
    -- full HP on every join; armour never carries over
    CreateThread(function()
        Wait(2000)
        local ped = PlayerPedId()
        if Config.FullHpOnJoin and not IsEntityDead(ped) then
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
        end
        if Config.ClearArmorOnJoin then
            SetPedArmour(ped, 0)
        end
    end)
end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    loaded = false
    nui({ action = 'visible', state = false })
end)

-- payday hook (reward added later) — for now just snap the local timer back
RegisterNetEvent('custom_hud:client:payday', function()
    nui({ action = 'paycheck', seconds = Config.PaycheckSeconds or 3599 })
end)

-- ── event-driven updates ─────────────────────────────────────────────────
RegisterNetEvent('hud:client:UpdateNeeds', function(h, t)
    if h then hunger = h end
    if t then thirst = t end
end)
RegisterNetEvent('hud:client:UpdateStress', function(s) if s then stress = s end end)

RegisterNetEvent('hud:client:OnMoneyChange', function(kind, amount, isMinus)
    if kind ~= 'cash' and kind ~= 'bank' then return end
    nui({ action = 'money', kind = kind, delta = (isMinus and -amount or amount) })
end)

RegisterNetEvent('hud:client:ShowAccounts', function(kind, amount)
    nui({ action = 'accountPopup', kind = kind == 'bank' and 'bank' or 'cash', amount = amount })
end)

RegisterNetEvent('custom_hud:client:ppChange', function(newVal, delta)
    pp = newVal or pp
    nui({ action = 'pp', value = pp, delta = delta or 0 })
end)

RegisterNetEvent('custom_hud:client:serverInfo', function(info)
    nui({ action = 'serverInfo', online = info and info.online })
end)

RegisterNetEvent('custom_hud:client:paycheck', function(seconds)
    nui({ action = 'paycheck', seconds = seconds })
end)

-- ── toggle ──────────────────────────────────────────────────────────────
local function toggleHud()
    hudVisible = not hudVisible
    nui({ action = 'visible', state = hudVisible })
end
RegisterCommand('hud', toggleHud, false)
RegisterKeyMapping('hud', 'Ascunde / arată HUD-ul', 'keyboard', Config.ToggleKey or '')

-- ── clock ──────────────────────────────────────────────────────────────
local function clockText()
    if Config.ClockUnit == 'real' then
        return os.date('%H:%M')
    end
    return ('%02d:%02d'):format(GetClockHours(), GetClockMinutes())
end

-- ── main status loop ───────────────────────────────────────────────────
CreateThread(function()
    while true do
        local sleep = 300
        if loaded and hudVisible then
            local ped = PlayerPedId()
            local pd = QBCore.Functions.GetPlayerData()

            local health = math.max(0, GetEntityHealth(ped) - 100) -- qb peds: 100 = dead
            local maxHealth = math.max(1, GetEntityMaxHealth(ped) - 100)
            local hpPct = math.floor(health / maxHealth * 100)
            if IsEntityDead(ped) then hpPct = 0 end

            local uw = GetPlayerUnderwaterTimeRemaining(PlayerId())
            local oxygen = math.min(100, math.floor((uw / 10) * 100))

            nui({
                action = 'status',
                data = {
                    cash = pd and pd.money and pd.money.cash or 0,
                    bank = pd and pd.money and pd.money.bank or 0,
                    health = hpPct,
                    armor = GetPedArmour(ped),
                    hunger = math.floor(hunger),
                    thirst = math.floor(thirst),
                    oxygen = oxygen,
                    inWater = IsPedSwimmingUnderWater(ped),
                    talking = NetworkIsPlayerTalking(PlayerId()),
                    clock = clockText(),
                },
            })

            -- stress: shooting
            if Config.Stress.enable and IsPedShooting(ped) and math.random() < Config.Stress.shootChance then
                TriggerServerEvent('hud:server:GainStress',
                    math.random(Config.Stress.shootAmount.min, Config.Stress.shootAmount.max))
            end
            -- stress: subtle camera shake at high stress
            if stress >= Config.Stress.shakeAt then
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ((stress - Config.Stress.shakeAt) / 100) * 0.05 + 0.01)
            end
        end
        Wait(sleep)
    end
end)

-- hide the default GTA cash counters (we render our own)
if Config.HideDefaultCash then
    CreateThread(function()
        while true do
            if loaded then
                HideHudComponentThisFrame(3) -- CASH
                HideHudComponentThisFrame(4) -- MP_CASH
                Wait(0)
            else
                Wait(500)
            end
        end
    end)
end
