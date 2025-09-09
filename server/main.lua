local function sanitizeLink(url)
    if url:match("youtube%.com/watch%?v=") then
        local videoId = url:match("v=([%w-_]+)")
        if videoId then return "https://www.youtube.com/embed/" .. videoId end
    end
    if url:match("youtu%.be/") then
        local videoId = url:match("be/([%w-_]+)")
        if videoId then return "https://www.youtube.com/embed/" .. videoId end
    end
    if url:match("twitch%.tv/([%w_]+)") then
        local channel = url:match("twitch%.tv/([%w_]+)")
        return ("https://player.twitch.tv/?channel=%s&parent=localhost"):format(channel)
    end
    if url:match("google%.com/maps") then
        url = url:gsub("/maps/place/", "/maps/embed/place/")
        url = url:gsub("/maps/", "/maps/embed/")
        return url
    end
    return url
end

local function sanitizeLinks(list)
    local out, seen = {}, {}
    for _, raw in ipairs(list or {}) do
        if type(raw) == 'string' then
            local url = raw:gsub('^%s+', ''):gsub('%s+$', '')
            if url ~= '' then
                if not url:match('^https?://') then url = 'https://' .. url end
                url = sanitizeLink(url)
                if not seen[url] then
                    seen[url] = true
                    table.insert(out, url)
                    if #out >= 20 then break end
                end
            end
        end
    end
    return out
end

exports('tablet', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local tablets = exports.ox_inventory:Search(inventory.id, 1, 'tablet')
        local tablet
        for _, v in pairs(tablets) do
            if v.slot == slot then
                tablet = v
                break
            end
        end

        local metadata = (tablet and tablet.metadata) or {}
        local links = metadata.links
        local single = metadata.link


        if (not links or #links == 0) and type(single) == 'string' and single ~= '' then
            links = { sanitizeLink(single) }
            exports.ox_inventory:SetMetadata(inventory.id, slot, { links = links, link = links[1] })
        end

        if not links or #links == 0 then
            TriggerClientEvent('old_tablet:requestLinks', inventory.id, slot, links or {})
            return false
        else
            TriggerClientEvent('old_tablet:openTablet', inventory.id, links)
        end
        return
    end
end)


lib.callback.register('old_tablet:getLinks', function(source, slot)
    local links = {}
    if type(slot) ~= 'number' then return links end

    local items = exports.ox_inventory:Search(source, 1, 'tablet')
    if items then
        for _, v in pairs(items) do
            if v.slot == slot then
                local md = v.metadata or {}
                if type(md.links) == 'table' then
                    links = md.links
                elseif type(md.link) == 'string' and md.link ~= '' then
                    links = { md.link }
                end
                break
            end
        end
    end
    return links
end)

RegisterNetEvent('old_tablet:saveLinks', function(slot, list)
    local src = source
    if type(slot) ~= 'number' or type(list) ~= 'table' then return end

    local cleaned = sanitizeLinks(list)

    if #cleaned == 0 then
        exports.ox_inventory:SetMetadata(src, slot, { links = nil, link = nil })
        TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'Liens supprimés' })
        return
    end

    exports.ox_inventory:SetMetadata(src, slot, { links = cleaned, link = cleaned[1] })
    TriggerClientEvent('ox_lib:notify', src,
        { type = 'success', description = ('%d lien(s) enregistré(s)'):format(#cleaned) })
end)
