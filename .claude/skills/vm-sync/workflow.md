# vm-sync Workflow

Skill checkout nhánh `develop` và pull code mới nhất, đảm bảo working directory sạch trước khi thực hiện.

## Bước 1: Kiểm tra trạng thái hiện tại

Chạy đồng thời:
- `git status` — kiểm tra uncommitted changes
- `git branch --show-current` — xác định nhánh hiện tại
- `git stash list` — kiểm tra có stash nào không

## Bước 2: Kiểm tra uncommitted changes

Nếu có uncommitted changes (staged hoặc unstaged hoặc untracked files quan trọng):

> **⚠️ CẢNH BÁO: Phát hiện thay đổi chưa commit trên nhánh `<nhánh-hiện-tại>`!**
>
> Các file thay đổi:
> - `<danh sách file>`
>
> **Không thể checkout sang `develop` khi có code chưa commit.**
> Gợi ý:
> 1. Dùng `/vm-commit` để commit trước
> 2. Hoặc `git stash` để lưu tạm thay đổi

Sau đó **DỪNG LẠI**, không thực hiện checkout và pull.

## Bước 3: Kiểm tra unpushed commits

Chạy:
- `git fetch origin`
- `git log origin/<nhánh-hiện-tại>..HEAD --oneline` — kiểm tra commits chưa push

Nếu nhánh hiện tại KHÔNG phải `develop` và có commits chưa push lên remote:

> **⚠️ CẢNH BÁO: Có commits chưa push trên nhánh `<nhánh-hiện-tại>`!**
>
> Commits chưa push:
> - `<danh sách commits>`
>
> **Không thể checkout sang `develop` khi có code chưa push.**
> Gợi ý:
> 1. Dùng `/vm-push` để push code trước
> 2. Hoặc `/vm-ship` để commit + push cùng lúc

Sau đó **DỪNG LẠI**, không thực hiện checkout và pull.

## Bước 4: Checkout nhánh develop

Nếu đang ở nhánh `develop` rồi, bỏ qua bước này.

Nếu đang ở nhánh khác:
```bash
git checkout develop
```

Nếu checkout thất bại, thông báo lỗi và dừng lại.

## Bước 5: Pull code mới nhất

```bash
git pull origin develop
```

Nếu có conflict, thông báo:
> **⚠️ Phát hiện conflict khi pull. Vui lòng giải quyết conflict trước khi tiếp tục.**

## Bước 6: Hiển thị kết quả

Sau khi thành công, hiển thị:

```
✅ VietMatch Sync Complete
━━━━━━━━━━━━━━━━━━━━━━━━━
Nhánh: develop (up-to-date)
<Số commits mới được pull, nếu có>
```

Chạy thêm `git log --oneline -5` để hiển thị 5 commits gần nhất trên develop.

## Lưu ý quan trọng

- **LUÔN LUÔN** kiểm tra uncommitted changes và unpushed commits TRƯỚC khi checkout
- **KHÔNG BAO GIỜ** dùng `git checkout --force` hoặc bỏ qua cảnh báo
- **KHÔNG BAO GIỜ** tự động stash hoặc discard changes mà không có sự đồng ý của người dùng
- Nếu đã ở nhánh `develop`, chỉ cần pull là đủ
