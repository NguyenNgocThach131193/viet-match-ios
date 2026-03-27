# Story 1.5: Fix Hardcoded currentUserId trong ChatViewModel

Status: ready-for-dev

## Story

As a **nguoi dung dang chat**,
I want **tin nhan duoc gui voi userId that cua toi**,
so that **nguoi nhan thay dung nguoi gui va tin nhan hien thi dung ben (trai/phai)**.

## Acceptance Criteria

1. ChatViewModel lay `currentUserId` tu auth state thay vi hardcoded string
2. userId duoc inject qua Swinject container hoac lay tu UserDefaultsService/AuthRepository
3. Tin nhan gui di co `senderId` la userId that cua nguoi dung hien tai
4. Message bubble hien thi dung ben (phai cho tin nhan cua minh, trai cho nguoi khac)
5. Khong co hardcoded `"current_user_id"` con lai trong ChatViewModel
6. Tat ca unit tests hien tai van pass

## Tasks / Subtasks

- [ ] Task 1: Cap nhat ChatViewModel inject currentUserId (AC: #1, #2, #5)
  - [ ] 1.1 Sua `VietMatch/Presentation/Screens/Chat/ChatViewModel.swift`
  - [ ] 1.2 Thay `private var currentUserId = "current_user_id"` bang property duoc inject
  - [ ] 1.3 Option A: Inject `UserDefaultsService` va lay tu `UserDefaultsKey.currentUserId`
  - [ ] 1.4 Option B: Them `currentUserId: String` parameter vao init (truyen tu Coordinator)
  - [ ] 1.5 Dam bao `sendMessage()` su dung userId that

- [ ] Task 2: Cap nhat DI registration (AC: #2)
  - [ ] 2.1 Sua `PresentationAssembly` - truyen currentUserId khi resolve ChatViewModel
  - [ ] 2.2 Sua `ChatCoordinator.chatView(matchId:)` - truyen userId khi tao ChatViewModel

- [ ] Task 3: Viet/cap nhat unit tests (AC: #3, #4, #6)
  - [ ] 3.1 Cap nhat `ChatViewModelTests` (neu co) hoac tao moi
  - [ ] 3.2 Test: sendMessage su dung dung senderId
  - [ ] 3.3 Test: isCurrentUser check cho message bubbles

- [ ] Task 4: Chay full test suite va xac nhan 100% pass

## Dev Notes

- Hien tai `ChatViewModel.swift:16` co `private var currentUserId = "current_user_id"` - day la hardcoded string
- `UserDefaultsService` da luu `currentUserId` khi login thanh cong (xem AuthRepository.swift)
- `UserDefaultsKey.currentUserId` la key da dinh nghia san
- ChatViewModel da duoc resolve voi argument `matchId` trong PresentationAssembly - co the them `userId` argument
- ChatView su dung `currentUserId` de xac dinh ben hien thi cua message bubble

### Project Structure Notes

- File sua: `Presentation/Screens/Chat/ChatViewModel.swift`
- File sua: `App/DI/PresentationAssembly.swift`
- File sua: `Presentation/Navigation/ChatCoordinator.swift` (co the)
- Test moi/sua: `VietMatchTests/Presentation/ViewModels/ChatViewModelTests.swift`

### References

- [Source: VietMatch/Presentation/Screens/Chat/ChatViewModel.swift#L16 - hardcoded hien tai]
- [Source: VietMatch/Data/DataSources/Local/UserDefaultsService.swift - currentUserId key]
- [Source: VietMatch/Data/Repositories/AuthRepository.swift - set currentUserId khi login]
- [Source: docs/navigation-deep-dive.md#4.5 ChatCoordinator - resolve voi argument]
- [Source: docs/architecture.md#3. Dependency Injection]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
