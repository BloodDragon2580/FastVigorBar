-- Core.lua
FastVigorBarDB = FastVigorBarDB or {}
FastVigorBar   = FastVigorBar   or {}

local ADDON = ...
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
f:RegisterEvent("SPELL_UPDATE_CHARGES")
f:RegisterEvent("SPELL_UPDATE_COOLDOWN")

local L      = FastVigorBar.L
local Themes = FastVigorBar.Themes

local CHARGE_SPELL_IDS = { 372608, 372610 }

local function clamp(x,a,b) if x<a then return a elseif x>b then return b else return x end end

local function SafeGetSpellCharges(spellID)
	if C_Spell and C_Spell.GetSpellCharges then
		local ch = C_Spell.GetSpellCharges(spellID)
		if type(ch) == "table" then
			return ch.currentCharges, ch.maxCharges, ch.cooldownStartTime, ch.cooldownDuration
		end
	end
	if GetSpellCharges then
		local c,m,s,d = GetSpellCharges(spellID)
		return c,m,s,d
	end
	return nil
end

local function FindChargeSpell()
	for i=1,#CHARGE_SPELL_IDS do
		local id = CHARGE_SPELL_IDS[i]
		local _, max = SafeGetSpellCharges(id)
		if max and max > 0 then return id end
	end
	return nil
end

local DEFAULTS = {
	point="CENTER", relativePoint="CENTER", x=0, y=-140,
	scale=1.0, alpha=1.0,
	locked=false, showOnlyMounted=true,
	width=220, height=18, gap=3,
	segmentsMaxFallback=6,

	-- DEFAULT THEME:
	theme="HEAT",

	showText=true,
	showCooldown=true,

	customFull=nil,
	customPartial=nil,
	customEmpty=nil, -- (optional) falls du das später in Options nutzt
}

local function ApplyDefaults(db, defaults)
	for k,v in pairs(defaults) do
		if db[k] == nil then db[k] = v end
	end
end

local UI = {}
local state = { spellID=nil }

local function ColorOr(custom, fallback)
	if type(custom) == "table" and #custom >= 4 then return custom end
	return fallback
end

local function FormatCD(seconds)
	if not seconds or seconds<=0 then return "" end
	if seconds < 10 then
		return string.format(" (%.1fs)", seconds)
	end
	return string.format(" (%ds)", math.ceil(seconds))
end

-- -------- UI create / config

function UI:Create()
	if self.frame then return end

	local frame = CreateFrame("Frame","FastVigorBarFrame",UIParent,"BackdropTemplate")
	self.frame = frame

	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if not FastVigorBarDB.locked then self:StartMoving() end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local p,_,rp,x,y = self:GetPoint(1)
		-- -> Wird in SavedVariables gespeichert (bleibt nach Reload/Neustart)
		FastVigorBarDB.point=p; FastVigorBarDB.relativePoint=rp; FastVigorBarDB.x=x; FastVigorBarDB.y=y
	end)

	local label = frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	label:SetPoint("BOTTOM", frame, "TOP", 0, 4)
	label:SetText(L and L.VIGOR_LABEL or "Vigor")
	label:SetAlpha(0.8)
	self.label = label

	local text = frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	text:SetPoint("CENTER", frame, "CENTER", 0, 0)
	text:SetText("")
	self.text = text

	-- Segments / Orbs containers
	self.segments = {}
	self.maxSegments = 0
	self._builtType = nil

	-- Single bar widgets
	self.single = {}
	self.single.bar = CreateFrame("StatusBar", nil, frame, "BackdropTemplate")
	self.single.bar:SetMinMaxValues(0, 1)
	self.single.bar:SetValue(0)
	self.single.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	self.single.bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	self.single.bar:Hide()

	self.single.glow = self.single.bar:CreateTexture(nil, "BACKGROUND")
	self.single.glow:SetAllPoints(self.single.bar)
	self.single.glow:SetTexture("Interface/Buttons/WHITE8x8")
	self.single.glow:Hide()

	self.single.markers = {}

	self:ApplyConfig(true)
	frame:Hide()
end

function UI:ApplyTheme()
	local db = FastVigorBarDB
	local theme = Themes:Get(db.theme)
	self._theme = theme

	local frameEdge = theme.frameEdgeSize or 1

	self.frame:SetBackdrop({
		bgFile="Interface/Buttons/WHITE8x8",
		edgeFile="Interface/Buttons/WHITE8x8",
		tile=false, edgeSize=frameEdge,
		insets={left=frameEdge,right=frameEdge,top=frameEdge,bottom=frameEdge},
	})
	self.frame:SetBackdropColor(unpack(theme.frameBG))
	self.frame:SetBackdropBorderColor(unpack(theme.frameBorder))

	self.label:SetFontObject(theme.font or "GameFontNormalSmall")
	self.text:SetFontObject(theme.font or "GameFontNormalSmall")
end

function UI:ApplyConfig(rebuild)
	local db = FastVigorBarDB
	if not self.frame then return end

	self.frame:ClearAllPoints()
	self.frame:SetPoint(db.point, UIParent, db.relativePoint, db.x, db.y)
	self.frame:SetScale(db.scale)
	self.frame:SetAlpha(db.alpha)
	self.frame:SetSize(db.width, db.height)

	self.label:SetShown(not db.locked)
	self.text:SetShown(db.showText or db.showCooldown)

	self:ApplyTheme()

	if rebuild then
		self.maxSegments = 0
		self._builtType = nil
	end
end

function UI:ResetPosition()
	local db=FastVigorBarDB
	db.point,db.relativePoint,db.x,db.y = DEFAULTS.point,DEFAULTS.relativePoint,DEFAULTS.x,DEFAULTS.y
	self:ApplyConfig(false)
end

-- -------- SEGMENTS / ORBS build

local ORB_MASK = "Interface/CHARACTERFRAME/TempPortraitAlphaMask"

function UI:SetSegments(maxCharges)
	maxCharges = tonumber(maxCharges) or 0
	if maxCharges <= 0 then maxCharges = FastVigorBarDB.segmentsMaxFallback or 6 end

	local db = FastVigorBarDB
	local theme = self._theme or Themes:Get(db.theme)
	local buildType = theme.type or "SEGMENTS"

	-- rebuild not only when count changes, but also when theme type changes
	if maxCharges == self.maxSegments and self._builtType == buildType then
		return
	end

	-- cleanup old
	for i=1,#self.segments do
		self.segments[i]:Hide()
		self.segments[i]:SetParent(nil)
	end
	self.segments = {}
	self.maxSegments = maxCharges
	self._builtType = buildType

	local w, h, gap = db.width, db.height, db.gap
	local totalGap = gap * (maxCharges - 1)
	local segW = math.max(6, (w - totalGap) / maxCharges)

	for i=1, maxCharges do
		local holder = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
		holder:SetSize(segW, h)

		if i == 1 then
			holder:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
		else
			holder:SetPoint("LEFT", self.segments[i-1], "RIGHT", gap, 0)
		end

		-- classic fill frame (SEGMENTS)
		local fill = CreateFrame("Frame", nil, holder, "BackdropTemplate")
		fill:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8" })
		fill:SetPoint("LEFT", holder, "LEFT", 0, 0)
		fill:SetPoint("TOP", holder, "TOP", 0, 0)
		fill:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
		fill:SetWidth(0)
		holder.fill = fill

		if buildType == "ORBS" then
			-- Make orbs truly round: slot keeps segW, but orb is square centered
			local orbSize = math.min(h, segW)
			local orb = CreateFrame("Frame", nil, holder)
			orb:SetSize(orbSize, orbSize)
			orb:SetPoint("CENTER", holder, "CENTER", 0, 0)
			holder._orb = orb

			-- Mask for perfect circle
			local mask = orb:CreateMaskTexture()
			mask:SetAllPoints(orb)
			mask:SetTexture(ORB_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
			orb._mask = mask

			-- background (masked)
			local bgTex = orb:CreateTexture(nil, "BACKGROUND")
			bgTex:SetAllPoints(orb)
			bgTex:SetTexture("Interface/Buttons/WHITE8x8")
			bgTex:SetColorTexture(unpack(theme.orbBG or {0,0,0,0.35}))
			bgTex:AddMaskTexture(mask)
			orb._bgTex = bgTex

			-- fill (masked)
			local fillTex = orb:CreateTexture(nil, "ARTWORK")
			fillTex:SetAllPoints(orb)
			fillTex:SetTexture("Interface/Buttons/WHITE8x8")
			fillTex:AddMaskTexture(mask)
			orb._fillTex = fillTex

			-- border ring (use Blizzard atlas if you want IceHUD-like look)
			local ring = orb:CreateTexture(nil, "OVERLAY")
			ring:SetAllPoints(orb)
			if theme.orbFrameAtlas and ring.SetAtlas then
				ring:SetAtlas(theme.orbFrameAtlas, true)
			else
				ring:SetTexture("Interface/Buttons/WHITE8x8")
				ring:SetColorTexture(unpack(theme.orbBorder or {0,0,0,0.8}))
				ring:AddMaskTexture(mask)
			end
			orb._ring = ring

			-- hide classic fill for ORBS
			fill:Hide()

		else
			-- SEGMENTS look (thicker borders + optional overlay for “more theme difference”)
			local segEdge = theme.segEdgeSize or 1
			holder:SetBackdrop({
				bgFile="Interface/Buttons/WHITE8x8",
				edgeFile="Interface/Buttons/WHITE8x8",
				tile=false, edgeSize=segEdge,
				insets={left=segEdge,right=segEdge,top=segEdge,bottom=segEdge},
			})
			holder:SetBackdropColor(unpack(theme.segBG))
			holder:SetBackdropBorderColor(unpack(theme.segBorder))

			if theme.segOverlay then
				local ov = holder:CreateTexture(nil, "OVERLAY")
				ov:SetAllPoints(holder)
				ov:SetTexture(theme.segOverlay, "REPEAT", "REPEAT")
				ov:SetAlpha(theme.segOverlayAlpha or 0.20)
				if ov.SetRotation and theme.segOverlayRotation then
					ov:SetRotation(theme.segOverlayRotation)
				end
				holder._overlay = ov
			end
		end

		self.segments[i] = holder
	end
end

-- -------- SINGLE BAR build

function UI:EnsureSingleMarkers(maxCharges)
	local theme = self._theme or Themes:Get(FastVigorBarDB.theme)
	local markers = self.single.markers

	for i = #markers, maxCharges-1 + 1, -1 do
		if markers[i] then markers[i]:Hide(); markers[i]=nil end
	end

	for i=1, maxCharges-1 do
		if not markers[i] then
			local t = self.single.bar:CreateTexture(nil, "OVERLAY")
			t:SetTexture("Interface/Buttons/WHITE8x8")
			t:SetWidth(1)
			t:SetColorTexture(unpack(theme.marker or {1,1,1,0.2}))
			markers[i] = t
		end
		markers[i]:Show()
		local x = (i / maxCharges)
		markers[i]:ClearAllPoints()
		markers[i]:SetPoint("TOP", self.single.bar, "TOP", 0, 0)
		markers[i]:SetPoint("BOTTOM", self.single.bar, "BOTTOM", 0, 0)
		markers[i]:SetPoint("LEFT", self.single.bar, "LEFT", math.floor(self.single.bar:GetWidth() * x), 0)
	end
end

-- -------- Render switch

function UI:Render(charges, maxCharges, partialPct, secondsToNext)
	local db = FastVigorBarDB
	local theme = self._theme or Themes:Get(db.theme)

	charges = tonumber(charges) or 0
	partialPct = clamp(tonumber(partialPct) or 0, 0, 1)

	local txt = ""
	if db.showText then
		txt = string.format("%d/%d", charges, maxCharges)
	end
	if db.showCooldown and charges < maxCharges then
		txt = txt .. FormatCD(secondsToNext)
	end
	self.text:SetText(txt)

	local fullCol    = ColorOr(db.customFull, theme.full)
	local partialCol = ColorOr(db.customPartial, theme.full)
	local emptyCol   = ColorOr(db.customEmpty, theme.empty or fullCol)

	if theme.type == "SINGLE" then
		for i=1,#self.segments do self.segments[i]:Hide() end

		self.single.bar:Show()
		self.single.bar:SetBackdrop({
			bgFile="Interface/Buttons/WHITE8x8",
			edgeFile="Interface/Buttons/WHITE8x8",
			tile=false, edgeSize=1,
			insets={left=1,right=1,top=1,bottom=1},
		})
		self.single.bar:SetBackdropColor(unpack(theme.barBG or {0,0,0,0.3}))
		self.single.bar:SetBackdropBorderColor(unpack(theme.barBorder or {0,0,0,0.8}))
		self.single.bar:SetStatusBarTexture("Interface/Buttons/WHITE8x8")

		local value = (charges + partialPct) / math.max(1, maxCharges)
		self.single.bar:SetValue(clamp(value, 0, 1))
		self.single.bar:SetStatusBarColor(fullCol[1], fullCol[2], fullCol[3], fullCol[4])

		self.single.glow:Show()
		self.single.glow:SetColorTexture(unpack(theme.glow or {0.35,0.65,1.0,0.25}))

		C_Timer.After(0, function()
			if not self.single.bar:IsShown() then return end
			self:EnsureSingleMarkers(maxCharges)
		end)

		return
	end

	-- SEGMENTS / ORBS
	self.single.bar:Hide()
	self.single.glow:Hide()
	for i=1,#self.single.markers do if self.single.markers[i] then self.single.markers[i]:Hide() end end

	self:SetSegments(maxCharges)

	local emptyAlpha   = theme.emptyAlpha or 0.6
	local partialAlpha = theme.partialAlpha or 0.9

	-- Gradient helpers (HEAT)
	local function Lerp(a,b,t) return a + (b-a)*t end
	local function GradientColor(t)
		local stops = theme.gradientStops
		if not (theme.gradient and type(stops)=="table" and #stops>=2) then
			return fullCol[1], fullCol[2], fullCol[3], fullCol[4]
		end
		t = clamp(t, 0, 1)

		local s1, s2 = stops[1], stops[#stops]
		for j=1,#stops-1 do
			if t >= stops[j][1] and t <= stops[j+1][1] then
				s1, s2 = stops[j], stops[j+1]
				break
			end
		end

		local span = (s2[1]-s1[1])
		local lt = span > 0 and ((t - s1[1]) / span) or 0
		local r = Lerp(s1[2], s2[2], lt)
		local g = Lerp(s1[3], s2[3], lt)
		local b = Lerp(s1[4], s2[4], lt)
		local a = Lerp(s1[5] or 1, s2[5] or 1, lt)
		return r,g,b,a
	end

	for i=1,self.maxSegments do
		local seg = self.segments[i]
		if not seg then break end

		if theme.type == "ORBS" then
			-- ORBS: fill alpha per orb (full/partial/empty)
			local isFull    = i <= charges
			local isPartial = (i == charges+1 and partialPct > 0)

			local orb = seg._orb or seg
			local fillTex = orb._fillTex

			if fillTex then
				fillTex:SetColorTexture(fullCol[1], fullCol[2], fullCol[3], fullCol[4])
				if isFull then
					fillTex:SetAlpha(1.0)
				elseif isPartial then
					fillTex:SetAlpha(partialAlpha * partialPct)
				else
					-- “empty” wirkt schöner, wenn es wirklich dunkler ist:
					fillTex:SetColorTexture(emptyCol[1], emptyCol[2], emptyCol[3], emptyCol[4])
					fillTex:SetAlpha(emptyAlpha)
				end
			end

		else
			-- SEGMENTS: width fill + optional gradient per segment
			local holderW = seg:GetWidth()
			local tpos = (self.maxSegments > 1) and ((i-1) / (self.maxSegments-1)) or 0
			local gr,gg,gb,ga = GradientColor(tpos)

			if i <= charges then
				seg.fill:Show()
				seg.fill:SetWidth(holderW)
				seg.fill:SetBackdropColor(gr,gg,gb,ga)
				seg.fill:SetAlpha(1.0)
			elseif i == (charges+1) and partialPct > 0 then
				seg.fill:Show()
				seg.fill:SetWidth(holderW * partialPct)
				seg.fill:SetBackdropColor(gr,gg,gb,ga)
				seg.fill:SetAlpha(partialAlpha)
			else
				seg.fill:Show()
				seg.fill:SetWidth(0)
				seg.fill:SetAlpha(emptyAlpha)
			end
		end
	end
end

-- -------- logic

local function ShouldShow()
	if FastVigorBarDB.showOnlyMounted and (not IsMounted or not IsMounted()) then
		return false
	end
	state.spellID = state.spellID or FindChargeSpell()
	if not state.spellID then return false end
	local _, max = SafeGetSpellCharges(state.spellID)
	return (max and max > 0) and true or false
end

local function Update()
	UI:Create()

	if not ShouldShow() then
		UI.frame:Hide()
		return
	end

	local cur,max,start,duration = SafeGetSpellCharges(state.spellID)
	if not max or max<=0 then
		UI.frame:Hide()
		return
	end

	local partialPct, secondsToNext = 0, 0
	if duration and duration>0 and start and start>0 and cur and cur < max then
		local now = GetTime()
		local elapsed = now - start
		partialPct = clamp(elapsed/duration, 0, 1)
		secondsToNext = clamp(duration - elapsed, 0, duration)
	end

	UI:ApplyConfig(false)
	UI.frame:Show()
	UI:Render(cur or 0, max, partialPct, secondsToNext)
end

FastVigorBar.Update = Update
FastVigorBar.UI = UI

f:SetScript("OnEvent", function(self,event,...)
	if event=="ADDON_LOADED" then
		local name = ...
		if name ~= ADDON then return end

		ApplyDefaults(FastVigorBarDB, DEFAULTS)

		if FastVigorBar.Locale and FastVigorBar.Locale.Finalize then
			FastVigorBar.Locale:Finalize()
		end

		UI:Create()
		UI:ApplyConfig(true)
		Update()
		return
	end

	if event=="PLAYER_ENTERING_WORLD" then
		C_Timer.After(0.5, function()
			state.spellID=nil
			Update()
		end)
		return
	end

	if event=="PLAYER_MOUNT_DISPLAY_CHANGED" or event=="SPELL_UPDATE_CHARGES" or event=="SPELL_UPDATE_COOLDOWN" then
		Update()
		return
	end
end)
