
# Deferred Work Registry

> Consolidated từ code reviews Story 1.2–1.6 (2026-03-28). Grouped theo root cause, deduplicated.

## Priority Legend

- 🔴 **Critical** — Blocks correct behavior hoặc gây data corruption
- 🟡 **Medium** — Functional nhưng inconsistent/fragile
- 🟢 **Low** — Edge case hoặc cosmetic

---

## 1. Auth Session Management 🔴

**Root cause:** Không có centralized auth session service. `currentUserId` được lấy từ `UserDefaults` với fallback `?? ""`, và social login không persist userId.

| ID | Mô tả | Nguồn | Files ảnh hưởng |
|----|-------|-------|-----------------|
| AUTH-1 | `currentUserId ?? ""` fallback tạo phantom userId khi UserDefaults bị clear | 1.2, 1.3, 1.5, 1.6, 1.7 | `PresentationAssembly`, tất cả ViewModels dùng userId |
| ~~AUTH-2~~ | ~~`loginWithGoogle()` và `loginWithApple()` không persist~~ | ~~1.5, 1.6~~ | **FIXED in Story 1.7** |
| ~~AUTH-3~~ | ~~`ConversationsView` hardcode `"current_user_id"`~~ | ~~1.5~~ | **FIXED in Story 1.7** |
| ~~AUTH-4~~ | ~~`ProfileDetailViewModel` nhận `currentUserId: ""`~~ | ~~1.2, 1.5~~ | **FIXED in Story 1.7** |
| AUTH-5 | Cold start: Firebase restore session nhưng không re-persist currentUserId → ViewModel nhận "" | 1.7 review | `AuthRepository.swift`, `PresentationAssembly.swift` |
| AUTH-6 | Stale currentUserId nếu user logout rồi login bằng account khác — ViewModel giữ reference cũ (DI lifecycle) | 1.7 review | `PresentationAssembly.swift` |
| AUTH-7 | `OnboardingViewModel` vẫn nhận userId qua parameter, chưa migrate sang inject pattern | 1.7 review | `OnboardingViewModel.swift` |
| AUTH-8 | `deleteAccount()` có race condition giữa Firestore delete và auth delete | 1.7 review | `AuthRepository.swift:91-97` |

**Đề xuất giải pháp:** Tạo `AuthSessionService` protocol, inject vào coordinators/VMs thay vì đọc trực tiếp từ UserDefaults. Gate tất cả authenticated screens — chỉ hiển thị sau login thành công.

---

## 2. Concurrency Guards 🟡

**Root cause:** Không có in-flight guard hoặc debounce cho async actions. Rapid user interaction trigger duplicate requests.

| ID | Mô tả | Nguồn | Files ảnh hưởng |
|----|-------|-------|-----------------|
| CONC-1 | Swipe actions không debounce/throttle → concurrent API calls | 1.2 | `ProfileDetailViewModel.swift` |
| CONC-2 | `loadMoreProfiles()` chạy concurrent khi swipe nhanh → duplicate profiles. `.task` re-fires khi view re-appears → double-reset | 1.6 | `DiscoverViewModel.swift` |
| CONC-3 | Google Sign-In button không disable khi `isLoading = true` → multiple GIDSignIn sessions | 1.4 | `LoginView.swift` |
| CONC-4 | `loadProfiles()` thiếu reentrancy guard — `.task` có thể re-fire khi view re-appears gây concurrent fetch | 1.8 review | `DiscoverViewModel.swift:35-47` |

**Đề xuất giải pháp:** Thêm `guard !isLoading` / `guard !isSwiping` state cho tất cả async entry points. Disable interactive elements khi loading.

---

## 3. Photo & Profile Save Flow 🟡

**Root cause:** Photo lifecycle không consistent — upload/delete flow khác nhau, dismiss không check unsaved changes.

| ID | Mô tả | Nguồn | Files ảnh hưởng |
|----|-------|-------|-----------------|
| PHOTO-1 | `addPhoto` upload lên Storage nhưng không persist Firestore cho đến khi tap "Lưu thay đổi" → orphaned files nếu dismiss | 1.3 (EC-7) | `ProfileViewModel.swift` |
| ~~PHOTO-2~~ | ~~`removePhoto` gọi `profileRepository.deletePhoto` trực tiếp, bypass UseCase layer~~ | ~~1.3 (BH-10)~~ | **FIXED in Story 1.9** |
| ~~PHOTO-3~~ | ~~`dismiss()` gọi unconditionally sau `saveProfile()` failure → swallow errorMessage~~ | ~~1.3 (EC-10)~~ | **FIXED in Story 1.9** |
| PHOTO-4 | `errorMessage == nil` dùng làm success signal cho conditional dismiss — fragile nếu saveProfile() thay đổi error handling | 1.9 review | `EditProfileView.swift` |
| PHOTO-5 | `removePhoto` URL mismatch (trailing slash, encoding) → silent no-op: server delete thành công nhưng UI giữ photo | 1.9 review | `ProfileViewModel.swift` |

**Đề xuất giải pháp:** Tạo `DeletePhotoUseCaseProtocol` cho symmetry. Thêm unsaved-changes warning trước dismiss. Chỉ dismiss khi save thành công.

---

## 4. Feature Gaps 🟡

| ID | Mô tả | Nguồn | Files ảnh hưởng |
|----|-------|-------|-----------------|
| FEAT-1 | Match alert "Nhắn tin" chỉ dismiss, không navigate tới chat screen | 1.2 | `ProfileDetailView.swift`, `DiscoverView.swift` |
| FEAT-2 | Distance display: Profile entity có `location` nhưng không có `distance` field. Cần compute từ current user location hoặc thêm field từ API | 1.2 (AC#3) | `Profile.swift`, `CardView.swift` |
| FEAT-3 | Không có tap gesture trên CardView để navigate tới ProfileDetail | 1.2 | `DiscoverView.swift`, `CardView.swift` |

---

## 5. DI & Architecture 🟢

| ID | Mô tả | Nguồn | Files ảnh hưởng |
|----|-------|-------|-----------------|
| DI-1 | `resolver.resolve(...)!` force-unwrap toàn bộ PresentationAssembly — không có graceful error handling | 1.5 | `PresentationAssembly.swift` |

**Đề xuất:** Dùng `precondition` với message rõ ràng thay vì force-unwrap, giúp debug nhanh hơn khi registration thiếu.

---

## 6. Edge Cases 🟢

| ID | Mô tả | Nguồn | Files ảnh hưởng |
|----|-------|-------|-----------------|
| EDGE-1 | HEIC/WebP: nếu `UIImage(data:)` thành công nhưng `jpegData` trả nil (rare color space) → upload fail. Fallback `pngData()` chưa có | 1.3 (EC-9) | Photo upload flow |
| EDGE-2 | Firebase network errors hiển thị tiếng Anh (`localizedDescription`). Không có `AuthError.networkError` case riêng | 1.4 | `AuthRepository.swift` |

---

## 7. Configuration Tasks

| ID | Mô tả | Nguồn | Action |
|----|-------|-------|--------|
| CFG-1 | `Info.plist` chứa placeholder `REPLACE_WITH_REVERSED_CLIENT_ID` — cần lấy từ `GoogleService-Info.plist` (Firebase Console) | 1.4 | Manual config, file bị gitignore |

---

## Story Candidates

Từ registry trên, đề xuất 3 stories mới:

1. **Auth Session Service** (🔴) — AUTH-1, AUTH-5 → AUTH-8. Centralized auth state, gate authenticated screens, cold start restore, DI lifecycle.
2. **Concurrency Guards** (🟡) — CONC-1 → CONC-3. In-flight guards cho tất cả async actions.
3. **Photo Save Flow** (🟡) — PHOTO-1 → PHOTO-3. Consistent photo lifecycle, DeletePhotoUseCase, conditional dismiss.
