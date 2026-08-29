local QBCore = exports['qb-core']:GetCoreObject()

local inAuth = false
local authCam = nil
local handedOff = false -- passed control to custom_charcreator
local accountName = ''  -- username of the authenticated account

local function dbg(...)
    if Config.Debug then print('^5[custom_auth]^7', ...) end
end

-- ────────────────────────────────────────────────────────────────────────────
--  Scene helpers
-- ────────────────────────────────────────────────────────────────────────────
local function startCam()
    DestroyAllCams(true)
    authCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
        Config.Camera.coords.x, Config.Camera.coords.y, Config.Camera.coords.z,
        Config.Camera.rotation.x, Config.Camera.rotation.y, Config.Camera.rotation.z,
        Config.Camera.fov + 0.0, false, 0)
    SetCamActive(authCam, true)
    RenderScriptCams(true, false, 0, true, true)
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
end

local function stopCam()
    SetTimecycleModifier('default')
    if authCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(authCam, true)
        authCam = nil
    end
end

local function prepareScene()
    DoScreenFadeOut(0)
    Wait(200)

    local interior = GetInteriorAtCoords(Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    if interior ~= 0 then
        LoadInterior(interior)
        local tries = 0
        while not IsInteriorReady(interior) and tries < 50 do
            Wait(100); tries = tries + 1
        end
    end

    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z, false, false, false)
    SetEntityHeading(ped, Config.HiddenCoords.w)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    SetPlayerInvincible(PlayerId(), true)
    DisplayRadar(false)

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
end

-- ────────────────────────────────────────────────────────────────────────────
--  Auth lifecycle
-- ────────────────────────────────────────────────────────────────────────────
local function openAuth()
    inAuth = true
    handedOff = false
    prepareScene()
    startCam()
    Wait(150)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        rules = {
            usernameMin = Config.Username.min,
            usernameMax = Config.Username.max,
            passwordMin = Config.Password.min,
            passwordMax = Config.Password.max,
        },
    })
    Wait(250)
    DoScreenFadeIn(650)
end

-- Keep the player caged while the auth UI is up
CreateThread(function()
    while true do
        if inAuth then
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)
            ThefeedHideThisFrame()
            HideHudAndRadarThisFrame()
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- Boot
CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(100) end
    Wait(200)
    -- If the resource is (re)started while already in-game, don't cage the player.
    if LocalPlayer.state.isLoggedIn then return end
    openAuth()
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Hand-off helpers
-- ────────────────────────────────────────────────────────────────────────────
local function closeUiKeepScene()
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
end

local function handToCreator(mode)
    handedOff = true
    inAuth = false
    closeUiKeepScene()
    DoScreenFadeOut(350)
    Wait(450)
    stopCam()
    -- custom_charcreator takes over the same frozen/hidden ped with its own camera.
    TriggerEvent('custom_charcreator:client:start', { mode = mode, username = accountName }) -- 'register' | 'resume'
end

-- ────────────────────────────────────────────────────────────────────────────
--  NUI callbacks
-- ────────────────────────────────────────────────────────────────────────────
RegisterNUICallback('register', function(data, cb)
    QBCore.Functions.TriggerCallback('custom_auth:server:register', function(res)
        cb(res or { status = false, msg = 'Fără răspuns de la server.' })
        if res and res.status then
            accountName = res.username or ''
            Wait(400)
            handToCreator('register')
        end
    end, data)
end)

RegisterNUICallback('login', function(data, cb)
    QBCore.Functions.TriggerCallback('custom_auth:server:login', function(res)
        cb(res or { status = false, msg = 'Fără răspuns de la server.' })
        if res and res.status then
            accountName = res.username or ''
            Wait(400)
            if res.hasCharacter then
                inAuth = false
                handedOff = true
                closeUiKeepScene()
                DoScreenFadeOut(500)
                Wait(600)
                TriggerServerEvent('custom_auth:server:finalizeLogin')
            else
                handToCreator('resume')
            end
        end
    end, data)
end)

RegisterNUICallback('quit', function(_, cb)
    cb('ok')
    TriggerServerEvent('custom_auth:server:quit')
end)

-- ────────────────────────────────────────────────────────────────────────────
--  Spawn finalisation (both new character and returning login end up here)
-- ────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('custom_auth:client:finishSpawn', function(coords, isNew)
    handedOff = true
    inAuth = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    DoScreenFadeOut(250)
    Wait(500)
    stopCam()
    -- also drop any camera owned by custom_charcreator so we return to the gameplay cam
    RenderScriptCams(false, false, 0, true, true)
    DestroyAllCams(true)
    SetTimecycleModifier('default')

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)

    -- let the map stream in around the real spawn
    local tries = 0
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(ped) and tries < 100 do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(50); tries = tries + 1
    end

    SetEntityVisible(ped, true, false)
    SetPlayerInvincible(PlayerId(), false)
    FreezeEntityPosition(ped, false)
    DisplayRadar(true)
    ClearPedTasksImmediately(ped)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')

    Wait(400)
    DoScreenFadeIn(800)
    TriggerEvent('qb-weathersync:client:EnableSync')
end)

RegisterNetEvent('custom_auth:client:loginError', function(msg)
    inAuth = true
    handedOff = false
    SetNuiFocus(true, true)
    startCam()
    SendNUIMessage({ action = 'open' })
    SendNUIMessage({ action = 'error', view = 'login', msg = msg or 'Eroare la autentificare.' })
    DoScreenFadeIn(400)
end)

-- /logout : tear down the character and reopen auth
RegisterNetEvent('custom_auth:client:restart', function()
    handedOff = false
    DoScreenFadeOut(400)
    Wait(600)
    openAuth()
end)

-- Let other resources know we still own the screen
exports('IsInAuth', function() return inAuth end)
exports('HandedOff', function() return handedOff end)
