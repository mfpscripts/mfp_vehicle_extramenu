_menuPool = NativeUI.CreatePool()

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
local neonActive = true

function has_hash_value (tab, val)
    for index, value in ipairs(tab) do
		if GetHashKey(value) == val then
			return true
        end
    end
    return false
end

cardoors = {}
for k, v in pairs (Config.doors) do 
    cardoors[k] = v
end

carwindows = {}
for k, v in pairs (Config.windows) do 
    carwindows[k] = v
end

---- Creating Menus
function LiveryMenu(vehicle, menu)
	local liveryMenu = _menuPool:AddSubMenu(menu, "Lackierung", "Wechsele die Beklebung", true, true, true)
	local livery_count = GetVehicleLiveryCount(vehicle)
	local livery_list = {}
	local fetched_liveries = false
	
	for liveryID = 1, livery_count do
		livery_list[liveryID] = liveryID
		fetched_liveries = true
    end
	
	local liveryItem = NativeUI.CreateListItem("Lackierung", livery_list, GetVehicleLivery(vehicle))
    liveryMenu:AddItem(liveryItem)
    
	liveryMenu.OnListChange = function(sender, item, index)
        if item == liveryItem then
			SetVehicleLivery(vehicle,item:IndexToItem(index))
        end
    end
end

function NeonMenu(vehicle, menu)
	local NeonMenu = _menuPool:AddSubMenu(menu, "Unterbodenbeleuchtung", "Schalte Neon an/aus", true, true, true)	
	local neonItem = NativeUI.CreateListItem("Unterboden", nil)
   	NeonMenu:AddItem(neonItem)
    
	--liveryMenu.OnListChange = function(sender, item, index)
        --if item == liveryItem then
	--		SetVehicleLivery(vehicle,item:IndexToItem(index))
        --end
    
	NeonMenu.OnCheckboxChange = function(sender, item, checked)
					neonItem = checked
					if neonItem then
						DisableVehicleNeonLights(vehicle, true)
					else
						DisableVehicleNeonLights(vehicle, false)
					end
	end


end


function ExtrasMenu(vehicle, menu)
	local extrasMenu = _menuPool:AddSubMenu(menu, "Anbauten", "Baue Extra-Anbauten an/ab", true, true)
    
	local veh_extras = {['vehicleExtras'] = {}}
    local items = {['vehicle'] = {}}
    local fetched_extras = false
    
	--SetVehicleAutoRepairDisabled(vehicle, true) -- disable auto repair

	for extraID = 0, 20 do
        if DoesExtraExist(vehicle, extraID) then
            veh_extras.vehicleExtras[extraID] = (IsVehicleExtraTurnedOn(vehicle, extraID) == 1)
            fetched_extras = true
        end
    end

    if fetched_extras then
		for k, v in pairs(veh_extras.vehicleExtras) do
			local extraItem = NativeUI.CreateCheckboxItem('Anbaute ' .. k, veh_extras.vehicleExtras[k],"Baue folgendes Teil an: "..k)
			extrasMenu:AddItem(extraItem)
			items.vehicle[k] = extraItem
		end
		
		extrasMenu.OnCheckboxChange = function(sender, item, checked)
			for k, v in pairs(items.vehicle) do
				if item == v then
					veh_extras.vehicleExtras[k] = checked
					if veh_extras.vehicleExtras[k] then
						SetVehicleExtra(vehicle, k, 0)
					else
						SetVehicleExtra(vehicle, k, 1)
					end
				end
			end
		end
    end
    
end

function AddLocksEngineMenu(vehicle, menu)
	local lockMenu = NativeUI.CreateItem("Fahrzeugschlüssel", "Schließe/Öffne das Fahrzeug")
	local engineMenu = NativeUI.CreateItem("Motor starten/stoppen", "Starte/Stoppe den Motor")
	local neonMenu = NativeUI.CreateItem("Unterbodenbelichtung", "An/Aus machen")
	menu:AddItem(lockMenu)
	menu:AddItem(engineMenu)
	menu:AddItem(neonMenu)


	menu.OnListChange = function(sender, item, index)
        print("Beep Beep.")
    end
	
	menu.OnItemSelect = function(sender, item, index)
		if item == lockMenu then
            print("Lock status:")
            print(GetVehicleDoorLockStatus(vehicle))
			if GetVehicleDoorLockStatus(vehicle) == 1 or GetVehicleDoorLockStatus(vehicle) == 0 then
				SetVehicleDoorsLocked(vehicle,4)
				ShowNotification("Die Türen werden verschlossen")
			else
				SetVehicleDoorsLocked(vehicle,1)
				ShowNotification("Die Türen werden aufgeschlossen")
			end
        end
		if item == engineMenu then
            print("engine running?:")
			print(GetIsVehicleEngineRunning(vehicle))
			if GetIsVehicleEngineRunning(vehicle) then
				SetVehicleEngineOn(vehicle,false,false,true)
			else
				SetVehicleEngineOn(vehicle,true,false,true)
			end
        end
	if item == neonMenu then
            print("neon running?:")
			print(IsVehicleNeonLightEnabled(vehicle))
			local neonan = nil
			local neonan = IsVehicleNeonLightEnabled(vehicle)
			if neonan then
				SetVehicleNeonLightEnabled(vehicle, 0, false)
				SetVehicleNeonLightEnabled(vehicle, 1, false)
				SetVehicleNeonLightEnabled(vehicle, 2, false)
				SetVehicleNeonLightEnabled(vehicle, 3, false)
				neonan = false
				--SetVehicleNeonLightEnabled(vehicle, false)

			elseif not neonan then
				SetVehicleNeonLightEnabled(vehicle, 0, true)
				SetVehicleNeonLightEnabled(vehicle, 1, true)
				SetVehicleNeonLightEnabled(vehicle, 2, true)
				SetVehicleNeonLightEnabled(vehicle, 3, true)
				neonan = true
				--DisableVehicleNeonLights(vehicle, true)
			end
        end

    end  
end

function AddDoorsMenu(vehicle, menu)
	local doorMenu = _menuPool:AddSubMenu(menu, "Türen", "Öffne/Schließe Türen", true, true)

	for k, v in pairs(cardoors) do
		newIndex = k - 1
		if DoesVehicleHaveDoor(vehicle, newIndex) then 
			local doorItem = NativeUI.CreateItem("Öffne/Schließe "..v,"Für die Tür: "..v)
			doorMenu:AddItem(doorItem)
		end
	end

	doorMenu.OnItemSelect = function(sender, item, index)
		newIndex = index - 1
		if DoesVehicleHaveDoor(vehicle, newIndex) then 
			local isopen = GetVehicleDoorAngleRatio(vehicle,newIndex)
			if isopen == 0 then
				SetVehicleDoorOpen(vehicle,newIndex,0,0)
				ShowNotification("Öffne "..Config.doors[index].." Tür")
			else
				SetVehicleDoorShut(vehicle,newIndex,0)
				ShowNotification("Schließe "..Config.doors[index].." Tür")
			end
		end
    end
end

function AddWindowsMenu(vehicle, menu)
	local windowMenu = _menuPool:AddSubMenu(menu, "Fenster", "Öffne/Schließe Fenster", true, true)

	for k, v in pairs(carwindows) do
		local windowItem = NativeUI.CreateItem("Interagiere mit "..v.." Fenster","")
		windowMenu:AddItem(windowItem)
	end

	windowMenu.OnItemSelect = function(sender, item, index)
		newIndex = index - 1
		local isopen = IsVehicleWindowIntact(vehicle,newIndex)
		if isopen then
			RollDownWindow(vehicle,newIndex,0,0)
			ShowNotification("Öffne "..Config.windows[index].." Fenster")
		else
			RollUpWindow(vehicle,newIndex,0)
			ShowNotification("Schließe "..Config.windows[index].." Fenster")
		end
    end 
end

function openDynamicMenu(vehicle)
    print("Menu oppened")
	_menuPool:Remove()
	if vehMenu ~= nil and vehMenu:Visible() then
		vehMenu:Visible(false)
		return
	end
    print("after romove and return")
	--vehMenu = NativeUI.CreateMenu(Config.mTitle, 'Fahrzeugverwaltung und -bearbeitung', 5, 100,Config.mBG[1],Config.mBG[2])
    vehMenu = NativeUI.CreateMenu(Config.mTitle, 'Fahrzeugverwaltung und -bearbeitung', 5, 100,nil,nil)
	_menuPool:Add(vehMenu)
	LiveryMenu(vehicle, vehMenu)
	ExtrasMenu(vehicle, vehMenu)
	AddDoorsMenu(vehicle, vehMenu)
	AddWindowsMenu(vehicle, vehMenu)
	AddLocksEngineMenu(vehicle, vehMenu)
	
	_menuPool:RefreshIndex()
	_menuPool:MouseControlsEnabled (false);
	_menuPool:MouseEdgeEnabled (false);
	_menuPool:ControlDisablingEnabled(false);
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		_menuPool:ProcessMenus()
		
		local ped = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(ped, false)
		neonActive = IsVehicleNeonLightEnabled(vehicle, 1)
		
		--[[if IsControlJustReleased(1, Config.menuKey) then
			if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, -1) == ped then
				print("Open Menu!")
				collectgarbage()
				openDynamicMenu(vehicle)
				vehMenu:Visible(not vehMenu:Visible())
			end
        end]]
		
		if IsPedInAnyVehicle(ped, false) == false then
			if vehMenu ~= nil and vehMenu:Visible() then
				vehMenu:Visible(false)
			end
		end
    end
end)


RegisterNetEvent("mfp_vehiclemenu:openMenu")
AddEventHandler("mfp_vehiclemenu:openMenu", function()

	local ped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(ped, false)

	if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, -1) == ped then
        --print("isInVehicle = true")
		print("MFP_Vehicleextras working!")
		collectgarbage()
        --print("skipped garbage")
		openDynamicMenu(vehicle)
        --print("Passed Menu visible, Astra ist doof hehe")
        --vehMenu:Visible(true)
		vehMenu:Visible(not vehMenu:Visible())
	end
	
	if IsPedInAnyVehicle(ped, false) == false then
        --print("isInVehicle = false")
		if vehMenu ~= nil and vehMenu:Visible() then
            --print("nevMenu = false")
			vehMenu:Visible(false)
		end
		ShowNotification("Du befindest Dich nicht in einem Auto als Fahrer, um diese Aktion auszuführen.")
	end
    --print("Event = true")
    --print("ped: "..ped.. ", vehicle: "..vehicle)
end)