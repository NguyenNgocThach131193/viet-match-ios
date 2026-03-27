# vm-push Workflow

Skill push code và tạo Pull Request tuân thủ VietMatch GitFlow.

## Bước 1: Kiểm tra trạng thái hiện tại

Chạy đồng thời:
- `git status` — kiểm tra có uncommitted changes không
- `git branch --show-current` — xác định nhánh hiện tại
- `git log --oneline -5` — xem các commits gần đây
- `git remote -v` — kiểm tra remote

## Bước 2: Validate nhánh và xác định target branch

Dựa vào tên nhánh hiện tại, xác định quy trình GitFlow phù hợp:

| Nhánh hiện tại | Push lên remote | Target branch cho PR |
|---|---|---|
| `feature/*` hoặc `feat/*` | Cùng tên nhánh | `develop` |
| `bugfix/*` | Cùng tên nhánh | `develop` |
| `release/*` | Cùng tên nhánh | `main` VÀ `develop` |
| `hotfix/*` | Cùng tên nhánh | `main` VÀ `develop` |
| `develop` | `develop` | Không tạo PR (push trực tiếp) |
| `main` | **CHẶN** | **KHÔNG PUSH** |

Nếu nhánh là `main`:
> **CẢNH BÁO: KHÔNG push trực tiếp vào `main`. Mọi thay đổi vào `main` phải thông qua PR từ nhánh `release/*` hoặc `hotfix/*`.**

Sau đó DỪNG LẠI.

## Bước 3: Kiểm tra uncommitted changes

Nếu có uncommitted changes:
> **Phát hiện thay đổi chưa commit. Bạn có muốn commit trước khi push không?**
> Gợi ý: Dùng `/vm-commit` để commit theo chuẩn VietMatch.

Hỏi người dùng muốn:
1. Commit trước rồi push (gợi ý dùng `/vm-commit`)
2. Push chỉ những gì đã commit
3. Hủy bỏ

## Bước 4: Kiểm tra sync với remote

- `git fetch origin`
- So sánh nhánh local với remote: `git log origin/<branch>..HEAD --oneline` (commits chưa push)
- So sánh remote với local: `git log HEAD..origin/<branch> --oneline` (commits chưa pull)

Nếu có commits chưa pull:
> **Nhánh remote có commits mới hơn. Bạn nên pull trước khi push.**
> Gợi ý: `git pull --rebase origin <branch>`

## Bước 5: Push lên remote

```bash
git push -u origin <tên-nhánh-hiện-tại>
```

Nếu push lần đầu (nhánh chưa có trên remote), dùng flag `-u` để set upstream.

## Bước 6: Hỏi tạo Pull Request

Sau khi push thành công, hỏi người dùng:
> **Push thành công! Bạn có muốn tạo Pull Request không?**

Nếu người dùng đồng ý, tiếp tục Bước 7. Nếu không, kết thúc.

## Bước 7: Tạo Pull Request

### 7.1 Thu thập thông tin PR

- Xem tất cả commits từ khi tách nhánh: `git log develop..HEAD --oneline` (hoặc `main..HEAD` cho hotfix/release)
- Xem toàn bộ diff: `git diff develop...HEAD --stat`

### 7.2 Soạn PR title

Dựa vào commits và loại nhánh:
- `feature/*` → title bắt đầu bằng `feat: ...` hoặc mô tả tính năng
- `bugfix/*` → title bắt đầu bằng `fix: ...`
- `hotfix/*` → title bắt đầu bằng `hotfix: ...`
- `release/*` → title: `release: vX.Y.Z`

Giữ title ngắn gọn, dưới 70 ký tự.

### 7.3 Soạn PR body

Format chuẩn:
```markdown
## Summary
- <Mô tả ngắn gọn thay đổi chính>
- <Các thay đổi quan trọng khác>

## Changes
- <Liệt kê chi tiết các thay đổi>

## Screenshots
<!-- Đính kèm ảnh UI nếu có thay đổi giao diện -->

## Test Plan
- [ ] <Các bước test cần thực hiện>

## Related Issues
<!-- VD: [VM-123] hoặc link đến ticket -->

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 7.4 Trình bày cho người dùng xác nhận

```
📋 VietMatch Pull Request
━━━━━━━━━━━━━━━━━━━━━━━━━
Từ: feature/xxx
Vào: develop
Title: feat: add awesome feature
Commits: 3 commits

Xác nhận tạo PR? (hoặc chỉnh sửa)
```

### 7.5 Tạo PR bằng GitHub CLI

```bash
gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'EOF'
<PR body>
EOF
)"
```

### 7.6 Hiển thị kết quả

Sau khi tạo PR thành công, hiển thị:
- Link đến PR
- Nhắc nhở: cần tối thiểu 1 approver trước khi merge
- Nhắc nhở: sử dụng **Squash and Merge** khi merge feature vào develop

## Bước 8: Xử lý release và hotfix (merge vào cả main và develop)

Nếu nhánh là `release/*` hoặc `hotfix/*`:
1. Tạo PR đầu tiên vào `main`
2. Hỏi người dùng có muốn tạo PR thứ hai vào `develop` không
3. Nhắc nhở gắn tag version sau khi merge vào `main`:
   > Sau khi PR được merge vào `main`, nhớ gắn tag: `git tag vX.Y.Z && git push origin vX.Y.Z`

## Lưu ý quan trọng

- **KHÔNG BAO GIỜ** push trực tiếp vào `main`
- **KHÔNG BAO GIỜ** dùng `--force` push trừ khi người dùng yêu cầu rõ ràng
- Luôn nhắc nhở về quy tắc **Squash and Merge** cho feature branches
- Với `release/*` và `hotfix/*`, phải tạo PR vào CẢ `main` và `develop`
- Tối thiểu 1 approver trước khi merge
