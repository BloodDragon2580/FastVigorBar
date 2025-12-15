local Locale = FastVigorBar.Locale
local L = Locale:NewLocale("zhCN")
if not L then return end

L.ADDON_NAME = "FastVigorBar"
L.SUBTITLE = "极简驭空 / 精力条"

L.VIGOR_LABEL = "精力"

L.ONLY_MOUNTED = "仅骑乘时显示"
L.ONLY_MOUNTED_TT = "启用后，仅在骑乘状态显示。"
L.LOCK_FRAME = "锁定框体"
L.LOCK_FRAME_TT = "启用后无法拖动。"

L.SCALE = "缩放"
L.ALPHA = "透明度"
L.WIDTH = "宽度"
L.HEIGHT = "高度"
L.GAP = "分段间距"

L.FRAME_EDGE = "边框厚度"
L.SEG_EDGE = "分段边框"
L.ORBS_SIZE = "球体大小"

L.SHOW_TEXT = "显示文字（充能）"
L.SHOW_TEXT_TT = "显示当前 / 最大充能。"
L.SHOW_CD = "显示冷却"
L.SHOW_CD_TT = "显示到下一次充能的秒数。"

L.SHOW_EMPTY = "显示空分段"
L.SHOW_EMPTY_TT = "关闭时隐藏空分段。"

L.THEME = "主题"
L.THEME_TT = "选择外观预设。"

L.COLORS = "颜色"
L.FULL_COLOR = "已满"
L.EMPTY_COLOR = "空"
L.PARTIAL_COLOR = "充能中"

L.RESET_POS = "重置位置"
L.RESET_COLORS = "重置颜色"
L.RESET_COLORS_TT = "恢复主题默认颜色。"

L.HINT_DRAG = "提示：解锁后可拖动移动。"

L.THEME_CLASSIC = "经典分段"
L.THEME_MINIMAL = "极简平面"
L.THEME_ICE = "冰霜光晕"
L.THEME_DARK = "深色简洁"
L.THEME_ORBS = "符文球"
L.THEME_SINGLE = "单条"
L.THEME_HEAT = "热度渐变"
L.THEME_ICEHUD = "暴雪精力（Atlas）"
