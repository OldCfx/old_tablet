local tabletAnimDict = "amb@world_human_tourist_map@male@base"
local tabletAnim     = "base"
local tabletProp     = "prop_cs_tablet"
local tabletObj      = nil


local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end


local function playTabletAnim()
    local ped = PlayerPedId()
    loadAnimDict(tabletAnimDict)
    TaskPlayAnim(ped, tabletAnimDict, tabletAnim, 2.0, -1, -1, 49, 0, 0, 0, 0)


    local x, y, z = table.unpack(GetEntityCoords(ped))
    tabletObj     = CreateObject(GetHashKey(tabletProp), x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(tabletObj, ped, GetPedBoneIndex(ped, 28422),
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end


local function stopTabletAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if DoesEntityExist(tabletObj) then
        DeleteEntity(tabletObj)
        tabletObj = nil
    end
end


RegisterNetEvent('old_tablet:requestLink', function(slot)
    local input = lib.inputDialog('Configurer la tablette', {
        { type = 'input', label = 'Lien (URL)', placeholder = 'https://...' }
    })

    if input and input[1] and input[1] ~= '' then
        TriggerServerEvent('old_tablet:saveLink', slot, input[1])
    else
        lib.notify({
            title = 'Tablette',
            description = 'Aucun lien fourni',
            type = 'error'
        })
    end
end)

RegisterNetEvent('old_tablet:openTablet', function(link)
    playTabletAnim()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        url = link
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
    stopTabletAnim()
end)


exports('editLink', function(slot)
    TriggerEvent('old_tablet:requestLink', slot)
end)
