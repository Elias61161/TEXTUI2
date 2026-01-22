```lua
Put this on top of your client side and you don't need to do anything else. This is for classic cordinates

This is for spesific coord text-ui
CreateThread(function()
    exports['qs-textui']:create3DTextUI("test", {
        coords = vector3(-1461.18, -31.48, 54.63),
        displayDist = 6.0,
        interactDist = 2.0,
        enableKeyClick = true, -- If true when you near it and click key it will trigger the event that you write inside triggerData
        keyNum = 38,
        key = "E",
        text = "Test",
        triggerData = {
            triggerName = "",
            args = {}
        }
    })
end)
```

## qb-core/client/drawtext.lua
```lua
    exports['qb-core']:DrawText() => exports["qs-textui"]:displayTextUI(text, position)

    exports['qb-core']:HideText() => exports["qs-textui"]:hideTextUI()

    exports['qb-core']:KeyPressed() => Dont change it

    exports['qb-core']:ChangeText() => exports['qs-textui']:changeText(text, position)
```

### es_extended/client/functions.lua

function ESX.TextUI(...)
    return IsResourceFound('esx_textui') and exports['esx_textui']:TextUI(...)
end

---@return nil
function ESX.HideUI()
    return IsResourceFound('esx_textui') and exports['esx_textui']:HideUI()
end

set them to these:

function ESX.TextUI(...)
    return exports["qs-textui"]:displayTextUI(...)
end

---@return nil
function ESX.HideUI()
    return exports["qs-textui"]:hideTextUI()
end



Example drawtext

local texts = {}
if GetResourceState('qs-textui') == 'started' then
    function DrawText3D(x, y, z, text, id, key, theme)
        local _id = key
        if not texts[_id] then
            CreateThread(function()
                texts[_id] = 5
                while texts[_id] > 0 do
                    texts[_id] = texts[_id] - 1
                    Wait(0)
                end
                texts[_id] = nil
                exports['qs-textui']:DeleteDrawText3D(id)
                Debug('Deleted text', id)
            end)
            Debug('Created text', id)
            TriggerEvent('textui:DrawText3D', x, y, z, text, id, key, theme)
        end
        texts[_id] = 5
    end
else
    function DrawText3D(x, y, z, text)
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry('STRING')
        SetTextCentre(true)
        AddTextComponentString(text)
        SetDrawOrigin(x, y, z, 0)
        DrawText(0.0, 0.0)
        local factor = text:len() / 370
        DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
        ClearDrawOrigin()
    end
end