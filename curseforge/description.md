# Summary (one line)

Gathers the crafting order buttons into one movable panel, so you can start, craft and complete orders with little mouse movement.

---

# Description

## GatheredOrderButtons

I made this addon because moving my mouse between the Start Order, Create and Complete Order buttons while filling NPC patron orders got too tedious. GatheredOrderButtons puts these buttons in one movable panel. Patron orders are the main focus, but it works the same for other order types.

### Features

- The panel opens with the crafting order view. Drag it to move it.
- First row: Back. It changes to Cancel Order after you start the order.
- Second row: Start Order, then Create (No Confirm) and Create, then Complete Order. Each step starts from the same left edge, so you barely need to move your mouse.
  - Create: same as the default Create button, including the confirmation popup.
  - Create (No Confirm): for faster crafting. It crafts and automatically accepts the confirmation popup.
- Title bar buttons: opacity (10-100%), minimize and close. A closed panel reappears the next time the order view opens.
- Panel position, minimize state and opacity are saved.
- Tooltips from the original buttons, such as why crafting is unavailable, also appear on the panel buttons.
- The original Blizzard buttons stay where they are.
- The panel is drawn above other windows, such as your bags, where they overlap.
- Works with patron, personal, guild and public orders, including recrafts.
- Available in English and Korean.

### Typical flow

1. Open an order and click Start Order in the panel.
2. Click Create (No Confirm) in the same row.
3. When the craft is done, click Complete Order in the same row.

### Slash command

`/gob reset` or `/gatheredorderbuttons reset` restores the default panel position, minimize state and opacity.

### Important: about "Create (No Confirm)"

**Always check the order details (reagents, quality, commission) before clicking.** Once you click, the craft goes ahead without a second chance to cancel.

Create (No Confirm) accepts any confirmation popup that appears as a result of that click, not only the usual "use some of your own reagents" prompt. For example, a warning about using soulbound or expensive reagents is also accepted automatically. If you want to review a warning, use the plain Create button instead.

The auto-accept only happens when you click the button yourself. The addon never crafts or accepts anything on its own.

### Feedback

Bug reports and suggestions are welcome in the comments or the issue tracker.

---

## GatheredOrderButtons (한국어)

NPC 손님 의뢰를 처리하면서 주문 시작, 제작, 주문 완료 버튼 사이로 마우스를 옮기는 게 귀찮아서 만든 애드온입니다. GatheredOrderButtons는 이 버튼들을 이동 가능한 패널 하나에 모아 줍니다. NPC 손님 의뢰가 주 목적이지만, 다른 종류의 주문에서도 똑같이 동작합니다.

### 기능

- 패널은 주문 제작 화면이 열릴 때 함께 열립니다. 드래그해서 옮길 수 있습니다.
- 첫째 줄: 뒤로. 주문을 시작하면 주문 취소로 바뀝니다.
- 둘째 줄: 주문 시작, 그다음 제작 (확인 생략)과 제작, 그다음 주문 완료. 단계마다 왼쪽 끝이 같아서 마우스를 거의 움직이지 않아도 됩니다.
  - 제작: 기본 '제작' 버튼과 같습니다. 확인 팝업도 그대로 뜹니다.
  - 제작 (확인 생략): 빠른 제작용입니다. 제작하면서 확인 팝업을 자동으로 수락합니다.
- 제목 줄 버튼: 투명도(10-100%), 최소화, 닫기. 닫은 패널은 다음에 주문 제작 화면이 열릴 때 다시 나타납니다.
- 패널 위치, 최소화 상태, 투명도는 저장됩니다.
- 제작할 수 없는 이유 같은 원래 버튼의 툴팁이 패널 버튼에도 표시됩니다.
- 블리자드 기본 버튼은 원래 자리에 그대로 있습니다.
- 가방 같은 다른 창과 겹치면 패널이 그 위에 표시됩니다.
- NPC 손님 주문, 개인 주문, 길드 주문, 공개 주문과 재제작 주문에서 동작합니다.
- 영어와 한국어를 지원합니다.

### 사용 순서

1. 주문을 열고 패널의 주문 시작을 누릅니다.
2. 같은 줄의 제작 (확인 생략)을 누릅니다.
3. 제작이 끝나면 같은 줄의 주문 완료를 누릅니다.

### 명령어

`/gob reset` 또는 `/gatheredorderbuttons reset`을 입력하면 패널 위치, 최소화 상태, 투명도가 기본값으로 돌아갑니다.

### 주의: '제작 (확인 생략)'에 대해

**버튼을 누르기 전에 주문 내용(재료, 품질, 수수료)을 꼭 확인하세요.** 누르는 순간 취소할 기회 없이 바로 제작이 진행됩니다.

제작 (확인 생략)은 그 클릭으로 뜬 확인 팝업을 종류와 상관없이 모두 수락합니다. 흔히 뜨는 "보유한 재료 일부를 사용" 팝업뿐만이 아닙니다. 예를 들어 귀속되거나 비싼 재료를 사용한다는 경고도 자동으로 수락됩니다. 경고 내용을 직접 확인하고 싶을 때는 일반 제작 버튼을 사용하세요.

자동 수락은 사용자가 직접 버튼을 눌렀을 때만 동작합니다. 애드온이 스스로 제작하거나 팝업을 수락하는 일은 없습니다.

### 의견

버그 제보와 제안은 댓글이나 이슈 트래커에 남겨 주세요.
