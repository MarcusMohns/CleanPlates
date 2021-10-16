
-------------------------------------------------------------------------------------
-- Default Theme
-------------------------------------------------------------------------------------

local config = {}
local path = "Interface\\Addons\\TidyPlates\\Artwork"

local adjust = -6 -- Adjust Cast Bar distance

config.healthborder = {
	texture		 =				path.."\\GreyerBorder",
	glowtexture =					path.."\\Highlight",
	elitetexture =					path.."\\GreyerElite",
	width = 128,
	height = 64,
	x = 0,
	y = 0,
	anchor = "CENTER",
}

config.threatborder = {
	texture =			path.."\\ThreatB",
	elitetexture =			path.."\\ThreatB",
	width = 128,
	height = 64,
	x = 0,
	y = 0,
	anchor = "CENTER",
}



config.castborder = {
	texture =					path.."\\Cast",
	width = 128,
	height = 64,
	x = 0,
	y = 0 +adjust,
	anchor = "CENTER",
}

config.castnostop = {
	texture = 				path.."\\NoCast",
	width = 128,
	height = 64,
	x = 0,
	y = 0+adjust,
	anchor = "CENTER",
}

config.name = {
	typeface =					path.."\\arial.ttf",
	size = 9,
	width = 75,
	height = 10,
	x = -13,
	y = 6,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
}

config.level = {
	typeface =					path.."\\arial.ttf",
	size = 9,
	width = 25,
	height = 10,
	x = 35,
	y = 6,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
}

config.healthbar = {
	texture =					 path.."\\Bar",
	height = 12,
	width = 101,
	x = 0,
	y = 15,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

config.castbar = {
	texture =					path.."\\Bar",
	height = 12,
	width = 99,
	x = 0,
	y = -8+adjust,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

config.specialText = {
	typeface =					path.."\\arial.ttf",
	size = 9,
	width = 93,
	height = 10,
	x = 0,
	y = 16,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
}

config.specialText2 = {
	typeface =					path.."\\arial.ttf",
	size = 8,
	width = 100,
	height = 10,
	x = 1,
	y = adjust-8,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
}

config.specialArt = {
	--[[
	width = 128,
	height = 64,
	x = 0,
	y = 0 +adjust,
	anchor = "CENTER",
	--]]
	-- [[
	width = 24,
	height = 24,
	x = -5,
	y = 15,
	anchor = "TOP",
	-- ]]
}

config.spellicon = {
	width = 24,
	height = 24,
	x = 65,
	y = -11+adjust,
	anchor = "CENTER",
}

config.raidicon = {
	width = 20,
	height = 20,
	x = -35,
	y = 12,
	anchor = "TOP",
}

config.dangerskull = {
	width = 18,
	height = 18,
	x = -17,
	y = 10,
	anchor = "TOP",
}

config.frame = {
	emptyTexture =					path.."\\Empty",
	width = 101,
	height = 45,
	x = 0,
	y = 0,
	anchor = "CENTER",
}

config.threatcolor = {
	LOW = { r = .75, g = 1, b = 0, a= 1, },
	MEDIUM = { r = 1, g = 1, b = 0, a = 1, },
	HIGH = { r = 1, g = 0, b = 0, a = 1, },
}

config.options = {
	showLevel = true,
	showName = true,
	showSpecialText = false,
	showSpecialText2 = false,
	showSpecialArt = false,
	showDangerSkull = false,
	showspellIcon = true,
	showNostopSpell = true,
	useOnUpdate = false,
	useCustomHealthbarColor = false,
}


TidyPlates.defaultTheme = config
TidyPlates:ActivateTheme(TidyPlates.defaultTheme)

-------------------------------------------------------------------------------------
--  Helpers
-------------------------------------------------------------------------------------

local function copytable(original)
	local duplicate = {}
	for key, value in pairs(original) do
		if type(value) == "table" then duplicate[key] = copytable(value)
		else duplicate[key] = value end
	end
	return duplicate
end

local function mergetable(master, mate)
	local merged = {}
	local matedata
	for key, value in pairs(master) do
		if type(value) == "table" then 
			matedata = mate[key]
			if type(matedata) == "table" then merged[key] = mergetable(value, matedata) 
			else merged[key] = copytable(value) end
		else 
			matedata = mate[key]
			if matedata == nil then merged[key] = master[key] 
			else merged[key] = matedata end
		end
	end
	return merged
end

function TidyPlates:CreateTheme() 
	local newtheme = copytable(TidyPlates.defaultTheme)
	return newtheme
end

function TidyPlates:CreateStyle() 
	local newstyle = copytable(TidyPlates.defaultTheme)
	return newstyle
end

-------------------------------------------------------------------------------------
-- Auto-Loader
-------------------------------------------------------------------------------------



local function LoadTheme(incomingtheme) 
	local theme, style, stylename
	local merged = {}
	if type(incomingtheme) == "table" then theme = incomingtheme
	elseif type(TidyPlatesThemeList) == "table" then _, theme = next(TidyPlatesThemeList) 
	else return end
	
	-- Compatibility Loader
	if theme.SetStyle and type(theme.SetStyle) == "function" then
		-- Load Multiplate
		for stylename, style in pairs(theme) do
			if type(style) == "function" then 
				merged[stylename] = style
			elseif type(style) == "table" then
				merged[stylename] = mergetable(TidyPlates.defaultTheme, style)					
			end
		end
		merged.multiStyle = true
	else 
		-- load Single Plate
		merged = mergetable(TidyPlates.defaultTheme, theme)	
		for stylename, style in pairs(theme) do
			if type(style) == "function" then merged[stylename] = style end
		end
	end
	
	if type(merged) == "table" then TidyPlates:ActivateTheme(merged) end
end
	
local PrivateHandler = CreateFrame("Frame")
PrivateHandler:SetScript("OnEvent", function(self, event)  LoadTheme() end)
PrivateHandler:RegisterEvent("PLAYER_ENTERING_WORLD")

TidyPlates.ActivateOldTheme = LoadTheme
------------------------------------------------------------------
-- Panel Helpers (Used to create interface panels)
------------------------------------------------------------------
PanelHelpers = {}

function PanelHelpers:CreatePanelFrame(reference, title)
	local panelframe = CreateFrame( "Frame", reference, UIParent);
	panelframe.name = title
	panelframe.Label = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panelframe.Label:SetPoint("TOPLEFT", panelframe, "TOPLEFT", 16, -16)
	panelframe.Label:SetHeight(15)
	panelframe.Label:SetWidth(350)
	panelframe.Label:SetJustifyH("LEFT")
	panelframe.Label:SetJustifyV("TOP")
	panelframe.Label:SetText(title.." Options")
	return panelframe
end

function PanelHelpers:CreateCheckButton(reference, parent, label)
	local checkbutton = CreateFrame( "CheckButton", reference, parent, "InterfaceOptionsCheckButtonTemplate" )
	_G[reference.."Text"]:SetText(label)
	return checkbutton
end

function PanelHelpers:CreateRadioButtons(reference, parent, numberOfButtons, defaultButton, spacing, list)
	local index
	local radioButtonSet = {}
	
	for index = 1, numberOfButtons do
		radioButtonSet[index] = CreateFrame( "CheckButton", reference..index, parent, "UIRadioButtonTemplate" )
		radioButtonSet[index].Label = _G[reference..index.."Text"]
		radioButtonSet[index].Label:SetText(list[index] or " ")
		radioButtonSet[index].Label:SetWidth(250)
		radioButtonSet[index].Label:SetJustifyH("LEFT")
		
		if index > 1 then 
			radioButtonSet[index]:SetPoint("TOP", radioButtonSet[index-1], "BOTTOM", 0, -(spacing or 10)) 
		end
		
		radioButtonSet[index]:SetScript("OnClick", function (self) 
			local button
			for button = 1, numberOfButtons do radioButtonSet[button]:SetChecked(false) end
			self:SetChecked(true)
		end)
	end
	
	radioButtonSet.GetChecked = function() 
		local index
		for index = 1, numberOfButtons do
			if radioButtonSet[index]:GetChecked() then return index end
		end
	end
	
	radioButtonSet.SetChecked = function(self, number) 
		local index
		for index = 1, numberOfButtons do radioButtonSet[index]:SetChecked(false) end
		radioButtonSet[number]:SetChecked(true)
	end
	
	
	radioButtonSet[defaultButton]:SetChecked(true)
	return radioButtonSet
end

function PanelHelpers:CreateSliderFrame(reference, parent)
	local slider = CreateFrame("Slider", reference, parent, 'OptionsSliderTemplate')
	slider:SetWidth(100)
	slider:SetHeight(15)
	--slider.tooltipText =
	slider.Label = _G[reference..'Text']
	slider.Low = _G[reference.."Low"]
	slider.High = _G[reference.."High"]
	slider:SetMinMaxValues(1, 10)
	slider:SetValueStep(1) 
	slider:SetOrientation("HORIZONTAL")
	return slider
end
		
function PanelHelpers:CreateDropdownFrame(reference, parent, menu, default)
	local dropdown = CreateFrame("Frame", reference, parent, "UIDropDownMenuTemplate" )
	local index, item
	dropdown.Label = _G[reference.."Text"]
	dropdown.Label:SetText(menu[default].text)
	dropdown.Value = default
	dropdown.initialize = function(self, level)
		if not level == 1 then return end
		for index, item in pairs(menu) do
			item.func = function(self) dropdown.Label:SetText(item.text); dropdown.Value = index  end
			UIDropDownMenu_AddButton(item, level)
		end end
	dropdown.SetValue = function (self, value) dropdown.Label:SetText(menu[value].text); dropdown.Value = value end
	return dropdown
end

------------------------------------------------------------------
-- Panel Helper Demo
------------------------------------------------------------------
--[[
-- Main Panel
local panel = PanelHelpers:CreatePanelFrame( "ExamplePanelRef", "Example Interface Panel Title" )
-- Check Button
panel.checkbutton = PanelHelpers:CreateCheckButton("ExampleCheckbutton", panel, "Optional Feature")

local radiolist = {"Small","Medium","Large", "Epic"}
panel.radiobuttons = PanelHelpers:CreateRadioButtons("ExampleRadioSet", panel, 4, 1, 10, radiolist)
panel.radiobuttons[1]:SetPoint("TOPLEFT", 16, -190)


panel.checkbutton:SetPoint("TOPLEFT", 16, -50)
-- Dropdown Menu
local dropmenu = { 
			{ text = "Turtle", notCheckable = 1 } ,
			{ text = "Dog", notCheckable = 1 } ,
			{ text = "Cheetah", notCheckable = 1 }
			}
panel.dropdown = PanelHelpers:CreateDropdownFrame("ExampleDropdown", panel, dropmenu, "Turtle")
panel.dropdown:SetPoint("TOPLEFT", 16, -90)
-- Slider
panel.slider = PanelHelpers:CreateSliderFrame("ExampleSlider", panel)
panel.slider:SetPoint("TOPLEFT", 16, -140)
panel.slider:SetValue(5)
-- Functions
panel.okay = function (self) 
	print( panel.checkbutton:GetChecked().." "..panel.dropdown.Label:GetText().." "..panel.slider:GetValue())
end;
-- Adds the panel to the interface window
InterfaceOptions_AddCategory(panel);
--]]