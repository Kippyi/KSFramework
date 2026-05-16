Config = {}

Config.FrameworkName = 'KSFramework'
Config.FrameworkVersion = '1.1.0'

Config.Economy = {
    StartingMoney = 1000,
    StartingBank = 500,
    PaycheckInterval = 600000,
    PaycheckAmount = 100,
    TaxRate = 0.10,
}

Config.Database = {
    Users = 'users',
    PlayerCharacters = 'player_characters',
    PlayerJobs = 'player_jobs',
    Items = 'items',
    Properties = 'properties',
    SocietyAccounts = 'society_accounts',
    BankTransactions = 'bank_transactions',
}

Config.Jobs = {
    unemployed = {
        label = 'Unemployed',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Freelancer', salary = 0 }
        }
    },
    police = {
        label = 'Police Department',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Recruit', salary = 50 },
            [1] = { name = 'Officer', salary = 65 },
            [2] = { name = 'Sergeant', salary = 80 },
            [3] = { name = 'Lieutenant', salary = 100 },
            [4] = { name = 'Captain', salary = 120 },
            [5] = { name = 'Chief', salary = 150 }
        }
    },
    ambulance = {
        label = 'EMS',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Trainee', salary = 45 },
            [1] = { name = 'Paramedic', salary = 55 },
            [2] = { name = 'EMT', salary = 70 },
            [3] = { name = 'Doctor', salary = 90 },
            [4] = { name = 'Surgeon', salary = 110 },
            [5] = { name = 'Chief of Medicine', salary = 140 }
        }
    },
    mechanic = {
        label = 'Mechanic',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Apprentice', salary = 40 },
            [1] = { name = 'Mechanic', salary = 55 },
            [2] = { name = 'Senior Mechanic', salary = 70 },
            [3] = { name = 'Master Mechanic', salary = 85 },
            [4] = { name = 'Shop Manager', salary = 100 },
            [5] = { name = 'Owner', salary = 130 }
        }
    },
    taxi = {
        label = 'Taxi Driver',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Driver', salary = 35 },
            [1] = { name = 'Senior Driver', salary = 45 },
            [2] = { name = 'Fleet Driver', salary = 55 },
            [3] = { name = 'Dispatcher', salary = 70 },
            [4] = { name = 'Manager', salary = 85 },
            [5] = { name = 'Owner', salary = 110 }
        }
    },
    reporter = {
        label = 'Reporter',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Intern', salary = 30 },
            [1] = { name = 'Reporter', salary = 45 },
            [2] = { name = 'Senior Reporter', salary = 60 },
            [3] = { name = 'Editor', salary = 75 },
            [4] = { name = 'Director', salary = 95 },
            [5] = { name = 'Owner', salary = 120 }
        }
    },
    realtor = {
        label = 'Real Estate Agent',
        defaultGrade = 0,
        grades = {
            [0] = { name = 'Junior Agent', salary = 35 },
            [1] = { name = 'Agent', salary = 50 },
            [2] = { name = 'Senior Agent', salary = 65 },
            [3] = { name = 'Broker', salary = 85 },
            [4] = { name = 'Senior Broker', salary = 105 },
            [5] = { name = 'Agency Owner', salary = 135 }
        }
    }
}

Config.MaxJobsPerPlayer = 2
Config.EnableUnemployment = true
Config.UnemploymentAmount = 50
Config.UnemploymentInterval = 1800000

Config.Inventory = {
    MaxWeight = 120,
    MaxSlots = 40,
    EnableCrafting = true,
    EnableStash = true
}

Config.Housing = {
    EnableRentals = true,
    EnableMortgages = true,
    DefaultRentPrice = 200,
    DefaultMortgageRate = 0.05,
    RentCollectionInterval = 86400000
}

Config.Banking = {
    EnableLoans = true,
    EnableInterest = true,
    InterestRate = 0.005,
    LoanInterestRate = 0.02,
    MaxLoanAmount = 50000,
    TransferFee = 0.01
}

Config.Commands = {
    EnableAdminCommands = true,
    EnableMoneyCommands = true,
    EnableJobCommands = true,
    EnableHousingCommands = true,
    EnableBankingCommands = true
}

Config.DefaultSpawn = vector3(-540.0, -212.0, 37.0)
Config.AutoSaveInterval = 300000

return Config
