import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel: MatchesViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: VietMatchSpacing.xl) {
                    if !viewModel.newMatches.isEmpty {
                        newMatchesSection
                    }

                    allMatchesSection
                }
                .padding(.horizontal, VietMatchSpacing.lg)
            }
            .background(VietMatchColors.background.ignoresSafeArea())
            .navigationTitle("Matches")
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.matches.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "Chưa có match nào",
                        message: "Hãy tiếp tục khám phá để tìm match!"
                    )
                }
            }
            .task {
                await viewModel.loadMatches(userId: "current_user_id")
            }
        }
    }

    private var newMatchesSection: some View {
        VStack(alignment: .leading, spacing: VietMatchSpacing.md) {
            Text("Matches mới")
                .font(VietMatchTypography.headline)
                .foregroundColor(VietMatchColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: VietMatchSpacing.md) {
                    ForEach(viewModel.newMatches) { match in
                        MatchCellView(match: match, style: .compact)
                    }
                }
            }
        }
    }

    private var allMatchesSection: some View {
        VStack(alignment: .leading, spacing: VietMatchSpacing.md) {
            Text("Tất cả matches")
                .font(VietMatchTypography.headline)
                .foregroundColor(VietMatchColors.textPrimary)

            LazyVStack(spacing: VietMatchSpacing.md) {
                ForEach(viewModel.matches) { match in
                    MatchCellView(match: match, style: .full)
                }
            }
        }
    }
}
