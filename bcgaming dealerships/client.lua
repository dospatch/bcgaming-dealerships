-- BCGAMING Dealership Client Script

local ESX = nil
local PlayerData = {}
local isDealershipOpen = false
local previewVehicle = nil
local dealershipBlips = {}
local currentDealership = nil -- Used for camera system

-- Initialize ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    
    PlayerData = ESX.GetPlayerData()
end)

-- Create blips
Citizen.CreateThread(function()
    if not Config.EnableBlips then return end
    
    for _, dealership in ipairs(Config.Dealerships) do
        local blip = AddBlipForCoord(dealership.location.x, dealership.location.y, dealership.location.z)
        SetBlipSprite(blip, dealership.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, dealership.blip.scale)
        SetBlipColour(blip, dealership.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(dealership.blip.label)
        EndTextCommandSetBlipName(blip)
        table.insert(dealershipBlips, blip)
    end
end)

-- Check for nearby dealerships
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearDealership = false
        
        for _, dealership in ipairs(Config.Dealerships) do
            local distance = #(playerCoords - dealership.location)
            
            if distance < Config.InteractionDistance then
                nearDealership = true
                DisplayHelpText("Press ~INPUT_CONTEXT~ to open the dealership")
                
                if IsControlJustReleased(0, 51) then -- E key
                    OpenDealership(dealership)
                end
            end
        end
        
        if not nearDealership then
            Citizen.Wait(500)
        end
    end
end)

-- Store current dealership
function OpenDealership(dealership)
    currentDealership = dealership
    if isDealershipOpen then return end
    
    -- Filter vehicles by dealership categories
    local filteredVehicles = {}
    local filteredCategories = {}
    local categoryMap = {}
    
    if dealership.categories and #dealership.categories > 0 then
        -- Only show vehicles in specified categories
        for _, vehicle in ipairs(Config.Vehicles) do
            for _, cat in ipairs(dealership.categories) do
                if vehicle.category == cat then
                    table.insert(filteredVehicles, vehicle)
                    if not categoryMap[cat] then
                        categoryMap[cat] = true
                        table.insert(filteredCategories, cat)
                    end
                    break
                end
            end
        end
    else
        -- Show all vehicles if no category filter
        filteredVehicles = Config.Vehicles
        filteredCategories = Config.Categories
    end
    
    isDealershipOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openDealership",
        vehicles = filteredVehicles,
        categories = filteredCategories,
        dealership = dealership,
        resourceName = GetCurrentResourceName(),
        finance = Config.Finance
    })
    
    -- Request player money
    TriggerServerEvent('bcgaming-dealership:getPlayerMoney')
end

-- Close dealership UI
function CloseDealership()
    if not isDealershipOpen then return end
    
    isDealershipOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeDealership"
    })
    
    -- Reset camera
    ResetCamera()
    
    -- Delete preview vehicle
    if previewVehicle then
        DeleteVehicle(previewVehicle)
        previewVehicle = nil
    end
    
    currentDealership = nil
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseDealership()
    cb('ok')
end)

RegisterNUICallback('buyVehicle', function(data, cb)
    local vehicleModel = data.model
    local vehiclePrice = data.price
    local dealershipLocation = data.dealershipLocation
    local finance = data.finance or false
    local downPayment = data.downPayment or 0
    local paymentPeriods = data.paymentPeriods or 0
    
    if finance and Config.Finance.enabled then
        TriggerServerEvent('bcgaming-dealership:buyVehicleFinance', vehicleModel, vehiclePrice, dealershipLocation, downPayment, paymentPeriods)
    else
        TriggerServerEvent('bcgaming-dealership:buyVehicle', vehicleModel, vehiclePrice, dealershipLocation)
    end
    cb('ok')
end)

RegisterNUICallback('changeCamera', function(data, cb)
    local cameraIndex = data.index or 1
    ChangeShowroomCamera(cameraIndex)
    cb('ok')
end)

RegisterNUICallback('resetCamera', function(data, cb)
    ResetCamera()
    cb('ok')
end)

RegisterNUICallback('previewVehicle', function(data, cb)
    local vehicleModel = data.model
    PreviewVehicle(vehicleModel)
    cb('ok')
end)

RegisterNUICallback('stopPreview', function(data, cb)
    if previewVehicle then
        DeleteVehicle(previewVehicle)
        previewVehicle = nil
    end
    cb('ok')
end)

RegisterNUICallback('testDrive', function(data, cb)
    local vehicleModel = data.model
    StartTestDrive(vehicleModel)
    cb('ok')
end)

-- Preview vehicle
function PreviewVehicle(vehicleModel)
    if previewVehicle then
        DeleteVehicle(previewVehicle)
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find nearest dealership
    local nearestDealership = nil
    local minDistance = 999999.0
    
    for _, dealership in ipairs(Config.Dealerships) do
        local distance = #(playerCoords - dealership.location)
        if distance < minDistance then
            minDistance = distance
            nearestDealership = dealership
        end
    end
    
    if not nearestDealership then return end
    
    -- Spawn preview vehicle
    local spawnCoords = nearestDealership.location + vector3(0.0, -5.0, 0.0)
    
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(10)
    end
    
    previewVehicle = CreateVehicle(GetHashKey(vehicleModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, nearestDealership.heading, false, false)
    SetEntityAsMissionEntity(previewVehicle, true, true)
    SetVehicleOnGroundProperly(previewVehicle)
    SetEntityInvincible(previewVehicle, true)
    SetVehicleDoorsLocked(previewVehicle, 4)
    FreezeEntityPosition(previewVehicle, true)
    SetModelAsNoLongerNeeded(vehicleModel)
end

-- Test drive
function StartTestDrive(vehicleModel)
    if previewVehicle then
        DeleteVehicle(previewVehicle)
        previewVehicle = nil
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find nearest dealership
    local nearestDealership = nil
    local minDistance = 999999.0
    
    for _, dealership in ipairs(Config.Dealerships) do
        local distance = #(playerCoords - dealership.location)
        if distance < minDistance then
            minDistance = distance
            nearestDealership = dealership
        end
    end
    
    if not nearestDealership then return end
    
    -- Spawn test drive vehicle
    local spawnCoords = nearestDealership.location + vector3(0.0, -5.0, 0.0)
    
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(10)
    end
    
    local testVehicle = CreateVehicle(GetHashKey(vehicleModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, nearestDealership.heading, false, false)
    SetEntityAsMissionEntity(testVehicle, true, true)
    SetVehicleOnGroundProperly(testVehicle)
    TaskWarpPedIntoVehicle(playerPed, testVehicle, -1)
    
    ESX.ShowNotification(Config.Notifications.test_drive_start)
    
    -- Delete vehicle after test drive time
    Citizen.SetTimeout(Config.TestDriveTime, function()
        if DoesEntityExist(testVehicle) then
            DeleteVehicle(testVehicle)
            ESX.ShowNotification(Config.Notifications.test_drive_end)
        end
    end)
end

-- Spawn purchased vehicle
RegisterNetEvent('bcgaming-dealership:spawnPurchasedVehicle')
AddEventHandler('bcgaming-dealership:spawnPurchasedVehicle', function(vehicleModel, vehicleProps, dealershipLocation)
    CloseDealership()
    
    local playerPed = PlayerPedId()
    local spawnCoords = vector3(dealershipLocation.x, dealershipLocation.y, dealershipLocation.z) + vector3(0.0, -5.0, 0.0)
    
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(10)
    end
    
    local vehicle = CreateVehicle(vehicleProps.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, dealershipLocation.heading, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNumberPlateText(vehicle, vehicleProps.plate)
    
    -- Set vehicle properties
    SetVehicleProps(vehicle, vehicleProps)
    
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetModelAsNoLongerNeeded(vehicleModel)
end)

-- Set vehicle properties (simplified)
function SetVehicleProps(vehicle, props)
    if props.plate then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end
    -- Add more property setting as needed
end

-- Notifications
RegisterNetEvent('bcgaming-dealership:notify')
AddEventHandler('bcgaming-dealership:notify', function(message, type)
    ESX.ShowNotification(message)
end)

-- Set player money (from server)
RegisterNetEvent('bcgaming-dealership:setPlayerMoney')
AddEventHandler('bcgaming-dealership:setPlayerMoney', function(money)
    SendNUIMessage({
        action = "setPlayerMoney",
        money = money
    })
end)

-- Camera system
local showroomCamera = nil
local currentCameraIndex = 1
-- currentDealership is set in OpenDealership function

function ChangeShowroomCamera(cameraIndex)
    if not currentDealership or not currentDealership.showroom or not currentDealership.showroom.enabled then
        return
    end
    
    local cameras = currentDealership.showroom.camera
    if not cameras or #cameras == 0 then
        return
    end
    
    if cameraIndex < 1 or cameraIndex > #cameras then
        cameraIndex = 1
    end
    
    currentCameraIndex = cameraIndex
    local camera = cameras[cameraIndex]
    
    if showroomCamera then
        DestroyCam(showroomCamera, false)
    end
    
    showroomCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(showroomCamera, camera.coords.x, camera.coords.y, camera.coords.z)
    PointCamAtCoord(showroomCamera, camera.pointAt.x, camera.pointAt.y, camera.pointAt.z)
    SetCamFov(showroomCamera, camera.fov or 50.0)
    SetCamActive(showroomCamera, true)
    RenderScriptCams(true, true, 500, true, true)
end

function ResetCamera()
    if showroomCamera then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(showroomCamera, false)
        showroomCamera = nil
    end
    currentCameraIndex = 1
end

-- Display help text
function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if previewVehicle then
            DeleteVehicle(previewVehicle)
        end
        for _, blip in ipairs(dealershipBlips) do
            RemoveBlip(blip)
        end
    end
end)
