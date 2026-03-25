import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedItems: [PhotosPickerItem] = []

    private let columns = [
        GridItem(.flexible(), spacing: VietMatchSpacing.sm),
        GridItem(.flexible(), spacing: VietMatchSpacing.sm),
        GridItem(.flexible(), spacing: VietMatchSpacing.sm)
    ]

    var body: some View {
        VStack(spacing: VietMatchSpacing.xl) {
            Text("Thêm ảnh của bạn")
                .font(VietMatchTypography.title2)

            Text("Thêm ít nhất 1 ảnh để tiếp tục")
                .font(VietMatchTypography.subheadline)
                .foregroundColor(VietMatchColors.textSecondary)

            LazyVGrid(columns: columns, spacing: VietMatchSpacing.sm) {
                ForEach(0..<Constants.App.maxPhotos, id: \.self) { index in
                    if index < viewModel.selectedPhotos.count {
                        photoCell(data: viewModel.selectedPhotos[index], index: index)
                    } else {
                        addPhotoCell
                    }
                }
            }
            .padding(.horizontal, VietMatchSpacing.lg)

            Spacer()
        }
        .padding(.top, VietMatchSpacing.xxl)
    }

    private func photoCell(data: Data, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                viewModel.selectedPhotos.remove(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .offset(x: -4, y: 4)
        }
    }

    private var addPhotoCell: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: Constants.App.maxPhotos - viewModel.selectedPhotos.count,
            matching: .images
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundColor(VietMatchColors.textSecondary.opacity(0.3))
                    .frame(height: 160)

                VStack(spacing: VietMatchSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Thêm ảnh")
                        .font(VietMatchTypography.caption)
                }
                .foregroundColor(VietMatchColors.primary)
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        viewModel.selectedPhotos.append(data)
                    }
                }
                selectedItems = []
            }
        }
    }
}
