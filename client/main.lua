local heistState, activeRun, testMode, teamLeader = nil, false, false, false
local publicHeists = {}
local currentObjective = 1
local objectiveBlip = nil

local function notify(message) BeginTextCommandThefeedPost('STRING'); AddTextComponentSubstringPlayerName(message); EndTextCommandThefeedPostTicker(false, false) end
local function drawText3d(coords, text) SetDrawOrigin(coords.x, coords.y, coords.z, 0); SetTextScale(0.32, 0.32); SetTextFont(4); SetTextCentre(true); SetTextColour(255,255,255,230); BeginTextCommandDisplayText('STRING'); AddTextComponentSubstringPlayerName(text); EndTextCommandDisplayText(0.0,0.0); ClearDrawOrigin() end
local function closeCreator() SetNuiFocus(false, false); SendNUIMessage({ action = 'close' }) end

local function clearObjectiveBlip()
    if objectiveBlip then
        SetBlipRoute(objectiveBlip, false)
        RemoveBlip(objectiveBlip)
        objectiveBlip = nil
    end
    SetGpsMultiRouteRender(false)
end

local function updateObjectiveBlip()
    clearObjectiveBlip()
    if not heistState or not activeRun or currentObjective > #heistState.objectives then return end
    local objective = heistState.objectives[currentObjective]
    local position = objective.position
    local settings = Config.ObjectiveBlip or {}
    objectiveBlip = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(objectiveBlip, settings.sprite or 1)
    SetBlipColour(objectiveBlip, settings.color or 5)
    SetBlipScale(objectiveBlip, settings.scale or 0.85)
    SetBlipAsShortRange(objectiveBlip, settings.shortRange == true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('Objective %s: %s'):format(currentObjective, objective.label))
    EndTextCommandSetBlipName(objectiveBlip)
    if settings.route ~= false then
        SetBlipRouteColour(objectiveBlip, settings.routeColor or settings.color or 5)
        SetBlipRoute(objectiveBlip, true)
    end
end

local function stopRun()
    clearObjectiveBlip()
    heistState=nil; activeRun=false; testMode=false; teamLeader=false; currentObjective=1
end
RegisterNetEvent('heistcreator:client:open', function(heists) SetNuiFocus(true,true); SendNUIMessage({action='open',heists=heists}) end)
RegisterNetEvent('heistcreator:client:sync', function(heists) SendNUIMessage({action='sync',heists=heists}) end)
RegisterNetEvent('heistcreator:client:publicSync', function(heists) publicHeists=heists or {} end)
RegisterNetEvent('heistcreator:client:notify', function(message) notify(message) end)
RegisterNetEvent('heistcreator:client:invite', function(name,leader) notify(('Invitation to %s from player %s. Use /heistaccept or /heistdecline within 30 seconds.'):format(name,leader)) end)
RegisterNetEvent('heistcreator:client:test', function(heist) closeCreator(); heistState=heist; activeRun=true; testMode=true; teamLeader=true; currentObjective=1; updateObjectiveBlip(); notify('Test mode started. Rewards are disabled.') end)
RegisterNetEvent('heistcreator:client:run', function(heist,isLeader,nextObjective,isTest) heistState=heist; activeRun=true; testMode=isTest == true; teamLeader=isLeader == true; currentObjective=tonumber(nextObjective) or 1; updateObjectiveBlip(); notify(teamLeader and ('Team heist started: %s. Invite players with /heistinvite [id].'):format(heist.name) or ('Joined team heist: %s'):format(heist.name)) end)
RegisterNetEvent('heistcreator:client:objectiveAccepted', function(index) if index == currentObjective and heistState and heistState.objectives[index] then currentObjective=currentObjective+1; updateObjectiveBlip(); notify(('Objective complete: %s'):format(heistState.objectives[index].label)) end end)
RegisterNetEvent('heistcreator:client:teamEnded', function(message) notify(message); stopRun() end)
RegisterCommand('heistinvite', function(_,args) if activeRun and teamLeader and args[1] then TriggerServerEvent('heistcreator:server:invite',args[1]) else notify('Only the team leader can invite a player during a heist.') end end, false)
RegisterCommand('heistaccept', function() TriggerServerEvent('heistcreator:server:respondInvite',true) end, false)
RegisterCommand('heistdecline', function() TriggerServerEvent('heistcreator:server:respondInvite',false) end, false)
RegisterCommand('heistleave', function() if activeRun then TriggerServerEvent('heistcreator:server:leave'); stopRun() end end, false)
RegisterNUICallback('close', function(_,cb) closeCreator(); cb({ok=true}) end)
RegisterNUICallback('save', function(data,cb) TriggerServerEvent('heistcreator:server:save',data); cb({ok=true}) end)
RegisterNUICallback('delete', function(data,cb) TriggerServerEvent('heistcreator:server:delete',data.id); cb({ok=true}) end)
RegisterNUICallback('test', function(data,cb) TriggerServerEvent('heistcreator:server:test',data.id); cb({ok=true}) end)
RegisterNUICallback('getPosition', function(_,cb) local c=GetEntityCoords(PlayerPedId()); cb({x=math.floor(c.x*100)/100,y=math.floor(c.y*100)/100,z=math.floor(c.z*100)/100}) end)
CreateThread(function()
    TriggerServerEvent('heistcreator:server:requestHeists')
    while true do
        local wait=1000
        if heistState and activeRun then
            wait=0; local coords=GetEntityCoords(PlayerPedId())
            if currentObjective <= #heistState.objectives then
                local o=heistState.objectives[currentObjective]; local target=vector3(o.position.x,o.position.y,o.position.z); local distance=#(coords-target)
                DrawMarker(2,target.x,target.y,target.z+0.25,0.0,0.0,0.0,0.0,180.0,0.0,0.35,0.35,0.35,220,180,40,180,false,true,2,false,nil,nil,false)
                if distance < Config.InteractionDistance then drawText3d(target+vector3(0,0,0.65),('[E] %s'):format(o.label)); if IsControlJustReleased(0,38) then TriggerServerEvent('heistcreator:server:objective',heistState.id,currentObjective) end end
            elseif teamLeader and not testMode then
                local e=vector3(heistState.entry.x,heistState.entry.y,heistState.entry.z); DrawMarker(1,e.x,e.y,e.z-1.0,0,0,0,0,0,0,1.4,1.4,0.5,70,190,120,170,false,false,2,false,nil,nil,false)
                if #(coords-e)<Config.EntryDistance then drawText3d(e+vector3(0,0,0.8),'[E] Finish team heist'); if IsControlJustReleased(0,38) then TriggerServerEvent('heistcreator:server:complete',heistState.id); stopRun() end end
            elseif not teamLeader then
                notify('All objectives complete. Wait for the team leader to finish.')
                Wait(3000)
            end
        elseif not IsPauseMenuActive() then
            local coords=GetEntityCoords(PlayerPedId())
            for _, heist in ipairs(publicHeists) do
                local e=vector3(heist.entry.x,heist.entry.y,heist.entry.z); local distance=#(coords-e)
                if distance < 25.0 then
                    wait=0; DrawMarker(1,e.x,e.y,e.z-1.0,0,0,0,0,0,0,1.2,1.2,0.4,70,120,220,150,false,false,2,false,nil,nil,false)
                    if distance < Config.EntryDistance then drawText3d(e+vector3(0,0,0.75),('[E] Start %s'):format(heist.name)); if IsControlJustReleased(0,38) then TriggerServerEvent('heistcreator:server:start',heist.id) end end
                end
            end
        end
        Wait(wait)
    end
end)
CreateThread(function() while true do Wait(0); if IsControlJustReleased(0,167) and not IsPauseMenuActive() then TriggerServerEvent('heistcreator:server:open') end end end)
AddEventHandler('onResourceStop',function(resource) if resource==GetCurrentResourceName() then clearObjectiveBlip(); SetNuiFocus(false,false) end end)
