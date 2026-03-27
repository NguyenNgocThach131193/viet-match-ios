import SwiftUI
import Swinject

final class AuthCoordinator: Coordinator {
    @Published var path = NavigationPath()

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func start() -> some View {
        AuthCoordinatorView(coordinator: self)
    }

    func showRegister() {
        path.append(AuthRoute.register)
    }

    func showForgotPassword() {
        path.append(AuthRoute.forgotPassword)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    @ViewBuilder
    func destination(for route: AuthRoute) -> some View {
        switch route {
        case .login:
            loginView()
        case .register:
            registerView()
        case .forgotPassword:
            forgotPasswordView()
        }
    }

    func loginView() -> some View {
        let viewModel = container.resolve(LoginViewModel.self)!
        return LoginView(viewModel: viewModel, coordinator: self)
    }

    func registerView() -> some View {
        let viewModel = container.resolve(RegisterViewModel.self)!
        return RegisterView(viewModel: viewModel, coordinator: self)
    }

    func forgotPasswordView() -> some View {
        let viewModel = container.resolve(ForgotPasswordViewModel.self)!
        return ForgotPasswordView(viewModel: viewModel, coordinator: self)
    }
}

struct AuthCoordinatorView: View {
    @ObservedObject var coordinator: AuthCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.loginView()
                .navigationDestination(for: AuthRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}
