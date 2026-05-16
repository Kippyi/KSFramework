RegisterNetEvent('kr-core:deposit')
AddEventHandler('kr-core:deposit', function(amount)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local amount = tonumber(amount)

    if not character or not amount or amount <= 0 then return end

    if character.cash >= amount then
        MySQL.Async.execute('UPDATE player_characters SET cash = cash - @amount, bank = bank + @amount WHERE id = @id', {
            ['@amount'] = amount,
            ['@id'] = character.id
        })

        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = character.id,
            ['@type'] = 'deposit',
            ['@amount'] = amount,
            ['@description'] = 'Cash deposit'
        })

        character.cash = character.cash - amount
        character.bank = character.bank + amount

        TriggerClientEvent('kr-core:updateCash', source, character.cash)
        TriggerClientEvent('kr-core:updateBank', source, character.bank)
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {'[Bank]', ('Deposited $%d successfully.'):format(amount)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Insufficient cash.'}
        })
    end
end)

RegisterNetEvent('kr-core:withdraw')
AddEventHandler('kr-core:withdraw', function(amount)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local amount = tonumber(amount)

    if not character or not amount or amount <= 0 then return end

    if character.bank >= amount then
        MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount, bank = bank - @amount WHERE id = @id', {
            ['@amount'] = amount,
            ['@id'] = character.id
        })

        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = character.id,
            ['@type'] = 'withdraw',
            ['@amount'] = amount,
            ['@description'] = 'Cash withdrawal'
        })

        character.cash = character.cash + amount
        character.bank = character.bank - amount

        TriggerClientEvent('kr-core:updateCash', source, character.cash)
        TriggerClientEvent('kr-core:updateBank', source, character.bank)
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {'[Bank]', ('Withdrew $%d successfully.'):format(amount)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Insufficient bank balance.'}
        })
    end
end)

RegisterNetEvent('kr-core:transferMoney')
AddEventHandler('kr-core:transferMoney', function(targetSrc, amount)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local target = tonumber(targetSrc)
    local amount = tonumber(amount)

    if not character or not target or not amount or amount <= 0 then return end
    if target == source then return end

    local targetCharacter = exports['kr-core']:GetPlayerData(target)
    if not targetCharacter then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Player not found.'}
        })
        return
    end

    if character.bank >= amount then
        MySQL.Async.execute('UPDATE player_characters SET bank = bank - @amount WHERE id = @id', {
            ['@amount'] = amount,
            ['@id'] = character.id
        })

        MySQL.Async.execute('UPDATE player_characters SET bank = bank + @amount WHERE id = @id', {
            ['@amount'] = amount,
            ['@id'] = targetCharacter.id
        })

        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = character.id,
            ['@type'] = 'transfer_sent',
            ['@amount'] = amount,
            ['@description'] = ('Transfer to %s %s'):format(targetCharacter.firstname, targetCharacter.lastname)
        })

        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = targetCharacter.id,
            ['@type'] = 'transfer_received',
            ['@amount'] = amount,
            ['@description'] = ('Transfer from %s %s'):format(character.firstname, character.lastname)
        })

        character.bank = character.bank - amount
        targetCharacter.bank = targetCharacter.bank + amount

        TriggerClientEvent('kr-core:updateBank', source, character.bank)
        TriggerClientEvent('kr-core:updateBank', target, targetCharacter.bank)

        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {'[Bank]', ('Transferred $%d to %s %s.'):format(amount, targetCharacter.firstname, targetCharacter.lastname)}
        })

        TriggerClientEvent('chat:addMessage', target, {
            color = {0, 255, 0},
            args = {'[Bank]', ('Received $%d from %s %s.'):format(amount, character.firstname, character.lastname)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Insufficient bank balance.'}
        })
    end
end)

RegisterNetEvent('kr-core:takeLoan')
AddEventHandler('kr-core:takeLoan', function(amount)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local amount = tonumber(amount)

    if not character or not amount or amount <= 0 then return end

    if not Config.Banking.EnableLoans then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Loans are disabled on this server.'}
        })
        return
    end

    if amount > Config.Banking.MaxLoanAmount then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', ('Maximum loan amount is $%d.'):format(Config.Banking.MaxLoanAmount)}
        })
        return
    end

    local debt = character.bank_debt or 0
    if debt + amount > Config.Banking.MaxLoanAmount then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Cannot exceed maximum loan limit.'}
        })
        return
    end

    MySQL.Async.execute('UPDATE player_characters SET bank = bank + @amount, bank_debt = bank_debt + @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
        ['@characterId'] = character.id,
        ['@type'] = 'loan',
        ['@amount'] = amount,
        ['@description'] = 'Loan taken'
    })

    character.bank = character.bank + amount
    character.bank_debt = (character.bank_debt or 0) + amount

    TriggerClientEvent('kr-core:updateBank', source, character.bank)
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        args = {'[Bank]', ('Loan of $%d approved. Interest rate: %.0f%% daily.'):format(amount, Config.Banking.LoanInterestRate * 100)}
    })
end)

RegisterNetEvent('kr-core:repayLoan')
AddEventHandler('kr-core:repayLoan', function(amount)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local amount = tonumber(amount)

    if not character or not amount or amount <= 0 then return end

    local debt = character.bank_debt or 0
    if debt <= 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'You have no outstanding loans.'}
        })
        return
    end

    local repayAmount = math.min(amount, debt)

    if character.bank >= repayAmount then
        MySQL.Async.execute('UPDATE player_characters SET bank = bank - @amount, bank_debt = bank_debt - @amount WHERE id = @id', {
            ['@amount'] = repayAmount,
            ['@id'] = character.id
        })

        MySQL.Async.execute('INSERT INTO bank_transactions (character_id, transaction_type, amount, description) VALUES (@characterId, @type, @amount, @description)', {
            ['@characterId'] = character.id,
            ['@type'] = 'loan_repayment',
            ['@amount'] = repayAmount,
            ['@description'] = 'Loan repayment'
        })

        character.bank = character.bank - repayAmount
        character.bank_debt = character.bank_debt - repayAmount

        TriggerClientEvent('kr-core:updateBank', source, character.bank)
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            args = {'[Bank]', ('Repaid $%d towards your loan. Remaining debt: $%d'):format(repayAmount, character.bank_debt)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[Bank]', 'Insufficient bank balance.'}
        })
    end
end)

if Config.Banking.EnableInterest then
    CreateThread(function()
        while true do
            Wait(86400000)

            MySQL.Async.fetchAll('SELECT id, bank_debt FROM player_characters WHERE bank_debt > 0', {}, function(result)
                for _, row in ipairs(result) do
                    local interest = math.floor(row.bank_debt * Config.Banking.LoanInterestRate)
                    MySQL.Async.execute('UPDATE player_characters SET bank_debt = bank_debt + @interest WHERE id = @id', {
                        ['@interest'] = interest,
                        ['@id'] = row.id
                    })
                end
            end)

            MySQL.Async.fetchAll('SELECT id, bank FROM player_characters WHERE bank > 0', {}, function(result)
                for _, row in ipairs(result) do
                    local interest = math.floor(row.bank * Config.Banking.InterestRate)
                    MySQL.Async.execute('UPDATE player_characters SET bank = bank + @interest WHERE id = @id', {
                        ['@interest'] = interest,
                        ['@id'] = row.id
                    })
                end
            end)
        end
    end)
end
