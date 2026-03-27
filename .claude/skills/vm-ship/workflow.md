# vm-ship Workflow

Skill kết hợp commit + push + tạo PR trong một lệnh duy nhất, tuân thủ VietMatch GitFlow.

---

## PHASE 1: COMMIT

### Bước 1: Kiểm tra trạng thái

Chạy đồng thời:
- `git status` — xem các file thay đổi
- `git branch --show-current` — xác định nhánh hiện tại
- `git diff --stat` — tổng quan thay đổi
- `git log --oneline -3` — commits gần đây (để theo style)

### Bước 2: Validate nhánh

Nhánh hợp lệ: `feature/*`, `feat/*`, `bugfix/*`, `release/*`, `hotfix/*`, `develop`

Nếu nhánh là `main`:
> **CẢNH BÁO: Bạn đang ở nhánh `main`. Theo quy tắc GitFlow của VietMatch, KHÔNG commit/push trực tiếp vào `main`. Mọi thay đổi phải thông qua Pull Request.**

**DỪNG LẠI ngay.**

### Bước 3: Kiểm tra có thay đổi để commit không

- Nếu KHÔNG có thay đổi (staged hoặc unstaged) → chuyển thẳng sang PHASE 2 (push commits đã có)
- Nếu CÓ thay đổi → tiếp tục bước 4

### Bước 4: Phân tích thay đổi & tạo commit message

Đọc `git diff` để xác định:
- **Type**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- **Scope** (tùy chọn): dựa vào module bị thay đổi (auth, profile, chat, navigation, networking...)
- **Description**: tiếng Anh, bắt đầu bằng động từ nguyên thể, viết thường, < 72 ký tự, không dấu chấm cuối

### Bước 5: Trình bày summary để xác nhận

```
📋 VietMatch Ship Summary
━━━━━━━━━━━━━━━━━━━━━━━━━
Nhánh: feature/xxx → push to origin → PR vào develop

Files thay đổi:
  [M] path/to/file.swift
  [A] path/to/new-file.swift

Commit: feat(scope): description here
Push to: origin/feature/xxx
PR target: develop

Xác nhận? (hoặc nhập message mới)
```

### Bước 6: Thực hiện commit

1. `git add` các files cụ thể (KHÔNG dùng `git add -A` hay `git add .`)
2. Tạo commit:

```bash
git commit -m "$(cat <<'EOF'
<commit message>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

3. Xác nhận: `git log --oneline -1`

---

## PHASE 2: PUSH

### Bước 7: Sync với remote

- `git fetch origin`
- Kiểm tra commits chưa pull: `git log HEAD..origin/<branch> --oneline`
- Nếu có commits mới trên remote:
  > **Remote có commits mới. Cần pull trước khi push.**
  > Thực hiện: `git pull --rebase origin <branch>`

### Bước 8: Push lên remote

```bash
git push -u origin <tên-nhánh>
```

---

## PHASE 3: TẠO PR (tùy chọn)

### Bước 9: Hỏi tạo PR

> **Commit & Push thành công! Bạn có muốn tạo Pull Request không?**

Nếu người dùng từ chối → kết thúc với tóm tắt.

### Bước 10: Xác định target branch

| Nhánh hiện tại | Target PR |
|---|---|
| `feature/*`, `feat/*` | `develop` |
| `bugfix/*` | `develop` |
| `release/*` | `main` + `develop` |
| `hotfix/*` | `main` + `develop` |

### Bước 11: Soạn và tạo PR

Thu thập thông tin:
- `git log <target>..HEAD --oneline` — tất cả commits
- `git diff <target>...HEAD --stat` — tổng quan thay đổi

Tạo PR:
```bash
gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'EOF'
## Summary
- <Mô tả thay đổi chính>

## Changes
- <Chi tiết các thay đổi>

## Screenshots
<!-- Ảnh UI nếu có -->

## Test Plan
- [ ] <Các bước test>

## Related Issues
<!-- [VM-xxx] -->

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Bước 12: Kết quả & nhắc nhở

Hiển thị link PR và nhắc nhở:
- Cần tối thiểu **1 approver** trước khi merge
- Dùng **Squash and Merge** cho feature/bugfix branches
- Với `release/*`/`hotfix/*`: hỏi tạo PR thứ hai vào `develop`, nhắc gắn tag version sau merge vào `main`

---

## Lưu ý quan trọng

- **KHÔNG BAO GIỜ** commit/push trực tiếp vào `main`
- **KHÔNG BAO GIỜ** dùng `--force` push
- **KHÔNG** commit file nhạy cảm (.env, credentials, API keys...)
- Nếu pre-commit hook fail: sửa lỗi → tạo commit MỚI (không --amend)
- Luôn stage files cụ thể, tránh `git add .`
