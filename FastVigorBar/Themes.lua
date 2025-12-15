-- Themes.lua
FastVigorBar = FastVigorBar or {}
FastVigorBar.Themes = FastVigorBar.Themes or {}

local Themes = FastVigorBar.Themes

-- theme.type:
--  "SEGMENTS" = rechteckige Segmente
--  "ORBS"     = runde Pips (Mask)
--  "SINGLE"   = 1 Balken + Markierungen

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

		-- subtle diagonal “glass” overlay so it feels different
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
		frameEdgeSize = 2, -- thicker = instantly different

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

		-- no overlay: “solid brick”
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

	-- HEAT bleibt exakt wie du es magst ✅
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
