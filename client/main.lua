ESX               = nil
local LastGarage  = nil
local LastPart    = nil
local LastParking = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx_property:hasEnteredMarker', function(name, part, parking)
	
	if part == 'ExteriorEntryPoint' then

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		local garage    = Config.Garages[name]

		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance <= 2.0 then

				local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

				local spawnCoords  = {
					x = garage.InteriorSpawnPoint.Pos.x,
					y = garage.InteriorSpawnPoint.Pos.y,
					z = garage.InteriorSpawnPoint.Pos.z
				}

				ESX.Game.DeleteVehicle(vehicle)

				ESX.Game.Teleport(playerPed, spawnCoords, function()

					TriggerEvent('instance:create')

					ESX.Game.SpawnLocalVehicle(vehicleProps.model, spawnCoords, garage.InteriorSpawnPoint.Heading, function(vehicle)
						TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
						ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					end)

					ESX.TriggerServerCallback('esx_vehicleshop:getVehiclesInGarage', function(vehicles)

						for i=1, #garage.Parkings, 1 do
							for j=1, #vehicles, 1 do

								if i == vehicles[j].zone then
										
									local spawn = function(j)

										ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, {
											x = garage.Parkings[i].Pos.x,
											y = garage.Parkings[i].Pos.y,
											z = garage.Parkings[i].Pos.z											
										}, garage.Parkings[i].Heading, function(vehicle)
											ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
										end)

									end

									spawn(j)

								end

							end
						end

					end, name)

				end)

			end

		else

			ESX.Game.Teleport(playerPed, {
				x = garage.InteriorSpawnPoint.Pos.x,
				y = garage.InteriorSpawnPoint.Pos.y,
				z = garage.InteriorSpawnPoint.Pos.z
			}, function()

				TriggerEvent('instance:create')

				ESX.TriggerServerCallback('esx_vehicleshop:getVehiclesInGarage', function(vehicles)

					for i=1, #garage.Parkings, 1 do
						for j=1, #vehicles, 1 do

							if i == vehicles[j].zone then
									
								local spawn = function(j)

									ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, {
										x = garage.Parkings[i].Pos.x,
										y = garage.Parkings[i].Pos.y,
										z = garage.Parkings[i].Pos.z											
									}, garage.Parkings[i].Heading, function(vehicle)
										ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
									end)

								end

								spawn(j)

							end

						end
					end

				end, name)

			end)

		end

	end

	if part == 'InteriorExitPoint' then

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		local garage    = Config.Garages[name]

		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance <= 2.0 then

				local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
				
				local spawnCoords  = {
					x = garage.ExteriorSpawnPoint.Pos.x,
					y = garage.ExteriorSpawnPoint.Pos.y,
					z = garage.ExteriorSpawnPoint.Pos.z
				}

				ESX.Game.DeleteVehicle(vehicle)

				ESX.Game.Teleport(playerPed, spawnCoords, function()

					TriggerEvent('instance:close')

					ESX.Game.SpawnVehicle(vehicleProps.model, spawnCoords, garage.ExteriorSpawnPoint.Heading, function(vehicle)
						TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
						ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					end)

				end)

			end

		else

			ESX.Game.Teleport(playerPed, {
				x = garage.ExteriorSpawnPoint.Pos.x,
				y = garage.ExteriorSpawnPoint.Pos.y,
				z = garage.ExteriorSpawnPoint.Pos.z
			}, function()
				TriggerEvent('instance:close')
			end)

		end

		for i=1, #garage.Parkings, 1 do

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = garage.Parkings[i].Pos.x,
				y = garage.Parkings[i].Pos.y,
				z = garage.Parkings[i].Pos.z
			})

			if distance <= 2.0 then
				ESX.Game.DeleteVehicle(vehicle)
			end

		end

	end

	if part == 'Parking' then

		local playerPed = GetPlayerPed(-1)
		local garage    = Config.Garages[name]

		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle()
			local vehicleProps      = ESX.Game.GetVehicleProperties(vehicle)

			if distance <= 2.0 then
				TriggerServerEvent('esx_garage:setParking', name, parking, vehicleProps)
			end

		end

	end

end)

AddEventHandler('esx_property:hasExitedMarker', function(name, part, parking)

	if part == 'Parking' then

		local playerPed = GetPlayerPed(-1)

		if IsPedInAnyVehicle(playerPed,  false) then
			TriggerServerEvent('esx_garage:setParking', name, parking, false)
		end

	end

end)

-- Create Blips
Citizen.CreateThread(function()
		
	for k,v in pairs(Config.Garages) do

		if v.IsClosed then

			local blip = AddBlipForCoord(v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z)

		  SetBlipSprite (blip, 357)
		  SetBlipDisplay(blip, 4)
		  SetBlipScale  (blip, 1.2)
		  SetBlipColour (blip, 3)
		  SetBlipAsShortRange(blip, true)
			
			BeginTextCommandSetBlipName("STRING")
		  AddTextComponentString("Garage")
		  EndTextCommandSetBlipName(blip)

		end

	end

end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		
		for k,v in pairs(Config.Garages) do

			if v.IsClosed then

				if(GetDistanceBetweenCoords(coords, v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end	

				if(GetDistanceBetweenCoords(coords, v.InteriorExitPoint.Pos.x, v.InteriorExitPoint.Pos.y, v.InteriorExitPoint.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.InteriorExitPoint.Pos.x, v.InteriorExitPoint.Pos.y, v.InteriorExitPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end

			end

			if IsPedInAnyVehicle(playerPed,  false) then

				for i=1, #v.Parkings, 1 do

					local parking = v.Parkings[i]

					if(GetDistanceBetweenCoords(coords, parking.Pos.x, parking.Pos.y, parking.Pos.z, true) < Config.DrawDistance) then
						DrawMarker(Config.MarkerType, parking.Pos.x, parking.Pos.y, parking.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ParkingMarkerSize.x, Config.ParkingMarkerSize.y, Config.ParkingMarkerSize.z, Config.ParkingMarkerColor.r, Config.ParkingMarkerColor.g, Config.ParkingMarkerColor.b, 100, false, true, 2, false, false, false, false)
					end

				end

			end

		end

	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()

	while true do

		Wait(0)

		local playerPed      = GetPlayerPed(-1)
		local coords         = GetEntityCoords(playerPed)
		local isInMarker     = false
		local currentGarage  = nil
		local currentPart    = nil
		local currentParking = nil

		for k,v in pairs(Config.Garages) do

			if v.IsClosed then

				if GetDistanceBetweenCoords(coords, v.ExteriorEntryPoint.Pos.x, v.ExteriorEntryPoint.Pos.y, v.ExteriorEntryPoint.Pos.z, true) < Config.MarkerSize.x then
					isInMarker    = true
					currentGarage = k
					currentPart   = 'ExteriorEntryPoint'
				end

				if GetDistanceBetweenCoords(coords, v.InteriorExitPoint.Pos.x, v.InteriorExitPoint.Pos.y, v.InteriorExitPoint.Pos.z, true) < Config.MarkerSize.x then
					isInMarker    = true
					currentGarage = k
					currentPart   = 'InteriorExitPoint'
				end

				for i=1, #v.Parkings, 1 do

					local parking = v.Parkings[i]

					if GetDistanceBetweenCoords(coords, parking.Pos.x, parking.Pos.y, parking.Pos.z, true) < Config.ParkingMarkerSize.x then
						isInMarker     = true
						currentGarage  = k
						currentPart    = 'Parking'
						currentParking = i
					end

				end

			end

		end

		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastGarage ~= currentGarage or LastPart ~= currentPart) ) then
			
			if LastGarage ~= currentGarage or LastPart ~= currentPart then
				TriggerEvent('esx_property:hasExitedMarker', LastGarage, LastPart, LastParking)
			end

			HasAlreadyEnteredMarker = true
			LastGarage              = currentGarage
			LastPart                = currentPart
			LastParking             = currentParking
			
			TriggerEvent('esx_property:hasEnteredMarker', currentGarage, currentPart, currentParking)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			
			HasAlreadyEnteredMarker = false
			
			TriggerEvent('esx_property:hasExitedMarker', LastGarage, LastPart, LastParking)
		end

	end
end)