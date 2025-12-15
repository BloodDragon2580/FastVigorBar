local Locale = FastVigorBar.Locale
local L = Locale:NewLocale("zhTW")
if not L then return end

L.ADDON_NAME = "FastVigorBar"
L.SUBTITLE = "極簡馭空 / 精力條"

L.VIGOR_LABEL = "精力"

L.ONLY_MOUNTED = "僅騎乘時顯示"
L.ONLY_MOUNTED_TT = "啟用後，只在騎乘狀態顯示。"
L.LOCK_FRAME = "鎖定框架"
L.LOCK_FRAME_TT = "啟用後無法拖曳。"

L.SCALE = "縮放"
L.ALPHA = "透明度"
L.WIDTH = "寬度"
L.HEIGHT = "高度"
L.GAP = "區塊間距"

L.FRAME_EDGE = "邊框厚度"
L.SEG_EDGE = "分段邊框"
L.ORBS_SIZE = "球體大小"

L.SHOW_TEXT = "顯示文字（充能）"
L.SHOW_TEXT_TT = "顯示目前 / 最大充能。"
L.SHOW_CD = "顯示冷卻"
L.SHOW_CD_TT = "顯示到下一次充能的秒數。"

L.SHOW_EMPTY = "顯示空區塊"
L.SHOW_EMPTY_TT = "關閉時隱藏空區塊。"

L.THEME = "主題"
L.THEME_TT = "選擇外觀預設。"

L.COLORS = "顏色"
L.FULL_COLOR = "已滿"
L.EMPTY_COLOR = "空"
L.PARTIAL_COLOR = "充能中"

L.RESET_POS = "重置位置"
L.RESET_COLORS = "重置顏色"
L.RESET_COLORS_TT = "恢復主題預設顏色。"

L.HINT_DRAG = "提示：解鎖後可拖曳移動。"

L.THEME_CLASSIC = "經典分段"
L.THEME_MINIMAL = "極簡平面"
L.THEME_ICE = "冰霜光暈"
L.THEME_DARK = "深色簡潔"
L.THEME_ORBS = "符文球"
L.THEME_SINGLE = "單條"
L.THEME_HEAT = "熱度漸層"
L.THEME_ICEHUD = "暴雪精力（Atlas）"
