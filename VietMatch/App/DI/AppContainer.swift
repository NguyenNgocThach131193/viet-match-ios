import Foundation
import Swinject

final class AppContainer {
    static let shared = AppContainer()

    let container: Container

    private init() {
        container = Container()
        registerAssemblies()
    }

    private func registerAssemblies() {
        var assemblies: [Assembly] = []
        #if UIPREVIEW
        assemblies.append(MockDataAssembly())
        #else
        assemblies.append(DataAssembly())
        #endif
        assemblies.append(DomainAssembly())
        assemblies.append(PresentationAssembly())
        let assembler = Assembler(assemblies, container: container)
        _ = assembler // retain assembler
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("Could not resolve \(type)")
        }
        return resolved
    }

    func resolve<T>(_ type: T.Type, name: String) -> T {
        guard let resolved = container.resolve(type, name: name) else {
            fatalError("Could not resolve \(type) with name \(name)")
        }
        return resolved
    }
}
