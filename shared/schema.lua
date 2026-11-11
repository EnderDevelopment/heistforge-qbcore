HeistSchema = {}

local function number(value, fallback)
    value = tonumber(value)
    if not value then return fallback end
    return value
end

function HeistSchema.cleanPosition(position)
    if type(position) ~= 'table' then return nil end
    local x, y, z = number(position.x), number(position.y), number(position.z)
    if not x or not y or not z then return nil end
    if math.abs(x) > 10000 or math.abs(y) > 10000 or math.abs(z) > 2000 then return nil end
    return { x = x, y = y, z = z }
end

function HeistSchema.validate(input, existingId)
    if type(input) ~= 'table' then return false, 'Invalid heist payload.' end
    local name = tostring(input.name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if #name < 3 or #name > 64 then return false, 'Name must be between 3 and 64 characters.' end
    local description = tostring(input.description or '')
    if #description > 500 then return false, 'Description is too long.' end
    local entry = HeistSchema.cleanPosition(input.entry)
    if not entry then return false, 'A valid entry position is required.' end

    local cooldown = math.floor(number(input.cooldown, 0))
    if cooldown < Config.MinCooldown or cooldown > Config.MaxCooldown then return false, 'Cooldown is outside the allowed range.' end
    local minCops = math.floor(number(input.minCops, 0))
    if minCops < 0 or minCops > 100 then return false, 'Invalid minimum police count.' end
    local maxParticipants = math.floor(number(input.maxParticipants, 1))
    if maxParticipants < 1 or maxParticipants > Config.MaxParticipants then return false, 'Invalid maximum participant count.' end

    local objectives = input.objectives or {}
    if type(objectives) ~= 'table' or #objectives > Config.MaxObjectives then return false, 'Too many objectives.' end
    local cleanObjectives = {}
    for index, objective in ipairs(objectives) do
        if type(objective) ~= 'table' then return false, ('Invalid objective %s.'):format(index) end
        local position = HeistSchema.cleanPosition(objective.position)
        local label = tostring(objective.label or '')
        if not position or #label < 2 or #label > 80 then return false, ('Invalid objective %s.'):format(index) end
        local kind = tostring(objective.kind or 'interaction')
        if not ({ interaction = true, hack = true, loot = true, escape = true })[kind] then kind = 'interaction' end
        cleanObjectives[#cleanObjectives + 1] = { label = label, kind = kind, position = position }
    end

    local rewards = input.rewards or {}
    if type(rewards) ~= 'table' or #rewards > Config.MaxRewards then return false, 'Too many rewards.' end
    local cleanRewards = {}
    for index, reward in ipairs(rewards) do
        if type(reward) ~= 'table' then return false, ('Invalid reward %s.'):format(index) end
        local rewardType = tostring(reward.type or 'cash')
        local amount = math.floor(number(reward.amount, 0))
        if rewardType ~= 'cash' and rewardType ~= 'bank' and rewardType ~= 'item' then return false, 'Invalid reward type.' end
        local maxAmount = (rewardType == 'cash' or rewardType == 'bank') and Config.MaxRewardCash or Config.MaxRewardAmount
        if amount < 1 or amount > maxAmount then return false, 'Reward amount is outside the allowed range.' end
        local item = tostring(reward.item or '')
        if rewardType == 'item' and not item:match('^[%w_%-]+$') then return false, 'Invalid reward item.' end
        cleanRewards[#cleanRewards + 1] = { type = rewardType, amount = amount, item = rewardType == 'item' and item or nil }
    end

    return true, {
        id = existingId,
        name = name,
        description = description,
        cooldown = cooldown,
        minCops = minCops,
        maxParticipants = maxParticipants,
        entry = entry,
        objectives = cleanObjectives,
        rewards = cleanRewards
    }
end
