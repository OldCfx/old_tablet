local tabletAnimDict = "amb@world_human_tourist_map@male@base"
local tabletAnim     = "base"
local tabletProp     = "prop_cs_tablet"
local tabletObj      = nil

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

local function playTabletAnim()
    local ped = PlayerPedId()
    loadAnimDict(tabletAnimDict)
    TaskPlayAnim(ped, tabletAnimDict, tabletAnim, 2.0, -1, -1, 49, 0, 0, 0, 0)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    tabletObj = CreateObject(GetHashKey(tabletProp), x, y, z + 0.2, true, true, true)
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


RegisterNetEvent('old_tablet:openTablet', function(linkOrLinks)
    local links = {}
    if type(linkOrLinks) == 'table' then
        links = linkOrLinks
    elseif type(linkOrLinks) == 'string' and linkOrLinks ~= '' then
        links = { linkOrLinks }
    end

    playTabletAnim()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        url = links[1],
        sites = links,
        uiSize = Config.uiSize
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
    stopTabletAnim()
end)


local function openLinksEditor(slot, preset)
    local existing = preset
    if existing == nil then
        existing = lib.callback.await('old_tablet:getLinks', false, slot) or {}
    end


    local inputs = {}
    if #existing == 0 then
        table.insert(inputs, { type = 'input', label = 'Lien 1', placeholder = 'https://...' })
    else
        for i = 1, #existing do
            table.insert(inputs, { type = 'input', label = ('Lien %d'):format(i), default = existing[i] })
        end
        table.insert(inputs,
            { type = 'input', label = ('Lien %d (nouveau)'):format(#existing + 1), placeholder = 'https://...' })
    end

    local result = lib.inputDialog('Configurer la tablette', inputs)
    if not result then return end


    local newLinks = {}
    for i = 1, #result do
        local url = tostring(result[i] or ''):gsub('^%s+', ''):gsub('%s+$', '')
        if url ~= '' then
            if not url:match('^https?://') then url = 'https://' .. url end
            table.insert(newLinks, url)
        end
    end



    TriggerServerEvent('old_tablet:saveLinks', slot, newLinks)
end


RegisterNetEvent('old_tablet:requestLinks', function(slot, existing)
    openLinksEditor(slot, existing or {})
end)


exports('editLink', function(slot)
    openLinksEditor(slot, nil)
end)
