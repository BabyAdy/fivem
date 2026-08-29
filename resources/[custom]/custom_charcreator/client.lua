local QBCore = exports['qb-core']:GetCoreObject()

local active = false
local cam = nil
local camViews = {}          -- cached world coords per framing
local camTarget = nil        -- fixed point the cam looks at
local gender = 'male'
local heading = Config.PedCoords.w
local appearance = nil
local mode = 'register'
local accountName = ''

local function dbg(...)
    if Config.Debug then print('^6[custom_charcreator]^7', ...) end
end

local function deepcopy(t)
    if type(t) ~= 'table' then return t end
    local r = {}
    for k, v in pairs(t) do r[k] = deepcopy(v) end
    return r
end

local function clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo elseif v > hi then return hi end
    return math.floor(v + 0.5)
end

local function modelFor(g) return (g == 'female') and `mp_f_freemode_01` or `mp_m_freemode_01` end

-- ────────────────────────────────────────────────────────────────────────────
--  Appearance
-- ────────────────────────────────────────────────────────────────────────────
local function applyAppearance()
    local ped = PlayerPedId()
    local a = appearance

    local shape = a.heritage.resemblance / 100.0
    local skin = a.heritage.skinTone / 100.0
    SetPedHeadBlendData(ped, a.heritage.mother, a.heritage.father, 0,
        a.heritage.mother, a.heritage.father, 0, shape, skin, 0.0, true)

    SetPedComponentVariation(ped, 2, a.hair.style, 0, 0)
    SetPedHairColor(ped, a.hair.color, a.hair.highlight)

    local brow = a.eyebrows.style
    SetPedHeadOverlay(ped, 2, brow < 0 and 255 or brow, 1.0)
    SetPedHeadOverlayColor(ped, 2, 1, a.eyebrows.color, a.eyebrows.color)

    local beard = (gender == 'male') and a.beard.style or -1
    SetPedHeadOverlay(ped, 1, beard < 0 and 255 or beard, 1.0)
    SetPedHeadOverlayColor(ped, 1, 1, a.beard.color, a.beard.color)

    SetPedEyeColor(ped, a.eyeColor)

    -- fixed default outfit (t-shirt + trousers + sneakers), not user-editable
    local o = Config.DefaultOutfit[gender]
    SetPedComponentVariation(ped, 3, o.torso, 0, 2)       -- torso / arms
    SetPedComponentVariation(ped, 8, o.undershirt, 0, 2)  -- undershirt
    SetPedComponentVariation(ped, 11, o.top, 0, 2)        -- tops
    SetPedComponentVariation(ped, 4, o.pants, 0, 2)       -- legs
    SetPedComponentVariation(ped, 6, o.shoes, 0, 2)       -- feet
end

local function setModel(g)
    gender = (g == 'female') and 'female' or 'male'
    appearance = deepcopy(Config.Defaults[gender])

    local model = modelFor(gender)
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do RequestModel(model); Wait(50); t = t + 1 end

    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local ped = PlayerPedId()
    SetPedDefaultComponentVariation(ped)
    SetEntityCoordsNoOffset(ped, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, false, false, false)
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetEntityVisible(ped, true, false)
    ClearPedTasksImmediately(ped)

    applyAppearance()
end

local function randomize()
    local L = Config.Limits
    appearance.heritage.mother = math.random(L.parent.min, L.parent.max)
    appearance.heritage.father = math.random(L.parent.min, L.parent.max)
    appearance.heritage.resemblance = math.random(15, 85)
    appearance.heritage.skinTone = math.random(0, 100)
    appearance.hair.style = math.random(0, 25)
    appearance.hair.color = math.random(0, L.hairColor.max)
    appearance.hair.highlight = appearance.hair.color
    appearance.eyebrows.style = math.random(0, 15)
    appearance.eyebrows.color = appearance.hair.color
    if gender == 'male' then
        appearance.beard.style = math.random(-1, 15)
        appearance.beard.color = appearance.hair.color
    end
    appearance.eyeColor = math.random(0, L.eyeColor.max)
    applyAppearance()
end

-- ────────────────────────────────────────────────────────────────────────────
--  Camera
-- ────────────────────────────────────────────────────────────────────────────
local function cacheCamViews()
    local ped = PlayerPedId()
    SetEntityHeading(ped, Config.PedCoords.w)
    local base = GetEntityCoords(ped)
    camTarget = base
    for name, v in pairs(Config.Cameras) do
        local from = GetOffsetFromEntityInWorldCoords(ped, v.fromOffset.x, v.fromOffset.y, v.fromOffset.z)
        camViews[name] = { from = from, point = base + vector3(v.pointOffset.x, v.pointOffset.y, v.pointOffset.z), fov = v.fov }
    end
    SetEntityHeading(ped, heading)
end

local function setCamera(view)
    view = camViews[view] and view or 'body'
    local v = camViews[view]
    if not cam then
        cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', v.from.x, v.from.y, v.from.z, 0.0, 0.0, 0.0, v.fov, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    else
        SetCamCoord(cam, v.from.x, v.from.y, v.from.z)
        SetCamFov(cam, v.fov)
    end
    PointCamAtCoord(cam, v.point.x, v.point.y, v.point.z)
end

local function destroyCam()
    if cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, true)
        cam = nil
    end
end

-- ────────────────────────────────────────────────────────────────────────────
--  Start / stop
-- ────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('custom_charcreator:client:start', function(payload)
    if active then return end
    active = true
    payload = payload or {}
    mode = payload.mode or 'register'
    accountName = payload.username or ''

    DoScreenFadeOut(200)
    Wait(300)

    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, false, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    heading = Config.PedCoords.w
    setModel('male')
    cacheCamViews()
    setCamera('body')

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        mode = mode,
        username = accountName,
        limits = Config.Limits,
        appearance = appearance,
        gender = gender,
    })

    Wait(250)
    DoScreenFadeIn(650)
end)

-- keep player caged while creating
CreateThread(function()
    while true do
        if active then
            DisableAllControlActions(0)
            HideHudAndRadarThisFrame()
            ThefeedHideThisFrame()
            Wait(0)
        else
            Wait(500)
        end
    end
end)

local function cleanupScene()
    active = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    destroyCam()
end

-- custom_auth fires this once the character is in the world
RegisterNetEvent('custom_auth:client:finishSpawn', function()
    if not active and not cam then return end
    cleanupScene()
end)

-- ────────────────────────────────────────────────────────────────────────────
--  NUI callbacks
-- ────────────────────────────────────────────────────────────────────────────
RegisterNUICallback('setGender', function(data, cb)
    heading = Config.PedCoords.w
    setModel(data.gender)
    cacheCamViews()
    setCamera(data.view or 'face')
    cb({ appearance = appearance, gender = gender })
end)

RegisterNUICallback('updateAppearance', function(data, cb)
    local field, value = data.field, data.value
    local L = Config.Limits
    if field == 'heritage.mother' then appearance.heritage.mother = clamp(value, L.parent.min, L.parent.max)
    elseif field == 'heritage.father' then appearance.heritage.father = clamp(value, L.parent.min, L.parent.max)
    elseif field == 'heritage.resemblance' then appearance.heritage.resemblance = clamp(value, L.mix.min, L.mix.max)
    elseif field == 'heritage.skinTone' then appearance.heritage.skinTone = clamp(value, L.mix.min, L.mix.max)
    elseif field == 'hair.style' then appearance.hair.style = clamp(value, L.hair.min, L.hair.max)
    elseif field == 'hair.color' then appearance.hair.color = clamp(value, L.hairColor.min, L.hairColor.max); appearance.hair.highlight = appearance.hair.color
    elseif field == 'eyebrows.style' then appearance.eyebrows.style = clamp(value, L.eyebrows.min, L.eyebrows.max)
    elseif field == 'eyebrows.color' then appearance.eyebrows.color = clamp(value, L.overlayColor.min, L.overlayColor.max)
    elseif field == 'beard.style' then appearance.beard.style = clamp(value, L.beard.min, L.beard.max)
    elseif field == 'beard.color' then appearance.beard.color = clamp(value, L.overlayColor.min, L.overlayColor.max)
    elseif field == 'eyeColor' then appearance.eyeColor = clamp(value, L.eyeColor.min, L.eyeColor.max)
    end
    applyAppearance()
    cb({ appearance = appearance })
end)

RegisterNUICallback('rotate', function(data, cb)
    heading = (heading + (tonumber(data.dir) or 0) * 12.0) % 360.0
    SetEntityHeading(PlayerPedId(), heading)
    cb('ok')
end)

RegisterNUICallback('camera', function(data, cb)
    setCamera(data.view or 'body')
    cb('ok')
end)

RegisterNUICallback('randomize', function(_, cb)
    randomize()
    cb({ appearance = appearance })
end)

RegisterNUICallback('quit', function(_, cb)
    cb('ok')
    TriggerServerEvent('custom_auth:server:quit')
end)

RegisterNUICallback('confirm', function(_, cb)
    local payload = {
        gender = (gender == 'female') and 1 or 0,
        appearance = appearance,
    }

    QBCore.Functions.TriggerCallback('custom_charcreator:server:create', function(res)
        if not res or not res.status then
            return cb({ status = false, msg = (res and res.msg) or 'Eroare la crearea caracterului.' })
        end
        cb({ status = true })
        -- server has logged the player in and will trigger custom_auth:client:finishSpawn
        active = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close' })
        DoScreenFadeOut(500)
    end, payload)
end)
