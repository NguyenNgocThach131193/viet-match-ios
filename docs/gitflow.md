# VietMatch - GitFlow & Branching Strategy

Tài liệu này quy định quy trình quản lý mã nguồn (GitFlow) và các tiêu chuẩn commit cho dự án VietMatch, nhằm đảm bảo tiến độ triển khai mượt mà, hạn chế xung đột code và dễ dàng quản lý các phiên bản (releases) trên App Store.

## 1. Mô hình các nhánh (Branches)

Dự án áp dụng mô hình GitFlow tiêu chuẩn được thiết kế tối ưu cho quá trình phát triển ứng dụng iOS.

### Nhánh chính (Main Branches)
Hai nhánh này tồn tại song song trong suốt vòng đời của dự án:
- **`main`**: Chứa mã nguồn luôn ở trạng thái ổn định (production-ready). Mọi commit trên nhánh này đều phải được gắn tag (ví dụ: `v1.0.0`) và tương đương với một phiên bản được phát hành lên App Store.
- **`develop`**: Nhánh tích hợp chính. Chứa các tính năng mới nhất đã được review và đang chờ để phát hành trong phiên bản tiếp theo. Bản build trên nhánh này thường được dùng để phân phối qua TestFlight cho nội bộ (Internal Testing).

### Nhánh hỗ trợ (Supporting Branches)
Các nhánh này có vòng đời ngắn, được tạo ra để giải quyết một mục đích cụ thể và sẽ bị xóa sau khi hoàn thành.

#### Nhánh Tính năng (Feature Branches)
- Cú pháp: `feature/<tên-tính-năng>` hoặc `feat/<tên-tính-năng>`
- Ví dụ: `feature/user-profile`, `feature/chat-system`
- Tách ra từ: `develop`
- Merge vào: `develop`
- Mục đích: Phát triển các tính năng mới. Mỗi tính năng được phát triển độc lập và merge vào `develop` thông qua Pull Request (PR).

#### Nhánh Sửa lỗi (Bugfix Branches)
- Cú pháp: `bugfix/<mô-tả-lỗi>`
- Ví dụ: `bugfix/fix-login-crash`
- Tách ra từ: `develop`
- Merge vào: `develop`
- Mục đích: Sửa các lỗi phát sinh trong quá trình phát triển hoặc test trên nhánh `develop`.

#### Nhánh Phát hành (Release Branches)
- Cú pháp: `release/<version>`
- Ví dụ: `release/v1.1.0`
- Tách ra từ: `develop`
- Merge vào: `main` và `develop`
- Mục đích: Chuẩn bị cho đợt phát hành mới (bump version, sửa lỗi nhỏ cuối cùng). Trong lúc nhánh release tồn tại, nhánh `develop` vẫn có thể tiếp nhận các tính năng tiếp theo.

#### Nhánh Sửa lỗi khẩn cấp (Hotfix Branches)
- Cú pháp: `hotfix/<mô-tả-lỗi>`
- Ví dụ: `hotfix/fix-payment-crash`
- Tách ra từ: `main`
- Merge vào: `main` và `develop`
- Mục đích: Xử lý các lỗi nghiêm trọng (crash, lỗi logic nạp tiền...) ngay trên phiên bản đang chạy tren App Store mà không cần chờ đợt release tiếp theo.

---

## 2. Quy trình làm việc (Workflow)

Trình tự phát triển một tính năng thông thường:

1. Đội ngũ cập nhật nhánh `develop` cục bộ:
   ```bash
   git checkout develop
   git pull origin develop
   ```
2. Tạo nhánh tính năng mới:
   ```bash
   git checkout -b feature/awesome-feature
   ```
3. Lập trình và commit theo tiêu chuẩn Conventional Commits.
   ```bash
   git commit -m "feat: add awesome feature to profile"
   ```
4. Đẩy nhánh lên remote và tạo Pull Request (PR) trỏ vào nhánh `develop`.
5. Sau khi có Code Review và các bài Unit Test/UI Test vượt qua, PR được merge vào `develop`.
6. Xóa nhánh tính năng ở dưới và trên remote.

---

## 3. Tiêu chuẩn Commit (Conventional Commits)

Chúng tôi sử dụng quy tắc Conventional Commits để tự động tạo changelog và dễ dàng đọc hiểu lịch sử git.

**Cú pháp:**
`<type>[optional scope]: <description>`

**Các loại Tag (Type):**
- **feat**: Một tính năng mới
- **fix**: Sửa một lỗi
- **docs**: Thay đổi về tài liệu (VD: README.md)
- **style**: Thay đổi không ảnh hưởng đến logic code (khoảng trắng, định dạng, thiếu dấu phẩy...)
- **refactor**: Tái cấu trúc code (không thêm tính năng, không sửa lỗi)
- **perf**: Thay đổi code nhằm cải thiện hiệu năng
- **test**: Thêm hoặc sửa các bài test (Unit/UI Test)
- **chore**: Cập nhật công việc build, quản lý package (SPM), cấu hình dự án (.xcodeproj)

**Ví dụ:**
- `feat(profile): integrate photo upload to Firebase Storage`
- `fix(auth): fix memory leak in LoginUseCase`
- `style: format UI code in DiscoverView`
- `chore: add kingfisher dependency`

---

## 4. Quản lý Pull Request (PR)

- Tất cả thay đổi gộp vào `develop` và `main` đều phải thông qua Pull Request. KHÔNG commit trực tiếp.
- Mô tả PR phải ghi rõ: Vấn đề giải quyết là gì? Kèm theo các thay đổi lớn về giao diện (chụp ảnh màn hình nếu có).
- Tham chiếu tới thẻ Jira/Trello/Ticket nếu có (VD: `[VM-123]`).
- Tối thiểu 1 người phê duyệt (Approver) trước khi merge.
- Áp dụng kỹ thuật: **Squash and Merge** khi gộp từ `feature` vào `develop` để giao diện lịch sử gọn gàng nhất.
