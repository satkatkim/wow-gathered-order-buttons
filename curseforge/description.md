# Summary (one line)

Gathers all crafting order buttons into one movable panel, so you can start, craft and complete orders without moving your mouse.

---

# Description

## GatheredOrderButtons

I made this addon because moving my mouse back and forth between the Start Order, Create and Complete Order buttons while filling NPC patron orders got too tedious. **GatheredOrderButtons** gathers all the buttons you need into one movable panel, so you can finish orders with barely any mouse movement. Patron orders are the main focus, but it works the same for every other order type.

### Features

- **All order buttons in one movable panel.** Drag it anywhere; its position is saved.
- **Row 1:** Back, which becomes Release Order once the order is started.
- **Row 2 changes from Start Order → Create (No Confirm) | Create → Complete Order as you go**, so the next button is always under your mouse.
  - **Create:** same as the default Create button, confirmation popup included.
  - **Create (No Confirm):** for faster crafting. Crafts and automatically accepts the confirmation popup.
- **Title bar buttons:** opacity (10–100%), minimize and close. A closed panel reappears the next time you open an order.
- Tooltips from the original buttons (for example, why crafting is disabled) are shown on the panel buttons.
- The original Blizzard buttons stay where they are. This addon only adds shortcuts.
- Works with every order type: patron, personal, guild and public orders. Recraft orders are supported too.
- Localized in English and Korean.

### Typical flow

1. Open an order and click **Start Order** in the panel.
2. Click **Create (No Confirm)**, which appears in the same spot.
3. When the craft is done, click **Complete Order**, which also appears in the same spot.

### Slash commands

- `/gob reset` (or `/gatheredorderbuttons reset`): restore the default panel position, minimize state and opacity.

### Important: about "Create (No Confirm)"

**Always check the order details (reagents, quality, commission) before clicking.** Once you click, the craft goes ahead without a second chance to cancel.

**Create (No Confirm)** accepts **any** confirmation popup that appears as a result of that click, not only the usual "use some of your own reagents" prompt.
For example, a warning about using soulbound or expensive reagents is also accepted automatically.
If you want to review a warning, use the plain **Create** button instead.

The auto-accept only happens when you click the button yourself. The addon never crafts or accepts anything on its own.

### Feedback

Bug reports and suggestions are welcome in the comments or the issue tracker.

---

## GatheredOrderButtons (한국어)

NPC 손님 의뢰를 처리하면서 주문 시작, 제작, 주문 완료 버튼 사이를 오가는 게 너무 귀찮아서 만든 애드온입니다. **GatheredOrderButtons**는 필요한 버튼을 모두 하나의 이동 가능한 패널에 모아, 마우스를 거의 움직이지 않고 주문을 끝낼 수 있게 해 줍니다. NPC 손님 의뢰가 주 목적이지만, 다른 종류의 주문에서도 똑같이 동작합니다.

### 기능

- **주문 버튼을 모두 모은 이동 가능한 패널.** 드래그로 옮길 수 있고, 위치는 저장됩니다.
- **1줄:** 뒤로 → 주문을 시작하면 주문 취소로 바뀝니다.
- **2줄은 주문 시작 → 제작 (확인 생략) | 제작 → 주문 완료 순서로 같은 자리에서 바뀝니다.** 다음에 누를 버튼이 항상 마우스 아래에 있습니다.
  - **제작:** 기본 '제작' 버튼과 같습니다. 확인 팝업도 그대로 뜹니다.
  - **제작 (확인 생략):** 빠른 제작용입니다. 제작하면서 확인 팝업을 자동으로 수락합니다.
- **제목 줄 버튼:** 투명도(10–100%) 조절, 최소화, 닫기. 닫은 패널은 다음에 주문을 열면 다시 나타납니다.
- 원래 버튼의 툴팁(제작할 수 없는 이유 등)이 패널 버튼에도 표시됩니다.
- 블리자드 기본 버튼은 원래 자리에 그대로 있습니다. 이 애드온은 바로가기 버튼만 추가합니다.
- NPC 손님 주문, 개인 주문, 길드 주문, 공개 주문 모두에서 동작합니다. 재제작 주문도 지원합니다.
- 영어와 한국어를 지원합니다.

### 사용 순서

1. 주문을 열고 패널의 **주문 시작**을 누릅니다.
2. 같은 자리에 나타난 **제작 (확인 생략)**을 누릅니다.
3. 제작이 끝나면 역시 같은 자리에 나타난 **주문 완료**를 누릅니다.

### 명령어

- `/gob reset`(또는 `/gatheredorderbuttons reset`): 패널 위치, 최소화 상태, 투명도를 처음 상태로 되돌립니다.

### 주의: '제작 (확인 생략)'에 대해

**버튼을 누르기 전에 주문 내용(재료, 품질, 수수료)을 꼭 확인하세요.** 누르는 순간 취소할 기회 없이 바로 제작이 진행됩니다.

**제작 (확인 생략)**은 그 클릭으로 뜬 확인 팝업을 **종류와 상관없이 모두** 수락합니다. 흔히 뜨는 "보유한 재료 일부를 사용" 팝업뿐만이 아닙니다.
예를 들어 귀속되거나 비싼 재료를 사용한다는 경고도 자동으로 수락됩니다.
경고 내용을 직접 확인하고 싶을 때는 일반 **제작** 버튼을 사용하세요.

자동 수락은 사용자가 직접 버튼을 눌렀을 때만 동작합니다. 애드온이 스스로 제작하거나 팝업을 수락하는 일은 없습니다.

### 의견

버그 제보와 제안은 댓글이나 이슈 트래커에 남겨 주세요.
