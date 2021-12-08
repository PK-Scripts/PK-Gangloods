isLoggedIn = false
insideGangLoods = false
GangLoods = nil
GangKey = nil
PlayerItems = nil
Loodsinv = nil
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    isLoggedIn = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
    isLoggedIn = true

end)

Citizen.CreateThread(function()
	while ESX == nil do 
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	if ESX ~= nil then
        PlayerData = ESX.GetPlayerData()
	end
	
	while true do
		if isLoggedIn then
			if GangLoods == nil then
				ESX.TriggerServerCallback('pk-gangloods:krijgGangLoods', function(GangLoodsLoad)
					if GangLoodsLoad == nil then
						GangLoods = "{}"
					else
						GangLoods = GangLoodsLoad
					end
				end)
			end
			if VehicleTable == nil then
				ESX.TriggerServerCallback('pk-gangloods:GeefVoertuig', function(Vehilces)
					if Vehilces == nil then
						VehicleTable = "{}"
					else
						VehicleTable = Vehilces
					end
				end)
			end
			if PlayerItems == nil then
				ESX.TriggerServerCallback('pk-gangloods:getInventory', function(Inventory) 
					PlayerItems = Inventory
				end)
			end
			if Loodsinv == nil then
					Loodsinv = "{}"
			end
		end
		Citizen.Wait(10)
	end
end) 

Citizen.CreateThread(function()
	while true do
		if GangLoods ~= nil and GangLoods ~= "{}" and isLoggedIn then
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped, true)
			for k,v in pairs(GangLoods) do
				if ESX.PlayerData.job ~= nil and v.gang == ESX.PlayerData.job.name then
					if not insideGangLoods then
						local ingang = json.decode(GangLoods[k].ingang)
						local xingang,yingang,zingang,textingang = tonumber(ingang.x),tonumber(ingang.y),tonumber(ingang.z),Config.Offsets[GangLoods[k].gangloods].text
						local DistanceBetweenIngang = #(pos - vector3(xingang,yingang,zingang))
						local veh = GetVehiclePedIsIn(ped, false)
						if DistanceBetweenIngang < 1.5 and not IsPedInVehicle(ped, veh) then 
							DrawText3Ds(xingang,yingang,zingang, "[~g~E~w~] · Naar binnen gaan")
							if DistanceBetweenIngang < 1 then
								if IsControlJustPressed(0, Keys["E"]) then						
									BetreedGangloods(GangLoods[k])
									GangKey = k
								end
							end
						end
						
						local delelete = json.decode(GangLoods[k].garagedeletepoint)
						local deletepointx,deletepointy,deletepointz = tonumber(delelete.x),tonumber(delelete.y),tonumber(delelete.z)
						local DistanceBetweenGarageDeletePoint = #(pos - vector3(deletepointx,deletepointy,deletepointz))
						if DistanceBetweenGarageDeletePoint < 5 and IsPedInVehicle(ped, veh) then
							DrawText3Ds(deletepointx,deletepointy,deletepointz, '[~g~E~w~] · Zet voertuig in garage')
							if DistanceBetweenGarageDeletePoint < 2.5 and IsPedInVehicle(ped, veh) then
								if IsControlJustPressed(0, Keys["E"]) then
									ESX.TriggerServerCallback('pk-gangloods:CheckIfOwned', function(isOwned)
										if isOwned then
											TriggerServerEvent('pk-gangloods:ZerInGarage', plate)
											ESX.Game.DeleteVehicle(veh)
										else
											ESX.Game.DeleteVehicle(veh)
										end
									end, ESX.Math.Trim(GetVehicleNumberPlateText(veh)))
								end
							end
						end
					else
						local ingang = json.decode(GangLoods[k].ingang)
						local x,y,z,textingang = tonumber(ingang.x),tonumber(ingang.y),tonumber(ingang.z),Config.Offsets[GangLoods[k].gangloods].exitloods.text
						local DistanceBetweenIngang = #(pos - vector3(x + POIOffsets.x, y + POIOffsets.y, z + Config.ZOffset + POIOffsets.z))
						if DistanceBetweenIngang < 1.5 then 
							DrawText3Ds(x + POIOffsets.x, y + POIOffsets.y, z + Config.ZOffset + POIOffsets.z, textingang)
							if DistanceBetweenIngang < 1 then
								if IsControlJustPressed(0, Keys["E"]) then						
									NaarBuitenGaan(GangLoods[k])
									insideGangLoods = false
								end
							end
						end
						
						if Config.Offsets[GangLoods[k].gangloods].laptop.usage then
							local offsetlaptopx,offsetlaptopy,offsetlaptopz,offsetlaptoptext = Config.Offsets[GangLoods[k].gangloods].laptop.x,Config.Offsets[GangLoods[k].gangloods].laptop.y,Config.Offsets[GangLoods[k].gangloods].laptop.z,Config.Offsets[GangLoods[k].gangloods].laptop.text
							local DistanceBetweenIngang = #(pos - vector3(x + offsetlaptopx, y + offsetlaptopy, z + Config.ZOffset + offsetlaptopz))
							if DistanceBetweenIngang < 1.5 then 
								DrawText3Ds(x + offsetlaptopx, y + offsetlaptopy, z + Config.ZOffset + offsetlaptopz, offsetlaptoptext)
								if DistanceBetweenIngang < 1 then
									if IsControlJustPressed(0, Keys["E"]) then						
										TierUpgrade()
									end
								end
							end
						end
						
						if Config.Offsets[GangLoods[k].gangloods].computer.usage then
							local offsetcomputerx,offsetcomputery,offsetcomputerz,offsetcomputertext = Config.Offsets[GangLoods[k].gangloods].computer.x,Config.Offsets[GangLoods[k].gangloods].computer.y,Config.Offsets[GangLoods[k].gangloods].computer.z,Config.Offsets[GangLoods[k].gangloods].computer.text
							local DistanceBetweenIngang = #(pos - vector3(x + offsetcomputerx, y + offsetcomputery, z + Config.ZOffset + offsetcomputerz))
							if DistanceBetweenIngang < 1.5 then 
								DrawText3Ds(x + offsetcomputerx, y + offsetcomputery, z + Config.ZOffset + offsetcomputerz, offsetcomputertext)
								if DistanceBetweenIngang < 1 then
									if IsControlJustPressed(0, Keys["E"]) then						
										
									end
								end
							end
						end
						
						if Config.Offsets[GangLoods[k].gangloods].opslag.usage then
							local offsetopslagx,offsetopslagy,offsetopslagz,offsetopslagtext = Config.Offsets[GangLoods[k].gangloods].opslag.x,Config.Offsets[GangLoods[k].gangloods].opslag.y,Config.Offsets[GangLoods[k].gangloods].opslag.z,Config.Offsets[GangLoods[k].gangloods].opslag.text
							local DistanceBetweenIngang = #(pos - vector3(x + offsetopslagx, y + offsetopslagy, z + Config.ZOffset + offsetopslagz))
							if DistanceBetweenIngang < 1.5 then 
								DrawText3Ds(x + offsetopslagx, y + offsetopslagy, z + Config.ZOffset + offsetopslagz, offsetopslagtext)
								if DistanceBetweenIngang < 1 then
									if IsControlJustPressed(0, Keys["E"]) then						
										openStorage(k)
									end
								end
							end
						end
						
						if Config.Offsets[GangLoods[k].gangloods].garage.usage then
							local offsetgaragex,offsetgaragey,offsetgaragez,offsetgaragetext = Config.Offsets[GangLoods[k].gangloods].garage.x,Config.Offsets[GangLoods[k].gangloods].garage.y,Config.Offsets[GangLoods[k].gangloods].garage.z,Config.Offsets[GangLoods[k].gangloods].garage.text
							local DistanceBetweenIngang = #(pos - vector3(x + offsetgaragex, y + offsetgaragey, z + Config.ZOffset + offsetgaragez))
							if DistanceBetweenIngang < 1.5 then 
								DrawText3Ds(x + offsetgaragex, y + offsetgaragey, z + Config.ZOffset + offsetgaragez, offsetgaragetext)
								if DistanceBetweenIngang < 1 then
									if IsControlJustPressed(0, Keys["E"]) then						
										OpenGarage()
									end
								end
							end
						end
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end) 

RegisterNetEvent('pk-gangloods:creategangloods')
AddEventHandler('pk-gangloods:creategangloods', function(blahblahblah)
	local ingang,garage_spawnpoint,garage_deletepoint,gangnaam,gangloods
	local elements = {
		{label = "Gang ingang", value = "ingang"},
        {label = "Voertuig spawnpunt", value = "garage_spawnpoint"},
        {label = "Voertuig Deletepunt", value = "garage_deletepoint"},
		{label = "Gang naam", value = "gangnaam"},
		{label = "Gang Loogs", value = "gangloods"},
        {label = "Maak", value = "maak"}
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "creator", {
        title = "Gangloods aanmaken",
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        local action = data.current.value
		local ped = PlayerPedId()
    
        if action == "ingang" then
			ingang = GetEntityCoords(ped)
			ESX.ShowNotification("Done!")
        elseif action == "garage_spawnpoint" then
			garage_spawnpointheading = GetEntityHeading(ped)
			garage_spawnpointcoords = GetEntityCoords(ped)
			garage_spawnpoint = vector4(garage_spawnpointcoords.x, garage_spawnpointcoords.y, garage_spawnpointcoords.z, garage_spawnpointheading)
			ESX.ShowNotification("Done!")
        elseif action == "garage_deletepoint" then
			garage_deletepoint = GetEntityCoords(ped)
			ESX.ShowNotification("Done!")
		elseif action == "gangnaam" then
			local gangnaam1 = KeyboardInput("Voer de naam in van de gang job", "", 100)
			gangnaam = gangnaam1
		elseif action == "gangloods" then
			local gangloods1 = KeyboardInput("Voer de naam in van de loods", "stashhouse1_shell | stashhouse3_shell | container2_shell", 100)
			gangloods = gangloods1
        elseif action == "maak" then
            if ingang and gangnaam and gangloods then
				TriggerServerEvent('pk-gangloods:maaktgangloods', ingang, garage_spawnpoint,garage_deletepoint,gangnaam,gangloods)
				ESX.ShowNotification("Je hebt een Gangloods gemaakt")
            else
                ESX.ShowNotification("Je moet wel alles hebben gedaan")
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent('pk-gangloods:SyncGangLoods')
AddEventHandler('pk-gangloods:SyncGangLoods', function()
	GangLoods = nil
	GangKey = nil
	PlayerItems = nil
end)

RegisterNetEvent('pk-gangloods:spawngangvoertuig')
AddEventHandler('pk-gangloods:spawngangvoertuig', function(model)
	for k,v in pairs(GangLoods) do
		local garage = json.decode(GangLoods[k].garagespawnpoint)
		local x,y,z,heading = tonumber(garage.x),tonumber(garage.y),tonumber(garage.z),tonumber(garage.w)
		if ESX.Game.IsSpawnPointClear(vector3(x,y,z), 2) then	
			local coords = vector3(x,y,z)
			SpawnVehicle(model,coords,heading)		
			insideGangLoods = false
		else
			exports.pNotify:SendNotification({text = "<b>Gangloods</b></br>De parkeerplaats van het voertuig is geblokkeerd!", timeout = 4000})
		end
	end

end)

RegisterNetEvent('pk-gangloods:spawneigevoertuig')
AddEventHandler('pk-gangloods:spawneigevoertuig', function(kenteken)
	for k,v in pairs(GangLoods) do
		local garage = json.decode(GangLoods[k].garagespawnpoint)
		local x,y,z,heading = tonumber(garage.x),tonumber(garage.y),tonumber(garage.z),tonumber(garage.w)
		if ESX.Game.IsSpawnPointClear(vector3(x,y,z), 2) then	
			for k,v in pairs(VehicleTable) do
				if v.plate == kenteken then
					local vehicleProps = json.decode(v.vehicle)
					local vehicleHash = vehicleProps.model
					SpawnVehicleWithProps(vehicleHash,vector3(x,y,z),heading, vehicleProps)
					insideGangLoods = false
				end
			end							
		else
			exports.pNotify:SendNotification({text = "<b>Gangloods</b></br>De parkeerplaats van het voertuig is geblokkeerd!", timeout = 4000})
		end
	end

end)

RegisterNetEvent('pk-gangloods:leg')
AddEventHandler('pk-gangloods:leg', function(item)
	local amount = KeyboardInput("Voer een nummer in", "", 10)
	if amount ~= nil then
		exports.rprogress:Custom({
			Duration = 10000,
			Label = "SPULLEN NEERLEGGEN...",
			Animation = {
				scenario = "PROP_HUMAN_BUM_BIN",
				animationDictionary = "idle_a",
			},
			DisableControls = {
				Mouse = false,
				Player = true,
				Vehicle = true
			}
		})
		Wait(10000)
		TriggerServerEvent('pk-gangloods:putItem', item, amount, ESX.PlayerData.job.name)
	end
end)

RegisterNetEvent('pk-gangloods:krijg')
AddEventHandler('pk-gangloods:krijg', function(item)
	local amount = KeyboardInput("Voer een nummer in", "", 10)
	if amount ~= nil then
		exports.rprogress:Custom({
			Duration = 10000,
			Label = "SPULLEN PAKKEN...",
			Animation = {
				scenario = "PROP_HUMAN_BUM_BIN",
				animationDictionary = "idle_a",
			},
			DisableControls = {
				Mouse = false,
				Player = true,
				Vehicle = true
			}
		})
		Wait(10000)
		TriggerServerEvent('pk-gangloods:getItem', item, amount,ESX.PlayerData.job.name)
	end
end)

function openStorage(key)
	if Config.UseMenu == "br-menu" then
		exports['br-menu']:SetTitle("Gang Loods Inventory")
		for k,v in pairs(PlayerItems) do
			if v.count > 0 then
				exports['br-menu']:AddButton(v.label , "Count: "..FormatNumber(v.count) ,'pk-gangloods:leg' ,v.name ,"legmenu")
			end
		end
		
		for k,v in pairs(json.decode(GangLoods[key].stash)) do
			if tonumber(v.amount) > 0 then
				exports['br-menu']:AddButton(v.label , "count: " .. FormatNumber(tonumber(v.amount)) ,'pk-gangloods:krijg' ,v.item ,"krijgmenu")
			end
		end
		exports['br-menu']:SubMenu("Broekzak" , "Leg je spullen in de Gang loods" , "legmenu" )
		exports['br-menu']:SubMenu("Pak" , "Krijg spullen die in je Loods zitten" , "krijgmenu" )
	elseif Config.UseMenu == "linden" then
		exports['linden_inventory']:OpenStash({owner = "Loods"..ClosestDrugslab, id = "Loods"..ClosestDrugslab, label = "Loods"..ClosestDrugslab, slots = 200})
	end
end

function SpawnVehicle(model,coords,heading)
	Wait(1500)
	ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)  
		exports.pNotify:SendNotification({text = "<b>Gangloods</b></br>De auto staat er.", timeout = 5500})
	end)
end

function SpawnVehicleWithProps(model,coords,heading, props)
	Wait(1500)
	ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
		SetVehicleProperties(vehicle, props)
		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)  
		exports.pNotify:SendNotification({text = "<b>Gangloods</b></br>De auto staat er.", timeout = 5500})
	end)
end

function SetVehicleProperties(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    if vehicleProps["windows"] then
        for windowId = 1, 9, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
	if vehicleProps.vehicleHeadLight then SetVehicleHeadlightsColour(vehicle, vehicleProps.vehicleHeadLight) end
	
end

function OpenGarage()
	local vehiclePropsList = {}
	exports['br-menu']:SetTitle("Voertuig lijst")
	for k,v in pairs(GangLoods) do
		for index,value in pairs(Config.Garage) do
			if v.gang == ESX.PlayerData.job.name then
				if Config.Garage[index].job_grade == -1 then
					exports['br-menu']:AddButton(Config.Garage[index].label , "",'pk-gangloods:spawngangvoertuig' ,Config.Garage[index].value ,"gangauto")
				elseif ESX.PlayerData.job.grade >= Config.Garage[index].job_grade then
					exports['br-menu']:AddButton(Config.Garage[index].label , "",'pk-gangloods:spawngangvoertuig' ,Config.Garage[index].value ,"gangauto")
				end
			end
		end
	end
	for k,v in pairs(VehicleTable) do
		local vehicleProps = json.decode(v.vehicle)
		vehiclePropsList[v.plate] = vehicleProps
		local vehicleHash = vehicleProps.model
		exports['br-menu']:AddButton(GetDisplayNameFromVehicleModel(vehicleHash).." Kenteken: "..v.plate , "Pak je auto eruit",'pk-gangloods:spawneigevoertuig' ,v.plate ,"eigeauto")
	end
	exports['br-menu']:SubMenu("Gang Autos" , "Gang autos menu" , "gangauto" )
	exports['br-menu']:SubMenu("Eige Autos" , "Gekochte autos menu" , "eigeauto" )
end

function TierUpgrade()
	local nextupgrade,tiername,tierupgradename = nil,nil,nil
	exports['br-menu']:SetTitle("Loods Management")
	for k,v in pairs(GangLoods) do
		if GangLoods[k].gangloods == 'stashhouse1_shell' then
			tiername = "Tier 3"
			tierupgradename = "MAX"
		elseif GangLoods[k].gangloods == 'stashhouse3_shell' then
			tiername = "Tier 2"
			tierupgradename = "Tier3"
		elseif GangLoods[k].gangloods == 'container2_shell' then
			tiername = "Tier 1"
			tierupgradename = "Tier2"
		end
		if GangLoods[k].gangloods ~= 'stashhouse1_shell' then
			nextupgrade = Config.Offsets[GangLoods[k].gangloods].upgradeto
			exports['br-menu']:AddButton("Tier upgraden naar: "..tierupgradename, "Gang Loods: "..tiername,'pk-gangloods:spawneigevoertuig' , nextupgrade ,"")
		else
			nextupgrade = "MAX"
			exports['br-menu']:AddButton("Tier is al max", "Gang Loods: "..tiername,'pk-gangloods:spawneigevoertuig' ,"")
		end
	end
end

function FormatNumber(number)
    local toreturn = ""
    if number >= 1000 then
        local string_number = string.reverse(tostring(number))
        for i = 0, #string_number - 1 do
            if i % 3 == 0 then
                toreturn = toreturn .. " "
            end
            toreturn = toreturn .. string.sub(string_number, i + 1, i + 1)
        end
    else
        return tostring(number)
    end
    toreturn = string.reverse(toreturn)
    if string.sub(toreturn, #toreturn, #toreturn) == " " then
        toreturn = string.sub(toreturn, 0, #toreturn - 1)
    end
    return toreturn
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

function DespawnInterior(objects)
    Citizen.CreateThread(function()
        for k, v in pairs(objects) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
    end)
end

function TeleportToInterior(x, y, z, h)
    Citizen.CreateThread(function()
        SetEntityCoords(PlayerPedId(), x, y, z, 0, 0, 0, false)
        SetEntityHeading(PlayerPedId(), h)

        Citizen.Wait(100)

        DoScreenFadeIn(1000)
    end)
end

function CreateShell(spawn,shell)
	local objects = {}

    local POIOffsets = {}
	POIOffsets.x = Config.Offsets[shell].exitloods.x
	POIOffsets.y = Config.Offsets[shell].exitloods.y
	POIOffsets.z = Config.Offsets[shell].exitloods.z
	POIOffsets.h = 0.0
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(shell)
	while not HasModelLoaded(shell) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(shell, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	SetEntityCoords(house, spawn.x, spawn.y, spawn.z)
	table.insert(objects, house)

	TeleportToInterior(spawn.x + POIOffsets.x, spawn.y + POIOffsets.y, spawn.z + Config.Offsets[shell].exitloods.z, POIOffsets.h)

    return { objects, POIOffsets }
end

function BetreedGangloods(data)
	local decodedata = json.decode(data.ingang)
    local coords = { x = tonumber(decodedata.x), y = tonumber(decodedata.y), z = tonumber(decodedata.z) + Config.ZOffset}
	local shell = data.gangloods
    data = CreateShell(coords, shell)
    DrugslabObj = data[1]
    POIOffsets = data[2]
    insideGangLoods = true
    SetRainFxIntensity(0.0)
    TriggerEvent("ToggleWeatherSync", false)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
end

function NaarBuitenGaan(data)
	local decodedata = json.decode(data.ingang)
    local ped = GetPlayerPed(-1)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
    DespawnInterior(DrugslabObj)
    TriggerEvent("ToggleWeatherSync", true)
    DoScreenFadeIn(250)
    SetEntityCoords(ped, tonumber(decodedata.x), tonumber(decodedata.y), tonumber(decodedata.z) + 0.5)
    DrugslabObj = nil
    POIOffsets = nil
    insideGangLoods = false
end
