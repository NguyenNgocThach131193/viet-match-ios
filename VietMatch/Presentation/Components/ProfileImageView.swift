import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    let url: String?
    let size: CGFloat
    var showBorder: Bool = true

    var body: some View {
        Group {
            if let url, let imageURL = URL(string: url) {
                KFImage(imageURL)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
        .background(Color.gray.opacity(0.1))
        .clipShape(Circle())
        .overlay {
            if showBorder {
                Circle().stroke(VietMatchColors.primaryGradient, lineWidth: 2)
            }
        }
    }
}
