local Locale = FastVigorBar.Locale
local L = Locale:NewLocale("ptBR")
if not L then return end

L.ADDON_NAME = "FastVigorBar"
L.SUBTITLE = "Barra mínima de Skyriding/Vigor"

L.VIGOR_LABEL = "Vigor"

L.ONLY_MOUNTED = "Somente montado"
L.ONLY_MOUNTED_TT = "Mostra a barra apenas quando estiver montado."
L.LOCK_FRAME = "Travar quadro"
L.LOCK_FRAME_TT = "Impede arrastar a barra."

L.SCALE = "Escala"
L.ALPHA = "Opacidade"
L.WIDTH = "Largura"
L.HEIGHT = "Altura"
L.GAP = "Espaço entre segmentos"

L.FRAME_EDGE = "Espessura da borda (quadro)"
L.SEG_EDGE = "Espessura da borda (segmentos)"
L.ORBS_SIZE = "Tamanho dos orbes"

L.SHOW_TEXT = "Mostrar texto (cargas)"
L.SHOW_TEXT_TT = "Mostra cargas atuais/máx."
L.SHOW_CD = "Mostrar recarga"
L.SHOW_CD_TT = "Mostra segundos até a próxima carga."

L.SHOW_EMPTY = "Mostrar segmentos vazios"
L.SHOW_EMPTY_TT = "Oculta segmentos vazios quando desativado."

L.THEME = "Tema"
L.THEME_TT = "Escolha um preset visual."

L.COLORS = "Cores"
L.FULL_COLOR = "Cheio"
L.EMPTY_COLOR = "Vazio"
L.PARTIAL_COLOR = "Recarregando"

L.RESET_POS = "Redefinir posição"
L.RESET_COLORS = "Redefinir cores"
L.RESET_COLORS_TT = "Restaura as cores padrão do tema."

L.HINT_DRAG = "Dica: arraste para mover (se destravado)."

L.THEME_CLASSIC = "Segmentos clássicos"
L.THEME_MINIMAL = "Minimal plano"
L.THEME_ICE = "Brilho gelo"
L.THEME_DARK = "Escuro limpo"
L.THEME_ORBS = "Orbes rúnicos"
L.THEME_SINGLE = "Barra única"
L.THEME_HEAT = "Gradiente de calor"
L.THEME_ICEHUD = "Vigor Blizzard (Atlas)"
