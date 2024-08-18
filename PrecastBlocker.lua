PrecastBlocker = PrecastBlocker or {}
local r = PrecastBlocker
local EM = GetEventManager()
local SB = LibSkillBlocker
r.name = "PrecastBlocker"
r.version = "1.0.0"
r.variableVersion = 1

local TYPE_BACKLASH = 0 -- TEMPLAR BACKLASH                                                                
local TYPE_SCORCH = 1 -- WARDEN SHALKS                                                                     
local TYPE_DAEDRIC = 2 -- SORC PREY
r.defaults = {
    ["enabled"] = true,
    ["blockInPvP"] = true,
    ["abilities"] = {
        -- Templar Abilites                                                                                
        [TYPE_BACKLASH] = {
            types = {[21761] = {}, [21765] = {}, [21763] = {}},
            name = "Backlash",
            blocked = false
        },
        [TYPE_SCORCH] = {
            types = {[86009] = {}, [86019] = {}, [86015] = {}},
            name = "Shalks",
            blocked = false
        },
        [TYPE_DAEDRIC] = {
            types = {[24326] = {}, [24328] = {}, [24330] = {}},
            name = "Prey",
            blocked = false
        }
    }
}

r.divider = {
    [TYPE_BACKLASH] = true,
    [TYPE_SCORCH] = true,
    [TYPE_DAEDRIC] = true
}

local eprintln = function(str) if r.debug then d("[PB]" .. str) end end

r.abilities = r.defaults.abilities
r.invMapping = {}

for id, v in pairs(r.abilities) do
    for k, _ in pairs(v.types) do
        r.abilities[id].types[k].name = zo_strformat(SI_ABILITY_NAME,
                                                     GetAbilityName(k))
        r.abilities[id].types[k].tex = GetAbilityIcon(k)
        r.abilities[id].types[k].dura = GetAbilityDuration(k)
        r.invMapping[k] = id
    end
end
function r.cbevent(_, _, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _,
                   abilityId, _)
    eprintln("AbilityName: " .. abilityName .. "\nAbilityID: " .. abilityId)
    local type = r.invMapping[abilityId]
    if r.savedVars.abilities[type].blocked then
        SB.RegisterSkillBlock(r.name, abilityId)
        eprintln(abilityName .. " Blocked")
        zo_callLater(function()
            SB.UnregisterSkillBlock(r.name, abilityId)
            eprintln("Duration Ended")
        end, r.abilities[type].types[abilityId].dura)
    else
        eprintln(abilityName .. " Not Blocked")
    end
end

function r.init(_, addon)
    if addon ~= r.name then return end
    EM:UnregisterForEvent(r.name .. "onLoad", EVENT_ADD_ON_LOADED)
    r.savedVars = ZO_SavedVars:NewCharacterIdSettings(r.name .. "Vars",
                                                      r.variableVersion, r.name,
                                                      r.defaults, GetWorldName())
    r.buildMenu()
    for k, _ in pairs(r.invMapping) do
        local namespace = r.name .. "cbevent" .. k
        if not (r.savedVars.blockInPvP and
            (IsPlayerInAvAWorld() or IsActiveWorldBattleground())) then
            EM:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, r.cbevent)
            EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT,
                                 REGISTER_FILTER_ABILITY_ID, k,
                                 REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
                                 COMBAT_UNIT_TYPE_PLAYER, COMBAT_RESULT,
                                 ACTION_RESULT_EFFECT_GAINED_DURATION)
        end
    end
end

SLASH_COMMANDS["/pb.debug"] = function() r.debug = not r.debug end

EM:RegisterForEvent(r.name, EVENT_ADD_ON_LOADED, r.init)
