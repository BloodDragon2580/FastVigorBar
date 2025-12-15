-- locales/deDE.lua
local Locale = FastVigorBar.Locale
local L = Locale:NewLocale("deDE")
if not L then return end

L.ADDON_NAME = "FastVigorBar"
L.SUBTITLE = "Minimale Skyriding-/Vigor-Leiste"

-- Frame label
L.VIGOR_LABEL = "Vigor"

L.ONLY_MOUNTED = "Nur wenn gemountet"
L.ONLY_MOUNTED_TT = "Wenn aktiv, wird die Leiste nur angezeigt, solange du gemountet bist."

L.LOCK_FRAME = "Frame sperren"
L.LOCK_FRAME_TT = "Wenn aktiv, kannst du die Leiste nicht mehr per Drag verschieben."

L.SCALE = "Skalierung"
L.ALPHA = "Transparenz"
L.WIDTH = "Breite"
L.HEIGHT = "Höhe"
L.GAP = "Segment-Abstand"

-- Optional (für erweiterte Designs)
L.FRAME_EDGE = "Rahmenstärke"
L.SEG_EDGE   = "Segment-Rahmenstärke"
L.ORBS_SIZE  = "Orb-Größe"

L.SHOW_TEXT = "Text anzeigen (Charges)"
L.SHOW_TEXT_TT = "Zeigt aktuelle und maximale Charges auf der Leiste an."

L.SHOW_CD = "Cooldown anzeigen"
L.SHOW_CD_TT = "Zeigt die verbleibenden Sekunden bis zur nächsten Aufladung."

-- Optional
L.SHOW_EMPTY = "Leere Segmente anzeigen"
L.SHOW_EMPTY_TT = "Wenn deaktiviert, werden leere Segmente ausgeblendet."

L.THEME = "Design"
L.THEME_TT = "Wähle eine Design-Vorlage."

L.COLORS = "Farben"
L.FULL_COLOR = "Voll"
L.EMPTY_COLOR = "Leer"
L.PARTIAL_COLOR = "Lädt auf"

L.RESET_POS = "Position zurücksetzen"
L.RESET_COLORS = "Farben zurücksetzen"
L.RESET_COLORS_TT = "Setzt alle Farben auf die Standardwerte des Designs zurück."

L.HINT_DRAG = "Tipp: Leiste per Drag verschieben (nur wenn nicht gesperrt)."

L.THEME_CLASSIC = "Klassische Segmente"
L.THEME_MINIMAL = "Minimal Flat"
L.THEME_ICE = "Ice Glow"
L.THEME_DARK = "Dunkel & Clean"
L.THEME_ORBS = "Runen-Orbs"
L.THEME_SINGLE = "Einzelbalken"
L.THEME_HEAT = "Hitze-Verlauf"

-- Optional (für IceHUD-/Blizzard-ähnliches Theme)
L.THEME_ICEHUD = "Blizzard-Vigor"
