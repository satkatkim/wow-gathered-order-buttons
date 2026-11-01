-- 주문 제작 화면 위에 떠 있는 버튼 패널. 버튼은 모두 원래 블리자드 버튼을 대신 눌러주는 복제본이다.
-- 버튼은 왼쪽 정렬된 고정 칸에 진행 단계별로 바뀌어 나타나므로, 주문 하나를 마우스 이동 없이 처리할 수 있다.
--   1줄: 뒤로 → 주문 취소 → (제작 후) 주문 완료 안내 문구
--   2줄: 주문 시작 → 제작 (확인 생략) | 제작 → 주문 완료
-- 위치, 최소화 상태, 투명도는 GatheredOrderButtonsDB에 저장되며 '/gob reset'(또는 '/gatheredorderbuttons reset')으로 초기화한다.
-- 번역 글자는 Locales/*.lua 에서 채운다.
local _, ns = ...
local L = ns.L
local MAX_POPUPS = STATICPOPUP_NUMDIALOGS or 4
local PADDING = 10
local ROW_GAP = 6
local GAP_X = 4
local TEXT_PADDING = 32
local BUTTON_HEIGHT = 22
local MIN_BUTTON_WIDTH = 90
local HINT_INDENT_X = 4  -- 주문 완료 안내 문구의 왼쪽 들여쓰기 (대략 공백 한 칸)
local INSET = 4  -- 패널 테두리 두께
local TITLE_HEIGHT = 22
local CORNER_BUTTON_SIZE = 20  -- 제목 줄의 투명도/최소화/닫기 버튼 크기
local CORNER_GAP = 2  -- 제목 줄 버튼 사이 간격
-- 투명도 버튼: 최소화 버튼 그림(금테 + 화살표) 위에, 눈 버튼 그림의 테두리를 잘라낸 안쪽만 얹어
-- 닫기/최소화 버튼과 같은 금테 디자인으로 만든다.
local EYE_BUTTON = "128-redbutton-visibilityon"
local EYE_CROP = 0.25  -- 눈 그림에서 각 변을 잘라낼 비율 (원래 테두리 제거)
local EYE_INSET = 0.22  -- 눈 그림을 버튼 각 변에서 띄울 비율 (금테가 보이도록)
local BAR_CLOSE_SIZE = 14  -- 투명도 막대 닫기 버튼(투명 배경에 빨간 X) 크기
local BAR_CLOSE_GAP = 2  -- 닫기 버튼 오른쪽 여백. 값(%) 글자와 닫기 버튼 사이는 이 값의 두 배
local MIN_ALPHA, MAX_ALPHA, ALPHA_STEPS = 0.1, 1, 9  -- 투명도 막대: 0.1 ~ 1, 0.1 간격
local ALPHA_BAR_HEIGHT = 30
local ALPHA_BAR_WIDTH_RATIO = 0.6  -- 투명도 막대 폭 = 패널 폭의 60%
local ALPHA_SLIDER_SCALE = 0.8  -- 투명도 막대 안 슬라이더 크기 배율
local ALPHA_TEXT_WIDTH = 34  -- 슬라이더 오른쪽 '100%' 글자 자리
local CONTENT_TOP = INSET + TITLE_HEIGHT  -- 버튼 영역이 시작되는 위치 (패널 위쪽 기준)
local EXPANDED_HEIGHT = CONTENT_TOP + PADDING * 2 + 2 * BUTTON_HEIGHT + ROW_GAP
local MINIMIZED_HEIGHT = CONTENT_TOP + INSET
-- 처음 위치: 오른쪽 제작 정보 영역 왼쪽 위 기준 (한 번 옮기면 저장된 위치를 씀)
local DEFAULT_X, DEFAULT_Y = 255, -27

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

-- 원래 버튼의 툴팁(제작 불가 사유 등)을 그대로 쓰되, 패널을 어디로 옮겨도 보이도록 복제 버튼 오른쪽 위에 띄운다
-- (바로 위는 1줄 버튼을, 아래는 마우스 포인터에 가리므로 오른쪽 위)
local function MirrorTooltip(dst, src)
    dst:SetScript("OnEnter", function()
        local onEnter = src:GetScript("OnEnter")
        if onEnter then onEnter(src) end
        if GameTooltip:IsShown() and GameTooltip:GetOwner() == src then
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("BOTTOMLEFT", dst, "TOPRIGHT")
        end
    end)
    dst:SetScript("OnLeave", function()
        local onLeave = src:GetScript("OnLeave")
        if onLeave then onLeave(src) else GameTooltip_Hide() end
    end)
end

-- '제작 (확인 생략)' 버튼을 구분하는 주황색 글자 (마우스 오버 시 밝은 주황, 비활성 시 기본 회색)
local orangeFont = CreateFont("GatheredOrderButtonsOrangeFont")
orangeFont:CopyFontObject(GameFontNormal)
orangeFont:SetTextColor(1, 0.35, 0.1)
local orangeHighlightFont = CreateFont("GatheredOrderButtonsOrangeHighlightFont")
orangeHighlightFont:CopyFontObject(GameFontHighlight)
orangeHighlightFont:SetTextColor(1, 0.62, 0.45)

-- SavedVariables는 파일 실행 뒤에 로드되므로, 쓸 때마다 이 함수로 꺼낸다
local function DB()
    GatheredOrderButtonsDB = GatheredOrderButtonsDB or {}
    return GatheredOrderButtonsDB
end

-- 초기화된 저장값을 패널에 바로 적용하는 함수 (패널을 만들 때 채움, '/gob reset'에서 사용)
local resetPanel

local function NewButton(parent, onClick, src)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetHeight(BUTTON_HEIGHT)
    -- 비활성 상태에서도 툴팁(제작 불가 사유 등)이 뜨도록 마우스 진입/이탈 이벤트를 받는다 (원래 버튼과 같은 설정)
    b:SetMotionScriptsWhileDisabled(true)
    b:Hide()
    b:SetScript("OnClick", onClick)
    MirrorTooltip(b, src)
    return b
end

-- 글자가 실제로 바뀌었을 때만 글자와 폭을 다시 맞추고, 바뀌었는지 돌려준다
local function SetTextFit(b, text)
    if not text or text == b:GetText() then return false end
    b:SetText(text)
    b:SetWidth(math.max(MIN_BUTTON_WIDTH, b:GetTextWidth() + TEXT_PADDING))
    return true
end

local function CreatePanel(ov)
    local info = ov.OrderInfo
    local back, start, release = info.BackButton, info.StartOrderButton, info.ReleaseOrderButton
    local create, complete = ov.CreateButton, ov.CompleteOrderButton
    if not (back and start and release and create and complete) then return end

    local panel = CreateFrame("Frame", "GatheredOrderButtonsPanel", ov, "BackdropTemplate")
    -- 블리자드가 '고객 참고 사항' 입력칸을 HIGH strata로 띄워 두었으므로, 그 위에서도 클릭되도록 패널도 HIGH로 올린다.
    -- (이 때문에 가방 등 MEDIUM strata의 다른 창보다도 위에 그려진다)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(ov:GetFrameLevel() + 100)
    panel:SetClampedToScreen(true)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = INSET, right = INSET, top = INSET, bottom = INSET },
    })
    panel:SetBackdropColor(0, 0, 0, 0.5)

    -- 버튼이 없는 빈 곳(테두리 안쪽 여백)을 끌어서 옮긴다
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    -- 끄는 도중 주문 화면이 닫혀도 마우스를 계속 따라다니지 않게 이동을 끝낸다
    panel:SetScript("OnHide", panel.StopMovingOrSizing)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- 위치는 직접 저장하므로 블리자드 레이아웃 캐시에는 남기지 않는다
        self:SetUserPlaced(false)
        -- 최소화/펼치기로 높이가 바뀌어도 제목 줄이 제자리에 있도록 왼쪽 위 모서리 기준으로 저장한다
        local left, top = self:GetLeft(), self:GetTop()
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
        DB().panelPoint = { "TOPLEFT", "BOTTOMLEFT", left, top }
    end)

    -- 제목 줄: 반투명 띠, 왼쪽에 애드온 이름, 오른쪽에 투명도/최소화/닫기 버튼.
    -- 띠는 마우스를 받지 않으므로 끌면 패널이 옮겨진다.
    local titleBar = CreateFrame("Frame", nil, panel)
    titleBar:SetPoint("TOPLEFT", INSET, -INSET)
    titleBar:SetPoint("TOPRIGHT", -INSET, -INSET)
    titleBar:SetHeight(TITLE_HEIGHT)
    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints()
    titleBg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
    -- 애드온 이름. 아래 버튼들의 왼쪽 끝(PADDING)에 맞춘다
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", PADDING - INSET, 0)
    title:SetText("GatheredOrderButtons")

    local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeBtn:SetSize(CORNER_BUTTON_SIZE, CORNER_BUTTON_SIZE)
    closeBtn:SetPoint("RIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function() panel:Hide() end)
    -- 패널은 주문 화면(ov)의 자식이므로, 닫은 뒤 주문 화면을 다시 열 때 다시 보여준다
    ov:HookScript("OnShow", function() panel:Show() end)

    -- 최소화 버튼 그림: 블리자드 창 접기/펼치기 아이콘(atlas)을 쓰고, 없으면 글자로 대신한다
    local minBtn = CreateFrame("Button", nil, titleBar)
    minBtn:SetSize(CORNER_BUTTON_SIZE, CORNER_BUTTON_SIZE)
    minBtn:SetPoint("RIGHT", closeBtn, "LEFT", -CORNER_GAP, 0)
    minBtn:SetHighlightAtlas("RedButton-Highlight", "ADD")
    local function SetMinimizeIcon(minimized)
        local atlas = minimized and "RedButton-Expand" or "RedButton-Condense"
        if C_Texture.GetAtlasInfo(atlas) then
            minBtn:SetNormalAtlas(atlas)
            minBtn:SetPushedAtlas(atlas .. "-Pressed")
        else
            minBtn:SetNormalFontObject(GameFontNormal)
            minBtn:SetText(minimized and "+" or "-")
        end
    end

    -- 투명도 막대: 패널 바로 위 오른쪽에 붙는 작은 창 (폭은 패널의 ALPHA_BAR_WIDTH_RATIO). 패널 전체(버튼, 글자, 배경)의 투명도를 조절한다.
    -- 막대 자체는 패널 투명도의 영향을 받지 않아 항상 또렷하게 보인다.
    local alphaBar = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    alphaBar:SetIgnoreParentAlpha(true)
    alphaBar:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT")  -- 폭은 Layout에서 패널 폭에 맞춘다
    alphaBar:SetHeight(ALPHA_BAR_HEIGHT)
    alphaBar:SetBackdrop(panel:GetBackdrop())
    alphaBar:SetBackdropColor(0, 0, 0, 0.85)
    alphaBar:EnableMouse(true)
    alphaBar:Hide()

    local slider = CreateFrame("Frame", nil, alphaBar, "MinimalSliderWithSteppersTemplate")
    slider:SetScale(ALPHA_SLIDER_SCALE)
    slider:SetPoint("LEFT", INSET, 0)
    -- 오른쪽에 막대 닫기 버튼(앞뒤 여백 포함)과 '100%' 글자 자리를 남긴다.
    -- 슬라이더만 배율이 달라서, 막대 단위인 닫기 버튼 자리는 배율로 나눠 맞춘다.
    local closeArea = INSET + BAR_CLOSE_GAP + BAR_CLOSE_SIZE + BAR_CLOSE_GAP * 2
    slider:SetPoint("RIGHT", -closeArea / ALPHA_SLIDER_SCALE - ALPHA_TEXT_WIDTH, 0)

    local closeBar = CreateFrame("Button", nil, alphaBar)
    closeBar:SetSize(BAR_CLOSE_SIZE, BAR_CLOSE_SIZE)
    closeBar:SetPoint("RIGHT", -INSET - BAR_CLOSE_GAP, 0)
    closeBar:SetNormalAtlas("common-icon-redx")
    closeBar:SetHighlightAtlas("common-icon-redx", "ADD")
    closeBar:SetScript("OnClick", function() alphaBar:Hide() end)

    -- 값 글자는 원래 오른쪽 화살표에서 25만큼 떨어져 막대 밖으로 나가므로, 닫기 버튼 바로 왼쪽에 오른쪽 정렬로 둔다
    slider.RightText:ClearAllPoints()
    slider.RightText:SetPoint("RIGHT", closeBar, "LEFT", -BAR_CLOSE_GAP * 2, 0)
    slider.RightText:SetJustifyH("RIGHT")
    local function SetPanelAlpha(alpha)
        alpha = math.floor(alpha * 10 + 0.5) / 10  -- 0.1 단위로 맞춘다
        panel:SetAlpha(alpha)
        DB().alpha = alpha
    end
    slider:Init(DB().alpha or MAX_ALPHA, MIN_ALPHA, MAX_ALPHA, ALPHA_STEPS, {
        [MinimalSliderWithSteppersMixin.Label.Right] = function(value)
            return ("%d%%"):format(math.floor(value * 100 + 0.5))
        end,
    })
    slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
        SetPanelAlpha(value)
    end, alphaBar)

    -- 투명도 버튼: 누를 때마다 투명도 막대를 열고 닫는다
    local alphaBtn = CreateFrame("Button", nil, titleBar)
    alphaBtn:SetSize(CORNER_BUTTON_SIZE, CORNER_BUTTON_SIZE)
    alphaBtn:SetPoint("RIGHT", minBtn, "LEFT", -CORNER_GAP, 0)
    alphaBtn:SetNormalAtlas("RedButton-Condense")
    alphaBtn:SetPushedAtlas("RedButton-Condense-Pressed")
    alphaBtn:SetHighlightAtlas("RedButton-Highlight", "ADD")
    local eyeInfo = C_Texture.GetAtlasInfo(EYE_BUTTON)
    if eyeInfo then
        local l, r, t, b = eyeInfo.leftTexCoord, eyeInfo.rightTexCoord, eyeInfo.topTexCoord, eyeInfo.bottomTexCoord
        local dx, dy = (r - l) * EYE_CROP, (b - t) * EYE_CROP
        local eye = alphaBtn:CreateTexture(nil, "OVERLAY")  -- 버튼 배경(Normal/Pushed) 위에 그려 화살표를 가린다
        eye:SetTexture(eyeInfo.file or eyeInfo.filename)
        eye:SetTexCoord(l + dx, r - dx, t + dy, b - dy)
        local pad = CORNER_BUTTON_SIZE * EYE_INSET
        eye:SetPoint("TOPLEFT", pad, -pad)
        eye:SetPoint("BOTTOMRIGHT", -pad, pad)
    end
    alphaBtn:SetScript("OnClick", function() alphaBar:SetShown(not alphaBar:IsShown()) end)

    -- 버튼 영역. 최소화하면 이 프레임만 숨기고 패널은 제목 줄 높이로 줄인다
    local content = CreateFrame("Frame", nil, panel)
    content:SetAllPoints()

    local function SetMinimized(minimized)
        content:SetShown(not minimized)
        panel:SetHeight(minimized and MINIMIZED_HEIGHT or EXPANDED_HEIGHT)
        SetMinimizeIcon(minimized)
    end
    minBtn:SetScript("OnClick", function()
        DB().minimized = not DB().minimized
        SetMinimized(DB().minimized)
    end)

    -- 저장된 최소화 상태/투명도/위치를 적용한다 (저장값이 없으면 기본값)
    local function ApplySaved()
        SetMinimized(DB().minimized)
        local alpha = DB().alpha or MAX_ALPHA
        panel:SetAlpha(alpha)
        slider:SetValue(alpha)  -- 막대 위치도 맞춘다
        local saved = DB().panelPoint
        panel:ClearAllPoints()
        if saved then
            panel:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4])
        else
            panel:SetPoint("TOPLEFT", ov.OrderDetails or ov, "TOPLEFT", DEFAULT_X, DEFAULT_Y)
        end
    end
    -- SavedVariables는 파일 실행 뒤에 로드되므로 패널이 보일 때마다 적용한다
    panel:SetScript("OnShow", ApplySaved)
    resetPanel = function()
        alphaBar:Hide()
        ApplySaved()
        -- 닫아 둔 상태에서 초기화하면 주문 화면이 열려 있을 때 다시 보여준다
        if ov:IsVisible() then panel:Show() end
    end
    -- 이미 주문 화면이 열린 상태에서 만들어지면 OnShow가 오지 않으므로 바로 한 번 배치
    if panel:IsVisible() then ApplySaved() end

    -- 줄마다 칸 하나. 같은 칸의 버튼들은 상황에 따라 하나만(또는 제작 두 개만) 보인다
    local slots = {}
    for i = 1, 2 do
        local slot = CreateFrame("Frame", nil, content)
        local y = -CONTENT_TOP - PADDING - (i - 1) * (BUTTON_HEIGHT + ROW_GAP)
        slot:SetHeight(BUTTON_HEIGHT)
        slot:SetPoint("TOPLEFT", PADDING, y)
        slot:SetPoint("TOPRIGHT", -PADDING, y)
        slots[i] = slot
    end

    local backBtn = NewButton(slots[1], function() back:Click() end, back)
    backBtn:SetPoint("LEFT")
    local releaseBtn = NewButton(slots[1], function() release:Click() end, release)
    releaseBtn:SetPoint("LEFT")
    local startBtn = NewButton(slots[2], function() start:Click() end, start)
    startBtn:SetPoint("LEFT")

    local normalBtn = NewButton(slots[2], function() create:Click() end, create)
    local skipBtn = NewButton(slots[2], function()
        -- 같은 하드웨어 클릭 이벤트 안에서 제작과 팝업 수락을 모두 처리한다
        local before = GetVisiblePopups()
        create:Click()
        AcceptNewPopups(before)
    end, create)
    skipBtn:SetNormalFontObject(orangeFont)
    skipBtn:SetHighlightFontObject(orangeHighlightFont)
    skipBtn:SetPoint("LEFT")
    normalBtn:SetPoint("LEFT", skipBtn, "RIGHT", GAP_X, 0)
    local completeBtn = NewButton(slots[2], function() complete:Click() end, complete)
    completeBtn:SetPoint("LEFT")

    -- 제작 후에는 1줄이 비므로, 아래 '주문 완료' 버튼을 누르라는 안내 문구를 보여준다
    local completeHint = slots[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    -- 아래 '주문 완료' 버튼과 왼쪽 끝을 맞추되, 버튼 테두리가 안쪽에 그려지므로 글자를 조금 띄운다
    completeHint:SetPoint("LEFT", HINT_INDENT_X, 0)
    completeHint:SetText(L.COMPLETE_HINT)
    completeHint:Hide()

    -- 버튼 폭이 바뀌면 패널 폭을 가장 넓은 줄에 맞춘다
    local function Layout()
        local craftWidth = skipBtn:GetWidth() + GAP_X + normalBtn:GetWidth()
        local widest = math.max(craftWidth, backBtn:GetWidth(), startBtn:GetWidth(),
            releaseBtn:GetWidth(), completeBtn:GetWidth(), completeHint:GetStringWidth() + HINT_INDENT_X)
        -- 제목 줄에는 애드온 이름 오른쪽에 투명도/최소화/닫기 버튼 자리가 필요하다
        local titleWidth = title:GetStringWidth() + GAP_X + (CORNER_BUTTON_SIZE + CORNER_GAP) * 3
        local panelWidth = math.max(widest + PADDING * 2, titleWidth + PADDING + INSET)
        panel:SetWidth(panelWidth)
        alphaBar:SetWidth(panelWidth * ALPHA_BAR_WIDTH_RATIO)
    end

    -- 원래 버튼들의 표시 여부/활성 상태/글자를 따라간다 (버튼 영역이 보일 때만 동작)
    local function Mirror(dst, src, shown)
        dst:SetShown(shown)
        if not shown then return false end
        dst:SetEnabled(src:IsEnabled())
        return SetTextFit(dst, src:GetText())
    end

    local sync = CreateFrame("Frame", nil, content)
    sync:SetScript("OnUpdate", function()
        -- '뒤로'와 '주문 취소'는 같은 칸이므로 겹치지 않게 '주문 취소'를 우선한다
        local changed = Mirror(backBtn, back, back:IsShown() and not release:IsShown())
        changed = Mirror(startBtn, start, start:IsShown()) or changed
        changed = Mirror(releaseBtn, release, release:IsShown()) or changed
        changed = Mirror(completeBtn, complete, complete:IsShown() and not release:IsShown()) or changed
        completeHint:SetShown(completeBtn:IsShown() and not backBtn:IsShown())

        local craftShown = create:IsShown() and release:IsShown()
        if Mirror(normalBtn, create, craftShown) then
            SetTextFit(skipBtn, L.SKIP_FORMAT:format(normalBtn:GetText()))
            changed = true
        end
        skipBtn:SetShown(craftShown)
        skipBtn:SetEnabled(normalBtn:IsEnabled())

        if changed then Layout() end
    end)

    SetTextFit(normalBtn, create:GetText() or L.CRAFT)
    SetTextFit(skipBtn, L.SKIP_FORMAT:format(normalBtn:GetText()))
    Layout()
end

local function Init()
    local ov = ProfessionsFrame and ProfessionsFrame.OrdersPage and ProfessionsFrame.OrdersPage.OrderView
    -- 패치로 블리자드 프레임 이름이 바뀌면 에러 대신 조용히 비활성화
    if ov and ov.OrderInfo then CreatePanel(ov) end
end

-- '/gob reset' (또는 '/gatheredorderbuttons reset'): 패널 위치, 최소화 상태, 투명도를 처음 상태로 되돌린다
SLASH_GATHEREDORDERBUTTONS1 = "/gob"
SLASH_GATHEREDORDERBUTTONS2 = "/gatheredorderbuttons"
SlashCmdList.GATHEREDORDERBUTTONS = function(msg)
    if strtrim(msg):lower() == "reset" then
        wipe(DB())
        if resetPanel then resetPanel() end
        print(L.RESET_DONE)
    else
        print(L.SLASH_USAGE)
    end
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
