import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar

            // Content
            TabView(selection: $viewModel.currentStep) {
                ProfileSetupView(viewModel: viewModel)
                    .tag(0)

                genderSelectionStep
                    .tag(1)

                PhotoUploadView(viewModel: viewModel)
                    .tag(2)

                interestsStep
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)

            // Bottom buttons
            bottomButtons
        }
        .background(VietMatchColors.background.ignoresSafeArea())
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                Rectangle()
                    .fill(VietMatchColors.primaryGradient)
                    .frame(width: geometry.size.width * CGFloat(viewModel.currentStep + 1) / CGFloat(viewModel.totalSteps))
            }
        }
        .frame(height: 4)
    }

    private var genderSelectionStep: some View {
        VStack(spacing: VietMatchSpacing.xl) {
            Text("Giới tính của bạn")
                .font(VietMatchTypography.title2)

            ForEach(Gender.allCases, id: \.self) { gender in
                Button {
                    viewModel.gender = gender
                } label: {
                    HStack {
                        Text(genderLabel(gender))
                            .font(VietMatchTypography.body)
                        Spacer()
                        if viewModel.gender == gender {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(VietMatchColors.primary)
                        }
                    }
                    .padding()
                    .background(viewModel.gender == gender ? VietMatchColors.primary.opacity(0.1) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.gender == gender ? VietMatchColors.primary : Color.clear, lineWidth: 2)
                    )
                }
                .foregroundColor(VietMatchColors.textPrimary)
            }

            Spacer()

            Text("Bạn muốn gặp")
                .font(VietMatchTypography.title2)

            ForEach(Gender.allCases, id: \.self) { gender in
                Button {
                    viewModel.interestedIn = gender
                } label: {
                    HStack {
                        Text(genderLabel(gender))
                            .font(VietMatchTypography.body)
                        Spacer()
                        if viewModel.interestedIn == gender {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(VietMatchColors.primary)
                        }
                    }
                    .padding()
                    .background(viewModel.interestedIn == gender ? VietMatchColors.primary.opacity(0.1) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundColor(VietMatchColors.textPrimary)
            }

            Spacer()
        }
        .padding(.horizontal, VietMatchSpacing.xl)
        .padding(.top, VietMatchSpacing.xxl)
    }

    private var interestsStep: some View {
        VStack(spacing: VietMatchSpacing.xl) {
            Text("Sở thích của bạn")
                .font(VietMatchTypography.title2)

            Text("Chọn ít nhất 3 sở thích")
                .font(VietMatchTypography.subheadline)
                .foregroundColor(VietMatchColors.textSecondary)

            FlowLayout(spacing: VietMatchSpacing.sm) {
                ForEach(viewModel.availableInterests, id: \.self) { interest in
                    let isSelected = viewModel.interests.contains(interest)
                    Button {
                        viewModel.toggleInterest(interest)
                    } label: {
                        Text(interest)
                            .font(VietMatchTypography.callout)
                            .padding(.horizontal, VietMatchSpacing.lg)
                            .padding(.vertical, VietMatchSpacing.sm)
                            .background(isSelected ? VietMatchColors.primary : Color.white)
                            .foregroundColor(isSelected ? .white : VietMatchColors.textPrimary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, VietMatchSpacing.xl)
        .padding(.top, VietMatchSpacing.xxl)
    }

    private var bottomButtons: some View {
        HStack(spacing: VietMatchSpacing.lg) {
            if viewModel.currentStep > 0 {
                Button {
                    viewModel.previousStep()
                } label: {
                    Text("Quay lại")
                        .secondaryButtonStyle()
                }
            }

            Button {
                if viewModel.currentStep == viewModel.totalSteps - 1 {
                    onComplete()
                } else {
                    viewModel.nextStep()
                }
            } label: {
                Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Hoàn tất" : "Tiếp tục")
                    .primaryButtonStyle()
            }
            .disabled(!viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1 : 0.6)
        }
        .padding(.horizontal, VietMatchSpacing.xl)
        .padding(.bottom, VietMatchSpacing.xl)
    }

    private func genderLabel(_ gender: Gender) -> String {
        switch gender {
        case .male: return "Nam"
        case .female: return "Nữ"
        case .other: return "Khác"
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
            totalHeight = y + maxHeight
        }

        return (positions, CGSize(width: maxWidth, height: totalHeight))
    }
}
