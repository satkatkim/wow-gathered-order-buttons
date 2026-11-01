if GetLocale() ~= "koKR" then return end

local _, ns = ...
local L = ns.L

L.SKIP_FORMAT = "%s (확인 생략)"  -- %s = 원래 버튼 글자 (제작/재제작)
L.CRAFT = "제작"
L.COMPLETE_HINT = "아래 버튼을 눌러 주문을 완료하세요."
L.RESET_DONE = "GatheredOrderButtons: 패널 위치, 최소화 상태, 투명도를 초기화했습니다."
L.SLASH_USAGE = "GatheredOrderButtons: /gob reset (또는 /gatheredorderbuttons reset) - 패널 위치, 최소화 상태, 투명도 초기화"
