-- Options.lua (with scrollable panel)
FastVigorBar = FastVigorBar or {}
local L = FastVigorBar.L
local Themes = FastVigorBar.Themes
local UI = FastVigorBar.UI

local function clamp(x,a,b) if x<a then return a elseif x>b then return b else return x end end

local function MakeCheckbox(parent, text, tooltip, get, set)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb.Text:SetText(text)
	cb:SetScript("OnShow", function() cb:SetChecked(get() and true or false) end)
	cb:SetScript("OnClick", function() set(cb:GetChecked() and true or false) end)

	if tooltip then
		cb:HookScript("OnEnter", function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
			GameTooltip:SetText(text,1,1,1,true)
			GameTooltip:AddLine(tooltip,0.9,0.9,0.9,true)
			GameTooltip:Show()
		end)
		cb:HookScript("OnLeave", function() GameTooltip:Hide() end)
	end

	return cb
end

-- FIXED slider: no reliance on global name
local function MakeSlider(parent, text, tooltip, minV, maxV, step, get, set)
	local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	s:SetMinMaxValues(minV, maxV)
	s:SetValueStep(step)
	s:SetObeyStepOnDrag(true)

	if s.Text then s.Text:SetText(text) end
	if s.Low then s.Low:SetText(tostring(minV)) end
	if s.High then s.High:SetText(tostring(maxV)) end

	local name = s:GetName()
	if name then
		local t = _G[name .. "Text"]
		local l = _G[name .. "Low"]
		local h = _G[name .. "High"]
		if t then t:SetText(text) end
		if l then l:SetText(tostring(minV)) end
		if h then h:SetText(tostring(maxV)) end
	end

	s:SetScript("OnShow", function()
		local v = get()
		if v == nil then v = minV end
		s:SetValue(v)
	end)

	s:SetScript("OnValueChanged", function(_, value)
		set(value)
	end)

	if tooltip then
		s:HookScript("OnEnter", function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
			GameTooltip:SetText(text,1,1,1,true)
			GameTooltip:AddLine(tooltip,0.9,0.9,0.9,true)
			GameTooltip:Show()
		end)
		s:HookScript("OnLeave", function() GameTooltip:Hide() end)
	end

	return s
end

local function MakeDropdown(parent, text, tooltip, items, get, set)
	local dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetText(text)
	label:SetPoint("BOTTOMLEFT", dd, "TOPLEFT", 20, 4)

	local function OnSelect(value)
		UIDropDownMenu_SetSelectedValue(dd, value)
		set(value)
	end

	UIDropDownMenu_Initialize(dd, function(self, level)
		for _, it in ipairs(items) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = it.text
			info.value = it.value
			info.func = function() OnSelect(it.value) end
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	dd:SetScript("OnShow", function()
		UIDropDownMenu_SetWidth(dd, 190)
		UIDropDownMenu_SetSelectedValue(dd, get())
	end)

	if tooltip then
		dd:HookScript("OnEnter", function()
			GameTooltip:SetOwner(dd,"ANCHOR_RIGHT")
			GameTooltip:SetText(text,1,1,1,true)
			GameTooltip:AddLine(tooltip,0.9,0.9,0.9,true)
			GameTooltip:Show()
		end)
		dd:HookScript("OnLeave", function() GameTooltip:Hide() end)
	end

	return dd
end

local function MakeButton(parent, text, onClick)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetText(text)
	b:SetHeight(22)
	b:SetScript("OnClick", onClick)
	return b
end

-- TWW compatible color picker helpers
local function Picker_SetColorRGB(r,g,b)
	if ColorPickerFrame and ColorPickerFrame.SetColorRGB then
		ColorPickerFrame:SetColorRGB(r,g,b)
		return true
	end
	if ColorPickerFrame and ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker
		and ColorPickerFrame.Content.ColorPicker.SetColorRGB then
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(r,g,b)
		return true
	end
	return false
end

local function Picker_GetColorRGB()
	if ColorPickerFrame and ColorPickerFrame.GetColorRGB then
		return ColorPickerFrame:GetColorRGB()
	end
	if ColorPickerFrame and ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker
		and ColorPickerFrame.Content.ColorPicker.GetColorRGB then
		return ColorPickerFrame.Content.ColorPicker:GetColorRGB()
	end
	return 1,1,1
end

local function ColorButton(parent, labelText, getColor, setColor)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetText(labelText)
	b:SetWidth(160); b:SetHeight(22)

	local swatch = b:CreateTexture(nil, "OVERLAY")
	swatch:SetSize(14,14)
	swatch:SetPoint("LEFT", b, "RIGHT", 8, 0)

	local function Refresh()
		local c = getColor()
		if c and type(c)=="table" then
			swatch:SetColorTexture(c[1],c[2],c[3],c[4])
		else
			swatch:SetColorTexture(1,1,1,0)
		end
	end

	local function Picker_SetColorRGB(r,g,b2)
		if ColorPickerFrame and ColorPickerFrame.SetColorRGB then
			ColorPickerFrame:SetColorRGB(r,g,b2)
			return true
		end
		if ColorPickerFrame and ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker
			and ColorPickerFrame.Content.ColorPicker.SetColorRGB then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(r,g,b2)
			return true
		end
		return false
	end

	local function Picker_GetColorRGB()
		if ColorPickerFrame and ColorPickerFrame.GetColorRGB then
			return ColorPickerFrame:GetColorRGB()
		end
		if ColorPickerFrame and ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker
			and ColorPickerFrame.Content.ColorPicker.GetColorRGB then
			return ColorPickerFrame.Content.ColorPicker:GetColorRGB()
		end
		return 1,1,1
	end

	b:SetScript("OnShow", Refresh)

	b:SetScript("OnClick", function()
		local c = getColor()
		local r,g,b2,a = 0.35,0.65,1.0,0.95
		if c then r,g,b2,a = c[1],c[2],c[3],c[4] end

		local function ApplyFromPicker()
			local nr,ng,nb = Picker_GetColorRGB()
			local na = 1 - (ColorPickerFrame.opacity or 0)
			setColor({nr,ng,nb,na})
			Refresh()
			if FastVigorBar.Update then FastVigorBar.Update() end
		end

		local function Cancel(prev)
			if type(prev)=="table" then setColor(prev) end
			Refresh()
			if FastVigorBar.Update then FastVigorBar.Update() end
		end

		-- TWW expects swatchFunc; older expects func - set both to be safe
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.previousValues = {r,g,b2,a}

		ColorPickerFrame.swatchFunc  = ApplyFromPicker
		ColorPickerFrame.func        = ApplyFromPicker
		ColorPickerFrame.opacityFunc = ApplyFromPicker
		ColorPickerFrame.cancelFunc  = Cancel

		Picker_SetColorRGB(r,g,b2)
		ColorPickerFrame:Show()
	end)

	-- right click = reset to theme default
	b:SetScript("OnMouseUp", function(_, btn)
		if btn=="RightButton" then
			setColor(nil)
			Refresh()
			if FastVigorBar.Update then FastVigorBar.Update() end
		end
	end)

	return b
end

local function RegisterPanel()
	-- Main panel (registered with Blizzard Settings)
	local panel = CreateFrame("Frame", nil, UIParent)
	panel.name = "FastVigorBar"

	-- ScrollFrame wrapper so content stays inside the window
	local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 0, -4)
	scroll:SetPoint("BOTTOMRIGHT", -28, 4)

	local content = CreateFrame("Frame", nil, scroll)
	content:SetSize(1, 1) -- width is controlled by scrollframe
	scroll:SetScrollChild(content)

	-- Make scroll content width follow the scroll frame
	scroll:HookScript("OnSizeChanged", function(self)
		content:SetWidth(self:GetWidth())
	end)

	-- Title
	local title = content:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
	title:SetPoint("TOPLEFT",16,-16)
	title:SetText(L.ADDON_NAME)

	local sub = content:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
	sub:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-6)
	sub:SetText(L.SUBTITLE)

	local y = -60

	local cbMounted = MakeCheckbox(content, L.ONLY_MOUNTED, L.ONLY_MOUNTED_TT,
		function() return FastVigorBarDB.showOnlyMounted end,
		function(v) FastVigorBarDB.showOnlyMounted=v; FastVigorBar.Update() end
	)
	cbMounted:SetPoint("TOPLEFT",16,y); y=y-34

	local cbLocked = MakeCheckbox(content, L.LOCK_FRAME, L.LOCK_FRAME_TT,
		function() return FastVigorBarDB.locked end,
		function(v) FastVigorBarDB.locked=v; UI:ApplyConfig(false) end
	)
	cbLocked:SetPoint("TOPLEFT",16,y); y=y-44

	local themeItems = {}
	for _, key in ipairs(Themes:Keys()) do
		local th = Themes:Get(key)
		themeItems[#themeItems+1] = { value = key, text = L[th.nameKey] }
	end

	local ddTheme = MakeDropdown(content, L.THEME, L.THEME_TT, themeItems,
		function() return FastVigorBarDB.theme end,
		function(v)
			FastVigorBarDB.theme = v
			UI:ApplyConfig(true)
			FastVigorBar.Update()
		end
	)
	ddTheme:SetPoint("TOPLEFT", 0, y); y=y-70

	local cbText = MakeCheckbox(content, L.SHOW_TEXT, L.SHOW_TEXT_TT,
		function() return FastVigorBarDB.showText end,
		function(v) FastVigorBarDB.showText=v; FastVigorBar.Update() end
	)
	cbText:SetPoint("TOPLEFT",16,y); y=y-34

	local cbCD = MakeCheckbox(content, L.SHOW_CD, L.SHOW_CD_TT,
		function() return FastVigorBarDB.showCooldown end,
		function(v) FastVigorBarDB.showCooldown=v; FastVigorBar.Update() end
	)
	cbCD:SetPoint("TOPLEFT",16,y); y=y-46

	local sScale = MakeSlider(content, L.SCALE, nil, 0.5,2.5,0.05,
		function() return FastVigorBarDB.scale end,
		function(v) FastVigorBarDB.scale=clamp(v,0.5,2.5); UI:ApplyConfig(false) end
	)
	sScale:SetPoint("TOPLEFT",16,y); sScale:SetWidth(260); y=y-56

	local sAlpha = MakeSlider(content, L.ALPHA, nil, 0.2,1.0,0.05,
		function() return FastVigorBarDB.alpha end,
		function(v) FastVigorBarDB.alpha=clamp(v,0.2,1.0); UI:ApplyConfig(false) end
	)
	sAlpha:SetPoint("TOPLEFT",16,y); sAlpha:SetWidth(260); y=y-56

	local sWidth = MakeSlider(content, L.WIDTH, nil, 120,520,5,
		function() return FastVigorBarDB.width end,
		function(v) FastVigorBarDB.width=clamp(v,120,520); UI:ApplyConfig(true); FastVigorBar.Update() end
	)
	sWidth:SetPoint("TOPLEFT",16,y); sWidth:SetWidth(260); y=y-56

	local sHeight = MakeSlider(content, L.HEIGHT, nil, 10,40,1,
		function() return FastVigorBarDB.height end,
		function(v) FastVigorBarDB.height=clamp(v,10,40); UI:ApplyConfig(true); FastVigorBar.Update() end
	)
	sHeight:SetPoint("TOPLEFT",16,y); sHeight:SetWidth(260); y=y-56

	local sGap = MakeSlider(content, L.GAP, nil, 0,12,1,
		function() return FastVigorBarDB.gap end,
		function(v) FastVigorBarDB.gap=clamp(v,0,12); UI:ApplyConfig(true); FastVigorBar.Update() end
	)
	sGap:SetPoint("TOPLEFT",16,y); sGap:SetWidth(260); y=y-64

	local colorsTitle = content:CreateFontString(nil,"ARTWORK","GameFontNormal")
	colorsTitle:SetPoint("TOPLEFT",16,y)
	colorsTitle:SetText(L.COLORS)
	y=y-34

	local bFull = ColorButton(content, L.FULL_COLOR,
		function() return FastVigorBarDB.customFull end,
		function(c) FastVigorBarDB.customFull=c end
	)
	bFull:SetPoint("TOPLEFT",16,y); y=y-28

	local bPartial = ColorButton(content, L.PARTIAL_COLOR,
		function() return FastVigorBarDB.customPartial end,
		function(c) FastVigorBarDB.customPartial=c end
	)
	bPartial:SetPoint("TOPLEFT",16,y); y=y-28

	local bEmpty = ColorButton(content, L.EMPTY_COLOR,
		function() return FastVigorBarDB.customEmpty end,
		function(c) FastVigorBarDB.customEmpty=c end
	)
	bEmpty:SetPoint("TOPLEFT",16,y); y=y-44

	local btnResetColors = MakeButton(content, L.RESET_COLORS, function()
		FastVigorBarDB.customFull = nil
		FastVigorBarDB.customPartial = nil
		FastVigorBarDB.customEmpty = nil
		FastVigorBar.Update()
	end)
	btnResetColors:SetPoint("TOPLEFT",16,y)
	btnResetColors:SetWidth(160)
	y = y - 34

	local btnReset = MakeButton(content, L.RESET_POS, function()
		UI:ResetPosition()
		FastVigorBar.Update()
	end)
	btnReset:SetPoint("TOPLEFT",16,y)
	btnReset:SetWidth(160)

	local hint = content:CreateFontString(nil,"ARTWORK","GameFontDisableSmall")
	hint:SetPoint("TOPLEFT",btnReset,"BOTTOMLEFT",0,-10)
	hint:SetText(L.HINT_DRAG)

	-- IMPORTANT: Set content height so scrolling works
	content:SetHeight(math.abs(y) + 120)

	-- Register (TWW Settings UI + fallback)
	if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
		local category = Settings.RegisterCanvasLayoutCategory(panel, "FastVigorBar")
		Settings.RegisterAddOnCategory(category)
	elseif InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
end

C_Timer.After(0, RegisterPanel)
