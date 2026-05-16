RegisterNetEvent('kr-core:setJob')
AddEventHandler('kr-core:setJob', function(targetSrc, jobName, grade)
    local source = source
    local target = targetSrc or source
    local character = exports['kr-core']:GetPlayerData(target)

    if not character then
        if source then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {'[Error]', 'Player not loaded'}
            })
        end
        return
    end

    MySQL.Async.execute('UPDATE player_characters SET job = @job, job_grade = @grade WHERE id = @id', {
        ['@job'] = jobName,
        ['@grade'] = grade,
        ['@id'] = character.id
    }, function()
        character.job = jobName
        character.job_grade = grade

        MySQL.Async.fetchScalar('SELECT id FROM player_jobs WHERE character_id = @characterId', {
            ['@characterId'] = character.id
        }, function(existingJobId)
            if existingJobId then
                MySQL.Async.execute('UPDATE player_jobs SET job_name = @jobName, job_grade = @grade, on_duty = 0, employed_at = NOW() WHERE character_id = @characterId', {
                    ['@jobName'] = jobName,
                    ['@grade'] = grade,
                    ['@characterId'] = character.id
                })
            else
                MySQL.Async.execute('INSERT INTO player_jobs (character_id, job_name, job_grade, on_duty) VALUES (@characterId, @jobName, @grade, 0)', {
                    ['@characterId'] = character.id,
                    ['@jobName'] = jobName,
                    ['@grade'] = grade
                })
            end

            TriggerClientEvent('kr-core:jobUpdate', target, jobName, grade)
            TriggerEvent('kr-core:jobChanged', target, jobName, grade)
        end)
    end)
end)

RegisterNetEvent('kr-core:getJob')
AddEventHandler('kr-core:getJob', function()
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)

    if character then
        TriggerClientEvent('kr-core:jobUpdate', source, character.job or 'unemployed', character.job_grade or 0)
    end
end)

RegisterNetEvent('kr-core:setDuty')
AddEventHandler('kr-core:setDuty', function(onDuty)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)

    if character then
        MySQL.Async.execute('UPDATE player_jobs SET on_duty = @onDuty WHERE character_id = @characterId', {
            ['@onDuty'] = onDuty and 1 or 0,
            ['@characterId'] = character.id
        }, function()
            TriggerClientEvent('kr-core:dutyUpdate', source, onDuty)
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {'[Duty]', onDuty and 'You are now on duty.' or 'You are now off duty.'}
            })
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(60000)

        for _, playerId in ipairs(GetPlayers()) do
            local src = tonumber(playerId)
            local character = exports['kr-core']:GetPlayerData(src)

            if character and character.job and character.job ~= 'unemployed' then
                MySQL.Async.fetchScalar('SELECT on_duty FROM player_jobs WHERE character_id = @characterId', {
                    ['@characterId'] = character.id
                }, function(onDuty)
                    if onDuty == 1 then
                        local jobConfig = Config.Jobs[character.job]
                        local salary = jobConfig and jobConfig.grades[character.job_grade] and jobConfig.grades[character.job_grade].salary or 0

                        if salary > 0 then
                            MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount WHERE id = @id', {
                                ['@amount'] = salary,
                                ['@id'] = character.id
                            })

                            character.cash = character.cash + salary
                            TriggerClientEvent('kr-core:jobSalary', src, salary, character.job)
                        end
                    end
                end)
            end
        end
    end
end)

if Config.EnableUnemployment then
    CreateThread(function()
        while true do
            Wait(Config.UnemploymentInterval)

            for _, playerId in ipairs(GetPlayers()) do
                local src = tonumber(playerId)
                local character = exports['kr-core']:GetPlayerData(src)

                if character and character.job == 'unemployed' then
                    MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount WHERE id = @id', {
                        ['@amount'] = Config.UnemploymentAmount,
                        ['@id'] = character.id
                    })

                    character.cash = character.cash + Config.UnemploymentAmount
                    TriggerClientEvent('kr-core:unemploymentBenefit', src, Config.UnemploymentAmount)
                end
            end
        end
    end)
end
