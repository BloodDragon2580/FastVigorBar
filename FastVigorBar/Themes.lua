-- Themes.lua
FastVigorBar = FastVigorBar or {}
FastVigorBar.Themes = FastVigorBar.Themes or {}

local Themes = FastVigorBar.Themes

-- theme.type:
--  "SEGMENTS" = rechteckige Segmente
--  "ORBS"     = runde Pips (Mask)
--  "SINGLE"   = 1 Balken + Markierungen + Overlay-Pattern (code-generated)

Themes.List = {
	CLASSIC = {
		key = "CLASSIC",
		type = "SEGMENTS",
		nameKey = "THEME_CLASSIC",

		frameBG = {0,0,0,0.45},
		frameBorder = {0,0,0,0.90},
		frameEdgeSize = 1,

		segBG = {0,0,0,0.35},
		segBorder = {0,0,0,0.85},
		segEdgeSize = 1,

		full = {0.35, 0.65, 1.00, 0.95},
		emptyAlpha = 0.60,
		partialAlpha = 0.90,
		font = "GameFontNormalSmall",
	},

	MINIMAL = {
		key="MINIMAL",
		type="SEGMENTS",
		nameKey="THEME_MINIMAL",

		frameBG = {0,0,0,0.18},
		frameBorder = {0,0,0,0.35},
		frameEdgeSize = 1,

		segBG = {0,0,0,0.08},
		segBorder = {1,1,1,0.12},
		segEdgeSize = 1,

		segOverlay = "Interface/Buttons/WHITE8x8",
		segOverlayAlpha = 0.08,
		segOverlayRotation = 0.55,

		full = {0.70, 0.95, 1.00, 0.85},
		emptyAlpha = 0.35,
		partialAlpha = 0.75,
		font = "GameFontHighlightSmall",
	},

	ICE = {
		key="ICE",
		type="SEGMENTS",
		nameKey="THEME_ICE",

		frameBG = {0.02,0.06,0.10,0.55},
		frameBorder = {0.35,0.70,1.00,0.65},
		frameEdgeSize = 2,

		segBG = {0.02,0.05,0.10,0.35},
		segBorder = {0.35,0.70,1.00,0.40},
		segEdgeSize = 1,

		segOverlay = "Interface/Buttons/WHITE8x8",
		segOverlayAlpha = 0.14,
		segOverlayRotation = 0.78,

		full = {0.25, 0.85, 1.00, 0.95},
		emptyAlpha = 0.55,
		partialAlpha = 0.95,
		font = "GameFontNormal",
	},

	DARK = {
		key="DARK",
		type="SEGMENTS",
		nameKey="THEME_DARK",

		frameBG = {0,0,0,0.70},
		frameBorder = {0,0,0,0.98},
		frameEdgeSize = 2,

		segBG = {0,0,0,0.55},
		segBorder = {0,0,0,0.95},
		segEdgeSize = 2,

		full = {0.95, 0.95, 0.95, 0.75},
		emptyAlpha = 0.25,
		partialAlpha = 0.75,
		font = "GameFontHighlight",
	},

	ORBS = {
		key="ORBS",
		type="ORBS",
		nameKey="THEME_ORBS",

		frameBG = {0,0,0,0.35},
		frameBorder = {0.10,0.35,0.80,0.70},
		frameEdgeSize = 2,

		orbBG = {0,0,0,0.30},
		orbBorder = {0,0,0,0.85},

		full = {0.35, 0.70, 1.00, 0.95},
		emptyAlpha = 0.25,
		partialAlpha = 0.95,
		font = "GameFontNormal",
		orbFrameAtlas = "dragonriding_vigor_frame",
	},

	SINGLE = {
		key="SINGLE",
		type="SINGLE",
		nameKey="THEME_SINGLE",

		frameBG = {0,0,0,0.30},
		frameBorder = {0,0,0,0.85},
		frameEdgeSize = 1,

		barBG = {0,0,0,0.25},
		barBorder = {1,1,1,0.18},

		full = {0.35, 0.65, 1.00, 0.95},
		marker = {1,1,1,0.25},
		glow = {0.35, 0.65, 1.00, 0.20},
		font = "GameFontNormalSmall",
	},

	HEAT = {
		key="HEAT",
		type="SEGMENTS",
		nameKey="THEME_HEAT",

		frameBG = {0,0,0,0.40},
		frameBorder = {0,0,0,0.90},
		frameEdgeSize = 1,

		segBG = {0,0,0,0.20},
		segBorder = {0,0,0,0.60},
		segEdgeSize = 1,

		gradient = true,
		gradientStops = {
			{0.00, 0.78, 0.76, 0.18, 0.95},
			{0.55, 0.95, 0.55, 0.12, 0.95},
			{1.00, 0.85, 0.12, 0.12, 0.95},
		},

		emptyAlpha = 0.30,
		partialAlpha = 0.95,
		font = "GameFontNormalSmall",
	},

	-- ============================================================
	-- NEW SINGLE THEMES (NO TEXTURES, PURE CODE OVERLAYS)
	-- ============================================================

	SINGLE_NEON_DIAGONAL = {
		key="SINGLE_NEON_DIAGONAL", type="SINGLE", nameKey="THEME_SINGLE_NEON_DIAGONAL",
		frameBG={0.02,0.02,0.04,0.60}, frameBorder={0.10,1.00,0.85,0.45}, frameEdgeSize=2,
		barBG={0,0,0,0.22}, barBorder={0.10,1.00,0.85,0.20},
		full={0.10,1.00,0.85,0.92}, marker={1,1,1,0.18}, glow={0.10,1.00,0.85,0.18},
		font="GameFontNormalSmall",

		overlayMode="DIAGONAL",
		overlayColor={1,1,1,0.12},
		overlayCount=18, overlaySpacing=16, overlayThickness=6, overlayRotation=0.85,
	},

	SINGLE_OUTRUN_CHEVRON = {
		key="SINGLE_OUTRUN_CHEVRON", type="SINGLE", nameKey="THEME_SINGLE_OUTRUN_CHEVRON",
		frameBG={0.03,0.00,0.05,0.62}, frameBorder={1.00,0.25,0.80,0.40}, frameEdgeSize=2,
		barBG={0,0,0,0.22}, barBorder={0.40,0.90,1.00,0.18},
		full={1.00,0.25,0.80,0.88}, marker={1,1,1,0.16}, glow={0.40,0.90,1.00,0.14},
		font="GameFontNormalSmall",

		overlayMode="CHEVRON",
		overlayColor={1,1,1,0.10},
		overlayCount=14, overlaySpacing=18, overlayThickness=5, overlayRotation=0.90, overlayRotation2=0.90,
		overlayAlpha2=0.07,
	},

	SINGLE_FEL_DIAGONAL = {
		key="SINGLE_FEL_DIAGONAL", type="SINGLE", nameKey="THEME_SINGLE_FEL_DIAGONAL",
		frameBG={0.00,0.03,0.00,0.62}, frameBorder={0.55,1.00,0.10,0.40}, frameEdgeSize=2,
		barBG={0,0,0,0.18}, barBorder={0.55,1.00,0.10,0.20},
		full={0.55,1.00,0.10,0.92}, marker={1,1,1,0.14}, glow={0.55,1.00,0.10,0.16},
		font="GameFontNormalSmall",

		overlayMode="DIAGONAL",
		overlayColor={1,1,1,0.10},
		overlayCount=20, overlaySpacing=15, overlayThickness=6, overlayRotation=0.95,
	},

	SINGLE_ICE_SCANLINES = {
		key="SINGLE_ICE_SCANLINES", type="SINGLE", nameKey="THEME_SINGLE_ICE_SCANLINES",
		frameBG={0.02,0.06,0.10,0.56}, frameBorder={0.35,0.70,1.00,0.45}, frameEdgeSize=2,
		barBG={0,0,0,0.18}, barBorder={0.35,0.70,1.00,0.18},
		full={0.25,0.85,1.00,0.90}, marker={1,1,1,0.16}, glow={0.35,0.70,1.00,0.14},
		font="GameFontNormalSmall",

		overlayMode="SCANLINES",
		overlayColor={1,1,1,0.10},
		overlaySpacing=3, overlayThickness=1,
	},

	SINGLE_CARBON_GRID = {
		key="SINGLE_CARBON_GRID", type="SINGLE", nameKey="THEME_SINGLE_CARBON_GRID",
		frameBG={0,0,0,0.66}, frameBorder={1,1,1,0.10}, frameEdgeSize=1,
		barBG={0,0,0,0.28}, barBorder={1,1,1,0.08},
		full={0.95,0.95,0.95,0.80}, marker={1,1,1,0.10}, glow={1,1,1,0.06},
		font="GameFontHighlightSmall",

		overlayMode="GRID",
		overlayColor={1,1,1,0.07},
		overlaySpacing=12, overlayThickness=1,
	},

	SINGLE_GOLD_DIAGONAL = {
		key="SINGLE_GOLD_DIAGONAL", type="SINGLE", nameKey="THEME_SINGLE_GOLD_DIAGONAL",
		frameBG={0.05,0.04,0.01,0.60}, frameBorder={1.00,0.85,0.20,0.38}, frameEdgeSize=2,
		barBG={0,0,0,0.20}, barBorder={1.00,0.85,0.20,0.18},
		full={1.00,0.85,0.20,0.90}, marker={1,1,1,0.14}, glow={1.00,0.85,0.20,0.12},
		font="GameFontNormalSmall",

		overlayMode="DIAGONAL",
		overlayColor={1,1,1,0.10},
		overlayCount=16, overlaySpacing=18, overlayThickness=6, overlayRotation=0.75,
	},

	SINGLE_BLOOD_CHEVRON = {
		key="SINGLE_BLOOD_CHEVRON", type="SINGLE", nameKey="THEME_SINGLE_BLOOD_CHEVRON",
		frameBG={0.05,0.00,0.00,0.64}, frameBorder={0.95,0.12,0.12,0.35}, frameEdgeSize=2,
		barBG={0,0,0,0.22}, barBorder={0.95,0.12,0.12,0.18},
		full={0.95,0.12,0.12,0.88}, marker={1,1,1,0.12}, glow={0.95,0.12,0.12,0.14},
		font="GameFontNormalSmall",

		overlayMode="CHEVRON",
		overlayColor={1,1,1,0.09},
		overlayCount=14, overlaySpacing=18, overlayThickness=5, overlayRotation=0.90, overlayRotation2=0.90,
		overlayAlpha2=0.06,
	},

	SINGLE_ARCANE_DIAGONAL = {
		key="SINGLE_ARCANE_DIAGONAL", type="SINGLE", nameKey="THEME_SINGLE_ARCANE_DIAGONAL",
		frameBG={0.02,0.00,0.05,0.60}, frameBorder={0.70,0.45,1.00,0.40}, frameEdgeSize=2,
		barBG={0,0,0,0.20}, barBorder={0.70,0.45,1.00,0.18},
		full={0.70,0.45,1.00,0.88}, marker={1,1,1,0.14}, glow={0.70,0.45,1.00,0.14},
		font="GameFontNormalSmall",

		overlayMode="DIAGONAL",
		overlayColor={1,1,1,0.10},
		overlayCount=18, overlaySpacing=16, overlayThickness=6, overlayRotation=0.85,
	},

	SINGLE_MINT_GLASS = {
		key="SINGLE_MINT_GLASS", type="SINGLE", nameKey="THEME_SINGLE_MINT_GLASS",
		frameBG={0.00,0.02,0.02,0.45}, frameBorder={0.35,1.00,0.80,0.28}, frameEdgeSize=2,
		barBG={0,0,0,0.14}, barBorder={0.35,1.00,0.80,0.14},
		full={0.35,1.00,0.80,0.80}, marker={1,1,1,0.12}, glow={0.35,1.00,0.80,0.10},
		font="GameFontHighlightSmall",

		overlayMode="DIAGONAL",
		overlayColor={1,1,1,0.06},
		overlayCount=22, overlaySpacing=14, overlayThickness=4, overlayRotation=0.78,
	},

	-- ============================================================
	-- NEW SINGLE "SHEAR" THEMES (TRUE DIAGONAL BAR SHAPE)
	-- ============================================================

	SINGLE_HEAT_SHEAR = {
		key="SINGLE_HEAT_SHEAR", type="SINGLE", nameKey="THEME_SINGLE_HEAT_SHEAR",
		frameBG={0,0,0,0.42}, frameBorder={0,0,0,0.90}, frameEdgeSize=1,
		barBG={0,0,0,0}, barBorder={0,0,0,0},
		full={1.00,0.70,0.20,0.92}, marker={1,1,1,0.18}, glow={1.00,0.70,0.20,0.12},
		font="GameFontNormalSmall",

		diagonalFill=true,
		diagonalShearPx=10,
		diagonalFillSlices=28,
		diagonalFillGapPx=1,

		-- wichtig: Farbverlauf wie auf deinem Screenshot
		gradient = true,
		gradientStops = {
		  {0.00, 0.90, 0.85, 0.20, 0.95}, -- gelb
		  {0.55, 0.98, 0.55, 0.12, 0.95}, -- orange
		  {1.00, 0.90, 0.15, 0.12, 0.95}, -- rot
		},
	},

	SINGLE_NEON_SHEAR = {
		key="SINGLE_NEON_SHEAR", type="SINGLE", nameKey="THEME_SINGLE_NEON_SHEAR",
		frameBG={0.02,0.02,0.04,0.60}, frameBorder={0.10,1.00,0.85,0.45}, frameEdgeSize=2,
		barBG={0,0,0,0}, barBorder={0,0,0,0},
		full={0.10,1.00,0.85,0.92}, marker={1,1,1,0.16}, glow={0.10,1.00,0.85,0.16},
		font="GameFontNormalSmall",

		diagonalFill=true,
		diagonalShearPx=10,
		diagonalFillSlices=28,
		diagonalFillGapPx=1,

		-- optional: light scanlines on top
		overlayMode="SCANLINES",
		overlayColor={1,1,1,0.08},
		overlaySpacing=3, overlayThickness=1,
	},

	SINGLE_CARBON_SHEAR = {
		key="SINGLE_CARBON_SHEAR", type="SINGLE", nameKey="THEME_SINGLE_CARBON_SHEAR",
		frameBG={0,0,0,0.68}, frameBorder={1,1,1,0.10}, frameEdgeSize=1,
		barBG={0,0,0,0}, barBorder={0,0,0,0},
		full={0.95,0.95,0.95,0.80}, marker={1,1,1,0.10}, glow={1,1,1,0.06},
		font="GameFontHighlightSmall",

		diagonalFill=true,
		diagonalShearPx=10,
		diagonalFillSlices=28,
		diagonalFillGapPx=1,

		overlayMode="GRID",
		overlayColor={1,1,1,0.06},
		overlaySpacing=12, overlayThickness=1,
	},

	SINGLE_ARCANE_SHEAR = {
		key="SINGLE_ARCANE_SHEAR", type="SINGLE", nameKey="THEME_SINGLE_ARCANE_SHEAR",
		frameBG={0.02,0.00,0.05,0.60}, frameBorder={0.70,0.45,1.00,0.40}, frameEdgeSize=2,
		barBG={0,0,0,0}, barBorder={0,0,0,0},
		full={0.70,0.45,1.00,0.88}, marker={1,1,1,0.14}, glow={0.70,0.45,1.00,0.14},
		font="GameFontNormalSmall",

		diagonalFill=true,
		diagonalShearPx=10,
		diagonalFillSlices=28,
		diagonalFillGapPx=1,

		overlayMode="DIAGONAL",
		overlayColor={1,1,1,0.08},
		overlayCount=18, overlaySpacing=16, overlayThickness=5, overlayRotation=0.85,
	},
}

function Themes:Get(key)
	return self.List[key or "HEAT"] or self.List.HEAT or self.List.CLASSIC
end

function Themes:Keys()
	local t = {}
	for k in pairs(self.List) do t[#t+1] = k end
	table.sort(t)
	return t
end
