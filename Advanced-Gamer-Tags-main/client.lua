local headTagsEnabled = false
local currentRole = { tag = "Civilian", color = Config.DefaultColor }

local function getTagOffset(tag)
    local offsets = {
        ["Development Team"] = 0.042,
        ["Senior Staff Team"] = 0.040,
        ["High Staff Team"] = 0.038,
        ["Staff Team"] = 0.032,
        ["Co Owner"] = 0.035,
        ["Owner"] = 0.025,
        ["Booster"] = 0.025,
        ["Civilian"] = 0.022
    }
    return offsets[tag] or 0.022
end

function DrawText3D(x, y, z, id, role, name)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local dist = #(GetGameplayCamCoords() - vec(x, y, z))
    
    if onScreen then
        local textScale = 0.32
        
        -- Base settings for all text elements
        SetTextFont(0)
        SetTextProportional(0)
        SetTextCentre(false)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        
        -- Light Blue Bracket [
        SetTextScale(textScale, textScale)
        SetTextColour(87, 173, 255, 255)
        SetTextEntry("STRING")
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        AddTextComponentString("[")
        DrawText(_x - 0.020, _y)
        
        -- White ID
        SetTextScale(textScale, textScale)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        AddTextComponentString(id)
        DrawText(_x - 0.016, _y)
        
        -- Light Blue Bracket ]
        SetTextScale(textScale, textScale)
        SetTextColour(87, 173, 255, 255)
        SetTextEntry("STRING")
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        AddTextComponentString("]")
        DrawText(_x - 0.009, _y)
        
        -- Role with color
        SetTextScale(textScale, textScale)
        SetTextColour(role.color.r, role.color.g, role.color.b, 255)
        SetTextEntry("STRING")
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        AddTextComponentString(" " .. role.tag)
        DrawText(_x - 0.008, _y)
        
        -- Get dynamic offset based on role tag
        local tagOffset = getTagOffset(role.tag)
        
        -- Light Blue Separator |
        SetTextScale(textScale, textScale)
        SetTextColour(87, 173, 255, 255)
        SetTextEntry("STRING")
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        AddTextComponentString("   |")
        DrawText(_x + tagOffset, _y)
        
        -- Name (White)
        SetTextScale(textScale, textScale)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        AddTextComponentString("   " .. name)
        DrawText(_x + (tagOffset + 0.006), _y)
    end
end

function ManageHeadTags()
    for _, playerId in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(playerId) then
            local ped = GetPlayerPed(playerId)
            local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))

            if dist < Config.TagDistance then
                local id = GetPlayerServerId(playerId)
                local name = GetPlayerName(playerId)
                local coords = GetEntityCoords(ped)
                DrawText3D(coords.x, coords.y, coords.z + 1.0, id, currentRole, name)
            end
        end
    end
end

function ToggleHeadTags()
    headTagsEnabled = not headTagsEnabled
    local message = headTagsEnabled and 'Head tags enabled' or 'Head tags disabled'
    exports['mythic_notify']:SendAlert('inform', message, 5000, {
        ['background-color'] = '#87CEFA',
        ['color'] = '#000000'
    })
end

RegisterNetEvent('headtags:setRole')
AddEventHandler('headtags:setRole', function(role)
    currentRole = role
end)

RegisterCommand('headtags', function()
    ToggleHeadTags()
end, false)

RegisterKeyMapping('headtags', 'Toggle Head Tags', 'keyboard', Config.Keybind)

Citizen.CreateThread(function()
    while true do
        if headTagsEnabled then
            ManageHeadTags()
        end
        Citizen.Wait(0)
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('headtags:getRoles')
end)