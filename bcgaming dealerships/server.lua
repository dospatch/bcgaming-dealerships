-- BCGAMING Dealership Server Script

ESX = exports['es_extended']:getSharedObject()

-- Database table setup (run this SQL query in your database)
--[[
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(60) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`plate`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]]

RegisterNetEvent('bcgaming-dealership:buyVehicle')
AddEventHandler('bcgaming-dealership:buyVehicle', function(vehicleModel, vehiclePrice, dealershipLocation)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
        return
    end

    -- Find vehicle in config
    local vehicleData = nil
    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.model == vehicleModel then
            vehicleData = vehicle
            break
        end
    end

    if not vehicleData then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
        return
    end

    -- Check stock
    if vehicleData.stock and vehicleData.stock <= 0 then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.stock_unavailable, 'error')
        return
    end

    -- Check if player has enough money
    local playerMoney = 0
    if Config.UseBankAccount then
        playerMoney = xPlayer.getAccount('bank').money
    else
        playerMoney = xPlayer.getMoney()
    end

    if playerMoney < vehiclePrice then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.insufficient_funds, 'error')
        return
    end

    -- Check if player already owns this vehicle (optional check)
    MySQL.query('SELECT * FROM owned_vehicles WHERE owner = ? AND vehicle LIKE ?', {
        xPlayer.identifier,
        '%' .. vehicleModel .. '%'
    }, function(result)
        if result and #result > 0 then
            TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.vehicle_already_owned, 'error')
            return
        end

        -- Remove money
        if Config.UseBankAccount then
            xPlayer.removeAccountMoney('bank', vehiclePrice)
        else
            xPlayer.removeMoney(vehiclePrice)
        end

        -- Generate plate
        local plate = GeneratePlate()

        -- Create vehicle data
        local vehicleProps = {
            model = GetHashKey(vehicleModel),
            plate = plate
        }

        -- Insert vehicle into database
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
            xPlayer.identifier,
            plate,
            json.encode(vehicleProps)
        }, function(insertId)
            if insertId then
                -- Update stock
                if vehicleData.stock then
                    vehicleData.stock = vehicleData.stock - 1
                end

                -- Notify success
                TriggerClientEvent('bcgaming-dealership:notify', src, 
                    string.format(Config.Notifications.purchase_success, vehicleData.name, formatMoney(vehiclePrice)), 
                    'success')
                
                -- Spawn vehicle for player
                TriggerClientEvent('bcgaming-dealership:spawnPurchasedVehicle', src, vehicleModel, vehicleProps, dealershipLocation)
            else
                -- Refund money on error
                if Config.UseBankAccount then
                    xPlayer.addAccountMoney('bank', vehiclePrice)
                else
                    xPlayer.addMoney(vehiclePrice)
                end
                TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
            end
        end)
    end)
end)

-- Generate random plate
function GeneratePlate()
    local plate = ""
    for i = 1, 8 do
        local rand = math.random(1, 36)
        if rand <= 26 then
            plate = plate .. string.char(64 + rand)
        else
            plate = plate .. tostring(rand - 27)
        end
    end
    return plate
end

-- Format money
function formatMoney(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return "$" .. formatted
end

-- Finance purchase
RegisterNetEvent('bcgaming-dealership:buyVehicleFinance')
AddEventHandler('bcgaming-dealership:buyVehicleFinance', function(vehicleModel, vehiclePrice, dealershipLocation, downPayment, paymentPeriods)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer or not Config.Finance.enabled then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
        return
    end
    
    -- Find vehicle in config
    local vehicleData = nil
    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.model == vehicleModel then
            vehicleData = vehicle
            break
        end
    end
    
    if not vehicleData then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
        return
    end
    
    -- Validate finance parameters
    downPayment = math.max(Config.Finance.minDownPayment, math.min(Config.Finance.maxDownPayment, downPayment))
    paymentPeriods = math.max(Config.Finance.minPaymentPeriods, math.min(Config.Finance.maxPaymentPeriods, paymentPeriods))
    
    local downPaymentAmount = math.floor(vehiclePrice * (downPayment / 100))
    local financeAmount = vehiclePrice - downPaymentAmount
    local interestAmount = math.floor(financeAmount * (Config.Finance.interestRate / 100))
    local totalFinanceAmount = financeAmount + interestAmount
    local monthlyPayment = math.floor(totalFinanceAmount / paymentPeriods)
    
    -- Check if player has enough for down payment
    local playerMoney = 0
    if Config.UseBankAccount then
        playerMoney = xPlayer.getAccount('bank').money
    else
        playerMoney = xPlayer.getMoney()
    end
    
    if playerMoney < downPaymentAmount then
        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.finance_declined, 'error')
        return
    end
    
    -- Check if player already owns this vehicle
    MySQL.query('SELECT * FROM owned_vehicles WHERE owner = ? AND vehicle LIKE ?', {
        xPlayer.identifier,
        '%' .. vehicleModel .. '%'
    }, function(result)
        if result and #result > 0 then
            TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.vehicle_already_owned, 'error')
            return
        end
        
        -- Remove down payment
        if Config.UseBankAccount then
            xPlayer.removeAccountMoney('bank', downPaymentAmount)
        else
            xPlayer.removeMoney(downPaymentAmount)
        end
        
        -- Generate plate
        local plate = GeneratePlate()
        
        -- Create vehicle data
        local vehicleProps = {
            model = GetHashKey(vehicleModel),
            plate = plate
        }
        
        -- Insert vehicle into database
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
            xPlayer.identifier,
            plate,
            json.encode(vehicleProps)
        }, function(insertId)
            if insertId then
                -- Create finance record
                local nextPaymentDate = os.time() + (30 * 24 * 60 * 60) -- 30 days from now
                MySQL.insert('INSERT INTO vehicle_finances (owner, plate, vehicle, total_price, down_payment, monthly_payment, remaining_payments, total_payments, next_payment_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                    xPlayer.identifier,
                    plate,
                    vehicleModel,
                    vehiclePrice,
                    downPaymentAmount,
                    monthlyPayment,
                    paymentPeriods,
                    paymentPeriods,
                    nextPaymentDate
                }, function(financeId)
                    if financeId then
                        TriggerClientEvent('bcgaming-dealership:notify', src, 
                            string.format(Config.Notifications.finance_approved, formatMoney(monthlyPayment), paymentPeriods), 
                            'success')
                        TriggerClientEvent('bcgaming-dealership:spawnPurchasedVehicle', src, vehicleModel, vehicleProps, dealershipLocation)
                    else
                        -- Refund on error
                        if Config.UseBankAccount then
                            xPlayer.addAccountMoney('bank', downPaymentAmount)
                        else
                            xPlayer.addMoney(downPaymentAmount)
                        end
                        TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
                    end
                end)
            else
                -- Refund on error
                if Config.UseBankAccount then
                    xPlayer.addAccountMoney('bank', downPaymentAmount)
                else
                    xPlayer.addMoney(downPaymentAmount)
                end
                TriggerClientEvent('bcgaming-dealership:notify', src, Config.Notifications.purchase_failed, 'error')
            end
        end)
    end)
end)

-- Get player money
RegisterNetEvent('bcgaming-dealership:getPlayerMoney')
AddEventHandler('bcgaming-dealership:getPlayerMoney', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local money = 0
        if Config.UseBankAccount then
            money = xPlayer.getAccount('bank').money
        else
            money = xPlayer.getMoney()
        end
        TriggerClientEvent('bcgaming-dealership:setPlayerMoney', src, money)
    end
end)
