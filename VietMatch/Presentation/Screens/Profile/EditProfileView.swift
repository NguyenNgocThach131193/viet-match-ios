import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VietMatchSpacing.xl) {
                // Photos grid
                Text("Ảnh của bạn")
                    .font(VietMatchTypography.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PhotoGridView(
                    photos: viewModel.profile?.photos ?? [],
                    isUploadingPhoto: viewModel.isUploadingPhoto,
                    isDeletingPhoto: viewModel.isDeletingPhoto,
                    onAdd: { data in await viewModel.addPhoto(data: data) },
                    onRemove: { url in await viewModel.removePhoto(url: url) }
                )

                // Edit fields
                Group {
                    editField(title: "Tên", text: $viewModel.editName)
                    editField(title: "Giới thiệu", text: $viewModel.editBio, isMultiline: true)
                    editField(title: "Công việc", text: $viewModel.editJobTitle)
                    editField(title: "Công ty", text: $viewModel.editCompany)
                    editField(title: "Trường học", text: $viewModel.editSchool)
                }

                Button {
                    Task {
                        await viewModel.saveProfile()
                        dismiss()
                    }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Lưu thay đổi")
                        }
                    }
                    .primaryButtonStyle()
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, VietMatchSpacing.xl)
            .padding(.top, VietMatchSpacing.lg)
        }
        .background(VietMatchColors.background.ignoresSafeArea())
        .navigationTitle("Chỉnh sửa hồ sơ")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func editField(title: String, text: Binding<String>, isMultiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: VietMatchSpacing.xs) {
            Text(title)
                .font(VietMatchTypography.footnote)
                .foregroundColor(VietMatchColors.textSecondary)

            if isMultiline {
                TextEditor(text: text)
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .padding(VietMatchSpacing.md)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .cardShadow()
            } else {
                TextField(title, text: text)
                    .textFieldStyle(.plain)
                    .padding(VietMatchSpacing.md)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .cardShadow()
            }
        }
    }
}
