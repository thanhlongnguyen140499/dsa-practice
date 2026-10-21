//
//  05-Architecture.swift
//  Interview
//
// Architecture & Patterns: a beginner's tour for iOS quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Each #Playground block covers one idea. PREDICT the output before you run it.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// "Architecture" is about where code lives and who knows about whom.
// Every pattern below tries to reach the same three goals:
//
//   1. Each type has ONE job          → easier to read and change
//   2. Types depend on PROTOCOLS      → you can swap real code for fakes in tests
//   3. Data flows in a clear direction → you can tell why the screen shows what it shows
//
// Map of the patterns:
//   MVC          Apple's default. The view controller does too much ("Massive View Controller")
//   MVVM         The ViewModel turns models into display state. The view just binds to it
//   VIPER        View / Interactor / Presenter / Entity / Router. Very strict split
//   Clean Arch.  Layers. Dependencies point INWARD (UI → use cases → entities)
//   Coordinator  Takes navigation out of view controllers
//   TCA / Redux  State + Action → Reducer → new State (+ Effects). Unidirectional
//
// Plus SOLID, dependency injection, and the classic design patterns
// (Repository, Adapter, Strategy, Observer).

import Foundation
import Playgrounds

// Protocols can't be declared inside a function, so the ones the demos need
// live here. `private` keeps them out of the other files in this module.
private protocol ArchUserService { func fetchName(id: Int) -> String }
private protocol ArchPaymentClient { func charge(_ amount: Int) -> Bool }
private protocol ArchAnalyticsTracking { func track(_ event: String) }
private protocol ArchPricingRule { func price(subtotal: Double) -> Double }
private protocol ArchReadableCache { func value(for key: String) -> String? }
private protocol ArchWritableCache: ArchReadableCache { func store(_ value: String, for key: String) }
private protocol ArchDiscount { func apply(to price: Double) -> Double }
private protocol ArchUserRepository { func user(id: Int) -> String? }
private protocol ArchFeatureFlags { func isOn(_ flag: String) -> Bool }
private protocol ArchProfileViewDelegate: AnyObject { func didTapAvatar() }

// MARK: - 1. MVC → MVVM

#Playground("1. MVC vs MVVM") { demo {
    // ❌ MVC in UIKit: the view controller owns the view's lifecycle, so it becomes
    //    the default place for EVERYTHING: networking, decoding, formatting, navigation.
    //    It grows huge and you can't test it without a real screen.
    //
    // ✅ MVVM: the ViewModel takes raw model data and produces DISPLAY STATE
    //    (ready-to-show strings and flags). It also handles user intents.
    //    It doesn't import UIKit, so you can test it with plain code.

    struct Article { let title: String; let likes: Int; let isDraft: Bool }

    final class ArticleViewModel {
        private let article: Article
        init(article: Article) { self.article = article }

        // Output: display state
        var titleText: String { article.isDraft ? "[Draft] \(article.title)" : article.title }
        var likesText: String { article.likes == 1 ? "1 like" : "\(article.likes) likes" }
        var isShareEnabled: Bool { !article.isDraft }
    }

    let vm = ArticleViewModel(article: Article(title: "GCD 101", likes: 1, isDraft: true))
    // PREDICT the three values:
    print(vm.titleText, "|", vm.likesText, "|", vm.isShareEnabled)
    // [Draft] GCD 101 | 1 like | false

    // QUIZ: a good ViewModel
    //   ✅ exposes display state, handles user actions, gets dependencies injected
    //   ❌ holds references to UILabel / UIViewController, or imports UIKit
}}

// MARK: - 2. VIPER and Clean Architecture

// VIPER splits one screen into 5 roles:
//   View        shows things, forwards taps            (dumb)
//   Interactor  BUSINESS LOGIC, talks to services/DB   ← quiz favourite
//   Presenter   turns Interactor results into view data, tells the Router to navigate
//   Entity      plain model structs
//   Router      creates and presents the next screen
//
// Clean Architecture: the DEPENDENCY RULE
//   Source-code dependencies point INWARD only:
//
//     UI / Frameworks / DB  ──►  Use cases  ──►  Entities
//
//   Inner layers declare protocols (e.g. OrderRepository). Outer layers implement them.
//   The domain never imports UIKit, URLSession, or Core Data.

#Playground("2. Clean Architecture") { demo {
    // Inner layer: knows nothing about networking
    struct Order { let id: Int; let total: Double }
    struct FetchExpensiveOrders {
        let loadOrders: () -> [Order]      // depends on an abstraction it owns
        func execute() -> [Order] { loadOrders().filter { $0.total > 100 } }
    }

    // Outer layer: plugs a concrete source into the use case
    let fakeRemote = { [Order(id: 1, total: 50), Order(id: 2, total: 250)] }
    let useCase = FetchExpensiveOrders(loadOrders: fakeRemote)
    expect(useCase.execute().map(\.id), [2])
}}

// MARK: - 3. SOLID, one before/after per letter

#Playground("3. SOLID") { demo {
    // S: Single Responsibility. One reason to change per type.
    //   ❌ A ProfileViewController that downloads, decodes, saves to UserDefaults AND formats.
    //   ✅ ProfileService (fetch + decode), ProfileStore (persist), ProfileViewModel (format).
    struct ProfileFormatter { func display(_ name: String) -> String { name.uppercased() } }
    expect(ProfileFormatter().display("ana"), "ANA")

    // O: Open/Closed. Add behavior with NEW types, without editing old code.
    //   ❌ switch discountType { case "student": ... case "vip": ... }  // edit every time
    //   ✅ each discount conforms to a protocol
    struct Student: ArchDiscount { func apply(to p: Double) -> Double { p * 0.8 } }
    struct VIP: ArchDiscount { func apply(to p: Double) -> Double { p * 0.5 } }
    let discounts: [any ArchDiscount] = [Student(), VIP()]   // new kinds: no edits here
    expect(discounts.map { $0.apply(to: 100) }, [80, 50])

    // L: Liskov Substitution. A subtype must work everywhere its parent is expected.
    //   ❌ class ReadOnlyCache: Cache { override func store(...) { fatalError() } }
    //      Code written for Cache now crashes.
    //   ✅ Split the capabilities so no subtype has to break a promise:
    final class Snapshot: ArchReadableCache {                 // read-only: never promises store()
        func value(for key: String) -> String? { key == "a" ? "1" : nil }
    }
    final class Memory: ArchWritableCache {
        var dict: [String: String] = [:]
        func value(for key: String) -> String? { dict[key] }
        func store(_ value: String, for key: String) { dict[key] = value }
    }
    let memory = Memory(); memory.store("2", for: "b")
    let readers: [any ArchReadableCache] = [Snapshot(), memory]
    expect(readers.map { $0.value(for: "a") ?? "-" }, ["1", "-"])

    // I: Interface Segregation. Many small protocols beat one fat protocol.
    //   If most conformers stub methods with fatalError(), split the protocol.
    //   (ArchReadableCache / ArchWritableCache above is also an example.)

    // D: Dependency Inversion. High-level code depends on an ABSTRACTION.
    //   ❌ class CheckoutViewModel { let client = StripePaymentClient() }
    //   ✅ init(payments: ArchPaymentClient). Stripe, PayPal, or a test fake all fit.
    struct AlwaysApproves: ArchPaymentClient { func charge(_ amount: Int) -> Bool { true } }
    final class CheckoutViewModel {
        private let payments: any ArchPaymentClient
        init(payments: any ArchPaymentClient) { self.payments = payments }
        func pay() -> String { payments.charge(42) ? "Paid" : "Failed" }
    }
    expect(CheckoutViewModel(payments: AlwaysApproves()).pay(), "Paid")
}}

// MARK: - 4. Dependency injection and singletons

#Playground("4. Dependency injection") { demo {
    struct StubUsers: ArchUserService { func fetchName(id: Int) -> String { "Stub #\(id)" } }

    // ✅ Constructor (init) injection: the dependency is required, visible at the
    //    call site, and can be `let`. It can never be missing.
    final class ProfileVM {
        private let service: any ArchUserService
        init(service: any ArchUserService) { self.service = service }
        func title() -> String { service.fetchName(id: 7) }
    }
    expect(ProfileVM(service: StubUsers()).title(), "Stub #7")

    // ⚠️ Property injection: `var service: ArchUserService!` set AFTER init.
    //    The compiler can't check you set it. Forget it → crash at runtime.
    //    (Sometimes you have to use it, e.g. storyboard-created view controllers.)
    final class LegacyVC {
        var service: (any ArchUserService)?
        func title() -> String { service?.fetchName(id: 1) ?? "💥 would crash with !" }
    }
    print(LegacyVC().title())

    // ❌ Singletons like APIClient.shared used everywhere:
    //    - you can't see a type's dependencies from its init
    //    - shared state leaks from one test into the next
    //    - you can't swap in a fake
    //    Fine for truly global things. Even then, inject `.shared` through init.
}}

// MARK: - 5. Communication: delegate vs closure vs NotificationCenter vs Combine

#Playground("5. Delegate / closure / notification") { demo {
    // Delegate: one-to-one, a protocol with several callbacks.
    //   Make the protocol `: AnyObject` so the property can be `weak`
    //   (weak only works on class types). That avoids a retain cycle.
    final class AvatarView {
        weak var delegate: (any ArchProfileViewDelegate)?
        func tap() { delegate?.didTapAvatar() }
    }
    final class Screen: ArchProfileViewDelegate {
        var log: [String] = []
        func didTapAvatar() { log.append("delegate") }
    }
    let screen = Screen(); let avatar = AvatarView()
    avatar.delegate = screen
    avatar.tap()

    // Closure: one-to-one, a single callback. Lightweight.
    var onTap: (() -> Void)? = { [weak screen] in screen?.log.append("closure") }
    onTap?(); onTap = nil

    // NotificationCenter: ONE-TO-MANY broadcast. Senders don't know the receivers.
    //   Good for app-wide events like "user logged out".
    let center = NotificationCenter()
    let loggedOut = Notification.Name("loggedOut")
    var received = 0
    let tokens = (1...3).map { _ in
        center.addObserver(forName: loggedOut, object: nil, queue: nil) { _ in received += 1 }
    }
    center.post(name: loggedOut, object: nil)
    tokens.forEach(center.removeObserver)

    print(screen.log, "observers notified:", received)   // ["delegate", "closure"] observers notified: 3

    // Combine trap (also in the Combine file): `publisher.sink { }` returns an
    // AnyCancellable. If you don't store it, the subscription is cancelled right
    // away and the view model never receives any values. Store it in a Set<AnyCancellable>.
}}

// MARK: - 6. Coordinator

#Playground("6. Coordinator") { demo {
    // Problem: view controllers that push the next screen themselves
    //   (navigationController?.pushViewController(DetailVC(), ...)) are coupled
    //   to each other and hard to reuse.
    // Fix: screens only REPORT events. A Coordinator decides where to go next.
    final class ListScreen { var onSelect: ((Int) -> Void)?; func userTapped(_ id: Int) { onSelect?(id) } }

    final class AppCoordinator {
        var stack: [String] = []                 // stands in for a UINavigationController
        func start() {
            let list = ListScreen()
            list.onSelect = { [weak self] id in self?.showDetail(id) }
            stack.append("List")
            list.userTapped(42)                  // simulate a tap
        }
        func showDetail(_ id: Int) { stack.append("Detail(\(id))") }
    }

    let coordinator = AppCoordinator()
    coordinator.start()
    expect(coordinator.stack, ["List", "Detail(42)"])
}}

// MARK: - 7. Unidirectional data flow (Redux / TCA)

#Playground("7. Reducer") { demo {
    // Data goes around in ONE direction:
    //   View ──action──► Reducer(state, action) ──► new State ──► View re-renders
    // State changes in only one place, so every change is easy to trace and test.
    // In TCA, side effects (API calls) are NOT done inside the reducer. The reducer
    // returns an Effect, the Store runs it, and the result comes back as a new action.

    struct State: Equatable { var count = 0; var isLoading = false; var fact: String? }
    enum Action { case increment, factButtonTapped, factResponse(String) }
    enum Effect { case none, fetchFact(Int) }

    func reduce(_ state: inout State, _ action: Action) -> Effect {
        switch action {
        case .increment:
            state.count += 1
            return .none
        case .factButtonTapped:
            state.isLoading = true
            return .fetchFact(state.count)       // describe the work, don't do it here
        case .factResponse(let text):
            state.isLoading = false
            state.fact = text
            return .none
        }
    }

    // A tiny "Store" that runs effects and sends the results back as actions
    var state = State()
    func send(_ action: Action) {
        switch reduce(&state, action) {
        case .none: break
        case .fetchFact(let n): send(.factResponse("\(n) is a nice number"))  // fake API
        }
    }

    send(.increment); send(.increment); send(.factButtonTapped)
    expect(state, State(count: 2, isLoading: false, fact: "2 is a nice number"))
}}

// MARK: - 8. Repository, Adapter, Strategy

#Playground("8. Design patterns") { demo {
    // Repository: domain-friendly methods (user(id:)). It hides WHERE the data
    // comes from (memory cache → disk → network).
    final class CachedUserRepository: ArchUserRepository {
        private var cache: [Int: String] = [:]
        private(set) var networkCalls = 0
        func user(id: Int) -> String? {
            if let hit = cache[id] { return hit }
            networkCalls += 1                    // pretend network
            cache[id] = "User\(id)"
            return cache[id]
        }
    }
    let repo = CachedUserRepository()
    _ = repo.user(id: 1); _ = repo.user(id: 1)
    expect(repo.networkCalls, 1)

    // Adapter: wrap a third-party API so it fits YOUR protocol.
    //   Your app depends on ArchAnalyticsTracking, not the vendor SDK.
    final class VendorSDK { var sent: [String] = []; func logEvent(name: String, props: [String: Any]) { sent.append(name) } }
    struct VendorAdapter: ArchAnalyticsTracking {
        let sdk: VendorSDK
        func track(_ event: String) { sdk.logEvent(name: event, props: [:]) }
    }
    let sdk = VendorSDK()
    let tracker: any ArchAnalyticsTracking = VendorAdapter(sdk: sdk)
    tracker.track("purchase")
    expect(sdk.sent, ["purchase"])

    // Strategy: interchangeable algorithms behind one protocol, swappable at runtime.
    struct Regular: ArchPricingRule { func price(subtotal: Double) -> Double { subtotal } }
    struct BlackFriday: ArchPricingRule { func price(subtotal: Double) -> Double { subtotal * 0.7 } }
    final class Checkout {
        var rule: any ArchPricingRule
        init(rule: any ArchPricingRule) { self.rule = rule }
        func total(_ subtotal: Double) -> Double { rule.price(subtotal: subtotal) }
    }
    let checkout = Checkout(rule: Regular())
    let before = checkout.total(100)
    checkout.rule = BlackFriday()
    expect([before, checkout.total(100)], [100, 70])

    // Others you should be able to name:
    //   Observer   → NotificationCenter, KVO, Combine
    //   Factory    → a type whose job is creating other objects
    //   Decorator  → wraps an object to add behavior (e.g. LoggingClient wraps APIClient)
    //   Facade     → one simple API over a complex subsystem
}}

// MARK: - 9. Modularization and feature flags

#Playground("9. Feature flags") { demo {
    // SPM modules: each package target is its own module. Only `public` API can be
    // used from outside it. That enforces boundaries, lets Xcode build modules in
    // parallel, and makes incremental builds faster.
    //
    // Remote feature flags: ship code "dark", then turn it on remotely for 5% → 50% → 100%
    // of users, or switch it off instantly without a new App Store release.
    struct RemoteFlags: ArchFeatureFlags {
        let config: [String: Bool]               // would come from your server
        func isOn(_ flag: String) -> Bool { config[flag] ?? false }   // default OFF
    }
    let flags: any ArchFeatureFlags = RemoteFlags(config: ["newCheckout": true])
    print(flags.isOn("newCheckout") ? "new checkout" : "old checkout")   // new checkout
    print(flags.isOn("unknownFlag"))                                     // false
}}

// MARK: - Quiz cheat sheet
//
// Q: Why "Massive View Controller"?           A: In MVC the VC owns the view lifecycle, so networking, logic, formatting
//                                                and navigation all pile up there. Hard to test.
// Q: Good MVVM ViewModel?                     A: Turns models into display state + handles intents. No UIKit, deps injected.
// Q: VIPER: where's the business logic?       A: Interactor. (Presenter formats + talks to Router; Router navigates.)
// Q: Clean Architecture dependency rule?      A: Dependencies point inward: UI/DB/frameworks → use cases → entities. Never reverse.
// Q: TCA side effects?                        A: Reducer mutates state and returns an Effect. The Store runs it and feeds back actions.
// Q: What does a Coordinator solve?           A: Navigation/flow logic moves out of view controllers. Screens just report events.
// Q: VC fetches + decodes + saves + formats?  A: Violates Single Responsibility.
// Q: Subclass whose override fatalErrors?     A: Violates Liskov Substitution. Split into smaller protocols instead.
// Q: Protocol where conformers stub methods?  A: Interface Segregation: split it into smaller protocols.
// Q: VM creates StripeClient() itself?        A: Dependency Inversion: depend on a PaymentClient protocol injected via init.
// Q: Why constructor injection?               A: Dependencies are explicit, required, can be `let`, easy to fake in tests.
// Q: Downside of property injection (`!`)?    A: The compiler can't guarantee it's set, so you can crash at runtime.
// Q: Testable without network?                A: Inject a protocol (or URLSession/URLProtocol) instead of hard-coding URLSession.shared.
// Q: Main argument against singletons?        A: Hidden dependencies + shared state that leaks between tests.
// Q: Notify many parts of the app (logout)?   A: NotificationCenter (one-to-many). Delegates/closures are one-to-one.
// Q: View model never receives values?        A: The AnyCancellable from sink wasn't stored, so it was cancelled immediately.
// Q: Repository pattern?                      A: Domain-style API that hides whether data comes from cache, disk or network.
// Q: SPM modules benefit?                     A: Enforced boundaries (only public API visible), parallel/incremental builds.
// Q: Remote feature flags benefit?            A: Gradual rollout + instant kill switch without an App Store release.
// Q: Unidirectional data flow?                A: Actions → one place updates state → views render from state. Predictable and testable.
// Q: Wrap a vendor SDK in your own protocol?  A: Adapter.
// Q: Swappable pricing algorithms?            A: Strategy.
