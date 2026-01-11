# BCGAMING Dealership Script

A modern, feature-rich dealership script for FiveM servers, inspired by JG Scripts Dealerships.

## Features

- 🚗 **Vehicle Browsing**: Browse vehicles by category with filtering
- 💰 **Purchase System**: Buy vehicles with bank or cash
- 💸 **Financing System**: Advanced financing with customizable down payments, interest rates, and payment periods
- 👁️ **Vehicle Preview**: Preview vehicles before purchase
- 🎥 **Showroom Camera System**: Beautiful camera presets for viewing vehicles
- 🏎️ **Test Drive**: Customizable test drives
- 📦 **Stock System**: Track vehicle stock levels
- 🎨 **Modern UI**: Clean, intuitive, and responsive user interface
- 📍 **Multiple Locations**: Support for multiple dealership locations
- 🏪 **Category Filtering**: Custom vehicle categories per dealership
- 🗄️ **Database Integration**: Uses oxmysql for database operations
- 🛡️ **Admin Features**: Easy administration (coming soon)

## Requirements

- **ESX Framework**: This script requires ESX framework
- **oxmysql**: Database resource (https://github.com/overextended/oxmysql)
- **MySQL Database**: MySQL database for storing owned vehicles
- **Server Version**: FiveM server v7290 or newer recommended

## Installation

1. Download and extract the script to your `resources` folder
2. Rename the folder to `bcgaming-dealership` (or your preferred name)
3. Add `ensure bcgaming-dealership` to your `server.cfg`
4. Run the SQL file (`sql.sql`) in your database
5. Make sure `oxmysql` and `es_extended` are installed and running
6. Restart your server

## Configuration

Edit `config.lua` to customize:

### Dealership Locations

Add or modify dealership locations with showroom cameras:

```lua
{
    name = "Premium Motors",
    location = vector3(-56.79, -1098.9, 26.42),
    heading = 340.0,
    categories = {"Super", "Sports"}, -- Only show these categories
    blip = {
        sprite = 326,
        color = 4,
        scale = 0.8,
        label = "Premium Motors"
    },
    showroom = {
        enabled = true,
        camera = {
            {coords = vector3(-56.79, -1105.0, 27.0), pointAt = vector3(-56.79, -1098.9, 26.42), fov = 50.0}
        }
    }
}
```

### Adding Vehicles

To add vehicles to the dealership, edit `config.lua` and add entries to the `Config.Vehicles` table:

```lua
{
    model = "vehicle_model_name",
    name = "Display Name",
    price = 100000,
    category = "Sports",
    stock = 5
}
```

### Financing Settings

Customize financing options in `config.lua`:

```lua
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
```

## Usage

1. Players approach a dealership location (marked with a blip on the map)
2. Press **E** to open the dealership menu
3. Browse vehicles by category
4. Click on a vehicle to view details
5. Use the following options:
   - **Preview**: Spawn a preview vehicle (frozen, invincible)
   - **Test Drive**: Take the vehicle for a customizable test drive
   - **Purchase**: Buy the vehicle with cash/bank
   - **Finance**: Finance the vehicle with customizable terms

### Camera Controls

If a dealership has showroom cameras enabled:
- Use the arrow buttons to switch between camera angles
- Click "Reset" to return to default camera
- Camera controls appear when viewing vehicle details

### Financing

When financing is enabled:
1. Toggle "Enable Financing" in vehicle details
2. Adjust down payment percentage (slider)
3. Adjust payment period in months (slider)
4. View calculated monthly payments and total finance amount
5. Click "Finance" to purchase with financing

## File Structure

```
bcgaming-dealership/
├── fxmanifest.lua       # Resource manifest
├── config.lua           # Configuration file
├── server.lua           # Server-side script
├── client.lua           # Client-side script
├── sql.sql              # Database setup SQL
├── README.md            # This file
└── html/
    ├── index.html       # UI HTML
    ├── style.css        # UI Styles
    └── script.js        # UI Script
```

## Database Tables

The script creates the following tables:

- `owned_vehicles` - Stores player owned vehicles
- `vehicle_finances` - Stores financing information
- `dealership_display_vehicles` - Stores showroom display vehicles (for future use)

## Support

For support, issues, or feature requests, please contact BCGAMING.

## Credits

Created by BCGAMING for FiveM servers.
Inspired by JG Scripts Dealerships (https://jgscripts.com/scripts/dealerships)

## License

This script is provided as-is for use with FiveM servers.
