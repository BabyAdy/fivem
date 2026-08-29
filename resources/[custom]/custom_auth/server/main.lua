local QBCore = exports['qb-core']:GetCoreObject()

-- src -> { userid, username, license, citizenid, staff, subscription, authed, creating }
local Sessions = {}

local function dbg(...)
    if Config.Debug then print('^5[custom_auth]^7', ...) end
end

-- ────────────────────────────────────────────────────────────────────────────
--  Schema safety: extra columns on the users table
--   citizenid    - binds the single character to the account
--   staff        - staff rank (see custom_chat Config.StaffRanks), default 'none'
--   subscription - paid tier (none/premium/vip/legend), default 'none'
--   money / bank - mirror of the QBCore cash / bank balance (custom_hud keeps them in sync)
--   pp           - Premium Points, an account currency managed by custom_hud
-- ────────────────────────────────────────────────────────────────────────────
CreateThread(function()
    local function hasColumn(name)
        return (MySQL.scalar.await([[
            SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = ?
        ]], { name })) ~= 0
    end

    if not hasColumn('citizenid') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `citizenid` VARCHAR(11) NULL DEFAULT NULL, ADD KEY `citizenid` (`citizenid`)')
        print('^2[custom_auth]^7 Added `citizenid` column to `users`.')
    end
    if not hasColumn('staff') then
        MySQL.query.await("ALTER TABLE `users` ADD COLUMN `staff` VARCHAR(20) NOT NULL DEFAULT 'none'")
        print('^2[custom_auth]^7 Added `staff` column to `users`.')
    end
    if not hasColumn('subscription') then
        MySQL.query.await("ALTER TABLE `users` ADD COLUMN `subscription` VARCHAR(20) NOT NULL DEFAULT 'none'")
        print('^2[custom_auth]^7 Added `subscription` column to `users`.')
    end
    if not hasColumn('money') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `money` BIGINT NOT NULL DEFAULT 0')
        print('^2[custom_auth]^7 Added `money` column to `users`.')
    end
    if not hasColumn('bank') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `bank` BIGINT NOT NULL DEFAULT 0')
        print('^2[custom_auth]^7 Added `bank` column to `users`.')
    end
    if not hasColumn('pp') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `pp` BIGINT NOT NULL DEFAULT 0')
        print('^2[custom_auth]^7 Added `pp` column to `users`.')
    end
    if not hasColumn('paycheck') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `paycheck` INT NOT NULL DEFAULT 3599')
        print('^2[custom_auth]^7 Added `paycheck` column to `users`.')
    end
    if not hasColumn('food') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `food` TINYINT NOT NULL DEFAULT 100')
        print('^2[custom_auth]^7 Added `food` column to `users`.')
    end
    if not hasColumn('water') then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `water` TINYINT NOT NULL DEFAULT 100')
        print('^2[custom_auth]^7 Added `water` column to `users`.')
    end
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Helpers
-- ────────────────────────────────────────────────────────────────────────────
local sharedStarterItems = exports['qb-core']:GetShared('StarterItems')

local function giveStarterItems(src)
    if not Config.GiveStarterItems then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    for _, v in pairs(sharedStarterItems) do
        local info = {}
        if v.item == 'id_card' then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == 'driver_license' then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = 'Class C Driver License'
        end
        exports['qb-inventory']:AddItem(src, v.item, v.amount, false, info, 'custom_auth:starteritems')
    end
end

-- Trimmed copy of qb-multicharacter's house/garage config push so housing keeps working.
local function loadHouseData(src)
    local HouseGarages, Houses = {}, {}
    local result = MySQL.query.await('SELECT * FROM houselocations', {})
    if result and result[1] then
        for _, v in pairs(result) do
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = tonumber(v.owned) == 1,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = { label = v.label, takeVehicle = garage }
        end
    end
    TriggerClientEvent('qb-garages:client:houseGarageConfig', src, HouseGarages)
    TriggerClientEvent('qb-houses:client:setHouseConfig', src, Houses)
end

local function preloadThenSpawn(src, coords, isNew)
    -- give other resources a beat to preload against the freshly created Player
    Wait(750)
    QBCore.Commands.Refresh(src)
    loadHouseData(src)
    if isNew then giveStarterItems(src) end
    TriggerClientEvent('custom_auth:client:finishSpawn', src, coords, isNew)
    print(('^2[custom_auth]^7 %s loaded into the world (%s).'):format(GetPlayerName(src), isNew and 'new character' or 'returning'))
end

-- ────────────────────────────────────────────────────────────────────────────
--  Exports consumed by custom_charcreator
-- ────────────────────────────────────────────────────────────────────────────
exports('GetSession', function(src) return Sessions[src] end)

exports('BindCharacter', function(src, citizenid)
    local sess = Sessions[src]
    if not sess or not sess.userid then return false end
    MySQL.update.await('UPDATE `users` SET `citizenid` = ? WHERE `id` = ?', { citizenid, sess.userid })
    sess.citizenid = citizenid
    sess.creating = false
    return true
end)

-- Staff / subscription helpers (used by custom_chat)
exports('GetStaff', function(src)
    local sess = Sessions[src]
    return (sess and sess.staff) or 'none'
end)

exports('GetSubscription', function(src)
    local sess = Sessions[src]
    return (sess and sess.subscription) or 'none'
end)

-- Persist a staff rank by ACCOUNT id (users.id). Updates the live session if online.
exports('SetStaff', function(accountId, rank)
    accountId = tonumber(accountId)
    if not accountId then return false end
    rank = tostring(rank or 'none')
    MySQL.update.await('UPDATE `users` SET `staff` = ? WHERE `id` = ?', { rank, accountId })
    for src, s in pairs(Sessions) do
        if s.userid == accountId then
            s.staff = rank
            TriggerEvent('custom_auth:server:accountUpdated', src, 'staff', rank)
        end
    end
    return true
end)

exports('SetSubscription', function(accountId, tier)
    accountId = tonumber(accountId)
    if not accountId then return false end
    tier = tostring(tier or 'none')
    MySQL.update.await('UPDATE `users` SET `subscription` = ? WHERE `id` = ?', { tier, accountId })
    for src, s in pairs(Sessions) do
        if s.userid == accountId then
            s.subscription = tier
            TriggerEvent('custom_auth:server:accountUpdated', src, 'subscription', tier)
        end
    end
    return true
end)

-- Called by custom_charcreator once a brand-new character has been created & the
-- QBCore player logged in. Finishes preload and spawns at the fixed RPG start.
exports('FinishNewCharacter', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local s = Config.NewCharacterSpawn
        Player.Functions.SetPlayerData('position', vector4(s.x, s.y, s.z, s.w))
        Player.Functions.Save()
    end
    preloadThenSpawn(src, Config.NewCharacterSpawn, true)
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Register
-- ────────────────────────────────────────────────────────────────────────────
QBCore.Functions.CreateCallback('custom_auth:server:register', function(source, cb, data)
    local src = source
    data = data or {}
    local username = tostring(data.username or ''):gsub('%s+', '')
    local email = tostring(data.email or ''):gsub('%s+', ''):lower()
    local password = tostring(data.password or '')
    local confirm = tostring(data.confirmPassword or '')

    if #username < Config.Username.min or #username > Config.Username.max or not username:match(Config.Username.pattern) then
        return cb({ status = false, field = 'username', msg = 'Username invalid (3-24 caractere, litere/cifre/._).' })
    end
    if not email:match(Config.EmailPattern) then
        return cb({ status = false, field = 'email', msg = 'Adresa de email nu este validă.' })
    end
    if #password < Config.Password.min or #password > Config.Password.max then
        return cb({ status = false, field = 'password', msg = ('Parola trebuie să aibă între %d și %d caractere.'):format(Config.Password.min, Config.Password.max) })
    end
    if password ~= confirm then
        return cb({ status = false, field = 'confirmPassword', msg = 'Parolele nu se potrivesc.' })
    end

    local existing = MySQL.query.await('SELECT username, email FROM `users` WHERE username = ? OR email = ?', { username, email })
    if existing and existing[1] then
        local taken = (existing[1].username:lower() == username:lower()) and 'username' or 'email'
        return cb({ status = false, field = taken, msg = (taken == 'username') and 'Username-ul este deja folosit.' or 'Email-ul este deja folosit.' })
    end

    local license = QBCore.Functions.GetIdentifier(src, 'license') or ('unknown:' .. src)
    local hashed = Hash.create(password, Config.HashIterations)

    local insertId = MySQL.insert.await(
        'INSERT INTO `users` (license, username, email, password) VALUES (?, ?, ?, ?)',
        { license, username, email, hashed }
    )
    if not insertId then
        return cb({ status = false, msg = 'Eroare la baza de date. Încearcă din nou.' })
    end

    Sessions[src] = {
        userid = insertId, username = username, license = license, citizenid = nil,
        staff = 'none', subscription = 'none', authed = true, creating = true,
    }
    dbg('registered', username, 'id', insertId)
    cb({ status = true, msg = 'Cont creat. Continuă cu crearea caracterului.', hasCharacter = false, username = username })
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Login
-- ────────────────────────────────────────────────────────────────────────────
QBCore.Functions.CreateCallback('custom_auth:server:login', function(source, cb, data)
    local src = source
    data = data or {}
    local username = tostring(data.username or ''):gsub('%s+', '')
    local password = tostring(data.password or '')

    if username == '' or password == '' then
        return cb({ status = false, msg = 'Completează username și parolă.' })
    end

    local row = MySQL.single.await('SELECT * FROM `users` WHERE username = ?', { username })
    if not row then
        return cb({ status = false, field = 'username', msg = 'Contul nu există.' })
    end
    if not Hash.verify(password, row.password) then
        return cb({ status = false, field = 'password', msg = 'Parolă incorectă.' })
    end

    local license = QBCore.Functions.GetIdentifier(src, 'license') or ('unknown:' .. src)

    -- Re-bind the account (and its character) to the machine currently connecting,
    -- so an account is portable between PCs on this RPG server.
    if row.license ~= license then
        MySQL.update.await('UPDATE `users` SET `license` = ? WHERE `id` = ?', { license, row.id })
        if row.citizenid then
            MySQL.update.await('UPDATE `players` SET `license` = ? WHERE `citizenid` = ?', { license, row.citizenid })
        end
    end

    local hasCharacter = false
    if row.citizenid then
        local exists = MySQL.scalar.await('SELECT 1 FROM `players` WHERE citizenid = ? LIMIT 1', { row.citizenid })
        hasCharacter = exists ~= nil
    end

    Sessions[src] = {
        userid = row.id,
        username = row.username,
        license = license,
        citizenid = hasCharacter and row.citizenid or nil,
        staff = row.staff or 'none',
        subscription = row.subscription or 'none',
        authed = true,
        creating = not hasCharacter,
    }
    dbg('login', username, 'hasCharacter', hasCharacter)
    cb({
        status = true,
        hasCharacter = hasCharacter,
        username = row.username,
        msg = hasCharacter and 'Autentificare reușită.' or 'Continuă cu crearea caracterului.',
    })
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Finalize: load the existing character and spawn
-- ────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('custom_auth:server:finalizeLogin', function()
    local src = source
    local sess = Sessions[src]
    if not sess or not sess.authed or not sess.citizenid then
        dbg('finalizeLogin rejected for', src)
        return
    end

    if not QBCore.Player.Login(src, sess.citizenid) then
        TriggerClientEvent('custom_auth:client:loginError', src, 'Nu am putut încărca caracterul. Reconectează-te.')
        return
    end

    local coords = Config.NewCharacterSpawn
    if Config.UseLastLocationOnLogin then
        local Player = QBCore.Functions.GetPlayer(src)
        local pos = Player and Player.PlayerData.position
        if pos and pos.x then
            coords = vector4(pos.x + 0.0, pos.y + 0.0, pos.z + 0.0, pos.a or pos.w or 0.0)
        end
    end

    preloadThenSpawn(src, coords, false)
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Cleanup / logout
-- ────────────────────────────────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    Sessions[source] = nil
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    local sess = Sessions[src]
    if sess then
        sess.authed = false -- citizenid is kept so a re-login in the same session is instant
    end
end)

RegisterNetEvent('custom_auth:server:quit', function()
    local src = source
    DropPlayer(src, 'Ai părăsit ecranul de autentificare.')
end)

QBCore.Commands.Add('logout', 'Deconectează-te de la cont și revino la ecranul de autentificare', {}, false, function(source)
    local src = source
    QBCore.Player.Logout(src)
    Sessions[src] = nil
    TriggerClientEvent('custom_auth:client:restart', src)
end)
