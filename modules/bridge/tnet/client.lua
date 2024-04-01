local tNet = exports.tnet_core:getSharedObject()

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerData(key, value)
	PlayerData[key] = value
	tNet.SetCharacterData(key, value)
end

function client.setPlayerStatus(values)
	
end

RegisterNetEvent('tNet:onCharacterLogout', client.onLogout)

AddEventHandler('tNet:setCharacterData', function(key, value)

	if not PlayerData.loaded or GetInvokingResource() ~= 'tnet_core' then return end

	if key == 'job' then
		key = 'groups'
		value = { [value.name] = value.grade }
	end

	PlayerData[key] = value
	OnPlayerData(key, value)
end)