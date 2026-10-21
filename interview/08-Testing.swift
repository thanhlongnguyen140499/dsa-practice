//
//  08-Testing.swift
//  Interview
//
// Testing & Tooling: a beginner's tour for iOS quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// XCTest and Swift Testing can't be imported in this playground target, so real
// test code is shown in comments. The ideas behind it (test doubles, injection,
// async waiting, float tolerance) are runnable demos.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// A test runs your code and CHECKS the result automatically. Three kinds:
//
//   Unit test        one type or function, no network/disk. Fast → write MOST of these
//   Integration test a few real pieces working together (e.g. repository + database)
//   UI test          launches the real app and taps buttons (XCUITest). Slow → write FEW
//
//   This is the "test pyramid": wide base of unit tests, thin top of UI tests.
//
// To unit-test code that talks to the network, you hide the network behind a
// PROTOCOL and pass ("inject") the dependency in through init. In the test you
// pass a fake version instead. That fake is called a TEST DOUBLE.
//
// Two test frameworks:
//   XCTest         class MyTests: XCTestCase, func testX(), XCTAssertEqual(...)
//   Swift Testing  @Test func x(), #expect(...), #require(...)   (Xcode 16+)

import Foundation
import Playgrounds

// MARK: - Code under test (shared by the demos below)

private struct TestUser: Equatable { let id: Int; let name: String }

/// The dependency is a protocol, so tests can swap in a double.
private protocol UserService {
    func fetchUser(id: Int) throws -> TestUser
}

private enum ServiceError: Error { case offline }

/// The view model gets its service through init (constructor injection).
private final class ProfileViewModel {
    private let service: UserService
    private(set) var title = ""

    init(service: UserService) { self.service = service }

    func load(id: Int) {
        do {
            title = "Hi, \(try service.fetchUser(id: id).name)"
        } catch {
            title = "Offline"
        }
    }
}

// MARK: - 1. Test doubles: stub, spy, mock, fake

/// STUB: returns a canned answer. That's all it does.
private struct StubService: UserService {
    var result: Result<TestUser, Error>
    func fetchUser(id: Int) throws -> TestUser { try result.get() }
}

/// SPY: records how it was called, so the test can check the calls AFTERWARDS.
private final class SpyService: UserService {
    private(set) var requestedIDs: [Int] = []
    func fetchUser(id: Int) throws -> TestUser {
        requestedIDs.append(id)
        return TestUser(id: id, name: "Spy")
    }
}

/// MOCK: is told up front what calls to EXPECT, and verifies them itself.
private final class MockService: UserService {
    private let expectedID: Int
    private var called = false
    init(expecting id: Int) { expectedID = id }

    func fetchUser(id: Int) throws -> TestUser {
        called = (id == expectedID)
        return TestUser(id: id, name: "Mock")
    }
    func verify() -> Bool { called }
}

/// FAKE: a real, working, simplified implementation (here: an in-memory dictionary).
private final class FakeService: UserService {
    private var storage: [Int: TestUser] = [:]
    func save(_ user: TestUser) { storage[user.id] = user }
    func fetchUser(id: Int) throws -> TestUser {
        guard let user = storage[id] else { throw ServiceError.offline }
        return user
    }
}

#Playground("1. Test doubles") { demo {
    // Stub: control what the dependency returns
    let ok = ProfileViewModel(service: StubService(result: .success(TestUser(id: 1, name: "Ann"))))
    ok.load(id: 1)
    expect(ok.title, "Hi, Ann")

    let offline = ProfileViewModel(service: StubService(result: .failure(ServiceError.offline)))
    offline.load(id: 1)
    expect(offline.title, "Offline")          // the error path is easy to test with a stub

    // Spy: check which calls happened
    let spy = SpyService()
    ProfileViewModel(service: spy).load(id: 42)
    expect(spy.requestedIDs, [42])

    // Mock: it checks the expectation itself
    let mock = MockService(expecting: 7)
    ProfileViewModel(service: mock).load(id: 7)
    expect(mock.verify(), true)

    // Fake: works like the real thing, just simpler
    let fake = FakeService()
    fake.save(TestUser(id: 3, name: "Bo"))
    let vm = ProfileViewModel(service: fake)
    vm.load(id: 3)
    expect(vm.title, "Hi, Bo")

    // QUIZ: "A double that RECORDS calls for later assertions?" → a spy.
    //   Stub = canned answers. Mock = pre-programmed expectations. Fake = working light version.
}}

// MARK: - 2. Why constructor injection makes code testable

// ❌ Hard to test: the dependency is created inside, so a test always hits the real network.
//
//   final class FeedViewModel {
//       func load() { URLSession.shared.dataTask(with: url) { ... }.resume() }
//   }
//
// ✅ Testable: the dependency comes in through init, typed as a protocol.
//
//   final class FeedViewModel {
//       private let api: FeedAPI                  // protocol
//       init(api: FeedAPI) { self.api = api }     // test passes a stub
//   }
//
// Constructor (init) injection:  the dependency is visible at the call site, can be `let`,
//                                and the compiler forces you to provide it.
// Property injection (`var service: Service!` set after init): the compiler can't check
//                                it was set, so forgetting it crashes at runtime.
// Singletons (`APIClient.shared`): hide dependencies and share state between tests.
//                                Pass them in via init instead (it's fine as a default value).
//
// QUIZ: "Best change to make this view model testable?"
//   → inject a protocol through init. NOT "make the method public", NOT "mutate a global".

// MARK: - 3. Async tests: why you must WAIT

#Playground("3. Async tests need waiting") { demo {
    // A "test" that starts async work and returns immediately:
    let done = DispatchSemaphore(value: 0)
    func brokenTest() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            print("assertion runs now… but the test already finished")
            done.signal()
        }
        print("test function returned → reported as PASSED (even if the assertion would fail!)")
    }
    brokenTest()
    done.wait()

    // PREDICT: which line prints first? The "returned" line.
    // That's why XCTest has expectations: the test waits until fulfill() or a timeout.
}}

// XCTest, callback style:
//
//   func testLoadCallsBack() {
//       let exp = expectation(description: "loaded")
//       sut.load { result in
//           XCTAssertEqual(result, .success(1))
//           exp.fulfill()                       // ✅ mark it done
//       }
//       wait(for: [exp], timeout: 1)            // ✅ WITHOUT this the test ends right away
//   }
//
// XCTest, async/await style (Xcode 13+): no expectation needed.
//
//   func testLoad() async throws {
//       let user = try await sut.load()         // XCTest awaits the method
//       XCTAssertEqual(user.name, "Ann")        // a thrown error FAILS the test
//   }

// MARK: - 4. Comparing Doubles needs a tolerance

#Playground("4. Floating-point equality") { demo {
    let sum = 0.1 + 0.2
    print("0.1 + 0.2 =", sum)                 // 0.30000000000000004
    expect(sum == 0.3, false)                 // exact equality fails!
    expect(abs(sum - 0.3) < 0.0001, true)     // compare within a tolerance

    // XCTest:         XCTAssertEqual(sum, 0.3, accuracy: 0.0001)
    // Swift Testing:  #expect(abs(sum - 0.3) < 0.0001)
}}

// MARK: - 5. XCTest vs Swift Testing

// XCTest                                     Swift Testing
// ───────────────────────────────────────    ───────────────────────────────────────
// class T: XCTestCase                        @Suite struct T   (a struct is fine)
// func testSomething()  ("test" prefix)      @Test func something()
// override func setUp()  / tearDown()        init()  / deinit (deinit needs a class/actor)
// XCTAssertEqual(a, b)                       #expect(a == b)
// let x = try XCTUnwrap(optional)            let x = try #require(optional)
// one test per method                        @Test(arguments: [...]) parameterized
//
// Swift Testing creates a NEW suite instance for EVERY test, so `init()` is your setUp.
//
//   @Suite struct CartTests {
//       let cart: Cart
//       init() { cart = Cart() }               // runs before each @Test
//
//       @Test func addItem() throws {
//           cart.add("apple")
//           #expect(cart.count == 1)           // records a failure, test CONTINUES
//           let first = try #require(cart.items.first)   // fails AND STOPS the test
//           #expect(first == "apple")
//       }
//
//       @Test(arguments: [0, 1, 2])
//       func validIndexes(_ i: Int) { #expect(i >= 0) }
//       // → 3 separate test cases, reported one by one, run in parallel by default.
//       //   Two argument lists = every combination; zip(a, b) = pairs 1:1.
//   }
//
// QUIZ: #expect → soft check, keeps going. #require → hard precondition, needs `try`, stops.

#Playground("5. #expect vs #require (simulated)") { demo {
    struct RequireFailed: Error {}
    func require<T>(_ value: T?) throws -> T {
        guard let value else { throw RequireFailed() }
        return value
    }

    let items: [String] = []
    do {
        expect(items.count, 1)                // like #expect: prints ❌ and continues
        let first = try require(items.first)  // like #require: throws, the test stops here
        print("never reached:", first)
    } catch {
        print("test stopped at require")
    }
    // PREDICT: one ❌ line, then "test stopped at require".
}}

// MARK: - 6. Code coverage ≠ good tests

#Playground("6. 100% coverage, still buggy") { demo {
    func discount(_ price: Int) -> Int { price - price / 10 * 2 }   // bug: takes 20% instead of 10%

    // This "test" executes every line, so coverage says 100%…
    _ = discount(100)
    print("coverage: 100% ✅  but nothing was asserted")

    // …only an assertion finds the bug:
    expect(discount(100), 90)                 // ❌ got 80
    // Coverage measures which lines RAN, not whether the results were CHECKED.
}}

// MARK: - 7. UI tests and snapshot tests

// UI test (XCUITest) finds elements through the accessibility tree.
// Most reliable: an accessibilityIdentifier. It isn't shown to users, so it doesn't
// change with language, copy edits or layout.
//
//   // App code
//   loginButton.accessibilityIdentifier = "loginButton"           // UIKit
//   Button("Log In") { }.accessibilityIdentifier("loginButton")   // SwiftUI
//
//   // UI test
//   let app = XCUIApplication(); app.launch()
//   let login = app.buttons["loginButton"]                        // ✅ stable
//   XCTAssertTrue(login.waitForExistence(timeout: 5))
//   login.tap()
//   // ❌ app.buttons["Log In"] breaks in French. ❌ coordinates and indexes break on layout changes.
//
// Snapshot tests render a view and compare it pixel-by-pixel to a stored reference image.
//   + catch visual regressions cheaply
//   − brittle: a new iOS version, font rendering, simulator or device scale can change
//     pixels and fail the test even when nothing is really wrong. Pin the simulator/OS.

// MARK: - 8. Tooling: packages, builds, signing, crashes, debugging

// SPM vs CocoaPods
//   CocoaPods: Ruby tool, edits your project, you must open the generated .xcworkspace.
//   SPM: built into Swift and Xcode, Package.swift manifest, no extra tool or workspace.
//
// SPM: TARGETS vs PRODUCTS
//   A target is an internal build unit (one module). Clients of the package can only use
//   PRODUCTS. A target that isn't in any `.library(...)` product can't be imported by an app:
//
//     products: [
//         .library(name: "Core", targets: ["Core"]),
//         .library(name: "Networking", targets: ["Networking"]),   // ✅ now importable
//     ],
//
//   Also: each module only exposes `public` (or `open`) API. `internal` (the default)
//   stays inside the module. That's why splitting an app into packages enforces boundaries.
//
// BUILD CONFIGURATIONS + xcconfig
//   Debug / Staging / Release configurations, each with an .xcconfig file:
//     // Staging.xcconfig
//     PRODUCT_BUNDLE_IDENTIFIER = com.acme.app.staging
//     API_BASE_URL = staging.acme.com
//   Expose API_BASE_URL in Info.plist as $(API_BASE_URL), and make a scheme per environment.
//   No code edits between builds.
//
// SIGNING: entitlements vs provisioning profile
//   The app's entitlements (push notifications = aps-environment, iCloud, App Groups…) must
//   be a SUBSET of what the provisioning profile allows. "Profile doesn't include
//   aps-environment" → enable Push Notifications on the App ID (Signing & Capabilities),
//   then regenerate/download the profile.
//
// CRASH REPORTS: symbolication
//   Release builds have no function names. The dSYM file (debug symbols, matched by build
//   UUID) turns memory addresses back into function names and line numbers. Only addresses
//   for YOUR frames = the dSYM for that build is missing. Upload it (e.g. to Crashlytics).
//
// LLDB
//   v  x   reads the variable straight from memory/debug info. Fast, no code compiled.
//   p  x   evaluates an expression (compiles + runs code), prints with type info.
//   po x   evaluates and prints the object's description (debugDescription).
//
// XCODE CLOUD
//   Apple's CI/CD, set up inside Xcode / App Store Connect. Workflows run on triggers like a
//   push or pull request: build, test, archive, and deliver to TestFlight. Signing is managed.
//
// APP THINNING
//   Slicing:  the App Store builds a variant per device (only @3x images for a @3x phone,
//             only that device's architecture), so downloads are smaller.
//   On-demand resources: assets downloaded later, when needed.

// MARK: - Quiz cheat sheet
//
// Q: setUp() equivalent in Swift Testing?          A: The suite's init(). A new instance is made per test.
// Q: Test with an expectation but no wait?         A: Returns immediately. Add wait(for: [exp], timeout:).
// Q: Compare Doubles in XCTest?                    A: XCTAssertEqual(a, b, accuracy: 0.0001).
// Q: An `async throws` XCTest method?              A: Awaited directly. A thrown error fails the test.
// Q: #expect vs #require?                          A: #expect records and continues. try #require stops the test (and unwraps).
// Q: @Test(arguments: [0, 1, 2])?                  A: Three separate test cases, run in parallel, reported individually.
// Q: Xcode Cloud?                                  A: Apple CI/CD configured in Xcode, triggered by pushes/PRs, managed signing, ships to TestFlight.
// Q: Double that records calls?                    A: Spy. (Stub = canned values, Mock = expectations, Fake = simple working impl.)
// Q: 100% line coverage means?                     A: Every line ran. NOT that behavior was asserted.
// Q: Make a view model testable?                   A: Inject a protocol through init and pass a stub/spy in tests.
// Q: Most reliable way to find a UI-test element?  A: accessibilityIdentifier.
// Q: App slicing?                                  A: The App Store delivers device-specific variants (assets/architecture).
// Q: Snapshot test drawback?                       A: Brittle: OS, font or device rendering changes cause false failures.
// Q: Test pyramid, which kind most?                A: Unit tests. Then fewer integration tests, fewest UI tests.
// Q: Package target can't be imported by an app?   A: It isn't in any product. Only products are visible to clients.
// Q: CocoaPods vs SPM?                             A: CocoaPods = Ruby, modifies project, needs .xcworkspace. SPM = built into Swift/Xcode.
// Q: Staging bundle ID + base URL without code?    A: A build configuration + .xcconfig + its own scheme.
// Q: Profile lacks aps-environment?                A: Enable Push on the App ID / capability, regenerate the provisioning profile.
// Q: Crash log shows only addresses?               A: The dSYM is missing, so it can't be symbolicated.
// Q: LLDB read a variable without running code?    A: `v` (frame variable). p/po evaluate expressions.
