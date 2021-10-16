
TidyPlates = {}
local activetheme = {}
local numChildren = -1
local EMPTY_TEXTURE = "Interface\\Addons\\TidyPlates\\Artwork\\Empty"
local useOnUpdate, useAutohide = false, false
----------------------------------------------
local pairs = pairs
local select = select
----------------------------------------------
local regionPosition = { "threatGlow", "healthBorder", "castBorder", "castNostop", 
					"spellIcon", "highlightTexture", "nameText", "levelText",
					"dangerSkull", "raidIcon", "eliteIcon" }
----------------------------------------------
local listToClass = {}
local colorToClass = {}
local function pctToInt(number) return math.floor((100*number) + 0.5) end
for classname, color in pairs(RAID_CLASS_COLORS) do
	colorToClass["C"..pctToInt(color.r)+pctToInt(color.g)+pctToInt(color.b)] = classname
end
----------------------------------------------
local PlateHandler = CreateFrame("Frame")
----------------------------------------------
local function shouldDisplayThreat(unit)
	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" and IsThreatWarningEnabled() then return true 
	else return false end
end

local function threatByColor( object , name)
	local redCan, greenCan, blueCan, alphaCan = object:GetVertexColor()
	local shown
	if not object:IsShown() then return "LOW" end
	if greenCan > .7 then return "MEDIUM" end
	if redCan > .7 then return "HIGH" end
end

local function reactionByColor(object)																											
	local redCan, greenCan, blueCan, alphaCan = object:GetStatusBarColor()
	if redCan < .01 and blueCan < .01 and greenCan > .99 then return "FRIENDLY", "NPC" 
	elseif redCan < .01 and blueCan > .99 and greenCan < .01 then return "FRIENDLY", "PLAYER"
	elseif redCan > .99 and blueCan < .01 and greenCan > .99 then return "NEUTRAL", "NPC"
	else return "HOSTILE", "UNKNOWN" end
end

local function GetRegionReference(plate, ...)
	local index, region, position
	local select = select
	local regions = plate.extended.regions
	for index = 1, select( "#", ... ) do
		region = select( index, ... )
		position = regionPosition[index]
		if region and position then regions[regionPosition[index]] = region end
	end
end

local function IsFrameNameplate(frame)
	local region = frame:GetRegions()
	return region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" 
end

----------------------------------------------
local function SetFrameByStyle(frame, style, anchorTo)																						
	frame:ClearAllPoints()
	frame:SetWidth(style.width)
	frame:SetHeight(style.height)
	frame:SetPoint(style.anchor, anchorTo, style.anchor, style.x, style.y)
end

local function ApplyBarSettings(statBar, statbarStyle, extended)																			
		statBar:SetStatusBarTexture(statbarStyle.texture)
		SetFrameByStyle(statBar, statbarStyle, extended)
		statBar:SetOrientation(statbarStyle.orientation)
end

local function ApplyFontStyle(text, style) 																								
	text:SetFont(style.typeface, style.size, "NONE")
	text:SetJustifyH(style.align)
	text:SetJustifyV(style.vertical)
	text:SetDrawLayer("ARTWORK")
	text:SetShadowOffset(1, -1)
	if style.shadow then text:SetShadowColor(0,0,0,1)
	else text:SetShadowColor(0,0,0,0) end
end

local function ApplyTexture(region,texture) 
	if texture == region:GetTexture() then return end
	region:SetTexture(texture) 
	region:SetTexCoord(0,1,0,1) 
end

local function SetTextureRegion(region, texture, style, anchor) 
	ApplyTexture(region, texture)
	SetFrameByStyle(region, style, anchor)
end

local function SetFontstringRegion(region, style, anchor)
	ApplyFontStyle(region, style)
	SetFrameByStyle(region, style, anchor)
end
----------------------------------------------
local function UpdateStyle(plate)
	local index, region, content
	local extended = plate.extended
	local bars = extended.bars
	local regions = extended.regions 	
	local style = plate.extended.style
	local inArena = IsActiveBattlefieldArena();

		-- Alignment Frame
		SetFrameByStyle(extended, style.frame, plate)	
		-- Main overlay
		SetTextureRegion(regions.healthBorder, style.healthborder.texture, style.healthborder, extended)
		-- Mouseover glow
		ApplyTexture(regions.highlightTexture, style.healthborder.glowtexture)
		regions.highlightTexture:SetAllPoints(regions.healthBorder)
		-- Threat Glow
		SetTextureRegion(regions.threatIndicator, style.threatborder.texture, style.threatborder, extended)
		-- Cast Regular
		SetTextureRegion(regions.castBorder, style.castborder.texture, style.castborder, extended)
		regions.castBorder:SetDrawLayer("ARTWORK")
		-- Cast Unstoppable 
		if style.options.showNostopSpell then 
			SetTextureRegion(regions.castNostop, style.castnostop.texture, style.castnostop, extended)
		else SetTextureRegion(regions.castNostop, style.castborder.texture, style.castborder, extended) end
		regions.castNostop:SetDrawLayer("ARTWORK")
		-- Name Text
		if style.options.showName then regions.nameText:Show()
			if inArena then
				if (GetUnitName("arena1")) == regions.nameText:GetText() or (GetUnitName("arena1")) == regions.nameText:GetText().." (*)" then
						regions.nameText:SetText("1") end
				if (GetUnitName("arena2")) == regions.nameText:GetText() or (GetUnitName("arena2")) == regions.nameText:GetText().." (*)" then
						regions.nameText:SetText("2") end
				if (GetUnitName("arena3")) == regions.nameText:GetText() or (GetUnitName("arena3")) == regions.nameText:GetText().." (*)" then
						regions.nameText:SetText("3") end
				if (GetUnitName("arena4")) == regions.nameText:GetText() or (GetUnitName("arena4")) == regions.nameText:GetText().." (*)" then
						regions.nameText:SetText("4") end
				if (GetUnitName("arena5")) == regions.nameText:GetText() or (GetUnitName("arena5")) == regions.nameText:GetText().." (*)" then
						regions.nameText:SetText("5") end
			end	
		SetFontstringRegion(regions.nameText, style.name, extended)
		else regions.nameText:Hide() end
		-- Level Text
		if style.options.showLevel then regions.levelText:Show()
			SetFontstringRegion(regions.levelText, style.level, extended)
		else regions.levelText:Hide() end
		-- Special Text 1
		if style.options.showSpecialText then regions.specialText:Show()
			SetFontstringRegion(regions.specialText, style.specialText, extended)
		else regions.specialText:Hide() end
		-- Special Text 2
		if style.options.showSpecialText2 then regions.specialText2:Show()
			SetFontstringRegion(regions.specialText2, style.specialText2, extended)
		else regions.specialText2:Hide() end
		-- Special Art
		if style.options.showSpecialArt then regions.specialArt:Show()
			SetFrameByStyle(regions.specialArt, style.specialArt, extended)
		else regions.specialArt:Hide() end
		-- Raid Icon/Lucky Charms..
		SetFrameByStyle(regions.raidIcon, style.raidicon, extended)
		regions.raidIcon:SetDrawLayer("OVERLAY")
		-- Spellcast Icon
		SetFrameByStyle(regions.spellIcon, style.spellicon, extended)
		regions.spellIcon:SetDrawLayer("OVERLAY")
		if not style.options.showspellIcon then regions.spellIcon:SetAlpha(0) end
		-- Skull Icon
		if style.options.showDangerSkull then 
			SetFrameByStyle(regions.dangerSkull, style.dangerskull, extended)
			regions.dangerSkull:SetDrawLayer("OVERLAY")
		else regions.dangerSkull:SetAlpha(0) end
		-- Hide redundant items
		regions.threatGlow:SetTexture(EMPTY_TEXTURE )
		regions.eliteIcon:SetAlpha(0)
		bars.health:SetStatusBarTexture(EMPTY_TEXTURE )
		------------ Configure the Status Bars (Health and Cast)  ------------
		ApplyBarSettings(bars.displayhealth, style.healthbar, extended)  -- Replacement Healthbar
		ApplyBarSettings(bars.cast, style.castbar, extended)
end

local function UpdatePlateIndicators(plate)
	local scale
	local extended = plate.extended
	local unit = extended.unit
	local style = extended.style
	local color = extended.color
	local bars = extended.bars
	local regions = extended.regions 
	local threatregion = regions.threatIndicator
	local alpha = extended.alpha
	-- Elite
	if unit.isElite then 
		threatregion:SetTexture(style.threatborder.elitetexture)
		ApplyTexture(regions.healthBorder, style.healthborder.elitetexture)
	else threatregion:SetTexture(style.threatborder.texture) end
	-- Threat
	if shouldDisplayThreat(unit) then
		color = style.threatcolor[unit.threatSituation]
		threatregion:Show()
		threatregion:SetVertexColor(color.r, color.g, color.b, color.a)
		--threatregion:SetAlpha(alpha) 
	else threatregion:Hide() end
	-- Special-case Text
	if style.options.showSpecialText and activetheme.SetSpecialText then
		regions.specialText:SetText(activetheme.SetSpecialText(unit)) end
	if style.options.showSpecialText2 and activetheme.SetSpecialText2 then
		regions.specialText2:SetText(activetheme.SetSpecialText2(unit)) end
	-- Special Case Image
	if style.options.showSpecialArt and activetheme.SetSpecialArt then
		regions.specialArt:SetTexture(activetheme.SetSpecialArt(unit)) end
	-- Bar  -- Replacement Healthbar
	--if style.options.useCustomHealthbarColor and activetheme.SetHealthbarColor then
	--	bars.displayhealth:SetStatusBarColor(activetheme.SetHealthbarColor(unit))
	--else bars.displayhealth:SetStatusBarColor(bars.health:GetStatusBarColor()) end	
	bars.displayhealth:SetStatusBarColor(bars.health:GetStatusBarColor())
	bars.displayhealth:SetMinMaxValues(bars.health:GetMinMaxValues())
	bars.displayhealth:SetValue(bars.health:GetValue())
	-- Scale
	if activetheme.SetScale then
		scale = activetheme.SetScale(unit)
		extended:SetScale(scale)
		bars.displayhealth:SetScale(scale)
		bars.cast:SetScale(scale)
	end
	-- Alpha
	if type(activetheme.SetAlpha) == 'function' then
		alpha = activetheme.SetAlpha(unit)
		extended:SetAlpha(alpha)
		bars.displayhealth:SetAlpha(alpha)
		bars.cast:SetAlpha(alpha)
	end
end

local function UpdatePlate(statusbar, forceupdate)
	local _, stylename
	local plate = statusbar:GetParent()
	local extended = plate.extended
	local bars = extended.bars
	local regions = extended.regions 
	local unit = plate.extended.unit
	local alpha = 1
	--bars.health, bars.cast = plate:GetChildren()
	------------ Derived Properties  ------------
	unit.threatSituation = threatByColor(regions.threatGlow, regions.nameText:GetText())
	unit.reaction, unit.type = reactionByColor(bars.health)
	unit.isBoss = regions.dangerSkull:IsShown()
	unit.isDangerous = unit.isBoss
	unit.isElite = regions.eliteIcon:IsShown()
	unit.isMarked = regions.raidIcon:IsShown()
	unit.name = regions.nameText:GetText()
	unit.alpha = plate:GetAlpha()
	unit.level = regions.levelText:GetText()
	unit.health = bars.health:GetValue()
	unit.isMouseover = regions.highlightTexture:IsShown()
	unit.red, unit.green, unit.blue = bars.health:GetStatusBarColor()
	unit.isCasting = bars.cast:IsShown()
	_, unit.healthmax = bars.health:GetMinMaxValues()
	unit.class = colorToClass["C"..pctToInt(unit.red)+pctToInt(unit.green)+pctToInt(unit.blue)] or "UNKNOWN"
	------------ Get Current Plate Style ------------
	if activetheme.multiStyle then 
		stylename = activetheme.SetStyle(unit)
		plate.extended.style = activetheme[stylename]
	else plate.extended.style = activetheme end
	------------ Configure Graphical Elements ------------
	if forceupdate or extended.stylename ~= stylename then
		extended.stylename = stylename
		UpdateStyle(plate)
	end
	------------ Indicators  ------------
	UpdatePlateIndicators(plate)
	------------ Indicators  ------------
	if type(activetheme.OnUpdate) == 'function' then activetheme.OnUpdate(extended, unit) end
end

local function ApplyPlateExtension(plate)
	local health, cast, extended, regions
	plate.extended = CreateFrame("Frame", nil, plate)
	extended = plate.extended
	extended.style, extended.unit, extended.color, extended.regions, extended.bars = {}, {}, {}, {}, {}
	extended.bars.health, extended.bars.cast = plate:GetChildren()
	health, cast = extended.bars.health, extended.bars.cast 
	regions = extended.regions
	GetRegionReference(plate, plate:GetRegions())
	-- Add custom frame elements
	extended.stylename = ""
	extended.alpha = 1
	for index, region in pairs(regions) do region:SetParent(extended) end
	plate.extended:EnableDrawLayer( "HIGHLIGHT" );
	extended.bars.displayhealth = CreateFrame("StatusBar", nil, plate)	-- Replacement Healthbar
	extended.bars.displayhealth:SetFrameLevel(health:GetFrameLevel())	-- Replacement Healthbar
	regions.threatIndicator = extended:CreateTexture(nil, "ARTWORK")
	regions.specialArt = extended:CreateTexture(nil, "OVERLAY")
	regions.specialText = extended:CreateFontString(nil, "OVERLAY")
	regions.specialText2 = extended:CreateFontString(nil, "OVERLAY")
	-- For adding additionl plate subobjects  ******New
	if type(activetheme.OnInitialize) == 'function' then activetheme.OnInitialize(extended) end
	-- Update Immediately
	UpdatePlate(health, true)
	-- Hook for Updates
	if useOnUpdate then
		health:HookScript("OnShow", function (self)  UpdatePlate(self, true)  end) 
		health:HookScript("OnUpdate", function (self) UpdatePlate(self, false) end) 
	else
		health:HookScript("OnValueChanged", function (self) UpdatePlate(self, false) end) 
		health:HookScript("OnShow", function (self)  UpdatePlate(self, true) end) 
		health:HookScript("OnEvent", function (self, event) UpdatePlate(self, false)  end)
		health:RegisterEvent("PLAYER_REGEN_DISABLED")
		health:RegisterEvent("RAID_TARGET_UPDATE")
		health:RegisterEvent("PLAYER_REGEN_ENABLED")
		health:RegisterEvent("PLAYER_TARGET_CHANGED")
		health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
		health:RegisterEvent("UNIT_LEVEL")
	end
	-- Hook for Castbar
	cast:HookScript("OnShow", function (self) UpdatePlate(self, true) end) 
	cast:HookScript("OnValueChanged", function (self) UpdatePlate(self, true) end) 
	cast:HookScript("OnHide", function (self) UpdatePlate(self, false) end) 
end
----------------------------------------------
local function OnCreateChildFrames(...)
	for i=1, select("#", ...) do 
		local plate = select(i, ...)
		if IsFrameNameplate(plate) then
			if not plate.extended then ApplyPlateExtension(plate) end
		end end
end

local function OnUpdate(self)
	local curChildren = WorldFrame:GetNumChildren()
	if (curChildren ~= numChildren) then
		numChildren = curChildren
		OnCreateChildFrames(WorldFrame:GetChildren()) 
	end	
end

local function UpdateAll(...)
	for i=1, select("#", ...) do 
		local plate = select(i, ...)
		if type(plate.extended) == 'table' then UpdatePlate(plate, true) end
	end
end

----------------------------------------------
local events = {}
local PlateHandler = CreateFrame("Frame")
PlateHandler:SetScript("OnEvent", function(self, event, ...) events[event]() end)
function events:PLAYER_ENTERING_WORLD() PlateHandler:SetScript("OnUpdate", OnUpdate) end
for eventname in pairs(events) do PlateHandler:RegisterEvent(eventname) end
----------------------------------------------
function TidyPlates:ActivateTheme(theme) if theme and type(theme) == 'table' then activetheme = theme; end end
function TidyPlates:UseOnUpdate(self, option) useOnUpdate = option; end
function TidyPlates:ForceUpdate() UpdateAll(WorldFrame:GetChildren()) end





