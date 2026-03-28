import SwiftUI
import PhotosUI
import Kingfisher

struct PhotoGridView: View {
    let photos: [String]
    let isUploadingPhoto: Bool
    let isDeletingPhoto: Bool
    let onAdd: (Data) async -> Void
    let onRemove: (String) async -> Void

    private let columns = [
        GridItem(.flexible(), spacing: VietMatchSpacing.sm),
        GridItem(.flexible(), spacing: VietMatchSpacing.sm),
        GridItem(.flexible(), spacing: VietMatchSpacing.sm)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: VietMatchSpacing.sm) {
            ForEach(0..<Constants.App.maxPhotos, id: \.self) { index in
                if index < photos.count {
                    filledSlot(url: photos[index])
                } else if index == photos.count {
                    EmptySlotView(
                        isUploading: isUploadingPhoto,
                        isDisabled: isUploadingPhoto || isDeletingPhoto || photos.count >= Constants.App.maxPhotos,
                        onAdd: onAdd
                    )
                } else {
                    EmptySlotView(
                        isUploading: false,
                        isDisabled: isUploadingPhoto || isDeletingPhoto || photos.count >= Constants.App.maxPhotos,
                        onAdd: onAdd
                    )
                }
            }
        }
    }

    private func filledSlot(url: String) -> some View {
        ZStack(alignment: .topTrailing) {
            KFImage(URL(string: url))
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                Task { await onRemove(url) }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .offset(x: -4, y: 4)
            .disabled(isDeletingPhoto)
        }
        .frame(height: 120)
    }
}

private struct EmptySlotView: View {
    let isUploading: Bool
    let isDisabled: Bool
    let onAdd: (Data) async -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var loadError: Bool = false

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundColor(VietMatchColors.textSecondary.opacity(0.3))
                    .frame(height: 120)

                if isUploading {
                    ProgressView()
                        .tint(VietMatchColors.primary)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(VietMatchColors.primary)
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                do {
                    guard let data = try await newItem.loadTransferable(type: Data.self) else {
                        loadError = true
                        selectedItem = nil
                        return
                    }
                    selectedItem = nil
                    await onAdd(data)
                } catch {
                    loadError = true
                    selectedItem = nil
                }
            }
        }
        .disabled(isDisabled)
        .frame(height: 120)
        .alert("Không thể tải ảnh", isPresented: $loadError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Vui lòng thử ảnh khác.")
        }
    }
}
