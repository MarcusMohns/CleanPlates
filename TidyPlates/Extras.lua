
SetCVar("threatWarning", 3)
SetCVar("nameplateShowEnemies", 1)
SetCVar("ShowClassColorInNameplate", 1)
SetCVar("CameraDistanceMaxFactor", 6)

local TANK_MODE, DPS_MODE, PVP_MODE = 2, 3, 4
local HEALTH_PCT, HEALTH_TOTAL, HEALTH_DEF = 3, 3, 4

if not TidyPlatesVariables then TidyPlatesVariables = {} end
TidyPlatesVariables = {Mode = 1, HealthText = 1, AutoHide = false}

local function valueToString(value)
	if value >= 1000000 then return format('%.1fm', value / 1000000)
	elseif value >= 1000 then return format('%.1fk', value / 1000)
	else return value end
end

local function SpellTextDelegate(unit)
	local spellname
	if unit.isCasting then 
		spellname = UnitCastingInfo("target") or UnitChannelInfo("target")
		return spellname
	else return "" end
end

local function HealthTextDelegate(unit)
	if TidyPlatesVariables.HealthText == HEALTH_PCT then
		if unit.health ~= unit.healthmax then 
			return "%"..ceil(100*(unit.health/unit.healthmax))
		else return nil end
	elseif TidyPlatesVariables.HealthText == HEALTH_TOTAL then
		return valueToString(unit.health)
	elseif TidyPlatesVariables.HealthText == HEALTH_DEF then
		if unit.health ~= unit.healthmax then return "-"..valueToString(unit.healthmax - unit.health) end
	else return "" end
end

local function ArtDelegate(unit)
	if TidyPlatesVariables.Mode == 4 then
		if unit.class and (unit.class ~= "UNKNOWN") then 
			return "Interface\\Addons\\TidyPlates\\Artwork\\Class\\"..unit.class  
		end
	else return nil end
end		

local function ScaleDelegate(unit)
	if unit.isCasting then return 1 end
	
	if InCombatLockdown() then
		-- Set Scale for Tank Mode
		if TidyPlatesVariables.Mode == TANK_MODE and unit.reaction == "HOSTILE" and InCombatLockdown() then
			if unit.threatSituation == "LOW" then return 1.2 
			elseif unit.threatSituation == "HIGH" then return 0.8 end
		elseif TidyPlatesVariables.Mode == DPS_MODE then
			if unit.threatSituation == "LOW" then return .8 
			elseif unit.threatSituation == "HIGH" then return 1.2 end
		end
	end
	-- Set Scale for Non-Elites, in Combat
	if (TidyPlatesVariables.Mode ~= 1) and (not unit.isElite) then 
		return 0.8 
	else return 1 end
end

local function AlphaDelegate(unit)
	--if not InCombatLockdown() then return 0 end
	if unit.isCasting or unit.isMarked then return 1 end
	
	-- Mode Filters
	if TidyPlatesVariables.Mode == TANK_MODE then
		if unit.threatSituation == "HIGH" then return 0.4 end
	elseif TidyPlatesVariables.Mode == DPS_MODE then
		if unit.threatSituation == "LOW" then return 0.4 end
	else return 1 end
	
	-- Basic Filters
	if unit.reaction == "NEUTRAL" and unit.threatSituation == "LOW" then return 0  else return 1 end
end

local path = "Interface\\Addons\\TidyPlates\\Artwork"
local themedata = {
	options = {
		showSpecialText = true,
		showSpecialText2 = true,
		showSpecialArt = true,
	},
	SetSpecialText = HealthTextDelegate,
	SetSpecialText2 = SpellTextDelegate,
	SetSpecialArt = ArtDelegate,
	SetScale = ScaleDelegate,
	SetAlpha = AlphaDelegate,
}

TidyPlates.ActivateOldTheme(themedata)

------------------------------------------------------------------
-- Panel
------------------------------------------------------------------

--[[ 
To Do: 
	* Autohide/show on combat
	* Iconlist
		- Acidmaw/Dreadscale
		- "Watch your step"
		- Healer, Melee, Ranged
	* Check Class Colors for Icons
	* Fade creatures with less than 30% of your health
	* Fade creatures with less than 10% of you health
	* Fade creatures 20 levels or more below you
	* If threat is high, then fade non-elites
--]]

-- Main Panel
local panel = PanelHelpers:CreatePanelFrame( "TidyPlatesInterfaceOptions", "Tidy Plates: Default Theme" )

---- MODE 
panel.radiobuttonlabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
panel.radiobuttonlabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 35, -65)
panel.radiobuttonlabel:SetText("Display Mode:")
-- Radio Buttons
local radiolist = {"Default: |cFFFFFFFF No Scaling or extra art.",
		"Tank: |cFFFFFFFF Reduces visibility of units that are attacking you, preventing information overload. ",
		"Damage: |cFFFFFFFF Increases visibility of units that are attacking you.", 
		"PVP: |cFFFFFFFF  Shows enemy class icon on the nameplate. "}
		
panel.radiobuttons = PanelHelpers:CreateRadioButtons("TidyPlatesDefault_ModeRadio", panel, 4, 1, 20, radiolist)
panel.radiobuttons[1]:SetPoint("TOPLEFT", panel.radiobuttonlabel, 0, -17)

---- HEALTH TEXT
panel.dropdownmenulabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
panel.dropdownmenulabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 35, -225)
panel.dropdownmenulabel:SetText("Health Text:")
-- Dropdown Menu

local dropmenu = { 
				{ text = "None", notCheckable = 1 },
				{ text = "Percent", notCheckable = 1 } ,
				{ text = "Total Health", notCheckable = 1 } ,
				{ text = "Health Deficit", notCheckable = 1 },
			}
panel.dropdown = PanelHelpers:CreateDropdownFrame("TidyPlatesDefault_HealthTextDropdown", panel, dropmenu, 1)
panel.dropdown:SetPoint("TOPLEFT", panel.dropdownmenulabel, 0, -17)
panel.dropdown:SetValue(2)

-- Functions
panel.okay = function () 
	TidyPlatesVariables.Mode = panel.radiobuttons:GetChecked()
	TidyPlatesVariables.HealthText = panel.dropdown.Value
	TidyPlates:ForceUpdate()
end

panel.refresh = function ()
	panel.radiobuttons:SetChecked(TidyPlatesVariables.Mode)
	panel.dropdown:SetValue(TidyPlatesVariables.HealthText)
end

-- Adds the panel to the interface window
InterfaceOptions_AddCategory(panel);










