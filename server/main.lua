GangLoods = nil
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function KrijgGangLoods()
	GangLoods = nil
	if Config.MYSQLUsage == "mysqlasync" then
		MySQL.Async.fetchAll("SELECT * FROM `pk-gangloods`", {}, function(result)
			if result and #result > 0 then
				GangLoods = result
			end
		end)
	elseif Config.MYSQLUsage == "oxmysql" then
		query = "SELECT * FROM `pk-gangloods`"
		exports.oxmysql:execute(query, {}, function(result)
			if result and #result > 0 then
				GangLoods = result
			end
		end)
	end
end

if ESX.RegisterCommand ~= nil then
	ESX.RegisterCommand('gangloods-create', "admin", function(xPlayer, args, showError)
		xPlayer.triggerEvent('pk-gangloods:creategangloods', xPlayer)
	end, true)
	
	ESX.RegisterCommand('gangloods-remove', "admin", function(xPlayer, args, showError)
		xPlayer.triggerEvent('pk-gangloods:removegangloods', xPlayer)
	end, true)
else
	TriggerEvent('es:addGroupCommand', 'gangloods-create', 'admin', function(source, args, user)
		TriggerClientEvent('pk-gangloods:creategangloods', source)
	end, function(source, args, user)
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
	end, {help = "Maak een Gangloods aan"})
	
	TriggerEvent('es:addGroupCommand', 'gangloods-remove', 'admin', function(source, args, user)
		TriggerClientEvent('pk-gangloods:removegangloods', source)
	end, function(source, args, user)
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
	end, {help = "Verwijder een GangLoods"})
end

RegisterServerEvent('pk-gangloods:maaktgangloods')
AddEventHandler('pk-gangloods:maaktgangloods', function(ingang, garage_spawnpoint,garage_deletepoint,gangnaam,loods)
	if ingang ~= nil and gangnaam ~= nil then
		MySQL.Async.execute("INSERT INTO `pk-gangloods` ( `gang`, `gangloods`,`garagespawnpoint`, `garagedeletepoint`, `ingang`) VALUES (@gang, @gangloods, @garagespawnpoint, @garagedeletepoint, @ingang)", {
			["@gang"] = gangnaam,
			["@gangloods"] = loods,
			["@garagespawnpoint"] = json.encode(garage_spawnpoint),
			["@garagedeletepoint"] = json.encode(garage_deletepoint),
			["@ingang"] = json.encode(ingang),
		})
		KrijgGangLoods()
		Wait(100)
		refreshlabsclient(1)
	end
end)

function refreshlabsclient(something)
	Wait(20)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('pk-gangloods:SyncGangLoods', xPlayers[i])
	end
end

RegisterServerEvent('pk-gangloods:ZerInGarage')
AddEventHandler('pk-gangloods:ZerInGarage', function(plate)
	MySQL.Async.execute("UPDATE owned_vehicles SET stored=@stored WHERE plate = @plate", {
		["@plate"] = plate,
		["@stored"] = "1",
	})
	KrijgGangLoods()
	Wait(50)
	refreshlabsclient(1)
end)

Storage = function(src, gang, method, itemtype, amount, itemname)
	   local xPlayer = ESX.GetPlayerFromId(src)
	   local xItem = xPlayer.getInventoryItem(itemname)
       MySQL.Async.fetchScalar("SELECT `gang` FROM `pk-gangloods` WHERE `gang` = @id", {
           ["@id"] = gang
       }, function(owner)
           if owner then
               MySQL.Async.fetchScalar("SELECT `stash` FROM `pk-gangloods` WHERE `gang` = @gang", {
                   ["@gang"] = gang
               }, function(stashdata)
                   if stashdata then
                       stashdata = json.decode(stashdata)
                        if method == "put" then
                            if itemtype == "items" then
                                if stashdata[itemname] then
                                    stashdata[itemname].label = xItem.label
                                    stashdata[itemname].amount = stashdata[itemname].amount + amount
									xPlayer.removeInventoryItem(itemname, amount)
                                else
                                    stashdata[itemname] = {
                                        label = xItem.label,
                                        amount = amount,
                                        item = itemname
                                    }
									xPlayer.removeInventoryItem(itemname, amount)
                                end
                            end
                        elseif method == "get" then
                            if itemtype == "items" then
                                if stashdata[itemname] and stashdata[itemname].amount >= amount then
                                    stashdata[itemname].amount = stashdata[itemname].amount - amount
									xPlayer.addInventoryItem(itemname, amount)
                                    if stashdata[itemname].amount <= 0 then
                                        stashdata[itemname] = nil
                                    end
                                end
                            end
                        end
						
						print(json.encode(stashdata))
                        
                        MySQL.Async.execute("UPDATE `pk-gangloods` set `stash`=@stashdata WHERE `gang`=@gang", {
                            ["@stashdata"] = json.encode(stashdata),
                            ["@gang"] = gang
                        })
						KrijgGangLoods()
						Wait(100)
						refreshlabsclient(1)
                   end
               end)
           end
       end)
end

RegisterServerEvent('pk-gangloods:getItem')
AddEventHandler('pk-gangloods:getItem', function(item, count, gang)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(item)
	local amount = tonumber(count)
	Storage(source, gang, "get", "items", amount, item)
end)
KrijgGangLoods()
RegisterServerEvent('pk-gangloods:putItem')
AddEventHandler('pk-gangloods:putItem', function(item, count, gang)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local playerItemCount = xPlayer.getInventoryItem(item).count
	local amount = tonumber(count)
	Storage(source, gang, "put", "items", amount, item)
end)

ESX.RegisterServerCallback('pk-gangloods:getInventory', function(src, cb)
	local xPlayer = ESX.GetPlayerFromId(src)
	cb(xPlayer.inventory)
end)

ESX.RegisterServerCallback('pk-gangloods:GeefVoertuig', function(src, cb, kenteken)
	local xPlayer = ESX.GetPlayerFromId(src)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner", {["owner"] = xPlayer.identifier}, function(result)
		if result and #result > 0 then
			cb(result)
		else
			cb(false)
		end
	end)		
end)

ESX.RegisterServerCallback('pk-gangloods:CheckIfOwned', function(src, cb, kenteken)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {["plate"] = kenteken}, function(result)
		if result and #result > 0 then
			cb(true)
		else
			cb(false)
		end
	end)		
end)

ESX.RegisterServerCallback('pk-gangloods:krijgGangLoods', function(src, cb)
	cb(GangLoods)
end)
