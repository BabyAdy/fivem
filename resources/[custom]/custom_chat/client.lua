-- Full NUI chat client. Replaces the built-in `chat` resource but keeps its
-- events (chat:addMessage / chat:addSuggestion(s) / chat:removeSuggestion /
-- chat:clear) working so every other QBCore resource is unaffected.

local composerOpen = false
local suggestions = {} -- name -> { name, help, params }

local function pushSuggestions()
    local list = {}
    for _, s in pairs(suggestions) do list[#list + 1] = s end
    table.sort(list, function(a, b) return a.name < b.name end)
    SendNUIMessage({ type = 'suggestions', list = list })
end

local function rgbToHex(c)
    if type(c) ~= 'table' then return nil end
    local r = math.floor(tonumber(c[1]) or 255)
    local g = math.floor(tonumber(c[2]) or 255)
    local b = math.floor(tonumber(c[3]) or 255)
    return ('^#%02X%02X%02X'):format(r % 256, g % 256, b % 256)
end

-- ── our own channel messages ────────────────────────────────────────────
RegisterNetEvent('custom_chat:client:message', function(data)
    SendNUIMessage({ type = 'msg', header = data.header or '', body = data.body or '' })
end)

-- ── compatibility: chat:addMessage ─────────────────────────────────────
local function handleAddMessage(data)
    if type(data) ~= 'table' then
        SendNUIMessage({ type = 'msg', header = '', body = tostring(data) })
        return
    end
    local prefix = rgbToHex(data.color) or ''
    local args = data.args or {}
    if #args >= 2 then
        SendNUIMessage({ type = 'msg', header = prefix .. tostring(args[1]), body = prefix .. tostring(args[2]) })
    elseif #args == 1 then
        SendNUIMessage({ type = 'msg', header = '', body = prefix .. tostring(args[1]) })
    elseif data.message then
        SendNUIMessage({ type = 'msg', header = '', body = prefix .. tostring(data.message) })
    end
end
RegisterNetEvent('chat:addMessage', handleAddMessage)
AddEventHandler('chat:addMessage', handleAddMessage)
RegisterNetEvent('chatMessage', function() end) -- keep the event name known

-- ── compatibility: suggestions ─────────────────────────────────────────
local function addSuggestion(name, help, params)
    if not name then return end
    suggestions[name] = { name = name, help = help or '', params = params or {} }
    pushSuggestions()
end
RegisterNetEvent('chat:addSuggestion', addSuggestion)
AddEventHandler('chat:addSuggestion', addSuggestion)

local function addSuggestions(list)
    if type(list) ~= 'table' then return end
    for _, s in pairs(list) do
        if s.name then suggestions[s.name] = { name = s.name, help = s.help or '', params = s.params or {} } end
    end
    pushSuggestions()
end
RegisterNetEvent('chat:addSuggestions', addSuggestions)
AddEventHandler('chat:addSuggestions', addSuggestions)

local function removeSuggestion(name)
    if name then suggestions[name] = nil; pushSuggestions() end
end
RegisterNetEvent('chat:removeSuggestion', removeSuggestion)
AddEventHandler('chat:removeSuggestion', removeSuggestion)

local function clearChat() SendNUIMessage({ type = 'clear' }) end
RegisterNetEvent('chat:clear', clearChat)
AddEventHandler('chat:clear', clearChat)
RegisterNetEvent('chatClear', clearChat)

-- ── open / close ───────────────────────────────────────────────────────
local function openChat(prefill)
    if composerOpen then return end
    composerOpen = true
    -- cursor = true so the mouse wheel can scroll back through chat history
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'open', prefill = prefill or '' })
end

RegisterNUICallback('close', function(_, cb)
    composerOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('send', function(data, cb)
    cb('ok')
    local text = tostring(data.text or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if text == '' then return end
    if text:sub(1, 1) == '/' then
        ExecuteCommand(text:sub(2))
    else
        TriggerServerEvent('custom_chat:server:say', text)
    end
end)

-- ── keybinds ───────────────────────────────────────────────────────────
RegisterCommand('+cc_open', function() openChat('') end, false)
RegisterCommand('-cc_open', function() end, false)
RegisterKeyMapping('+cc_open', 'Deschide chat-ul', 'keyboard', 'T')

RegisterCommand('+cc_cmd', function() openChat('/') end, false)
RegisterCommand('-cc_cmd', function() end, false)
RegisterKeyMapping('+cc_cmd', 'Deschide chat-ul (comandă)', 'keyboard', '/')

-- `/say`-style fallback command if a key is unbound
RegisterCommand('chat', function() openChat('') end, false)

-- built-in default suggestions
CreateThread(function()
    Wait(500)
    addSuggestion('/pc', 'Chat premium — abonați (Premium/VIP/Legend) și staff', { { name = 'mesaj', help = 'text' } })
    addSuggestion('/a', 'Chat administrativ — trial admin → owner', { { name = 'mesaj', help = 'text' } })
    addSuggestion('/hc', 'Chat helperi — trial helper → owner', { { name = 'mesaj', help = 'text' } })
end)
