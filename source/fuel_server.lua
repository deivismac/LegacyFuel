ESX = nil

if Config.UseESX then
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Core Business helpers
-----------------------------------------------------------------------------------------------------------------------------------------

local function getPlayerCoords(source)
	local ped = GetPlayerPed(source)
	return ped and GetEntityCoords(ped)
end

local function coreBusinessRemoveFuel(source, price)
	if not Config.CoreBusiness or not Config.CoreBusiness.enabled then return true end

	local coords = getPlayerCoords(source)
	if not coords then return true end

	local fuelItem = Config.CoreBusiness.fuelItem
	local fuelPerLiter = Config.CoreBusiness.fuelPerLiter or 1
	local itemsNeeded = math.max(1, math.ceil(price * fuelPerLiter / (Config.CostMultiplier or 1.0)))

	local itemCount = exports['core_business']:closestPropertyItemCount(coords, fuelItem)
	if itemCount == 1000.0 then return true end

	local removed = exports['core_business']:closestPropertyRemoveItem(coords, fuelItem, itemsNeeded)
	return removed
end

local function coreBusinessRegisterSale(source, price, logMsg)
	if not Config.CoreBusiness or not Config.CoreBusiness.enabled or not Config.CoreBusiness.registerSales then return end

	local coords = getPlayerCoords(source)
	if not coords then return end

	exports['core_business']:closestPropertyRegisterSale(coords, math.floor(price), logMsg or "Fuel sale")
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Payment
-----------------------------------------------------------------------------------------------------------------------------------------

if Config.UseESX then
	RegisterServerEvent('fuel:pay')
	AddEventHandler('fuel:pay', function(price)
		local source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		local amount = ESX.Math.Round(price)

		if price > 0 then
			if not coreBusinessRemoveFuel(source, amount) then
				TriggerClientEvent('esx:showNotification', source, 'Not enough fuel in stock')
				return
			end

			xPlayer.removeMoney(amount)

			coreBusinessRegisterSale(source, amount, string.format("Fuel sale: $%d", amount))
		end
	end)
end
