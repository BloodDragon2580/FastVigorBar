local Locale = FastVigorBar.Locale
local L = Locale:NewLocale("ruRU")
if not L then return end

L.ADDON_NAME = "FastVigorBar"
L.SUBTITLE = "Минимальная полоса Skyriding/Энергии"

L.VIGOR_LABEL = "Энергия"

L.ONLY_MOUNTED = "Только верхом"
L.ONLY_MOUNTED_TT = "Показывать полосу только когда вы на транспорте."
L.LOCK_FRAME = "Закрепить окно"
L.LOCK_FRAME_TT = "Запретить перетаскивание полосы."

L.SCALE = "Масштаб"
L.ALPHA = "Прозрачность"
L.WIDTH = "Ширина"
L.HEIGHT = "Высота"
L.GAP = "Промежуток между сегментами"

L.FRAME_EDGE = "Толщина рамки"
L.SEG_EDGE = "Толщина сегментов"
L.ORBS_SIZE = "Размер сфер"

L.SHOW_TEXT = "Показывать текст (заряды)"
L.SHOW_TEXT_TT = "Показывает текущие/макс. заряды."
L.SHOW_CD = "Показывать перезарядку"
L.SHOW_CD_TT = "Показывает секунды до следующего заряда."

L.SHOW_EMPTY = "Показывать пустые сегменты"
L.SHOW_EMPTY_TT = "Скрывает пустые сегменты при отключении."

L.THEME = "Тема"
L.THEME_TT = "Выберите визуальный пресет."

L.COLORS = "Цвета"
L.FULL_COLOR = "Полный"
L.EMPTY_COLOR = "Пусто"
L.PARTIAL_COLOR = "Восстановление"

L.RESET_POS = "Сбросить позицию"
L.RESET_COLORS = "Сбросить цвета"
L.RESET_COLORS_TT = "Сбрасывает пользовательские цвета к значениям темы."

L.HINT_DRAG = "Совет: перетащите, чтобы переместить (если не закреплено)."

L.THEME_CLASSIC = "Классические сегменты"
L.THEME_MINIMAL = "Минимализм"
L.THEME_ICE = "Ледяное свечение"
L.THEME_DARK = "Темная чистая"
L.THEME_ORBS = "Рунические сферы"
L.THEME_SINGLE = "Одна полоса"
L.THEME_HEAT = "Тепловой градиент"
L.THEME_ICEHUD = "Энергия Blizzard (Atlas)"
