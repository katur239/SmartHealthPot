local addOnName, SHP = ...
local frame, events = CreateFrame("Frame"), {};
local HasConsumables

frame.defaults = {}
frame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...);
end);

local index = 1
local AllConsumableItems = { }
AllConsumableItems[index] = 5512 --Healthstone

index = index + 1
AllConsumableItems[index] = {}
AllConsumableItems[index][3] = 207023 --Dreamwalker's Healing Potion 3
AllConsumableItems[index][2] = 207022 --Dreamwalker's Healing Potion 2
AllConsumableItems[index][1] = 207021 --Dreamwalker's Healing Potion 1

index = index + 1
AllConsumableItems[index] = {}
AllConsumableItems[index][3] = 191371 --Potion of Withering Vitality 3
AllConsumableItems[index][2] = 191370 --Potion of Withering Vitality 2
AllConsumableItems[index][1] = 191369 --Potion of Withering Vitality 1

index = index + 1
AllConsumableItems[index] = {}
AllConsumableItems[index][3] = 191380 --Potion of Refreshing Healing 3
AllConsumableItems[index][2] = 191379 --Potion of Refreshing Healing 2
AllConsumableItems[index][1] = 191378 --Potion of Refreshing Healing 1

index = index + 1
AllConsumableItems[index] = 187802 --Cosmic Healing Potion

--171267, Spiritual Healing Potion
--180317, Soulful Healing Potion
--115498, Ashran Healing Tonic
--169451, Abyssal Healing Potion
--152615, Astral Healing Potion
--152494, Coastal Healing Potion
--127834, Ancient Healing Potion
--36569, Aged Health Potion
--109223, Healing Tonic
--76097, Master Healing Potion
--57191, Mythical Healing Potion
--33447, Runic Healing Potion
--22850, Super Rejuvenation Potion
--43569, Endless Healing Potion
--33092, Healing Potion Injector
--39671, Resurgent Healing Potion
--43531, Argent Healing Potion
--32947, Auchenai Healing Potion
--22829, Super Healing Potion
--13446, Major Healing Potion
--858, Lesser Healing Potion
--3928, Superior Healing Potion
--118, Minor Healing Potion
--1710, Greater Healing Potion
--929, Healing Potion

local macroName = "SmartHealthPot"

function events:ADDON_LOADED(...)
	--print("Event Triggered: ADDON_LOADED = "..select(1,...))
	if select(1,...) == addOnName then
		SHPDB = SHPDB or CopyTable(frame.defaults)
		frame.db = SHPDB
		--frame:InitializeOptions()
	end
end

function events:PLAYER_ENTERING_WORLD(...)
	--print("Event Triggered: PLAYER_ENTERING_WORLD")
	frame:GetConsumables()
end

function events:PLAYER_REGEN_ENABLED(...)
	--print("Event Triggered: PLAYER_REGEN_ENABLED")
	frame:GetConsumables()
end

function events:BAG_UPDATE(...)
	--print("Event Triggered: BAG_UPDATE")	
	frame:GetConsumables()
end

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("BAG_UPDATE");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

function frame:ReadyCheck()
	
end


function frame:GetConsumables()
    HasConsumables = {}
    for i = 1, #AllConsumableItems do
		if (HasConsumables[1] == 5512 and #HasConsumables >= 2) or (#HasConsumables >= 1 and HasConsumables[1] != 5512) then
			break
		end
        if type(AllConsumableItems[i]) == "table" and #AllConsumableItems[i] > 0 then
            -- Check if the outer index is a table (array)
			for j = #AllConsumableItems[i], 1, -1 do
				local count = GetItemCount(AllConsumableItems[i][j], false, false)
				if count > 0 then
					HasConsumables[#HasConsumables + 1] = AllConsumableItems[i][j]
					break
				end
			end
        elseif GetItemCount(AllConsumableItems[i], false, false) > 0 then
           HasConsumables[#HasConsumables + 1] = AllConsumableItems[i]
        end
    end
    self:UpdateMacro()
end

--function frame:GetConsumables()
--    HasConsumables = {}
--		
--	for i = 1, #AllConsumableItems do
--		if type(AllConsumableItems[i]) == "table" and #AllConsumableItems[i] > 0 then -- Check if the outer index is a table (array)
--			for j = #AllConsumableItems[i], 1, -1 do
--				local count = GetItemCount(AllConsumableItems[i][j], false, false)
--				if count > 0 then
--					HasConsumables[#HasConsumables + 1] = AllConsumableItems[i][j]
--					break
--				end
--			end
--		elseif GetItemCount(AllConsumableItems[i], false, false) > 0 then -- Check if the element itself is the targetValue
--			HasConsumables[#HasConsumables + 1] = AllConsumableItems[i]
--		end
--	end
--		
--	self:UpdateMacro()
--end

function frame:UpdateMacro()
	if InCombatLockdown() then return end
		
	local macroBody, macroIcon
	local consumableStrings = {}
		
	if next(HasConsumables) == nil then 
		macroBody = '/run print("|cff00c0ffSmartHealthPot|r: No consumables found!")'
		macroBody = macroBody..'\r/run UIErrorsFrame:AddMessage("No consumables found!", 1.0, 0.0, 0.0, 53, 5);'
		macroIcon = 3565717
	else
		macroBody = "#showtooltip\r/stopmacro [nocombat]"
		macroIcon = "INV_Misc_QuestionMark"

		for k, id in pairs(HasConsumables) do
			consumableStrings[#consumableStrings + 1] = "item:"..id
		end
		
		macroBody = macroBody.."\r/castsequence reset=combat " .. table.concat(consumableStrings, ", ")
	end
	
	if GetMacroInfo(macroName) ~=nil then
		EditMacro(macroName, nil, macroIcon, macroBody)
	else
		CreateMacro(macroName, macroIcon, macroBody)
	end
end