local QBCore = exports['qb-core']:GetCoreObject()

local hud = {} -- src -> { accId, username, pp, paycheckLeft }
local PAYCHECK_MAX = Config.PaycheckSeconds or 3599

local function dbg(...) if Config.Debug then print('^3[custom_hud]^7', ...) end end

-- ── helpers ───────────────────────────────────────────────────────────────
local function session(src)
    local ok, s = pcall(function() return exports['custom_auth']:GetSession(src) end)
    if ok then return s end
    return nil
end

local function rankColor(rank)
    if not rank or rank == 'none' then return nil end
    local ok, c = pcall(function() return exports['custom_chat']:RankColor(rank) end)
    if ok and c then return c end
    return Config.StaffColorsFallback[rank]
end

local function rankLabel(rank)
    if not rank or rank == 'none' then return nil end
    local ok, l = pcall(function() return exports['custom_chat']:RankLabel(rank) end)
    if ok and l then return l end
    return rank
end

local function mirrorMoney(src)
    local h = hud[src]
    local Player = QBCore.Functions.GetPlayer(src)
    if not h or not h.accId or not Player then return end
    MySQL.update('UPDATE `users` SET `money` = ?, `bank` = ? WHERE `id` = ?', {
        math.floor(Player.PlayerData.money.cash or 0),
        math.floor(Player.PlayerData.money.bank or 0),
        h.accId,
    })
end

local function clampPct(v) v = tonumber(v) or 100; return math.max(0, math.min(100, math.floor(v))) end

-- ── init a player ─────────────────────────────────────────────────────────
local function initPlayer(src)
    local s = session(src)
    if not s or not s.userid then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local firstInit = hud[src] == nil

    local row = MySQL.single.await('SELECT `pp`, `paycheck`, `food`, `water` FROM `users` WHERE `id` = ?', { s.userid })
    local pp = (row and tonumber(row.pp)) or 0
    local paycheckLeft = (hud[src] and hud[src].paycheckLeft) or (row and tonumber(row.paycheck)) or PAYCHECK_MAX
    if paycheckLeft <= 0 or paycheckLeft > PAYCHECK_MAX then paycheckLeft = PAYCHECK_MAX end

    hud[src] = { accId = s.userid, username = s.username, pp = pp, paycheckLeft = paycheckLeft }

    -- these run only on the real first init, not on a staff-refresh re-init
    if firstInit then
        if Config.PersistFoodWater then
            local food = row and clampPct(row.food) or 100
            local water = row and clampPct(row.water) or 100
            Player.Functions.SetMetaData('hunger', food)
            Player.Functions.SetMetaData('thirst', water)
            TriggerClientEvent('hud:client:UpdateNeeds', src, food, water)
        end
        if Config.ClearArmorOnJoin then
            Player.Functions.SetMetaData('armor', 0)
        end
    end

    TriggerClientEvent('custom_hud:client:init', src, {
        id = (Config.IdSource == 'server') and src or s.userid,
        name = s.username,
        pp = pp,
        staff = {
            rank = s.staff or 'none',
            color = rankColor(s.staff),
            label = rankLabel(s.staff),
        },
    })
    mirrorMoney(src)
    TriggerClientEvent('custom_hud:client:serverInfo', src, { online = #GetPlayers() })
    TriggerClientEvent('custom_hud:client:paycheck', src, paycheckLeft)
    dbg('init', src, 'acc', s.userid, 'pp', pp, 'paycheck', paycheckLeft)
end

RegisterNetEvent('custom_hud:server:requestInit', function()
    initPlayer(source)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    SetTimeout(1500, function() initPlayer(src) end)
end)

-- ── persistence (paycheck + food/water) ────────────────────────────────
local function savePlayerHud(src)
    local h = hud[src]
    if not h or not h.accId then return end
    local pc = math.max(0, math.floor(h.paycheckLeft or PAYCHECK_MAX))
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Config.PersistFoodWater then
        -- Player still present -> also persist current hunger/thirst
        MySQL.update('UPDATE `users` SET `paycheck` = ?, `food` = ?, `water` = ? WHERE `id` = ?', {
            pc,
            clampPct(Player.PlayerData.metadata.hunger),
            clampPct(Player.PlayerData.metadata.thirst),
            h.accId,
        })
    else
        -- Player already gone -> keep last-saved food/water, only update paycheck
        MySQL.update('UPDATE `users` SET `paycheck` = ? WHERE `id` = ?', { pc, h.accId })
    end
end

AddEventHandler('playerDropped', function()
    local src = source
    savePlayerHud(src)
    hud[src] = nil
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    savePlayerHud(src)
    hud[src] = nil
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for src in pairs(hud) do savePlayerHud(src) end
end)

-- staff rank changed live (custom_chat /setstaff) -> re-push the shield colour
AddEventHandler('custom_auth:server:accountUpdated', function(src, field)
    if field == 'staff' and hud[src] then
        SetTimeout(0, function() initPlayer(src) end)
    end
end)

-- ── Premium Points ────────────────────────────────────────────────────────
local function getPP(src) return (hud[src] and hud[src].pp) or 0 end

local function applyPP(src, newVal, delta, reason)
    local h = hud[src]
    if not h or not h.accId then return false end
    newVal = math.max(0, math.floor(newVal))
    h.pp = newVal
    MySQL.update('UPDATE `users` SET `pp` = ? WHERE `id` = ?', { newVal, h.accId })
    TriggerClientEvent('custom_hud:client:ppChange', src, newVal, delta or 0)
    dbg(('PP %s -> %d (%s%d) [%s]'):format(src, newVal, (delta or 0) >= 0 and '+' or '', delta or 0, reason or 'n/a'))
    return true
end

exports('GetPP', getPP)
exports('AddPP', function(src, amount, reason)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    return applyPP(src, getPP(src) + amount, amount, reason)
end)
exports('RemovePP', function(src, amount, reason)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    local cur = getPP(src)
    if cur < amount then return false end
    return applyPP(src, cur - amount, -amount, reason)
end)
exports('SetPP', function(src, amount, reason)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    return applyPP(src, amount, amount - getPP(src), reason or 'set')
end)

-- ── money mirror ──────────────────────────────────────────────────────
AddEventHandler('QBCore:Server:OnMoneyChange', function(src)
    SetTimeout(50, function() mirrorMoney(src) end)
end)

-- ── personal paycheck countdown ───────────────────────────────────────
local function payday(src)
    local h = hud[src]
    if not h then return end
    -- reward is added later; for now just fire the hooks and reset the timer
    TriggerEvent('custom_hud:server:payday', src, h.accId)
    TriggerClientEvent('custom_hud:client:payday', src)
    h.paycheckLeft = PAYCHECK_MAX
    savePlayerHud(src)
    dbg('payday', src)
end

CreateThread(function()
    local acc = 0
    while true do
        Wait(1000)
        for src, h in pairs(hud) do
            h.paycheckLeft = (h.paycheckLeft or PAYCHECK_MAX) - 1
            if h.paycheckLeft <= 0 then payday(src) end
        end
        acc = acc + 1
        if acc >= 5 then -- resync clients + safety flush every 5s
            acc = 0
            local online = #GetPlayers()
            for src, h in pairs(hud) do
                TriggerClientEvent('custom_hud:client:serverInfo', src, { online = online })
                TriggerClientEvent('custom_hud:client:paycheck', src, math.max(0, math.floor(h.paycheckLeft)))
                mirrorMoney(src)
            end
        end
    end
end)

-- periodic DB save of paycheck + food/water
CreateThread(function()
    while true do
        Wait(60000)
        for src in pairs(hud) do savePlayerHud(src) end
    end
end)

-- ── Stress (re-implemented; qb-hud is disabled) ──────────────────────────
local function changeStress(src, delta)
    if not Config.Stress.enable then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local jobType = Player.PlayerData.job.type
    local jobName = Player.PlayerData.job.name
    if Config.Stress.whitelistedJobTypes[jobType] or Config.Stress.whitelistedJobs[jobName] then return end
    local cur = Player.PlayerData.metadata.stress or 0
    local new = math.max(0, math.min(100, cur + delta))
    if new == cur then return end
    Player.Functions.SetMetaData('stress', new)
    TriggerClientEvent('hud:client:UpdateStress', src, new)
end

RegisterNetEvent('hud:server:GainStress', function(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 100 then return end
    changeStress(source, amount)
    TriggerClientEvent('QBCore:Notify', source, 'Ești stresat...', 'error', 1500)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 100 then return end
    changeStress(source, -amount)
end)

-- ── /cash /bank /setpp ──────────────────────────────────────────────────
QBCore.Commands.Add('cash', 'Verifică banii cash', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', Player.PlayerData.money.cash) end
end)

QBCore.Commands.Add('bank', 'Verifică banii din bancă', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', Player.PlayerData.money.bank) end
end)

local function canManage(src)
    if src == 0 then return true end
    local s = session(src)
    return s ~= nil and s.staff == Config.ManageRank
end

RegisterCommand('setpp', function(src, args)
    if not canManage(src) then
        if src ~= 0 then TriggerClientEvent('QBCore:Notify', src, 'Fără permisiune.', 'error') end
        return
    end
    local tgt = tonumber(args[1])
    local amount = tonumber(args[2])
    if not tgt or not amount then
        local m = 'Folosire: /setpp [id server] [sumă]'
        if src == 0 then print(m) else TriggerClientEvent('QBCore:Notify', src, m, 'error') end
        return
    end
    if not hud[tgt] then
        local m = 'Jucătorul nu este online sau nu are HUD încărcat.'
        if src == 0 then print(m) else TriggerClientEvent('QBCore:Notify', src, m, 'error') end
        return
    end
    amount = math.max(0, math.floor(amount))
    applyPP(tgt, amount, amount - getPP(tgt), 'setpp')
    local line = ('PP setat: id %d -> %d'):format(tgt, amount)
    if src == 0 then print('^2[custom_hud]^7 ' .. line) else TriggerClientEvent('QBCore:Notify', src, line, 'success') end
end, false)
