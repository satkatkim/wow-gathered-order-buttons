-- 주문 제작 화면에서 '주문 취소' 버튼(ReleaseOrderButton) 아래 줄에 일반 '제작' 버튼과
-- '제작 (확인 생략)' 버튼을 나란히 추가한다.
-- 원래 '제작' 버튼(CreateButton)은 그대로 두고, 새 버튼은 원래 버튼을 대신 눌러준 뒤
-- 그 클릭으로 새로 뜬 확인 팝업을 자동으로 수락한다.
-- 제작 완료 후에는 '주문 완료' 버튼을 제작 버튼 줄과 같은 자리에 복제해 보여준다.
-- 번역 글자는 Locales/*.lua 에서 채운다 (.toc에서 이 파일보다 먼저 로드됨)
local _, ns = ...
local L = ns.L
local OFFSET_Y = -4
local TEXT_PADDING = 32  -- 버튼 폭 = 글자 폭 + 이 값 (좌우 여백 합)
local GAP_X = 4
local MAX_POPUPS = STATICPOPUP_NUMDIALOGS or 4

-- 블리자드 StaticPopup 구조가 패치마다 바뀌어 왔으므로 구버전/신버전 모두 대응
local function GetAcceptButton(dialog)
    if dialog.GetButton1 then return dialog:GetButton1() end
    if dialog.ButtonContainer and dialog.ButtonContainer.Button1 then return dialog.ButtonContainer.Button1 end
    return dialog.button1
end

local function GetVisiblePopups()
    local visible = {}
    for i = 1, MAX_POPUPS do
        local dialog = _G["StaticPopup" .. i]
        if dialog and dialog:IsShown() then
            visible[dialog] = true
        end
    end
    return visible
end

local function AcceptNewPopups(before)
    for i = 1, MAX_POPUPS do
        local dialog = _G["StaticPopup" .. i]
        if dialog and dialog:IsShown() and not before[dialog] then
            local accept = GetAcceptButton(dialog)
            if accept and accept:IsShown() and accept:IsEnabled() then
                accept:Click()
            end
        end
    end
end

-- 원래 버튼의 툴팁(제작 불가 사유 등)과 마우스 이탈 처리를 그대로 사용한다 (툴팁은 원래 버튼 위치에 뜸)
local function MirrorTooltip(dst, src)
    dst:SetScript("OnEnter", function()
        local onEnter = src:GetScript("OnEnter")
        if onEnter then onEnter(src) end
    end)
    dst:SetScript("OnLeave", function()
        local onLeave = src:GetScript("OnLeave")
        if onLeave then onLeave(src) else GameTooltip_Hide() end
    end)
end

local function Init()
    local ov = ProfessionsFrame and ProfessionsFrame.OrdersPage and ProfessionsFrame.OrdersPage.OrderView
    local create = ov and ov.CreateButton
    local release = ov and ov.OrderInfo and ov.OrderInfo.ReleaseOrderButton
    local start = release and ov.OrderInfo.StartOrderButton
    -- 패치로 블리자드 프레임 이름이 바뀌면 에러 대신 조용히 비활성화
    if not (create and release) then return end

    -- '주문 취소' 버튼을 '주문 시작' 버튼(주문 시작 후에는 숨겨짐) 자리로 올린다.
    -- 아래의 새 버튼들은 '주문 취소'에 붙어 있으므로 함께 따라 올라간다.
    local function MoveReleaseButton()
        if not start then return end
        release:ClearAllPoints()
        release:SetPoint("CENTER", start, "CENTER")
    end
    MoveReleaseButton()
    ov:HookScript("OnShow", MoveReleaseButton)

    -- '주문 취소' 바로 아래 한 줄을 차지하는 보이지 않는 컨테이너.
    -- x는 '주문 취소'와 같고 y만 한 줄 아래이므로, 버튼들은 이 줄 안에서 배치한다.
    local row = CreateFrame("Frame", nil, ov.OrderInfo)
    row:SetSize(release:GetSize())
    row:SetPoint("TOP", release, "BOTTOM", 0, OFFSET_Y)

    -- 일반 '제작' 버튼 (왼쪽, 확인 팝업 그대로 뜸)
    local normalBtn = CreateFrame("Button", "GatheredOrderButtonsNormal", row, "UIPanelButtonTemplate")
    normalBtn:Hide()
    normalBtn:SetScript("OnClick", function() create:Click() end)
    MirrorTooltip(normalBtn, create)

    -- '제작 (확인 생략)' 버튼 (오른쪽)
    local btn = CreateFrame("Button", "GatheredOrderButtonsSkip", row, "UIPanelButtonTemplate")
    -- 확인 팝업을 건너뛰는 버튼임을 구분할 수 있도록 글자를 주황색으로 (마우스 오버 시 밝은 주황, 비활성 시 기본 회색)
    local orangeFont = CreateFont("GatheredOrderButtonsOrangeFont")
    orangeFont:CopyFontObject(GameFontNormal)
    orangeFont:SetTextColor(1, 0.35, 0.1)
    local orangeHighlightFont = CreateFont("GatheredOrderButtonsOrangeHighlightFont")
    orangeHighlightFont:CopyFontObject(GameFontHighlight)
    orangeHighlightFont:SetTextColor(1, 0.62, 0.45)
    btn:SetNormalFontObject(orangeFont)
    btn:SetHighlightFontObject(orangeHighlightFont)
    btn:SetPoint("LEFT", normalBtn, "RIGHT", GAP_X, 0)
    btn:Hide()
    btn:SetScript("OnClick", function()
        -- 같은 하드웨어 클릭 이벤트 안에서 제작과 팝업 수락을 모두 처리한다
        local before = GetVisiblePopups()
        create:Click()
        AcceptNewPopups(before)
    end)
    MirrorTooltip(btn, create)

    -- 버튼 글자를 원래 버튼 글자(제작/재제작 등)에 맞추고, 폭을 글자 길이에 맞춘 뒤
    -- 두 버튼 묶음을 줄 가운데에 둔다 (폭이 글자 길이에 맞춰지므로 '주문 취소'와 다를 수 있음)
    local function LayoutRow(normalText)
        normalBtn:SetText(normalText)
        btn:SetText(L.SKIP_FORMAT:format(normalText))
        normalBtn:SetSize(normalBtn:GetTextWidth() + TEXT_PADDING, row:GetHeight())
        btn:SetSize(btn:GetTextWidth() + TEXT_PADDING, row:GetHeight())
        local totalWidth = normalBtn:GetWidth() + GAP_X + btn:GetWidth()
        normalBtn:ClearAllPoints()
        normalBtn:SetPoint("LEFT", row, "CENTER", -totalWidth / 2, 0)
    end
    local normalText = create:GetText() or L.CRAFT
    LayoutRow(normalText)

    -- 제작 완료 후 오른쪽 아래에 뜨는 '주문 완료' 버튼(CompleteOrderButton)을
    -- '제작' 버튼 줄 전체(완료 화면에서는 숨겨져 있음)에 복제해서
    -- 제작 후 마우스를 옮기지 않고 바로 누를 수 있게 한다
    local complete = ov.CompleteOrderButton
    local completeBtn
    if complete then
        completeBtn = CreateFrame("Button", "GatheredOrderButtonsComplete", ov.OrderInfo, "UIPanelButtonTemplate")
        completeBtn:SetAllPoints(row)
        completeBtn:Hide()
        completeBtn:SetScript("OnClick", function() complete:Click() end)
        MirrorTooltip(completeBtn, complete)
    end

    -- 표시 여부/활성 상태/글자를 원래 버튼들과 동기화 (OrderView가 보일 때만 동작).
    -- 글자 변경은 레이아웃을 다시 계산하므로 실제로 바뀌었을 때만 적용한다.
    local completeText
    local sync = CreateFrame("Frame", nil, ov)
    sync:SetScript("OnUpdate", function()
        local shown = create:IsShown() and release:IsShown()
        normalBtn:SetShown(shown)
        btn:SetShown(shown)
        if shown then
            local enabled = create:IsEnabled()
            normalBtn:SetEnabled(enabled)
            btn:SetEnabled(enabled)
            local text = create:GetText()
            if text and text ~= normalText then
                normalText = text
                LayoutRow(text)
            end
        end

        if completeBtn then
            local completeShown = complete:IsShown() and not release:IsShown()
            completeBtn:SetShown(completeShown)
            if completeShown then
                completeBtn:SetEnabled(complete:IsEnabled())
                local text = complete:GetText()
                if text ~= completeText then
                    completeText = text
                    completeBtn:SetText(text)
                end
            end
        end
    end)
end

if C_AddOns.IsAddOnLoaded("Blizzard_Professions") then
    Init()
else
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, _, name)
        if name == "Blizzard_Professions" then
            Init()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end
