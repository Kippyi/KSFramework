print(('[%s] Initializing %s v%s'):format(
    os.date('%Y-%m-%d %H:%M:%S'),
    Config.FrameworkName,
    Config.FrameworkVersion
))

local PlayerData = {}

MySQL.ready(function()
    print('Database connection established')

    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `users` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(50) NOT NULL,
            `name` VARCHAR(50) NOT NULL,
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function() print('Users table ready') end)

    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `player_characters` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(50) NOT NULL,
            `firstname` VARCHAR(50) NOT NULL,
            `lastname` VARCHAR(50) NOT NULL,
            `dateofbirth` DATE NOT NULL,
            `gender` VARCHAR(10) NOT NULL,
            `nationality` VARCHAR(50) DEFAULT 'American',
            `height` INT(11) DEFAULT 180,
            `skin` JSON DEFAULT NULL,
            `job` VARCHAR(50) DEFAULT 'unemployed',
            `job_grade` INT(11) DEFAULT 0,
            `level` INT(11) DEFAULT 1,
            `xp` INT(11) DEFAULT 0,
            `cash` INT(11) DEFAULT 0,
            `bank` INT(11) DEFAULT 0,
            `bank_debt` INT(11) DEFAULT 0,
            `position` JSON DEFAULT '{"x": 0.0, "y": 0.0, "z": 0.0}',
            `inventory` JSON DEFAULT '{}',
            `metadata` JSON DEFAULT '{}',
            `is_dead` TINYINT(1) DEFAULT 0,
            `last_seen` DATETIME DEFAULT CURRENT_TIMESTAMP,
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            INDEX `identifier` (`identifier`),
            INDEX `job` (`job`),
            INDEX `job_grade` (`job_grade`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function() print('Characters table ready') end)

    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `player_jobs` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `character_id` INT(11) NOT NULL,
            `job_name` VARCHAR(50) NOT NULL,
            `job_grade` INT(11) DEFAULT 0,
            `on_duty` TINYINT(1) DEFAULT 0,
            `employed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            FOREIGN KEY (character_id) REFERENCES player_characters(id) ON DELETE CASCADE,
            INDEX `character_id` (character_id),
            INDEX `job_name` (job_name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function() print('Jobs table ready') end)

    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `bank_transactions` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `character_id` INT(11) NOT NULL,
            `transaction_type` VARCHAR(20) NOT NULL,
            `amount` INT(11) NOT NULL,
            `description` VARCHAR(255) DEFAULT NULL,
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            INDEX `character_id` (character_id),
            INDEX `transaction_type` (transaction_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function() print('Bank transactions table ready') end)

    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `society_accounts` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(50) NOT NULL,
            `label` VARCHAR(100) NOT NULL,
            `money` INT(11) DEFAULT 0,
            `bank` INT(11) DEFAULT 0,
            `type` VARCHAR(20) DEFAULT 'society',
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `name` (`name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function() print('Society accounts table ready') end)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)

    deferrals.defer()
    deferrals.update('Loading character data...')

    MySQL.Async.fetchScalar('SELECT id FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(userId)
        if not userId then
            MySQL.Async.execute('INSERT INTO users (identifier, name) VALUES (@identifier, @name)', {
                ['@identifier'] = identifier,
                ['@name'] = name
            })
        end
        deferrals.done()
    end)
end)

AddEventHandler('playerSpawned', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)

    MySQL.Async.fetchAll('SELECT * FROM player_characters WHERE identifier = @identifier ORDER BY id', {
        ['@identifier'] = identifier
    }, function(characters)
        if characters and #characters > 0 then
            TriggerClientEvent('kr-core:showCharacterSelection', source, characters)
        else
            TriggerClientEvent('kr-core:showCharacterCreation', source)
        end
    end)
end)

RegisterNetEvent('kr-core:selectCharacter')
AddEventHandler('kr-core:selectCharacter', function(characterId)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)

    MySQL.Async.fetchAll('SELECT * FROM player_characters WHERE id = @id AND identifier = @identifier', {
        ['@id'] = characterId,
        ['@identifier'] = identifier
    }, function(result)
        if result and result[1] then
            local character = result[1]
            PlayerData[source] = character

            local pos = {}
            if character.position then
                pos = json.decode(character.position)
            end

            local spawnPos = pos.x ~= 0 and pos or {x = -540.0, y = -212.0, z = 37.0}
            TriggerClientEvent('kr-core:spawnPlayer', source, spawnPos, character)

            print(('Character %s %s loaded for player %s'):format(character.firstname, character.lastname, GetPlayerName(source)))
        end
    end)
end)

RegisterNetEvent('kr-core:createCharacter')
AddEventHandler('kr-core:createCharacter', function(data)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)

    MySQL.Async.execute('INSERT INTO player_characters (identifier, firstname, lastname, dateofbirth, gender, nationality, job, cash, bank) VALUES (@identifier, @firstname, @lastname, @dateofbirth, @gender, @nationality, @job, @cash, @bank)', {
        ['@identifier'] = identifier,
        ['@firstname'] = data.firstname,
        ['@lastname'] = data.lastname,
        ['@dateofbirth'] = data.dateofbirth,
        ['@gender'] = data.gender,
        ['@nationality'] = data.nationality or 'American',
        ['@job'] = 'unemployed',
        ['@cash'] = Config.Economy.StartingMoney,
        ['@bank'] = Config.Economy.StartingBank
    }, function(charResult)
        MySQL.Async.fetchAll('SELECT * FROM player_characters WHERE id = @id', {
            ['@id'] = charResult
        }, function(result)
            if result and result[1] then
                PlayerData[source] = result[1]
                TriggerClientEvent('kr-core:spawnPlayer', source, {x = -540.0, y = -212.0, z = 37.0}, result[1])
                TriggerClientEvent('kr-core:characterCreated', source, result[1])
            end
        end)
    end)
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local character = PlayerData[source]

    if character then
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)

        MySQL.Async.execute('UPDATE player_characters SET position = @position, last_seen = NOW() WHERE id = @id', {
            ['@position'] = json.encode({x = coords.x, y = coords.y, z = coords.z}),
            ['@id'] = character.id
        })

        print(('Character %s %s saved. Player left: %s'):format(character.firstname, character.lastname, reason))
        PlayerData[source] = nil
    end
end)

function GetPlayerData(source)
    return PlayerData[source]
end

function GetCharacterId(source)
    local data = PlayerData[source]
    return data and data.id or nil
end

CreateThread(function()
    while true do
        Wait(Config.Economy.PaycheckInterval)

        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local src = tonumber(playerId)
            local character = PlayerData[src]

            if character then
                MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount WHERE id = @id', {
                    ['@amount'] = Config.Economy.PaycheckAmount,
                    ['@id'] = character.id
                })

                character.cash = character.cash + Config.Economy.PaycheckAmount
                TriggerClientEvent('kr-core:paycheck', src, Config.Economy.PaycheckAmount)
                TriggerClientEvent('kr-core:updateCash', src, character.cash)
            end
        end

        if #players > 0 then
            print(('Paycheck of $%d distributed to %d players'):format(Config.Economy.PaycheckAmount, #players))
        end
    end
end)

RegisterCommand('balance', function(source, args, rawCommand)
    local character = PlayerData[source]
    if character then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            args = {'[Balance]', ('Cash: $%d | Bank: $%d'):format(character.cash, character.bank)}
        })
    end
end, false)

RegisterCommand('givecash', function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, 'command') or source == 0 then
        local target = tonumber(args[1])
        local amount = tonumber(args[2])

        if target and amount and amount > 0 then
            local targetCharacter = PlayerData[target]
            if targetCharacter then
                MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount WHERE id = @id', {
                    ['@amount'] = amount,
                    ['@id'] = targetCharacter.id
                })

                targetCharacter.cash = targetCharacter.cash + amount
                TriggerClientEvent('kr-core:addMoney', target, amount)
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    args = {'[GiveCash]', ('Gave $%d to player %d'):format(amount, target)}
                })
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    args = {'[Error]', 'Player not loaded'}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /givecash [playerId] [amount]'}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Error]', 'Insufficient permissions'}
        })
    end
end, false)

RegisterCommand('setjob', function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, 'command') or source == 0 then
        if #args >= 2 then
            local target = tonumber(args[1])
            local jobName = args[2]
            local grade = tonumber(args[3]) or 0

            if target then
                TriggerEvent('kr-core:setJob', target, jobName, grade)
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    args = {'[Error]', 'Usage: /setjob [playerId] [jobName] [grade]'}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /setjob [playerId] [jobName] [grade]'}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Error]', 'Insufficient permissions'}
        })
    end
end, false)

RegisterCommand('myinfo', function(source, args, rawCommand)
    local character = PlayerData[source]
    if character then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            args = {'[Info]', ('Name: %s %s | Job: %s (Grade %s) | Level: %s'):format(character.firstname, character.lastname, character.job, character.job_grade, character.level)}
        })
    end
end, false)

RegisterCommand('help', function(source, args, rawCommand)
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        args = {'[Help]', 'Commands: /balance, /myinfo, /deposit, /withdraw, /transfer, /loan, /repayloan, /giveitem, /removeitem, /useitem, /inventory, /buyproperty, /sellproperty, /rentproperty, /myproperties, /listproperties, /onduty, /offduty'}
    })
end, false)

RegisterCommand('pos', function(source, args, rawCommand)
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(source), false))
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        args = {'[Position]', ('X: %.2f, Y: %.2f, Z: %.2f'):format(x, y, z)}
    })
end, false)

RegisterCommand('clear', function(source, args, rawCommand)
    TriggerClientEvent('chat:clear', source)
end, false)

CreateThread(function()
    while true do
        Wait(Config.AutoSaveInterval)

        local count = 0
        for source, character in pairs(PlayerData) do
            if character then
                local ped = GetPlayerPed(tonumber(source))
                local coords = GetEntityCoords(ped)

                MySQL.Async.execute('UPDATE player_characters SET cash = @cash, bank = @bank, job = @job, job_grade = @job_grade, level = @level, xp = @xp, position = @position, last_seen = NOW() WHERE id = @id', {
                    ['@cash'] = character.cash,
                    ['@bank'] = character.bank,
                    ['@job'] = character.job,
                    ['@job_grade'] = character.job_grade,
                    ['@level'] = character.level,
                    ['@xp'] = character.xp,
                    ['@position'] = json.encode({x = coords.x, y = coords.y, z = coords.z}),
                    ['@id'] = character.id
                })

                count = count + 1
            end
        end

        if count > 0 then
            print(('[AutoSave] Saved %d characters'):format(count))
        end
    end
end)

exports('GetPlayerData', function(source)
    return PlayerData[source]
end)

exports('GetCharacterId', function(source)
    local data = PlayerData[source]
    return data and data.id or nil
end)

exports('GetCash', function(source)
    local data = PlayerData[source]
    return data and data.cash or 0
end)

exports('GetBank', function(source)
    local data = PlayerData[source]
    return data and data.bank or 0
end)

exports('SetCash', function(source, amount, reason)
    local character = PlayerData[source]
    if not character then return false end

    local diff = amount - character.cash
    MySQL.Async.execute('UPDATE player_characters SET cash = @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    if reason then
        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = character.id,
            ['@type'] = diff > 0 and 'admin_add' or 'admin_remove',
            ['@amount'] = math.abs(diff),
            ['@description'] = reason
        })
    end

    character.cash = amount
    TriggerClientEvent('kr-core:updateCash', source, amount)
    return true
end)

exports('SetBank', function(source, amount, reason)
    local character = PlayerData[source]
    if not character then return false end

    local diff = amount - character.bank
    MySQL.Async.execute('UPDATE player_characters SET bank = @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    if reason then
        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = character.id,
            ['@type'] = diff > 0 and 'admin_add_bank' or 'admin_remove_bank',
            ['@amount'] = math.abs(diff),
            ['@description'] = reason
        })
    end

    character.bank = amount
    TriggerClientEvent('kr-core:updateBank', source, amount)
    return true
end)

exports('AddCash', function(source, amount)
    local character = PlayerData[source]
    if not character then return false end

    MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    character.cash = character.cash + amount
    TriggerClientEvent('kr-core:updateCash', source, character.cash)
    return true
end)

exports('RemoveCash', function(source, amount)
    local character = PlayerData[source]
    if not character or character.cash < amount then return false end

    MySQL.Async.execute('UPDATE player_characters SET cash = cash - @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    character.cash = character.cash - amount
    TriggerClientEvent('kr-core:updateCash', source, character.cash)
    return true
end)

exports('AddBank', function(source, amount)
    local character = PlayerData[source]
    if not character then return false end

    MySQL.Async.execute('UPDATE player_characters SET bank = bank + @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    character.bank = character.bank + amount
    TriggerClientEvent('kr-core:updateBank', source, character.bank)
    return true
end)

exports('RemoveBank', function(source, amount)
    local character = PlayerData[source]
    if not character or character.bank < amount then return false end

    MySQL.Async.execute('UPDATE player_characters SET bank = bank - @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    character.bank = character.bank - amount
    TriggerClientEvent('kr-core:updateBank', source, character.bank)
    return true
end)

exports('GetJob', function(source)
    local character = PlayerData[source]
    if not character then return nil end
    return { name = character.job, grade = character.job_grade }
end)

exports('SetJob', function(source, jobName, grade)
    TriggerEvent('kr-core:setJob', source, jobName, grade or 0)
end)

exports('IsPlayerLoaded', function(source)
    return PlayerData[source] ~= nil
end)

exports('GetConfig', function()
    return Config
end)

exports('GetJobConfig', function(jobName)
    return Config.Jobs[jobName]
end)

exports('GetAllJobs', function()
    return Config.Jobs
end)
