local QBCore = exports['qb-core']:GetCoreObject()

local function dbg(...)
    if Config.Debug then print('^5[custom_chat]^7', ...) end
end

-- ────────────────────────────────────────────────────────────────────────────
--  Helpers
-- ────────────────────────────────────────────────────────────────────────────
-- players may not inject colour codes / control characters
local function clean(s)
    return (tostring(s or ''):gsub('%^', ''):gsub('%c', ''))
end

-- colour segment: '^#RRGGBB text'  (hex mode)  or  '^N text'  (basic mode)
local function seg(hex, text)
    if Config.ColorMode == 'basic' then
        local code = Config.BasicCodes[hex] or '0'
        return ('^%s%s'):format(code, text)
    end
    return ('^%s%s'):format(hex, text) -- hex -> "^#RRGGBB..."
end

--- Account info for a source, or nil if the player is not authenticated / not spawned.
local function account(src)
    local sess = exports['custom_auth']:GetSession(src)
    if not sess or not sess.authed or not sess.userid then return nil end
    if not QBCore.Functions.GetPlayer(src) then return nil end -- not in the world yet
    return {
        id = (Config.IdSource == 'server') and src or sess.userid,
        name = sess.username or GetPlayerName(src) or 'Unknown',
        staff = sess.staff or 'none',
        subscription = sess.subscription or 'none',
    }
end

local function rankInfo(rank)
    return Config.StaffRanks[rank] or Config.StaffRanks.none
end

local function staffType(rank)
    return rankInfo(rank).type -- 'admin' | 'helper' | nil
end

local function isStaff(rank) return staffType(rank) ~= nil end

local function hasSubscription(tier)
    if not tier or tier == 'none' then return false end
    return Config.PremiumBadge.subscription[tier] ~= nil
end

-- Shared with custom_hud (staff shield colour) -----------------------------------
exports('RankColor', function(rank)
    local b = Config.RankBadge[rank]
    return b and b.color or nil -- nil for 'none' / unknown
end)

exports('RankLabel', function(rank)
    local b = Config.RankBadge[rank]
    return b and b.label or nil
end)

exports('StaffType', function(rank) return staffType(rank) end)

-- ────────────────────────────────────────────────────────────────────────────
--  Sending — hands the pre-coloured (^#RRGGBB) header/body to the custom NUI.
-- ────────────────────────────────────────────────────────────────────────────
local function send(target, header, message)
    TriggerClientEvent('custom_chat:client:message', target, { header = header, body = message })
end

local function onlineIds()
    local out = {}
    for _, id in ipairs(GetPlayers()) do out[#out + 1] = tonumber(id) end
    return out
end

-- ────────────────────────────────────────────────────────────────────────────
--  Message builders — return (header, message); colour via ^#RRGGBB codes.
-- ────────────────────────────────────────────────────────────────────────────
local function ts()
    if not Config.Timestamps then return '' end
    return seg(Config.TimestampColor, os.date('%H:%M') .. ' ')
end

local function buildLocal(acc, message)
    local c = Config.Channels.localChat.color
    return ts() .. seg(c, ('[%s]%s'):format(acc.id, clean(acc.name))), seg(c, clean(message))
end

local function buildPremium(acc, message)
    local c = Config.Channels.premium.color
    local badge
    if isStaff(acc.staff) then
        badge = Config.PremiumBadge.staffGroup[acc.staff]
    elseif hasSubscription(acc.subscription) then
        badge = Config.PremiumBadge.subscription[acc.subscription]
    end
    local badgeSeg = badge and seg(badge.color, '[' .. badge.label .. ']') or ''
    local header = ts() .. seg(c, ('(/pc)[%s]'):format(acc.id)) .. badgeSeg .. seg(c, clean(acc.name))
    return header, seg(c, clean(message))
end

local function buildStaff(channel, acc, message)
    local ch = Config.Channels[channel]
    local badge = Config.RankBadge[acc.staff]
    local badgeSeg = badge and seg(badge.color, '[' .. badge.label .. ']') or ''
    local header = ts() .. seg(ch.color, ('(%s)[%s]'):format(ch.prefix, acc.id)) .. badgeSeg .. seg(ch.color, clean(acc.name))
    return header, seg(ch.color, clean(message))
end

-- ────────────────────────────────────────────────────────────────────────────
--  Local chat (plain, unprefixed messages) — proximity only
-- ────────────────────────────────────────────────────────────────────────────
local function routeLocal(src, message)
    src = tonumber(src)
    if not src or src <= 0 then return end
    if type(message) ~= 'string' or not message:find('%S') then return end
    if message:sub(1, 1) == '/' then return end

    local acc = account(src)
    if not acc then return end -- not spawned / not authed

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end
    local from = GetEntityCoords(ped)
    local header, body = buildLocal(acc, message)

    for _, tgt in ipairs(onlineIds()) do
        if tgt == src then
            send(tgt, header, body)
        else
            local tped = GetPlayerPed(tgt)
            if tped and tped ~= 0 and DoesEntityExist(tped) then
                if #(from - GetEntityCoords(tped)) <= Config.LocalRange then
                    send(tgt, header, body)
                end
            end
        end
    end
    dbg(('local %s: %s'):format(acc.name, message))
end

-- from the custom chat NUI
RegisterNetEvent('custom_chat:server:say', function(text)
    routeLocal(source, text)
end)

-- legacy: anything still firing the classic `chatMessage` server event
AddEventHandler('chatMessage', function(src, _, message)
    CancelEvent()
    routeLocal(src, message)
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Global channels
-- ────────────────────────────────────────────────────────────────────────────
local function joinArgs(args) return (table.concat(args, ' ')):gsub('^%s+', ''):gsub('%s+$', '') end

RegisterCommand('pc', function(src, args)
    if src == 0 then return end
    local acc = account(src)
    if not acc then return end
    if not (hasSubscription(acc.subscription) or isStaff(acc.staff)) then
        TriggerClientEvent('QBCore:Notify', src, 'Nu ai acces la chat-ul premium.', 'error')
        return
    end
    local message = joinArgs(args)
    if message == '' then return end
    local header, body = buildPremium(acc, message)
    for _, tgt in ipairs(onlineIds()) do
        local t = exports['custom_auth']:GetSession(tgt)
        if t and (hasSubscription(t.subscription) or isStaff(t.staff)) then
            send(tgt, header, body)
        end
    end
    dbg(('premium %s: %s'):format(acc.name, message))
end, false)

RegisterCommand('a', function(src, args)
    if src == 0 then return end
    local acc = account(src)
    if not acc then return end
    if staffType(acc.staff) ~= 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'Nu ai acces la chat-ul de admin.', 'error')
        return
    end
    local message = joinArgs(args)
    if message == '' then return end
    local header, body = buildStaff('admin', acc, message)
    for _, tgt in ipairs(onlineIds()) do
        local t = exports['custom_auth']:GetSession(tgt)
        if t and staffType(t.staff) == 'admin' then send(tgt, header, body) end
    end
    dbg(('admin %s: %s'):format(acc.name, message))
end, false)

RegisterCommand('hc', function(src, args)
    if src == 0 then return end
    local acc = account(src)
    if not acc then return end
    if not isStaff(acc.staff) then
        TriggerClientEvent('QBCore:Notify', src, 'Nu ai acces la chat-ul de helper.', 'error')
        return
    end
    local message = joinArgs(args)
    if message == '' then return end
    local header, body = buildStaff('helper', acc, message)
    for _, tgt in ipairs(onlineIds()) do
        local t = exports['custom_auth']:GetSession(tgt)
        if t and isStaff(t.staff) then send(tgt, header, body) end
    end
    dbg(('helper %s: %s'):format(acc.name, message))
end, false)

-- ────────────────────────────────────────────────────────────────────────────
--  Management commands (console, or the configured top rank)
-- ────────────────────────────────────────────────────────────────────────────
local function canManage(src)
    if src == 0 then return true end
    local acc = account(src)
    return acc ~= nil and acc.staff == Config.ManageRank
end

local function resolveAccountId(arg)
    local n = tonumber(arg)
    if not n then return nil end
    -- prefer an online player's account id, fall back to treating the number as an account id
    local sess = exports['custom_auth']:GetSession(n)
    if sess and sess.userid then return sess.userid end
    return n
end

RegisterCommand('setstaff', function(src, args)
    if not canManage(src) then
        if src ~= 0 then TriggerClientEvent('QBCore:Notify', src, 'Fără permisiune.', 'error') end
        return
    end
    local target, rank = args[1], tostring(args[2] or ''):lower()
    if not target or not Config.StaffRanks[rank] then
        local msg = 'Folosire: /setstaff [id server / id cont] [rank]. Ranguri: ' ..
            table.concat((function() local t = {} for k in pairs(Config.StaffRanks) do t[#t + 1] = k end return t end)(), ', ')
        if src == 0 then print(msg) else TriggerClientEvent('QBCore:Notify', src, msg, 'error') end
        return
    end
    local accId = resolveAccountId(target)
    if not accId then return end
    exports['custom_auth']:SetStaff(accId, rank)
    local line = ('Rang staff setat: cont #%s -> %s'):format(accId, rank)
    if src == 0 then print('^2[custom_chat]^7 ' .. line) else TriggerClientEvent('QBCore:Notify', src, line, 'success') end
end, false)

RegisterCommand('setsub', function(src, args)
    if not canManage(src) then
        if src ~= 0 then TriggerClientEvent('QBCore:Notify', src, 'Fără permisiune.', 'error') end
        return
    end
    local target, tier = args[1], tostring(args[2] or ''):lower()
    local valid = (tier == 'none')
    for _, v in ipairs(Config.Subscriptions) do if v == tier then valid = true end end
    if not target or not valid then
        local msg = 'Folosire: /setsub [id server / id cont] [none/' .. table.concat(Config.Subscriptions, '/') .. ']'
        if src == 0 then print(msg) else TriggerClientEvent('QBCore:Notify', src, msg, 'error') end
        return
    end
    local accId = resolveAccountId(target)
    if not accId then return end
    exports['custom_auth']:SetSubscription(accId, tier)
    local line = ('Abonament setat: cont #%s -> %s'):format(accId, tier)
    if src == 0 then print('^2[custom_chat]^7 ' .. line) else TriggerClientEvent('QBCore:Notify', src, line, 'success') end
end, false)
