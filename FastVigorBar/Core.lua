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
	customEmpty=nil,
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

-- ---------- SINGLE overlay builder (NO custom textures needed)

local function EnsureTexture(t)
	if not t then return end
	t:SetTexture("Interface/Buttons/WHITE8x8")
end

function UI:SingleOverlay_Clear()
	if not self.single or not self.single.overlayLines then return end
	for i=1,#self.single.overlayLines do
		local tex = self.single.overlayLines[i]
		if tex then tex:Hide() end
	end
end

function UI:SingleOverlay_GetLine(i)
	local lines = self.single.overlayLines
	if not lines[i] then
		local t = self.single.overlay:CreateTexture(nil, "OVERLAY")
		EnsureTexture(t)
		t:SetBlendMode("ADD")
		lines[i] = t
	end
	return lines[i]
end

function UI:SingleOverlay_Apply(theme)
	-- theme.overlayMode:
	--  "DIAGONAL"  = schräge Streifen
	--  "SCANLINES" = horizontale Scanlines
	--  "GRID"      = feines Grid
	--  "CHEVRON"   = Chevron-Look (2 diagonale Sets)
	--  nil/false   = aus
	if not self.single or not self.single.overlay then return end

	local mode = theme.overlayMode
	if not mode then
		self.single.overlay:Hide()
		self:SingleOverlay_Clear()
		return
	end

	self.single.overlay:Show()
	self:SingleOverlay_Clear()

	local bar = self.single.bar
	local w = bar:GetWidth()
	local h = bar:GetHeight()
	if not w or not h or w <= 0 or h <= 0 then
		return
	end

	local col = theme.overlayColor or {1,1,1,0.10}
	local alpha = col[4] or 0.10

	local function SetLine(tex, cx, cy, lw, lh, rot, r,g,b,a)
		tex:ClearAllPoints()
		tex:SetPoint("CENTER", self.single.overlay, "BOTTOMLEFT", cx, cy)
		tex:SetSize(lw, lh)
		tex:SetColorTexture(r,g,b,a)
		if tex.SetRotation and rot then tex:SetRotation(rot) end
		tex:Show()
	end

	local diag = math.sqrt((w*w) + (h*h)) + w

	if mode == "DIAGONAL" then
		local count = theme.overlayCount or 18
		local spacing = theme.overlaySpacing or 16
		local thick = theme.overlayThickness or 6
		local rot = theme.overlayRotation or 0.85

		local cx = w/2
		local cy = h/2
		local start = cx - ((count-1) * spacing)/2

		for i=1,count do
			local t = self:SingleOverlay_GetLine(i)
			local x = start + (i-1)*spacing
			SetLine(t, x, cy, diag, thick, rot, col[1], col[2], col[3], alpha)
		end

	elseif mode == "SCANLINES" then
		local spacing = theme.overlaySpacing or 3
		local thick = theme.overlayThickness or 1
		local count = math.floor(h / spacing)
		local idx = 1
		for y=1,count do
			local t = self:SingleOverlay_GetLine(idx); idx = idx + 1
			local yy = y * spacing
			SetLine(t, w/2, yy, w, thick, 0, col[1], col[2], col[3], alpha)
		end

	elseif mode == "GRID" then
		local spacing = theme.overlaySpacing or 12
		local thick = theme.overlayThickness or 1
		local idx = 1

		local vcount = math.floor(w / spacing)
		for x=0,vcount do
			local t = self:SingleOverlay_GetLine(idx); idx = idx + 1
			local xx = x * spacing
			SetLine(t, xx, h/2, thick, h, 0, col[1], col[2], col[3], alpha)
		end

		local hcount = math.floor(h / spacing)
		for y=0,hcount do
			local t = self:SingleOverlay_GetLine(idx); idx = idx + 1
			local yy = y * spacing
			SetLine(t, w/2, yy, w, thick, 0, col[1], col[2], col[3], alpha)
		end

	elseif mode == "CHEVRON" then
		local count = theme.overlayCount or 16
		local spacing = theme.overlaySpacing or 18
		local thick = theme.overlayThickness or 5
		local rot1 = theme.overlayRotation or 0.85
		local rot2 = -(theme.overlayRotation2 or 0.85)

		local cx = w/2
		local cy = h/2
		local start = cx - ((count-1) * spacing)/2

		local a1 = alpha
		local a2 = (theme.overlayAlpha2 or alpha*0.75)

		for i=1,count do
			local t = self:SingleOverlay_GetLine(i)
			local x = start + (i-1)*spacing
			SetLine(t, x, cy, diag, thick, rot1, col[1], col[2], col[3], a1)
		end
		for i=1,count do
			local t = self:SingleOverlay_GetLine(count + i)
			local x = start + (i-1)*spacing
			SetLine(t, x, cy, diag, thick, rot2, col[1], col[2], col[3], a2)
		end
	else
		self.single.overlay:Hide()
		self:SingleOverlay_Clear()
	end
end

-- ---------- TRUE DIAGONAL BAR FILL (SHEAR) - WITH GAPS PER CHARGE (no textures needed)

-- Pool: textures for [slice][block]
function UI:EnsureSingleFillPieces(sliceCount, blockCount)
	sliceCount = tonumber(sliceCount) or 22
	blockCount = tonumber(blockCount) or 6
	if sliceCount < 6 then sliceCount = 6 end
	if sliceCount > 80 then sliceCount = 80 end
	if blockCount < 1 then blockCount = 1 end
	if blockCount > 12 then blockCount = 12 end

	self.single._fillSliceCount = sliceCount
	self.single._fillBlockCount = blockCount

	self.single.fillPieces = self.single.fillPieces or {}

	for s = 1, sliceCount do
		self.single.fillPieces[s] = self.single.fillPieces[s] or {}
		local row = self.single.fillPieces[s]

		for b = 1, blockCount do
			if not row[b] then
				local t = self.single.fillFrame:CreateTexture(nil, "ARTWORK")
				t:SetTexture("Interface/Buttons/WHITE8x8")
				t:SetBlendMode("BLEND")
				row[b] = t
			end
			row[b]:Hide()
		end
	end
end

function UI:HideSingleFillPieces()
	if not self.single or not self.single.fillFrame then return end
	self.single.fillFrame:Hide()
	if self.single.fillPieces then
		for s=1,#self.single.fillPieces do
			local row = self.single.fillPieces[s]
			if row then
				for b=1,#row do
					if row[b] then row[b]:Hide() end
				end
			end
		end
	end
end

-- Draw per-charge blocks as true PARALLELOGRAMS (all blocks slanted), with gaps.
function UI:RenderSingleShearedFillBlocks(charges, maxCharges, partialPct, theme, shearPx, gapPx)
	local bar = self.single.bar
	local w, h = bar:GetWidth(), bar:GetHeight()
	if not w or not h or w <= 0 or h <= 0 then return end

	maxCharges = math.max(1, tonumber(maxCharges) or 1)
	charges = clamp(tonumber(charges) or 0, 0, maxCharges)
	partialPct = clamp(tonumber(partialPct) or 0, 0, 1)

	shearPx = tonumber(shearPx) or 14
	gapPx = tonumber(gapPx) or 2
	if gapPx < 0 then gapPx = 0 end
	if gapPx > 20 then gapPx = 20 end

	local sliceCount = self.single._fillSliceCount or 22
	local sliceH = h / sliceCount

	-- block geometry
	local totalGap = gapPx * (maxCharges - 1)
	local blockW = (w - totalGap) / maxCharges
	if blockW < 1 then blockW = 1 end

	-- shear must not exceed block width (leave at least 2px)
	local shear = math.min(shearPx, math.max(0, blockW - 2))

	-- Helper: gradient per block (optional)
	local function Lerp(a,b,t) return a + (b-a)*t end
	local function GradientColor(t)
		local stops = theme and theme.gradientStops
		if not (theme and theme.gradient and type(stops)=="table" and #stops>=2) then
			-- fallback: theme.full
			local c = (theme and theme.full) or {1,1,1,1}
			return c[1],c[2],c[3],c[4] or 1
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

	-- Determine which block is currently filling partially
	local endIndex, endFill = 0, 0
	if charges >= maxCharges then
		endIndex, endFill = maxCharges, 1
	else
		if partialPct > 0 then
			endIndex, endFill = charges + 1, partialPct
		else
			endIndex, endFill = charges, 1
		end
	end

	self.single.fillFrame:Show()

	for s=1,sliceCount do
		local y0 = (s-1) * sliceH

		-- yNorm -0.5..+0.5 (unten..oben)
		local yNorm = ((s-0.5)/sliceCount) - 0.5

		-- For a parallelogram inside the block:
		-- shift range 0..shear, width reduced by shear
		local shift = (yNorm + 0.5) * shear
		local usableW = blockW - shear

		local row = self.single.fillPieces[s]
		for b=1,maxCharges do
			local t = row and row[b]
			if t then
				local fill = 0
				if b < endIndex then
					fill = 1
				elseif b == endIndex then
					fill = endFill
				else
					fill = 0
				end

				if fill <= 0 then
					t:Hide()
				else
					-- base block position
					local x0 = (b-1) * (blockW + gapPx)

					-- parallelogram start + width (scaled by fill for the current block)
					local xStart = x0 + shift
					local thisW  = usableW * fill
					if thisW < 0 then thisW = 0 end
					if thisW > usableW then thisW = usableW end

					-- per-block color like your screenshot
					local tpos = (maxCharges > 1) and ((b-1) / (maxCharges-1)) or 0
					local r,g,bb,a = GradientColor(tpos)

					t:ClearAllPoints()
					t:SetPoint("BOTTOMLEFT", self.single.fillFrame, "BOTTOMLEFT", xStart, y0)
					t:SetSize(thisW, sliceH + 0.2)
					t:SetColorTexture(r,g,bb,a)
					t:Show()
				end
			end
		end
	end
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

	-- True diagonal fill container (clipped)
	self.single.fillFrame = CreateFrame("Frame", nil, self.single.bar)
	self.single.fillFrame:SetAllPoints(self.single.bar)
	self.single.fillFrame:SetClipsChildren(true)
	self.single.fillFrame:Hide()
	self.single.fillPieces = {}
	self.single._fillSliceCount = 22
	self.single._fillBlockCount = 6

	-- Overlay frame (generated lines, clipped)
	self.single.overlay = CreateFrame("Frame", nil, self.single.bar)
	self.single.overlay:SetAllPoints(self.single.bar)
	self.single.overlay:SetClipsChildren(true)
	self.single.overlay:Hide()
	self.single.overlayLines = {}

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

	if maxCharges == self.maxSegments and self._builtType == buildType then
		return
	end

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

		local fill = CreateFrame("Frame", nil, holder, "BackdropTemplate")
		fill:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8" })
		fill:SetPoint("LEFT", holder, "LEFT", 0, 0)
		fill:SetPoint("TOP", holder, "TOP", 0, 0)
		fill:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
		fill:SetWidth(0)
		holder.fill = fill

		if buildType == "ORBS" then
			local orbSize = math.min(h, segW)
			local orb = CreateFrame("Frame", nil, holder)
			orb:SetSize(orbSize, orbSize)
			orb:SetPoint("CENTER", holder, "CENTER", 0, 0)
			holder._orb = orb

			local mask = orb:CreateMaskTexture()
			mask:SetAllPoints(orb)
			mask:SetTexture(ORB_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
			orb._mask = mask

			local bgTex = orb:CreateTexture(nil, "BACKGROUND")
			bgTex:SetAllPoints(orb)
			bgTex:SetTexture("Interface/Buttons/WHITE8x8")
			bgTex:SetColorTexture(unpack(theme.orbBG or {0,0,0,0.35}))
			bgTex:AddMaskTexture(mask)
			orb._bgTex = bgTex

			local fillTex = orb:CreateTexture(nil, "ARTWORK")
			fillTex:SetAllPoints(orb)
			fillTex:SetTexture("Interface/Buttons/WHITE8x8")
			fillTex:AddMaskTexture(mask)
			orb._fillTex = fillTex

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

			fill:Hide()
		else
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

	local fullCol  = ColorOr(db.customFull, theme.full)
	local emptyCol = ColorOr(db.customEmpty, theme.empty or fullCol)

	if theme.type == "SINGLE" then
		for i = 1, #self.segments do
			self.segments[i]:Hide()
		end

		self.single.bar:Show()
		self.single.bar:SetStatusBarTexture("Interface/Buttons/WHITE8x8")

		local value = clamp((charges + partialPct) / math.max(1, maxCharges), 0, 1)

		-- True diagonal fill with per-charge gaps?
		if theme.diagonalFill then
			-- remove the main frame backdrop entirely (kills the "bar behind" for real)
			self.frame:SetBackdrop(nil)

			-- remove the whole bar backdrop/background (only floating tiles remain)
			self.single.bar:SetBackdrop(nil)

			-- force-disable overlay + markers for SHEAR tiles
			self.single.overlay:Hide()
			self:SingleOverlay_Clear()
			for i = 1, #self.single.markers do
				if self.single.markers[i] then
					self.single.markers[i]:Hide()
				end
			end

			-- hide StatusBar texture completely (prevents any remaining "bar" behind)
			local sbTex = self.single.bar:GetStatusBarTexture()
			if sbTex then
				sbTex:SetAlpha(0)
			end

			-- hide glow for pure "floating tiles" look
			self.single.glow:Hide()

			-- make the StatusBar fill irrelevant; we draw our own fill
			self.single.bar:SetValue(1)
			self.single.bar:SetStatusBarColor(0, 0, 0, 0)

			-- gap between charge blocks inside the bar
			local gapPx = theme.diagonalFillGapPx
			if gapPx == nil then
				gapPx = 2
			end

			self:EnsureSingleFillPieces(theme.diagonalFillSlices or 22, maxCharges)

			-- IMPORTANT: draw AFTER layout so width/height are valid
			C_Timer.After(0, function()
				if not self.single.bar or not self.single.bar:IsShown() then
					return
				end

				self:RenderSingleShearedFillBlocks(
					charges, maxCharges, partialPct,
					theme,
					theme.diagonalShearPx or 14,
					gapPx
				)
			end)
		else
			-- Normal bar look (restore backdrop + statusbar texture)
			self:ApplyTheme()

			self.single.bar:SetBackdrop({
				bgFile = "Interface/Buttons/WHITE8x8",
				edgeFile = "Interface/Buttons/WHITE8x8",
				tile = false,
				edgeSize = 1,
				insets = { left = 1, right = 1, top = 1, bottom = 1 },
			})
			self.single.bar:SetBackdropColor(unpack(theme.barBG or { 0, 0, 0, 0.3 }))
			self.single.bar:SetBackdropBorderColor(unpack(theme.barBorder or { 0, 0, 0, 0.8 }))

			local sbTex = self.single.bar:GetStatusBarTexture()
			if sbTex then
				sbTex:SetAlpha(1)
			end

			self:HideSingleFillPieces()
			self.single.bar:SetValue(value)
			self.single.bar:SetStatusBarColor(fullCol[1], fullCol[2], fullCol[3], fullCol[4])

			self.single.glow:Show()
			self.single.glow:SetColorTexture(unpack(theme.glow or { 0.35, 0.65, 1.0, 0.25 }))
		end

		-- apply overlay pattern ONLY for normal bar (NOT for diagonalFill tiles)
		if not theme.diagonalFill then
			C_Timer.After(0, function()
				if not self.single.bar or not self.single.bar:IsShown() then
					return
				end
				self:EnsureSingleMarkers(maxCharges)
				self:SingleOverlay_Apply(theme)
			end)
		end

		return
	end

	-- SEGMENTS / ORBS
	self.single.bar:Hide()
	self.single.glow:Hide()
	self.single.overlay:Hide()
	self:SingleOverlay_Clear()
	self:HideSingleFillPieces()

	for i = 1, #self.single.markers do
		if self.single.markers[i] then
			self.single.markers[i]:Hide()
		end
	end

	self:SetSegments(maxCharges)

	local emptyAlpha = theme.emptyAlpha or 0.6
	local partialAlpha = theme.partialAlpha or 0.9

	local function Lerp(a, b, t)
		return a + (b - a) * t
	end

	local function GradientColor(t)
		local stops = theme.gradientStops
		if not (theme.gradient and type(stops) == "table" and #stops >= 2) then
			return fullCol[1], fullCol[2], fullCol[3], fullCol[4]
		end

		t = clamp(t, 0, 1)

		local s1, s2 = stops[1], stops[#stops]
		for j = 1, #stops - 1 do
			if t >= stops[j][1] and t <= stops[j + 1][1] then
				s1, s2 = stops[j], stops[j + 1]
				break
			end
		end

		local span = (s2[1] - s1[1])
		local lt = span > 0 and ((t - s1[1]) / span) or 0
		local r = Lerp(s1[2], s2[2], lt)
		local g = Lerp(s1[3], s2[3], lt)
		local b = Lerp(s1[4], s2[4], lt)
		local a = Lerp(s1[5] or 1, s2[5] or 1, lt)
		return r, g, b, a
	end

	for i = 1, self.maxSegments do
		local seg = self.segments[i]
		if not seg then
			break
		end

		if theme.type == "ORBS" then
			local isFull = i <= charges
			local isPartial = (i == charges + 1 and partialPct > 0)

			local orb = seg._orb or seg
			local fillTex = orb._fillTex

			if fillTex then
				fillTex:SetColorTexture(fullCol[1], fullCol[2], fullCol[3], fullCol[4])

				if isFull then
					fillTex:SetAlpha(1.0)
				elseif isPartial then
					fillTex:SetAlpha(partialAlpha * partialPct)
				else
					fillTex:SetColorTexture(emptyCol[1], emptyCol[2], emptyCol[3], emptyCol[4])
					fillTex:SetAlpha(emptyAlpha)
				end
			end
		else
			local holderW = seg:GetWidth()
			local tpos = (self.maxSegments > 1) and ((i - 1) / (self.maxSegments - 1)) or 0
			local gr, gg, gb, ga = GradientColor(tpos)

			if i <= charges then
				seg.fill:Show()
				seg.fill:SetWidth(holderW)
				seg.fill:SetBackdropColor(gr, gg, gb, ga)
				seg.fill:SetAlpha(1.0)
			elseif i == (charges + 1) and partialPct > 0 then
				seg.fill:Show()
				seg.fill:SetWidth(holderW * partialPct)
				seg.fill:SetBackdropColor(gr, gg, gb, ga)
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
