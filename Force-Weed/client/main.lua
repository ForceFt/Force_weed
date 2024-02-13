-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local inPickingArea = false
local currentspot = nil
local previousspot = nil
local PickingLocations = {}
local RedneckPed = {}
local pedSpawned = false
local lastTime = 0

-- Functions

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
       return tostring(o)
    end
end

local function loadModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
        RequestModel(model)
    end
    return model
end

local function loadDict(dict, anim)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        RequestAnimDict(dict)
    end
    return dict
end

local function helpText(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end


-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() -- Event when player has successfully loaded
    TriggerEvent('force-weed:client:DestroyZones') -- Destroy all zones
	Wait(100)
	TriggerEvent('force-weed:client:UpdatePickingZones') -- Reload mining information
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() -- Reset all variables
	TriggerEvent('force-weed:client:DestroyZones') -- Destroy all zones
	inPickingArea = false
    currentspot = nil
    previousspot = nil
    PickingLocations = {}
end)

AddEventHandler('onResourceStart', function(resource) -- Event when resource is reloaded
    if resource == GetCurrentResourceName() then -- Reload player information
		TriggerEvent('force-weed:client:DestroyZones') -- Destroy all zones
		Wait(100)
		TriggerEvent('force-weed:client:UpdatePickingZones') -- Reload mining information
		Wait(100)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then -- Reload player information
		TriggerEvent('force-weed:client:DestroyZones') -- Destroy all zones
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) --Events when players change jobs
    TriggerEvent('force-weed:client:DestroyZones') -- Destroy all zones
	Wait(100)
	TriggerEvent('force-weed:client:UpdatePickingZones') -- Reload mining information
	Wait(100)
end)

RegisterNetEvent('force-weed:client:UpdatePickingZones', function() -- Update Picking Zones
    for k, v in pairs(Config.Picking) do
        PickingLocations[k] = PolyZone:Create(v.zones, {
            name='Picking '..k,
            minZ = 	v.minz,
            maxZ = v.maxz,
            debugPoly = false
        })
    end
end)

RegisterNetEvent('force-weed:client:DestroyZones', function() -- Destroy all zones
    if PickingLocations then
		for k, v in pairs(PickingLocations) do
			PickingLocations[k]:destroy()
		end
	end
	PickingLocations = {}
end)

RegisterNetEvent('force-weed:client:startpicking', function() -- Start mining
	if not pickWait then
		pickWait = true
		SetTimeout(5000, function()
			pickWait = false
		end)
		local Ped = PlayerPedId()
		local coord = GetEntityCoords(Ped)
		for k, v in pairs(PickingLocations) do
			if PickingLocations[k] then
				if PickingLocations[k]:isPointInside(coord) then
					local model = loadModel(`p_cs_scissors_s`)
					local axe = CreateObject(model, GetEntityCoords(Ped), true, false, false)
					AttachEntityToEntity(axe, Ped, GetPedBoneIndex(Ped, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)
					QBCore.Functions.Progressbar("startpicking", "Cutting down Cannabis", 3000, false, false, {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
                    }, {
						animDict = "mini@repair", 
						anim = "fixing_a_player", 
						flags = 8,
					}, {}, {}, function() -- Done
						Wait(1000)
                        			StopAnimTask(Ped, "mini@repair", "startpicking", 1.0)
						ClearPedTasks(Ped)
						DeleteObject(axe)
                                                TriggerEvent("force-weed:client:Pedspawn")
						TriggerServerEvent('force-weed:server:getItem', Config.PickingItems)
						QBCore.Functions.Notify("You picked some  cannabis..", "success")
					end)
				end
			end
		end
	else
		QBCore.Functions.Notify("You Arm Getting Tired.", "error")
	end
end)

RegisterNetEvent('force-weed:client:startdry', function() -- Start smelting
	local Ped = PlayerPedId()
	local coord = GetEntityCoords(Ped)
		QBCore.Functions.Progressbar("startdry", "Bagging Weed", 6000, false, false, {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {
			animDict = "mp_arresting", 
			anim = "a_uncuff", 
			flags = 8,
		}, {}, {}, function() -- Done
			StopAnimTask(Ped, "mp_arresting", "startdry", 1.0)
			ClearPedTasks()
			TriggerServerEvent('force-weed:server:getItem', Config.BaggingItems)
			QBCore.Functions.Notify("You have bagged your  cannabis!..", "success")					
		end)
end)


RegisterNetEvent('force-weed:client:Pedspawn', function()
	if  GetClockHours() >= 6 and GetClockHours() <= 21 then 
		if pedSpawned then return end
		for k, v in pairs(Config.RednecksLocations) do
			if not RedneckPed[k] then RedneckPed[k] = {} end
			local nped = v["ped"]
			nped = type(nped) == 'string' and GetHashKey(nped) or nped
			RequestModel(nped)

			while HasModelLoaded(nped) == false do
				Wait(0)
			end 

			RedneckPed[k] = CreatePed(0, nped, v["coords"].x, v["coords"].y, v["coords"].z-1, v["coords"].w, true, false)

			SetEntityAsMissionEntity(RedneckPed[k], true, true)
			SetPedCombatAttributes(RedneckPed[k], 0, True)
			SetPedCombatAttributes(RedneckPed[k], 5, True)
			SetPedCombatAttributes(RedneckPed[k], 46, True)
			GiveWeaponToPed(RedneckPed[k], v["gun"], 100, true, false)
			SetPedFleeAttributes(RedneckPed[k], 0, 0)
			SetPedArmour(RedneckPed[k], 100)
			SetPedMaxHealth(RedneckPed[k], 100)
			SetEntityOnlyDamagedByPlayer(RedneckPed[k], true)
			TaskCombatPed(RedneckPed[k], GetPlayerPed(-1), 0, 16)
			PlayPedAmbientSpeechNative(RedneckPed[k], "Shout_Threaten_Ped", "Speech_Params_Force_Shouted_Critical")
			SetPedAsCop(RedneckPed[k], true)
    
		end
	

	end

end)

