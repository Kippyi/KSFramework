# KSFramework - Custom FiveM Framework

A comprehensive FiveM framework split into modular resources with economy, job, inventory, housing, and banking systems.

## Version

**1.1.0**

## Directory Structure

```
KSFramework/
  resources/
    [core]/
      kr-core/          # Economy, banking, jobs, character management, exports
      kr-inventory/     # Inventory system
      kr-characters/    # Housing, properties, blips & markers
  server.cfg            # Server configuration
  install.sql           # Database setup script
```

## Features

- **Character System**: Multiple characters per player with selection/creation UI
- **Economy System**: Cash and bank with configurable starting amounts
- **Job System**: 7 jobs with 6 grades each, duty system, salary, unemployment benefits
- **Inventory System**: Stackable items, weight limits, usable items
- **Housing System**: Property ownership, renting, selling, eviction, rent collection
- **Banking System**: Deposits, withdrawals, transfers, loans with interest, transaction logging
- **Auto-Save**: Every 5 minutes + on disconnect
- **Property Blips**: Map blips and 3D markers for all properties

## Requirements

- [mysql-async](https://github.com/MyRevolution/mysql-async)
- [kr-lib](resources/[core]/kr-lib/) (built-in custom utility library)
- MySQL database

## Installation

1. Copy `KSFramework/` to your server's `resources/` directory
2. Run `install.sql` on your MySQL database
3. Add to your `server.cfg`:
   ```
   exec resources/KSFramework/server.cfg
   ```
   Or manually ensure each resource:
   ```
   ensure kr-core
   ensure kr-inventory
   ensure kr-characters
   ```
4. Configure database connection in `server.cfg`

## Commands

### Economy & Banking
- `/balance` - Check cash and bank
- `/deposit [amount]` - Deposit cash to bank
- `/withdraw [amount]` - Withdraw from bank
- `/transfer [playerId] [amount]` - Transfer to player
- `/loan [amount]` - Take a loan
- `/repayloan [amount]` - Repay loan
- `/givecash [playerId] [amount]` - Give cash (admin)

### Jobs
- `/myjob` - View current job
- `/onduty` / `/offduty` - Toggle duty
- `/setjob [playerId] [jobName] [grade]` - Set job (admin)

### Inventory
- `/giveitem [name] [count]` - Give item
- `/removeitem [name] [count]` - Remove item
- `/useitem [name]` - Use item
- `/inventory` - View inventory

### Housing
- `/buyproperty [id]` - Buy property
- `/sellproperty [id]` - Sell property
- `/rentproperty [id]` - Rent property
- `/myproperties` - View owned properties
- `/listproperties` - List all properties

## Default Jobs

| Job | Grades | Salary Range |
|-----|--------|-------------|
| Police | 6 | $50 - $150 |
| EMS | 6 | $45 - $140 |
| Mechanic | 6 | $40 - $130 |
| Taxi | 6 | $35 - $110 |
| Reporter | 6 | $30 - $120 |
| Realtor | 6 | $35 - $135 |
| Unemployed | 1 | $0 |

## Exports (Server)

```lua
exports['kr-core']:GetPlayerData(source)
exports['kr-core']:GetCash(source)
exports['kr-core']:GetBank(source)
exports['kr-core']:SetCash(source, amount)
exports['kr-core']:SetBank(source, amount)
exports['kr-core']:AddCash(source, amount)
exports['kr-core']:RemoveCash(source, amount)
exports['kr-core']:AddBank(source, amount)
exports['kr-core']:RemoveBank(source, amount)
exports['kr-core']:GetJob(source)
exports['kr-core']:SetJob(source, job, grade)
exports['kr-core']:IsPlayerLoaded(source)
exports['kr-core']:GetConfig()
exports['kr-core']:GetAllJobs()
```

## Exports (Client)

```lua
exports['kr-core']:GetPlayerData()
exports['kr-core']:IsPlayerLoaded()
exports['kr-inventory']:GetItemCount(name)
exports['kr-inventory']:HasItem(name, count)
exports['kr-inventory']:GetInventory()
exports['kr-characters']:GetPlayerProperties()
exports['kr-characters']:GetAllProperties()
exports['kr-characters']:IsPropertyOwned(id)
```

## Configuration

Edit `resources/[core]/kr-core/shared/config.lua` for all settings.

## License

Feel free to modify and use for your FiveM server.
