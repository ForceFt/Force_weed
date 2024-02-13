local QBCore = exports['qb-core']:GetCoreObject()

-- Events
RegisterServerEvent('force-weed:server:getItem', function(itemlist)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemlist = itemlist
    local removed = false
    for k, v in pairs(itemlist) do
        if v.threshold > math.random(0, 100) then
            Player.Functions.AddItem(v.name, math.random(1, v.max))
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[v.name], "add")
            if v.remove ~= nil and not removed then
                removed = true
                Player.Functions.RemoveItem(v.remove, 1)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[v.remove], "remove")
            end
        end
    end
end)


QBCore.Functions.CreateUseableItem("trowel", function(source, item)
	local src = source
    TriggerClientEvent('force-weed:client:startpicking', src)
end)

QBCore.Functions.CreateUseableItem("empty_weed_bag", function(source, item)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName("raw_weed_skunk")
    if item ~= nil then
        TriggerClientEvent('force-weed:client:startdry', src)
        Player.Functions.RemoveItem("empty_weed_bag", 1)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["empty_weed_bag"], "remove")
    else
        TriggerClientEvent('QBCore:Notify', src, 'You have nothing to Dry!..', 'error')
    end
end)

