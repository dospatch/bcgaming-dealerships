Config = {}

-- Dealership Locations (vector3 format: x, y, z, heading)
Config.Dealerships = {
    {
        name = "Premium Motors",
        location = vector3(-56.79, -1098.9, 26.42),
        heading = 340.0,
        categories = {"Super", "Sports"}, -- Only show these categories in this dealership
        blip = {
            sprite = 326,
            color = 4,
            scale = 0.8,
            label = "Premium Motors"
        },
        showroom = {
            enabled = true,
            camera = {
                {coords = vector3(-56.79, -1105.0, 27.0), pointAt = vector3(-56.79, -1098.9, 26.42), fov = 50.0}, -- Front view
                {coords = vector3(-48.0, -1098.9, 27.0), pointAt = vector3(-56.79, -1098.9, 26.42), fov = 50.0}, -- Side view
                {coords = vector3(-56.79, -1092.0, 30.0), pointAt = vector3(-56.79, -1098.9, 26.42), fov = 50.0}  -- Top view
            },
            displaySlots = {
                {coords = vector3(-60.0, -1098.9, 26.42), heading = 340.0},
                {coords = vector3(-53.58, -1098.9, 26.42), heading = 340.0},
                {coords = vector3(-56.79, -1102.0, 26.42), heading = 250.0}
            }
        }
    },
    {
        name = "LS Customs Dealership",
        location = vector3(-33.74, -1102.02, 26.42),
        heading = 340.0,
        categories = {"Sedans", "SUVs", "Muscle", "Coupes", "Compacts"}, -- Only show these categories
        blip = {
            sprite = 326,
            color = 4,
            scale = 0.8,
            label = "LS Customs Dealership"
        },
        showroom = {
            enabled = true,
            camera = {
                {coords = vector3(-33.74, -1108.0, 27.0), pointAt = vector3(-33.74, -1102.02, 26.42), fov = 50.0},
                {coords = vector3(-25.0, -1102.02, 27.0), pointAt = vector3(-33.74, -1102.02, 26.42), fov = 50.0},
                {coords = vector3(-33.74, -1095.0, 30.0), pointAt = vector3(-33.74, -1102.02, 26.42), fov = 50.0}
            },
            displaySlots = {
                {coords = vector3(-37.0, -1102.02, 26.42), heading = 340.0},
                {coords = vector3(-30.48, -1102.02, 26.42), heading = 340.0}
            }
        }
    }
}

-- Vehicle Categories
Config.Categories = {
    "Sports",
    "Super",
    "Sedans",
    "SUVs",
    "Muscle",
    "Coupes",
    "Compacts",
    "Motorcycles"
}

-- Vehicle List (Add your vehicles here)
Config.Vehicles = {
    -- Sports Cars
    {
        model = "adder",
        name = "Adder",
        price = 1000000,
        category = "Super",
        stock = 5
    },
    {
        model = "entityxf",
        name = "Entity XF",
        price = 795000,
        category = "Super",
        stock = 3
    },
    {
        model = "zentorno",
        name = "Zentorno",
        price = 725000,
        category = "Super",
        stock = 4
    },
    {
        model = "t20",
        name = "T20",
        price = 2200000,
        category = "Super",
        stock = 2
    },
    {
        model = "osiris",
        name = "Osiris",
        price = 1950000,
        category = "Super",
        stock = 3
    },
    {
        model = "turismor",
        name = "Turismo R",
        price = 500000,
        category = "Super",
        stock = 5
    },
    -- Sports
    {
        model = "carbonizzare",
        name = "Carbonizzare",
        price = 195000,
        category = "Sports",
        stock = 5
    },
    {
        model = "comet2",
        name = "Comet",
        price = 100000,
        category = "Sports",
        stock = 7
    },
    {
        model = "coquette",
        name = "Coquette",
        price = 138000,
        category = "Sports",
        stock = 6
    },
    {
        model = "elegy",
        name = "Elegy RH8",
        price = 95000,
        category = "Sports",
        stock = 8
    },
    {
        model = "feltzer2",
        name = "Feltzer",
        price = 130000,
        category = "Sports",
        stock = 5
    },
    {
        model = "jester",
        name = "Jester",
        price = 240000,
        category = "Sports",
        stock = 4
    },
    -- Sedans
    {
        model = "asea",
        name = "Asea",
        price = 12000,
        category = "Sedans",
        stock = 10
    },
    {
        model = "asterope",
        name = "Asterope",
        price = 22000,
        category = "Sedans",
        stock = 10
    },
    {
        model = "cognoscenti",
        name = "Cognoscenti",
        price = 150000,
        category = "Sedans",
        stock = 5
    },
    {
        model = "fugitive",
        name = "Fugitive",
        price = 12000,
        category = "Sedans",
        stock = 10
    },
    {
        model = "glendale",
        name = "Glendale",
        price = 20000,
        category = "Sedans",
        stock = 8
    },
    -- SUVs
    {
        model = "baller",
        name = "Baller",
        price = 90000,
        category = "SUVs",
        stock = 6
    },
    {
        model = "cavalcade",
        name = "Cavalcade",
        price = 60000,
        category = "SUVs",
        stock = 7
    },
    {
        model = "granger",
        name = "Granger",
        price = 35000,
        category = "SUVs",
        stock = 8
    },
    {
        model = "huntley",
        name = "Huntley S",
        price = 195000,
        category = "SUVs",
        stock = 5
    },
    -- Muscle
    {
        model = "blade",
        name = "Blade",
        price = 15000,
        category = "Muscle",
        stock = 8
    },
    {
        model = "buccaneer",
        name = "Buccaneer",
        price = 29000,
        category = "Muscle",
        stock = 7
    },
    {
        model = "chino",
        name = "Chino",
        price = 225000,
        category = "Muscle",
        stock = 4
    },
    {
        model = "dominator",
        name = "Dominator",
        price = 35000,
        category = "Muscle",
        stock = 6
    },
    {
        model = "gauntlet",
        name = "Gauntlet",
        price = 32000,
        category = "Muscle",
        stock = 7
    },
    -- Motorcycles
    {
        model = "akuma",
        name = "Akuma",
        price = 9000,
        category = "Motorcycles",
        stock = 10
    },
    {
        model = "bagger",
        name = "Bagger",
        price = 13500,
        category = "Motorcycles",
        stock = 8
    },
    {
        model = "bati",
        name = "Bati 801",
        price = 15000,
        category = "Motorcycles",
        stock = 9
    },
    {
        model = "carbonrs",
        name = "Carbon RS",
        price = 40000,
        category = "Motorcycles",
        stock = 6
    },
    {
        model = "daemon",
        name = "Daemon",
        price = 12000,
        category = "Motorcycles",
        stock = 8
    }
}

-- Settings
Config.EnableBlips = true
Config.TestDriveTime = 60000 -- 60 seconds in milliseconds
Config.PreviewDistance = 50.0 -- Distance to spawn preview vehicle
Config.InteractionDistance = 3.0 -- Distance to interact with dealership
Config.UseBankAccount = true -- Set to false to use cash
Config.EnableFinance = true -- Enable financing options

-- Financing Settings
Config.Finance = {
    enabled = true,
    minDownPayment = 10, -- Minimum down payment percentage
    maxDownPayment = 50, -- Maximum down payment percentage
    defaultDownPayment = 20, -- Default down payment percentage
    interestRate = 5, -- Interest rate percentage
    maxPaymentPeriods = 60, -- Maximum payment periods (months)
    minPaymentPeriods = 12, -- Minimum payment periods (months)
    defaultPaymentPeriods = 24 -- Default payment periods
}

-- Admin Settings
Config.AdminGroups = {
    'admin',
    'superadmin',
    'mod'
}

-- Preview Settings
Config.PreviewSpawnOffset = vector3(0.0, 0.0, 0.0) -- Offset from dealership location

-- Notifications
Config.Notifications = {
    purchase_success = "You have successfully purchased a %s for $%s",
    purchase_failed = "Failed to purchase vehicle",
    insufficient_funds = "You don't have enough money to purchase this vehicle",
    test_drive_start = "Test drive started! You have 60 seconds.",
    test_drive_end = "Test drive ended.",
    vehicle_already_owned = "You already own this vehicle",
    stock_unavailable = "This vehicle is out of stock",
    finance_approved = "Finance approved! You will pay $%s per month for %s months.",
    finance_declined = "Finance application declined. Insufficient funds for down payment.",
    admin_added_vehicle = "Vehicle added to dealership",
    admin_removed_vehicle = "Vehicle removed from dealership",
    admin_set_stock = "Stock updated"
}
