local function sanitizeLink(url)
    if url:match("youtube%.com/watch%?v=") then
        local videoId = url:match("v=([%w-_]+)")
        if videoId then
            return "https://www.youtube.com/embed/" .. videoId
        end
    end


    if url:match("youtu%.be/") then
        local videoId = url:match("be/([%w-_]+)")
        if videoId then
            return "https://www.youtube.com/embed/" .. videoId
        end
    end


    if url:match("twitch%.tv/([%w_]+)") then
        local channel = url:match("twitch%.tv/([%w_]+)")
        return "https://player.twitch.tv/?channel=" .. channel .. "&parent=localhost"
    end


    if url:match("google%.com/maps") then
        url = url:gsub("/maps/place/", "/maps/embed/place/")
        url = url:gsub("/maps/", "/maps/embed/")
        return url
    end


    return url
end



exports('tablet', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local tablets = exports.ox_inventory:Search(inventory.id, 1, 'tablet')
        local tablet = nil

        for _, v in pairs(tablets) do
            if v.slot == slot then
                tablet = v
                break
            end
        end

        local metadata = (tablet and tablet.metadata) or {}

        if not metadata.link then
            TriggerClientEvent('old_tablet:requestLink', inventory.id, slot)
            return false
        else
            TriggerClientEvent('old_tablet:openTablet', inventory.id, metadata.link)
        end

        return
    end
end)



RegisterNetEvent('old_tablet:saveLink', function(slot, link)
    local src = source


    if not link or not link:match("^http") then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Lien invalide (doit commencer par http:// ou https://)'
        })
        return
    end


    local safeLink = sanitizeLink(link)

    exports.ox_inventory:SetMetadata(src, slot, { link = safeLink })

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = 'Lien enregistré sur la tablette'
    })
end)
