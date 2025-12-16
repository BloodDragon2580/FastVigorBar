-- locales/enUS.lua
local Locale = FastVigorBar.Locale
FastVigorBar.L_enUS = {
	ADDON_NAME = "FastVigorBar",
	SUBTITLE = "Minimal Skyriding/Vigor bar",

	-- Frame label
	VIGOR_LABEL = "Vigor",

	ONLY_MOUNTED = "Only while mounted",
	ONLY_MOUNTED_TT = "If enabled, the bar is only shown while mounted.",

	LOCK_FRAME = "Lock frame",
	LOCK_FRAME_TT = "If enabled, you cannot drag the bar.",

	SCALE = "Scale",
	ALPHA = "Opacity",
	WIDTH = "Width",
	HEIGHT = "Height",
	GAP = "Segment gap",

	-- Optional (if you add more styling controls)
	FRAME_EDGE = "Frame border thickness",
	SEG_EDGE   = "Segment border thickness",
	ORBS_SIZE  = "Orb size",

	SHOW_TEXT = "Show text (charges)",
	SHOW_TEXT_TT = "Shows current/max charges on the bar.",

	SHOW_CD = "Show cooldown",
	SHOW_CD_TT = "Shows seconds until the next charge.",

	-- Optional toggle
	SHOW_EMPTY = "Show empty segments",
	SHOW_EMPTY_TT = "If disabled, only active segments are displayed.",

	THEME = "Theme",
	THEME_TT = "Choose a visual preset.",

	COLORS = "Colors",
	FULL_COLOR = "Full segment",
	EMPTY_COLOR = "Empty segment",
	PARTIAL_COLOR = "Recharging segment",

	RESET_POS = "Reset position",
	RESET_COLORS = "Reset colors",
	RESET_COLORS_TT = "Resets custom colors back to the theme defaults.",

	HINT_DRAG = "Tip: Drag the bar to move it (only if unlocked).",

	THEME_CLASSIC = "Classic Segments",
	THEME_MINIMAL = "Minimal Flat",
	THEME_ICE = "Ice Glow",
	THEME_DARK = "Dark Clean",
	THEME_ORBS = "Rune Orbs",
	THEME_SINGLE = "Single Bar",
	THEME_HEAT = "Heat Gradient",

	-- Optional (if you add a Blizzard/IceHUD-atlas theme)
	THEME_ICEHUD = "Blizzard Vigor (Atlas)",
	-- New SINGLE themes (code overlays)
	THEME_SINGLE_NEON_DIAGONAL   = "Neon (Diagonal Stripes)",
	THEME_SINGLE_OUTRUN_CHEVRON  = "Outrun (Chevron)",
	THEME_SINGLE_FEL_DIAGONAL    = "Fel (Diagonal Stripes)",
	THEME_SINGLE_ICE_SCANLINES   = "Ice (Scanlines)",
	THEME_SINGLE_CARBON_GRID     = "Carbon (Grid)",
	THEME_SINGLE_GOLD_DIAGONAL   = "Gold (Diagonal Stripes)",
	THEME_SINGLE_BLOOD_CHEVRON   = "Blood (Chevron)",
	THEME_SINGLE_ARCANE_DIAGONAL = "Arcane (Diagonal Stripes)",
	THEME_SINGLE_MINT_GLASS      = "Mint (Glass)",

	THEME_SINGLE_HEAT_SHEAR      = "Heat (Slanted Bar)",
	THEME_SINGLE_NEON_SHEAR      = "Neon (Slanted Bar)",
	THEME_SINGLE_CARBON_SHEAR    = "Carbon (Slanted Bar)",
	THEME_SINGLE_ARCANE_SHEAR    = "Arcane (Slanted Bar)",
}

-- build enUS baseline into live L on enUS clients
local L = Locale:NewLocale("enUS")
if L then
	for k, v in pairs(FastVigorBar.L_enUS) do L[k] = v end
end
