-- Cmds Made By NS100#0001
RegisterCommand("comserv", function(source, args)
    -- if IsPlayerAceAllowed(source, "nsadmin.comserv") then
	if DoesPlayerHavePermission(source, "player.freeze") then

        if args[1] then
            local ped = GetPlayerPed(tonumber(args[1]))
            local target = GetEntityCoords(ped)
			TriggerEvent('zaza_sweepthefloor:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
        else
           print("Was Invalid, Could Not Locate Player.")
        end
    end
end, false)


RegisterCommand("endserv", function(source, args)
    -- if IsPlayerAceAllowed(source, "nsadmin.comserv") then
	if DoesPlayerHavePermission(source, "player.freeze") then -- set to ez admin
        if args[1] then 
            local ped = GetPlayerPed(tonumber(args[1]))
            local target = GetEntityCoords(ped)
			TriggerEvent('zaza_sweepthefloor:endCommunityServiceCommand', tonumber(args[1]))
        else
           print("Was Invalid, Could Not Locate Player.")
        end
    end
end, false)



RegisterServerEvent('zaza_sweepthefloor:endCommunityServiceCommand')
AddEventHandler('zaza_sweepthefloor:endCommunityServiceCommand', function(source)
	if source ~= nil then
		releaseFromCommunityService(source)
	end
end)


RegisterServerEvent('zaza_sweepthefloor:finishCommunityService')
AddEventHandler('zaza_sweepthefloor:finishCommunityService', function()
	releaseFromCommunityService(source)
end)





RegisterServerEvent('zaza_sweepthefloor:completeService')
AddEventHandler('zaza_sweepthefloor:completeService', function()

	local _source = source
	local identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE communityservice SET actions_remaining = actions_remaining - 1 WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})
		else
			print ("zaza_sweepthefloor :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)




RegisterServerEvent('zaza_sweepthefloor:extendService')
AddEventHandler('zaza_sweepthefloor:extendService', function()

	local _source = source
	local identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE communityservice SET actions_remaining = actions_remaining + @extension_value WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@extension_value'] = 8
			})
		else
			print ("zaza_sweepthefloor :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)






RegisterServerEvent('zaza_sweepthefloor:sendToCommunityService')
AddEventHandler('zaza_sweepthefloor:sendToCommunityService', function(target, actions_count)

	local identifier = GetPlayerIdentifiers(target)[1]

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] and result[1] ~=nil then
			MySQL.Async.execute('UPDATE communityservice SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		else
			MySQL.Async.execute('INSERT INTO communityservice (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		end
	end)

	print("sent to coms")
	TriggerClientEvent('zaza_sweepthefloor:inCommunityService', target, actions_count)
end)


















RegisterServerEvent('zaza_sweepthefloor:checkIfSentenced')
AddEventHandler('zaza_sweepthefloor:checkIfSentenced', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local identifier = GetPlayerIdentifiers(_source)[1] -- get steam identifier

	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil and result[1].actions_remaining > 0 then
            
			TriggerClientEvent('zaza_sweepthefloor:inCommunityService', _source, tonumber(result[1].actions_remaining))
		end
	end)
end)







function releaseFromCommunityService(target)

	local identifier = GetPlayerIdentifiers(target)[1]
	MySQL.Async.fetchAll('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('DELETE from communityservice WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			-- TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_finished', GetPlayerName(target)) }, color = { 147, 196, 109 } })
			print("this is where u put finished coms")
		end
	end)

	TriggerClientEvent('zaza_sweepthefloor:finishCommunityService', target)
end
