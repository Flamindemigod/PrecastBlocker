PrecastBlocker = PrecastBlocker or {}                                                                      
local r = PrecastBlocker                                                                                   
                                                                                                           
function r.buildMenu()                                                                                     
    local LAM = LibAddonMenu2 -- External                                                                  
    local ability = {                                                                                      
        {                                                                                                  
            type = "description",                                                                          
            text = "Blocks you from precasting certain skills before their duration ends\nMainly was built for a kekplar main who couldnt wait to POTL"                                                               
        }                                                                                                  
    }
for k, v in pairs(r.abilities) do                                                                      
        if r.divider[k] then ability[#ability + 1] = {type = "divider"} end                                
        ability[#ability + 1] = {                                                                          
            type = "description",                                                                          
            text = "",                                                                                     
            title = "|c00FFCC" .. string.upper(v.name) .. "|r"                                             
        }                                                                                                  
        for a_id, a_v in pairs(v.types) do                                                                 
            local type = k                                                                                 
            local tex = "|t24:24:" .. a_v.tex .. "|t  "                                                    
            ability[#ability + 1] = {
                type = "checkbox",
                name = tex .. a_v.name,
                getFunc = function()
                    return r.savedVars.abilities[k].blocked
                end,
                setFunc = function(val)
                    r.savedVars.abilities[k].blocked = val
                end,
                disabled = function()
                    return not r.savedVars.enabled
                end,
                default = r.defaults.abilities[type].blocked
            }
        end
    end

local panelData = {                                                    
        type = "panel",
        name = "Precast Blocker",
        displayName = "Precast Blocker",
        author = "|cFFA500FlaminDemigod|r",
        version = "" .. r.version,
        slashCommand = "/pb",
        registerForDefaults = true,
        registerForRefresh = true
    }
 LAM:RegisterAddonPanel(r.name .. "GeneralOptions", panelData)

    local generalOptions = {
        [1] = {type = "description", text = "Skill Precast Blocker"},
        [2] = {
            type = "submenu",
            name = "|c00ffffGeneral|r",
            controls = {
                {
                    type = "description",
                    text = "Settings related to global synergy toggling"
                }, {
                    type = "checkbox",
                    name = "Global Toggle",
                    getFunc = function()
                        return r.savedVars.enabled
                    end,
                    setFunc = function(var)
                        r.savedVars.enabled = var
                    end,
                    default = r.defaults["enabled"],
                    width = "half"
                }, {
 type = "checkbox",
                    name = "Disable in PvP",
                    getFunc = function()
                        return r.savedVars.blockInPvP 
                    end,
                    setFunc = function(var)
                        r.savedVars.blockInPvP = var
                    end,
                    default = r.defaults["blockInPvP"],
                    width = "half"
                }
            }
        },
        [3] = {type = "submenu", name = "|c00ffffSkills|r", controls = ability}
    }

    LAM:RegisterOptionControls(r.name .. "GeneralOptions", generalOptions)
end
