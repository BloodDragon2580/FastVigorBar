-- FastVigorBar.lua (Standalone)
-- Minimal Skyriding/Vigor charges bar for TWW 11.2.7+ with in-game Options panel

FastVigorBarDB = FastVigorBarDB or {}

local ADDON = ...
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
f:RegisterEvent("SPELL_UPDATE_CHARGES")
f:RegisterEvent("SPELL_UPDATE_COOLDOWN")

-- Shared-charge spells (Skyriding)
local CHARGE_SPELL_IDS = { 372608, 372610 }

local function clamp(x, a, b)
	if x < a then return a end
	if x > b then return b end
	return x
end

local function SafeGetSpellCharges(spellID)
	if C_Spell and C_Spell.GetSpellCharges then
		local ch = C_Spell.GetSpellCharges(spellID)
		if type(ch) == "table" then
			return ch.currentCharges, ch.maxCharges, ch.cooldownStartTime, ch.cooldownDuration
		end
	end
	if GetSpellCharges then
		local currentCharges, maxCharges, start, duration = GetSpellCharges(spellID)
		return currentCharges, maxCharges, start, duration
	end
	return nil
end

local function FindChargeSpell()
	for i = 1, #CHARGE_SPELL_IDS do
		local spellID = CHARGE_SPELL_IDS[i]
		local _, max = SafeGetSpellCharges(spellID)
		if max and max > 0 then
			return spellID
		end
	end
	return nil
end

-- -------------------------
-- Saved settings defaults
-- -------------------------
local DEFAULTS = {
	point = "CENTER",
	relativePoint = "CENTER",
	x = 0,
	y = -140,

	scale = 1.0,
	alpha = 1.0,

	locked = false,
	showOnlyMounted = true,

	width = 220,
	height = 18,
	gap = 3,

	segmentsMaxFallback = 6,
}

local function ApplyDefaults(db, defaults)
	for k, v in pairs(defaults) do
		if db[k] == nil then db[k] = v end
	end
end

-- -------------------------
-- UI (Bar)
-- -------------------------
local UI = {}
local state = { spellID = nil }

function UI:Create()
	if self.frame then return end

	local frame = CreateFrame("Frame", "FastVigorBarFrame", UIParent, "BackdropTemplate")
	self.frame = frame

	frame:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8x8",
		edgeFile = "Interface/Buttons/WHITE8x8",
		tile = false, tileSize = 0, edgeSize = 1,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.45)
	frame:SetBackdropBorderColor(0, 0, 0, 0.9)

	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if not FastVigorBarDB.locked then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local p, _, rp, x, y = self:GetPoint(1)
		FastVigorBarDB.point = p
		FastVigorBarDB.relativePoint = rp
		FastVigorBarDB.x = x
		FastVigorBarDB.y = y
	end)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("BOTTOM", frame, "TOP", 0, 4)
	label:SetText("Vigor")
	label:SetAlpha(0.8)
	self.label = label

	self.segments = {}
	self.maxSegments = 0

	self:ApplyConfig()
	frame:Hide()
end

function UI:ApplyConfig()
	local db = FastVigorBarDB
	if not self.frame then return end

	self.frame:ClearAllPoints()
	self.frame:SetPoint(db.point, UIParent, db.relativePoint, db.x, db.y)
	self.frame:SetScale(db.scale)
	self.frame:SetAlpha(db.alpha)
	self.frame:SetSize(db.width, db.height)

	-- label only when unlocked (helpful for positioning)
	self.label:SetShown(not db.locked)
end

function UI:ResetPosition()
	local db = FastVigorBarDB
	db.point, db.relativePoint, db.x, db.y = DEFAULTS.point, DEFAULTS.relativePoint, DEFAULTS.x, DEFAULTS.y
	self:ApplyConfig()
end

function UI:SetSegments(maxCharges)
	maxCharges = tonumber(maxCharges) or 0
	if maxCharges <= 0 then
		maxCharges = FastVigorBarDB.segmentsMaxFallback or 6
	end
	if maxCharges == self.maxSegments then
		return
	end

	for i = 1, #self.segments do
		self.segments[i]:Hide()
		self.segments[i]:SetParent(nil)
	end
	self.segments = {}
	self.maxSegments = maxCharges

	local db = FastVigorBarDB
	local w = db.width
	local h = db.height
	local gap = db.gap

	local totalGap = gap * (maxCharges - 1)
	local segW = (w - totalGap) / maxCharges
	segW = math.max(6, segW)

	for i = 1, maxCharges do
		local holder = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
		holder:SetBackdrop({
			bgFile = "Interface/Buttons/WHITE8x8",
			edgeFile = "Interface/Buttons/WHITE8x8",
			tile = false, edgeSize = 1,
			insets = { left = 1, right = 1, top = 1, bottom = 1 },
		})
		holder:SetBackdropColor(0, 0, 0, 0.35)
		holder:SetBackdropBorderColor(0, 0, 0, 0.8)

		holder:SetSize(segW, h)
		if i == 1 then
			holder:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
		else
			holder:SetPoint("LEFT", self.segments[i-1], "RIGHT", gap, 0)
		end

		local fill = CreateFrame("Frame", nil, holder, "BackdropTemplate")
		fill:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })
		fill:SetBackdropColor(0.35, 0.65, 1.0, 0.95)
		fill:SetPoint("LEFT", holder, "LEFT", 0, 0)
		fill:SetPoint("TOP", holder, "TOP", 0, 0)
		fill:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
		fill:SetWidth(0)

		holder.fill = fill
		self.segments[i] = holder
	end
end

function UI:Render(charges, maxCharges, partialPct)
	if not self.frame then return end
	if not maxCharges or maxCharges <= 0 then
		self.frame:Hide()
		return
	end

	self:SetSegments(maxCharges)

	charges = tonumber(charges) or 0
	partialPct = clamp(tonumber(partialPct) or 0, 0, 1)

	for i = 1, self.maxSegments do
		local seg = self.segments[i]
		local holderW = seg:GetWidth()

		if i <= charges then
			seg.fill:SetWidth(holderW)
			seg.fill:SetAlpha(1.0)
		elseif i == (charges + 1) and partialPct > 0 then
			seg.fill:SetWidth(holderW * partialPct)
			seg.fill:SetAlpha(0.9)
		else
			seg.fill:SetWidth(0)
			seg.fill:SetAlpha(0.6)
		end
	end
end

-- -------------------------
-- Logic
-- -------------------------
local function ShouldShow()
	if FastVigorBarDB.showOnlyMounted and (not IsMounted or not IsMounted()) then
		return false
	end

	state.spellID = state.spellID or FindChargeSpell()
	if not state.spellID then
		return false
	end

	local _, max = SafeGetSpellCharges(state.spellID)
	if not max or max <= 0 then
		return false
	end

	return true
end

local function Update()
	UI:Create()

	if not ShouldShow() then
		UI.frame:Hide()
		return
	end

	local cur, max, start, duration = SafeGetSpellCharges(state.spellID)
	if not max or max <= 0 then
		UI.frame:Hide()
		return
	end

	local partialPct = 0
	if duration and duration > 0 and start and start > 0 and cur and cur < max then
		local now = GetTime()
		partialPct = clamp((now - start) / duration, 0, 1)
	end

	UI.frame:Show()
	UI:Render(cur or 0, max, partialPct)
end

-- -------------------------
-- Options Panel (Settings UI)
-- -------------------------
local Options = {}

local function MakeCheckbox(parent, label, tooltip, initial, onChanged)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb.Text:SetText(label)
	cb:SetChecked(initial and true or false)

	if tooltip and cb.SetScript then
		cb:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(label, 1, 1, 1, true)
			GameTooltip:AddLine(tooltip, 0.9, 0.9, 0.9, true)
			GameTooltip:Show()
		end)
		cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end

	cb:SetScript("OnClick", function(self)
		onChanged(self:GetChecked() and true or false)
	end)

	return cb
end

local function MakeSlider(parent, label, tooltip, minV, maxV, step, initial, onChanged)
	local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	s:SetMinMaxValues(minV, maxV)
	s:SetValueStep(step)
	s:SetObeyStepOnDrag(true)
	s:SetValue(initial or minV)

	_G[s:GetName() .. "Text"]:SetText(label)
	_G[s:GetName() .. "Low"]:SetText(tostring(minV))
	_G[s:GetName() .. "High"]:SetText(tostring(maxV))

	if tooltip then
		s:HookScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(label, 1, 1, 1, true)
			GameTooltip:AddLine(tooltip, 0.9, 0.9, 0.9, true)
			GameTooltip:Show()
		end)
		s:HookScript("OnLeave", function() GameTooltip:Hide() end)
	end

	s:SetScript("OnValueChanged", function(self, value)
		value = tonumber(value) or minV
		onChanged(value)
	end)

	return s
end

local function MakeButton(parent, text, onClick)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetText(text)
	b:SetHeight(22)
	b:SetScript("OnClick", onClick)
	return b
end

function Options:Build(panel)
	panel.name = "FastVigorBar"

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("FastVigorBar")

	local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	sub:SetText("Minimal Skyriding/Vigor bar (TWW 11.2.7+)")

	local y = -60

	local cbMounted = MakeCheckbox(
		panel,
		"Nur wenn gemountet",
		"Wenn aktiv, wird die Leiste nur angezeigt, solange du gemountet bist.",
		FastVigorBarDB.showOnlyMounted,
		function(v)
			FastVigorBarDB.showOnlyMounted = v
			Update()
		end
	)
	cbMounted:SetPoint("TOPLEFT", 16, y)
	y = y - 34

	local cbLocked = MakeCheckbox(
		panel,
		"Frame sperren",
		"Wenn aktiv, kannst du die Leiste nicht mehr per Drag verschieben.",
		FastVigorBarDB.locked,
		function(v)
			FastVigorBarDB.locked = v
			UI:ApplyConfig()
		end
	)
	cbLocked:SetPoint("TOPLEFT", 16, y)
	y = y - 46

	local sScale = MakeSlider(
		panel,
		"Skalierung",
		"Größe der Leiste.",
		0.5, 2.5, 0.05,
		FastVigorBarDB.scale,
		function(v)
			FastVigorBarDB.scale = clamp(v, 0.5, 2.5)
			UI:ApplyConfig()
		end
	)
	sScale:SetPoint("TOPLEFT", 16, y)
	sScale:SetWidth(260)
	y = y - 56

	local sAlpha = MakeSlider(
		panel,
		"Alpha",
		"Transparenz der Leiste.",
		0.2, 1.0, 0.05,
		FastVigorBarDB.alpha,
		function(v)
			FastVigorBarDB.alpha = clamp(v, 0.2, 1.0)
			UI:ApplyConfig()
		end
	)
	sAlpha:SetPoint("TOPLEFT", 16, y)
	sAlpha:SetWidth(260)
	y = y - 56

	local sWidth = MakeSlider(
		panel,
		"Breite",
		"Gesamtbreite der Leiste.",
		120, 520, 5,
		FastVigorBarDB.width,
		function(v)
			FastVigorBarDB.width = clamp(v, 120, 520)
			UI:ApplyConfig()
			-- force rebuild segments
			UI.maxSegments = 0
			Update()
		end
	)
	sWidth:SetPoint("TOPLEFT", 16, y)
	sWidth:SetWidth(260)
	y = y - 56

	local sHeight = MakeSlider(
		panel,
		"Höhe",
		"Höhe der Leiste/Segmente.",
		10, 40, 1,
		FastVigorBarDB.height,
		function(v)
			FastVigorBarDB.height = clamp(v, 10, 40)
			UI:ApplyConfig()
			UI.maxSegments = 0
			Update()
		end
	)
	sHeight:SetPoint("TOPLEFT", 16, y)
	sHeight:SetWidth(260)
	y = y - 56

	local sGap = MakeSlider(
		panel,
		"Abstand (Gap)",
		"Abstand zwischen den Segmenten.",
		0, 12, 1,
		FastVigorBarDB.gap,
		function(v)
			FastVigorBarDB.gap = clamp(v, 0, 12)
			UI.maxSegments = 0
			Update()
		end
	)
	sGap:SetPoint("TOPLEFT", 16, y)
	sGap:SetWidth(260)
	y = y - 60

	local btnReset = MakeButton(panel, "Reset Position", function()
		UI:ResetPosition()
		Update()
	end)
	btnReset:SetPoint("TOPLEFT", 16, y)
	btnReset:SetWidth(140)

	local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", btnReset, "BOTTOMLEFT", 0, -10)
	hint:SetText("Tipp: Leiste per Drag verschieben (nur wenn Frame sperren AUS ist).")

	self.panel = panel
	self.widgets = { cbMounted, cbLocked, sScale, sAlpha, sWidth, sHeight, sGap, btnReset }
end

local function RegisterOptionsPanel()
	local panel = CreateFrame("Frame", nil, UIParent)
	Options:Build(panel)

	-- New Settings UI (Dragonflight+ / TWW)
	if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
		local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(category)
		return
	end

	-- Fallback: old InterfaceOptions
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
end

-- -------------------------
-- Events
-- -------------------------
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local name = ...
		if name ~= ADDON then return end

		ApplyDefaults(FastVigorBarDB, DEFAULTS)
		UI:Create()
		UI:ApplyConfig()

		RegisterOptionsPanel()
		Update()
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		C_Timer.After(0.5, function()
			state.spellID = nil
			Update()
		end)
		return
	end

	if event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
		Update()
		return
	end

	if event == "SPELL_UPDATE_CHARGES" or event == "SPELL_UPDATE_COOLDOWN" then
		Update()
		return
	end
end)
