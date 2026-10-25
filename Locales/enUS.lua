-- 기본(영어) 글자. 다른 언어 파일에 없는 키는 이 값이 그대로 쓰인다.
-- 직접 정의하는 글자만 번역한다 (일반 '제작'/'주문 완료'는 블리자드 버튼 글자를 복사하므로 자동 번역됨)
local _, ns = ...

ns.L = {
    SKIP_FORMAT = "%s (No Confirm)",  -- %s = 원래 버튼 글자 (Create/Recraft)
    CRAFT = "Create",
}
