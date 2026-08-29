local QBCore = exports['qb-core']:GetCoreObject()

local beltOn = false
local cruiseOn = false
local nitro = { level = 0, has = false }
local harnessHp = 0

local SPEED_MULT = (Config.SpeedUnit == 'mph') and 2.236936 or 3.6

-- state fed by qb-smallresources / qb-mechanicjob (kept enabled)
AddEventHandler('seatbelt:client:ToggleSeatbelt', function(state)
    if state == nil then state = not beltOn end
    beltOn = state and true or false
end)
AddEventHandler('seatbelt:client:ToggleCruise', function(state)
    if state == nil then state = not cruiseOn end
    cruiseOn = state and true or false
end)
RegisterNetEvent('hud:client:UpdateNitrous', function(level, has)
    nitro.level = level or 0
    nitro.has = has and true or false
end)
RegisterNetEvent('hud:client:UpdateHarness', function(hp)
    harnessHp = tonumber(hp) or 0
end)

local lastSpeedStress = 0
local wasInVehicle = false

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()

        if Config.ShowVehicleHud and IsPedInAnyVehicle(ped, false) then
            wasInVehicle = true
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                sleep = 80
                local isDriver = GetPedInVehicleSeat(veh, -1) == ped
                local speed = GetEntitySpeed(veh) * SPEED_MULT
                local gear = GetVehicleCurrentGear(veh)
                local rpm = GetVehicleCurrentRpm(veh)
                local _ls, lightsOn, highBeams = GetVehicleLightsState(veh)
                local fuel = 0
                local okf, f = pcall(function() return exports['qb-fuel']:GetFuel(veh) end)
                if okf and f then fuel = math.floor(f + 0.5) end

                SendNUIMessage({
                    action = 'vehicle',
                    inVehicle = true,
                    data = {
                        speed = math.floor(speed + 0.5),
                        unit = Config.SpeedUnit,
                        gear = (gear == 0) and 'R' or gear,
                        rpm = rpm,                                    -- 0..1
                        fuel = fuel,                                  -- 0..100
                        engine = math.max(0, math.floor(GetVehicleEngineHealth(veh) / 10)), -- 0..100
                        engineOn = GetIsVehicleEngineRunning(veh),
                        belt = beltOn,
                        cruise = cruiseOn,
                        lights = highBeams == 1 and 2 or (lightsOn == 1 and 1 or 0),
                        nitro = nitro.has and math.floor(nitro.level) or -1,
                        harness = harnessHp > 0 and harnessHp or -1,
                        seat = GetPedInVehicleSeat(veh, -1) == ped and 'driver' or 'passenger',
                        locked = GetVehicleDoorLockStatus(veh) >= 2,
                    },
                })

                -- speeding stress (driver only)
                if isDriver and Config.Stress.enable then
                    local now = GetGameTimer()
                    local threshold = beltOn and Config.Stress.minSpeedBuckled or Config.Stress.minSpeedUnbuckled
                    -- normalise threshold to the configured unit's number space (config is kmh)
                    local speedKmh = GetEntitySpeed(veh) * 3.6
                    if speedKmh >= threshold and now - lastSpeedStress > 5000 then
                        lastSpeedStress = now
                        TriggerServerEvent('hud:server:GainStress',
                            math.random(Config.Stress.speedAmount.min, Config.Stress.speedAmount.max))
                    end
                end
            end
        else
            if wasInVehicle then
                wasInVehicle = false
                beltOn, cruiseOn = false, false
                SendNUIMessage({ action = 'vehicle', inVehicle = false })
            end
            sleep = 500
        end

        Wait(sleep)
    end
end)
