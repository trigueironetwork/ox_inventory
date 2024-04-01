local Inventory = require 'modules.inventory.server'
local Items = require 'modules.items.server'

local tNet

SetTimeout(500, function()
	tNet = exports.tnet_core:getSharedObject()

	server.UseItem = tNet.UseItem
	server.GetPlayerFromId = tNet.GetCharacterFromPlayerId

	for _, character in pairs(tNet.Characters) do
		server.setPlayerInventory(character, character?.inventory)
	end
end)

function server.setPlayerData(character)

	return {
		source = character.source,
		name = character.name,
		groups = {  }, -- character.roles
		-- sex = character.sex,
		dateofbirth = character.birthData
	}
end

function server.syncInventory(inv)
	local accounts = Inventory.GetAccountItemCounts(inv)

    if accounts then
        local player = server.GetPlayerFromId(inv.id)
        player.syncInventory(inv.weight, inv.maxWeight, inv.items, accounts)
    end
end

function server.hasLicense(inv, name)
	return MySQL.scalar.await('SELECT 1 FROM `user_licenses` WHERE `type` = ? AND `owner` = ?', { name, inv.owner })
end

function server.buyLicense(inv, license)

	if server.hasLicense(inv, license.name) then
		return false, 'already_have'
	elseif Inventory.GetItem(inv, 'money', false, true) < license.price then
		return false, 'can_not_afford'
	end

	Inventory.RemoveItem(inv, 'money', license.price)
	TriggerEvent('tnet:addLicense', inv.id, license.name)

	return true, 'have_purchased'
end

function server.isPlayerBoss(playerId)
	return
end

MySQL.ready(function()
	MySQL.insert('INSERT IGNORE INTO `tnet_licenses` (`type`, `label`) VALUES (?, ?)', { 'weapon', 'Weapon License'})
end)