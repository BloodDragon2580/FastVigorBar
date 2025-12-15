-- locales/Locales.lua
FastVigorBar = FastVigorBar or {}
FastVigorBar.L = FastVigorBar.L or {}
FastVigorBar.Locale = FastVigorBar.Locale or {}

local Locale = FastVigorBar.Locale
local L = FastVigorBar.L

function Locale:NewLocale(locale)
	if GetLocale() ~= locale then return nil end
	return L
end

function Locale:Finalize()
	-- Fallback: wenn Keys fehlen, nutze enUS (falls vorhanden), sonst Key selbst
	local en = FastVigorBar.L_enUS or {}
	for k, v in pairs(en) do
		if L[k] == nil then L[k] = v end
	end
	setmetatable(L, {
		__index = function(_, key)
			return en[key] or tostring(key)
		end
	})
end
