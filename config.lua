Config = {}

Config.AdminPermissions = { 'god', 'admin' }
Config.AdminAce = 'heistcreator.admin'
Config.DataFile = 'heists.json'
Config.MaxHeists = 100
Config.MaxObjectives = 20
Config.MaxRewards = 10
Config.MaxParticipants = 8
Config.InviteDistance = 25.0
Config.InteractionDistance = 3.0
Config.EntryDistance = 4.0
Config.MinCooldown = 0
Config.MaxCooldown = 604800
Config.MaxRewardCash = 1000000
Config.MaxRewardAmount = 1000
Config.Debug = false

Config.ObjectiveBlip = {
    sprite = 1,
    color = 5,
    scale = 0.85,
    shortRange = false,
    route = true,
    routeColor = 5
}

Config.DefaultHeist = {
    name = 'New Heist',
    description = 'Plan and execute the operation.',
    cooldown = 3600,
    minCops = 0,
    entry = { x = 0.0, y = 0.0, z = 0.0 },
    objectives = {},
    rewards = {}
}
