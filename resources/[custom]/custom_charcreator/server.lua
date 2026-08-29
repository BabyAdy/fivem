local QBCore = exports['qb-core']:GetCoreObject()

local function dbg(...)
    if Config.Debug then print('^6[custom_charcreator]^7', ...) end
end

local function clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo elseif v > hi then return hi end
    return math.floor(v + 0.5)
end

-- Build a qb-clothing / playerskins compatible skin table from the creator's picks.
local function buildSkin(app, gender)
    local L = Config.Limits
    local skin = {}
    for k, v in pairs(Config.SkinTemplate) do
        skin[k] = { item = v.item, texture = v.texture, defaultTexture = v.defaultTexture, defaultItem = v.defaultItem }
        if k == 'facemix' then
            skin[k] = { shapeMix = v.shapeMix, skinMix = v.skinMix, defaultShapeMix = v.defaultShapeMix, defaultSkinMix = v.defaultSkinMix }
        end
    end

    local h = app.heritage or {}
    skin['face'].item      = clamp(h.mother, L.parent.min, L.parent.max)
    skin['face'].texture   = clamp(h.mother, L.parent.min, L.parent.max)
    skin['face2'].item     = clamp(h.father, L.parent.min, L.parent.max)
    skin['face2'].texture  = clamp(h.father, L.parent.min, L.parent.max)
    skin['facemix'].shapeMix = clamp(h.resemblance, 0, 100) / 100.0
    skin['facemix'].skinMix  = clamp(h.skinTone, 0, 100) / 100.0

    skin['hair'].item    = clamp(app.hair and app.hair.style, L.hair.min, L.hair.max)
    skin['hair'].texture = clamp(app.hair and app.hair.color, L.hairColor.min, L.hairColor.max)

    skin['eyebrows'].item    = clamp(app.eyebrows and app.eyebrows.style, -1, L.eyebrows.max)
    skin['eyebrows'].texture = clamp(app.eyebrows and app.eyebrows.color, 0, L.overlayColor.max)

    if gender == 'male' then
        skin['beard'].item    = clamp(app.beard and app.beard.style, -1, L.beard.max)
        skin['beard'].texture = clamp(app.beard and app.beard.color, 0, L.overlayColor.max)
    else
        skin['beard'].item = -1
    end

    skin['eye_color'].item = clamp(app.eyeColor, 0, L.eyeColor.max)

    -- fixed default outfit for this gender (t-shirt + trousers + sneakers)
    local o = Config.DefaultOutfit[gender]
    skin['arms'].item    = o.torso
    skin['t-shirt'].item = o.undershirt
    skin['torso2'].item  = o.top
    skin['pants'].item    = o.pants
    skin['shoes'].item   = o.shoes

    return skin
end

local function savePlayerSkin(citizenid, model, skinTable)
    local hash = GetHashKey(model)
    MySQL.query.await('DELETE FROM playerskins WHERE citizenid = ?', { citizenid })
    MySQL.insert.await('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
        citizenid, tostring(hash), json.encode(skinTable), 1,
    })
end

QBCore.Functions.CreateCallback('custom_charcreator:server:create', function(source, cb, data)
    local src = source
    data = data or {}

    local sess = exports['custom_auth']:GetSession(src)
    if not sess or not sess.authed then
        return cb({ status = false, msg = 'Sesiune de autentificare invalidă.' })
    end
    if sess.citizenid then
        return cb({ status = false, msg = 'Ai deja un caracter pe acest cont.' })
    end
    if not sess.username or sess.username == '' then
        return cb({ status = false, msg = 'Contul nu are un username valid.' })
    end

    local gender = (tonumber(data.gender) == 1) and 'female' or 'male'
    local model = (gender == 'female') and 'mp_f_freemode_01' or 'mp_m_freemode_01'

    -- Character name is the account username; the rest of charinfo comes from config.
    local newData = {
        cid = 1,
        charinfo = {
            firstname = sess.username,
            lastname = Config.Character.lastname or '',
            birthdate = Config.Character.birthdate or '2000-01-01',
            gender = (gender == 'female') and 1 or 0,
            nationality = Config.Character.nationality or 'România',
        },
    }

    if not QBCore.Player.Login(src, false, newData) then
        return cb({ status = false, msg = 'QBCore nu a putut crea caracterul.' })
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return cb({ status = false, msg = 'Jucătorul nu a putut fi încărcat după creare.' })
    end
    local citizenid = Player.PlayerData.citizenid

    local skin = buildSkin(data.appearance or {}, gender)
    savePlayerSkin(citizenid, model, skin)

    exports['custom_auth']:BindCharacter(src, citizenid)
    dbg('created character', citizenid, 'for account', sess.username)

    cb({ status = true, citizenid = citizenid })

    CreateThread(function()
        exports['custom_auth']:FinishNewCharacter(src)
    end)
end)
