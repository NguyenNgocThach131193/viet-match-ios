# vm-commit Workflow

Skill commit code tuân thủ VietMatch GitFlow & Conventional Commits.

## Bước 1: Kiểm tra trạng thái hiện tại

Chạy đồng thời:
- `git status` — xem các file thay đổi
- `git branch --show-current` — xác định nhánh hiện tại
- `git diff --stat` — xem tổng quan thay đổi

## Bước 2: Validate nhánh hiện tại

Kiểm tra tên nhánh có tuân thủ GitFlow conventions:
- **Hợp lệ để commit**: `feature/*`, `feat/*`, `bugfix/*`, `release/*`, `hotfix/*`, `develop`
- **KHÔNG được commit trực tiếp**: `main` — Cảnh báo người dùng và DỪNG LẠI ngay

Nếu nhánh là `main`:
> **CẢNH BÁO: Bạn đang ở nhánh `main`. Theo quy tắc GitFlow của VietMatch, KHÔNG commit trực tiếp vào `main`. Mọi thay đổi phải thông qua Pull Request.**
> Gợi ý: Hãy tạo nhánh phù hợp trước (feature/*, bugfix/*, hotfix/*).

Sau đó DỪNG LẠI, không tiếp tục.

## Bước 3: Phân tích thay đổi

- Đọc `git diff` (staged + unstaged) để hiểu nội dung thay đổi
- Xác định loại thay đổi phù hợp với Conventional Commits:
  - `feat` — Tính năng mới
  - `fix` — Sửa lỗi
  - `docs` — Thay đổi tài liệu
  - `style` — Thay đổi format, không ảnh hưởng logic
  - `refactor` — Tái cấu trúc code
  - `perf` — Cải thiện hiệu năng
  - `test` — Thêm/sửa test
  - `chore` — Cập nhật build, package, cấu hình

## Bước 4: Xác định scope (tùy chọn)

Dựa vào các file thay đổi, gợi ý scope phù hợp:
- Thay đổi trong module auth → scope: `auth`
- Thay đổi trong module profile → scope: `profile`
- Thay đổi trong module chat → scope: `chat`
- Thay đổi trong navigation → scope: `navigation`
- Thay đổi trong networking → scope: `networking`
- Thay đổi đa module hoặc chung → không cần scope

## Bước 5: Tạo commit message

Format: `<type>[optional scope]: <description>`

Quy tắc:
- Description viết bằng tiếng Anh, bắt đầu bằng động từ ở dạng nguyên thể (add, fix, update, remove, refactor...)
- Viết thường chữ cái đầu description
- Không kết thúc bằng dấu chấm
- Ngắn gọn, dưới 72 ký tự

Ví dụ:
- `feat(profile): integrate photo upload to Firebase Storage`
- `fix(auth): fix memory leak in LoginUseCase`
- `refactor(navigation): simplify coordinator flow`
- `chore: add kingfisher dependency`

## Bước 6: Trình bày cho người dùng xác nhận

Hiển thị cho người dùng:
1. Nhánh hiện tại
2. Danh sách files sẽ được commit
3. Commit message đề xuất
4. Hỏi người dùng xác nhận hoặc chỉnh sửa

Format hiển thị:
```
📋 VietMatch Commit Summary
━━━━━━━━━━━━━━━━━━━━━━━━━
Nhánh: feature/xxx
Files thay đổi:
  - [M] path/to/modified/file.swift
  - [A] path/to/new/file.swift
  - [D] path/to/deleted/file.swift

Commit message: feat(scope): description here

Xác nhận commit? (hoặc nhập message mới)
```

## Bước 7: Thực hiện commit

Sau khi người dùng xác nhận:
1. `git add` các files phù hợp (KHÔNG dùng `git add -A` hay `git add .` — chỉ add các files liên quan, tránh commit file nhạy cảm như .env)
2. Tạo commit với message đã xác nhận, kèm co-author:

```bash
git commit -m "$(cat <<'EOF'
<commit message>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

3. Xác nhận commit thành công bằng `git log --oneline -1`

## Bước 8: Gợi ý bước tiếp theo

Sau khi commit thành công, gợi ý:
- Dùng `/vm-push` để push code và tạo PR
- Hoặc tiếp tục code và commit thêm

## Lưu ý quan trọng

- **KHÔNG BAO GIỜ** commit trực tiếp vào `main`
- **KHÔNG BAO GIỜ** commit file chứa secrets (.env, credentials, API keys...)
- Nếu pre-commit hook fail: sửa lỗi và tạo commit MỚI (không dùng --amend)
- Luôn kiểm tra không có file nhạy cảm trước khi stage
