//
//  04-SwiftUI.swift
//  Interview
//
// SwiftUI for iOS interview quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// The example views at file level compile on macOS too, so read them like normal app code.
// The #Playground demos run the parts of SwiftUI you can see WITHOUT drawing anything:
// observation, identity (view types), preference merging, task cancellation.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// SwiftUI is "declarative": a View is a cheap STRUCT that DESCRIBES the UI for
// the current state. It's not the on-screen object itself.
//
//     state changes → SwiftUI calls `body` again → diffs old vs new description
//                   → updates only what changed on screen
//
// So view structs are created and thrown away all the time. Anything that must
// SURVIVE that (counters, models, tasks) lives in storage SwiftUI manages for you.
// Who OWNS a piece of state decides which property wrapper to use:
//
//   I own a simple value            → @State
//   Someone else owns it, I edit it → @Binding
//   I own a reference-type model    → @State (with @Observable, iOS 17+)  |  @StateObject (ObservableObject)
//   I'm handed a model              → plain `let`/`var` (@Observable)    |  @ObservedObject
//   I need $bindings into a handed model → @Bindable (@Observable)
//   Shared far down the tree        → @Environment(Model.self)           |  @EnvironmentObject
//
// Identity: SwiftUI tracks each view by its POSITION in the view tree (structural
// identity) or by an explicit id (.id / ForEach ids). New identity = new view =
// state reset.

import Foundation
import SwiftUI
import Combine
import Observation
import Playgrounds

// MARK: - 1. State ownership: @State, @Binding, @StateObject vs @ObservedObject

private struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool                        // reads AND writes the parent's value
    var body: some View { Toggle(title, isOn: $isOn) }
}

private struct NotificationsScreen: View {
    @State private var pushEnabled = false         // source of truth, owned here
    var body: some View {
        ToggleRow(title: "Push", isOn: $pushEnabled)   // $ = pass a Binding
    }
}

private final class CounterModel: ObservableObject {
    @Published var count = 0
}

private struct BuggyCounter: View {
    @ObservedObject var model = CounterModel()     // ❌ new CounterModel every time the parent re-renders
    var body: some View { Button("Count: \(model.count)") { model.count += 1 } }
}

private struct FixedCounter: View {
    @StateObject private var model = CounterModel()   // ✅ created once, kept for the view's lifetime
    var body: some View { Button("Count: \(model.count)") { model.count += 1 } }
}

// Used by the demo below to see WHEN initializers run.
@Observable private final class HeavyModel {
    init() { print("   HeavyModel.init") }
}
private final class HeavyStore: ObservableObject {
    init() { print("   HeavyStore.init") }
}
private struct UsesState: View {
    @State var model = HeavyModel()
    var body: some View { EmptyView() }
}
private struct UsesStateObject: View {
    @StateObject var store = HeavyStore()
    var body: some View { EmptyView() }
}

#Playground("1. When do initializers run?") { demo {
    // Pretend the parent re-renders 3 times, so the child STRUCT is created 3 times.
    print("@State var model = HeavyModel()  ×3:")
    for _ in 1...3 { _ = UsesState() }
    print("@StateObject var store = HeavyStore()  ×3:")
    for _ in 1...3 { _ = UsesStateObject() }
    // PREDICT: HeavyModel.init prints 3 times. HeavyStore.init prints 0 times (here).
    //   @StateObject's initializer is an @autoclosure, run ONCE when the view first appears.
    //   @State is NOT lazy: the expression runs on every struct init, and SwiftUI throws the
    //   extra instances away and keeps the first one. Keep @State initializers cheap, or create
    //   the model in .task / pass it in.
}}

// MARK: - 2. @Observable (iOS 17+) vs ObservableObject

@Observable private final class ProfileModel {
    var name = "Ann"
    var age = 30
}

private final class LegacyProfile: ObservableObject {
    @Published var name = "Ann"
    @Published var age = 30
}

#Playground("2. Observation tracks what you READ") { demo {
    // @Observable: SwiftUI records which properties `body` READ, and only those invalidate it.
    let model = ProfileModel()
    withObservationTracking {
        _ = model.name                          // "body" only reads name
    } onChange: {
        print("   → body invalidated")
    }
    print("change age:");  model.age = 31       // nothing: age wasn't read
    print("change name:"); model.name = "Bo"    // invalidated

    // ObservableObject: ANY @Published change fires objectWillChange,
    // so every observing view re-renders, even if it never shows `age`.
    let legacy = LegacyProfile()
    var fired = 0
    let subscription = legacy.objectWillChange.sink { fired += 1 }
    legacy.age = 31
    legacy.name = "Bo"
    subscription.cancel()
    print("objectWillChange fired \(fired)×")   // 2
}}

private struct ProfileEditor: View {
    @Bindable var model: ProfileModel           // handed in. @Bindable gives us $model.name
    var body: some View { TextField("Name", text: $model.name) }
}

private struct ProfileScreen: View {
    @State private var model = ProfileModel()   // owner of an @Observable → plain @State
    var body: some View {
        ProfileEditor(model: model)
            .environment(model)                 // share down the tree…
    }
}

private struct ProfileBadge: View {
    @Environment(ProfileModel.self) private var model   // …read anywhere below
    var body: some View { Text(model.name) }
}

// The older way of sharing:
private final class AppSettings: ObservableObject { @Published var compact = false }
private struct SettingsRow: View {
    @EnvironmentObject var settings: AppSettings
    var body: some View { Toggle("Compact", isOn: $settings.compact) }
}
// QUIZ: if no ancestor calls .environmentObject(AppSettings()), the app CRASHES at runtime
//   when SettingsRow reads it. The compiler can't catch it.

// MARK: - 3. Identity: why state gets reset

@ViewBuilder
private func badge(highlighted: Bool) -> some View {
    if highlighted {
        Text("NEW").bold()
    } else {
        Text("NEW")
    }
}

private func badgeWithModifier(highlighted: Bool) -> some View {
    Text("NEW").opacity(highlighted ? 1 : 0.5)
}

#Playground("3. Structural identity") { demo {
    // Look at the TYPE SwiftUI sees. An if/else makes two different branches.
    print(type(of: badge(highlighted: true)))
    // _ConditionalContent<Text, Text>. Flipping the flag swaps branches,
    // so the view is a DIFFERENT view: its @State resets, and it animates as remove + insert.

    print(type(of: badgeWithModifier(highlighted: true)))
    // ModifiedContent<Text, _OpacityEffect>. It's the same view, so state is kept.
    // Prefer changing a modifier's value over if/else when it's "the same thing, looks different".
}}

private struct ResettableForm: View {
    @State private var draftID = UUID()
    var body: some View {
        VStack {
            FixedCounter()
                .id(draftID)                      // explicit identity
            Button("Reset") { draftID = UUID() }  // new id → brand-new view → its @State resets
        }
    }
}

#Playground("3b. ForEach needs unique, stable ids") { demo {
    let tags = ["swift", "ios", "swift"]
    // ForEach(tags, id: \.self) → two rows share the id "swift".
    let duplicates = Dictionary(grouping: tags, by: { $0 }).filter { $1.count > 1 }.keys
    print("duplicate ids:", Array(duplicates))
    // Result: undefined behavior. Wrong rows update, animations glitch, a console warning.

    // ✅ Give each element its own stable identity.
    struct Tag: Identifiable { let id = UUID(); let name: String }
    let fixed = tags.map { Tag(name: $0) }
    expect(Set(fixed.map(\.id)).count, 3)
    // QUIZ: ForEach(0..<items.count, id: \.self) is also risky. Indices aren't stable when
    //   items are inserted or deleted.
}}

// MARK: - 4. Modifier order matters

#Playground("4. Modifiers wrap, from inside out") { demo {
    // Each modifier WRAPS the view before it in a new view.
    let paddedThenColored = Text("Hi").padding(16).background(Color.blue)
    let coloredThenPadded = Text("Hi").background(Color.blue).padding(16)
    print(type(of: paddedThenColored))
    print(type(of: coloredThenPadded))
    // padded → background: blue fills the text AND the 16 pt padding.
    // background → padded: blue hugs only the text. The padding around it stays clear.

    // Same idea: Text("Hi").border(.red).frame(width: 200, height: 200)
    //   The border is drawn around the text's own small size. The frame then centers that
    //   bordered text inside an invisible 200×200 box.
}}

// MARK: - 5. Navigation and presentation

private struct Recipe: Hashable, Identifiable {
    let id: Int
    let name: String
}

private struct RecipeDetail: View {
    let recipe: Recipe
    var body: some View { Text(recipe.name) }
}

private struct EditRecipe: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss    // iOS 15+: the way to close a sheet from inside
    var body: some View { Button("Save \(recipe.name)") { dismiss() } }
}

private struct RecipeList: View {
    let recipes: [Recipe]
    @State private var path: [Recipe] = []         // programmatic navigation: push = append
    @State private var editing: Recipe?            // non-nil = sheet shown

    var body: some View {
        NavigationStack(path: $path) {
            List(recipes) { recipe in
                NavigationLink(recipe.name, value: recipe)   // only carries a VALUE…
            }
            // …the destination is looked up by the value's TYPE. Attach it OUTSIDE the lazy
            // List rows: a row that wasn't built yet couldn't register its destination.
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetail(recipe: recipe)
            }
            .toolbar {
                Button("Edit first") { editing = recipes.first }
            }
            // sheet(item:) hands you the UNWRAPPED value. With sheet(isPresented:) you'd keep a
            // Bool and an optional in sync yourself and could show stale/nil data.
            .sheet(item: $editing) { recipe in
                EditRecipe(recipe: recipe)
            }
        }
    }
}

// MARK: - 6. Async work: .task vs .onAppear

private func fakeSearch(_ query: String) async -> [String] {
    query.isEmpty ? [] : ["\(query) 1", "\(query) 2"]
}

private struct SearchScreen: View {
    @State private var query = ""
    @State private var results: [String] = []

    var body: some View {
        List(results, id: \.self) { Text($0) }
            .searchable(text: $query)
            // .task starts with the view and is CANCELLED automatically when the view goes away.
            // With id:, a new value cancels the running task and starts a new one.
            .task(id: query) {
                try? await Task.sleep(for: .milliseconds(300))   // simple debounce
                guard !Task.isCancelled else { return }
                results = await fakeSearch(query)
            }
    }
}
// .onAppear { Task { … } } is NOT cancelled when the view disappears. The work keeps
// running and may update a screen that's already gone.

#Playground("6. What .task(id:) does while you type") { demo {
    let finished = DispatchSemaphore(value: 0)

    func startSearch(_ query: String) -> Task<Void, Never> {
        Task.detached {
            do {
                try await Task.sleep(for: .milliseconds(150))
                print("   results for \"\(query)\"")
            } catch {
                print("   \"\(query)\" cancelled")       // Task.sleep throws when cancelled
            }
        }
    }

    var running: Task<Void, Never>?
    for query in ["s", "sw", "swi"] {                   // the user types fast
        running?.cancel()                               // what SwiftUI does when id changes
        running = startSearch(query)
        Thread.sleep(forTimeInterval: 0.03)
    }
    let last = running!
    Task.detached { await last.value; finished.signal() }
    finished.wait()
    // PREDICT: "s" and "sw" are cancelled, and only "swi" shows results.
}}

// MARK: - 7. Layout: GeometryReader and preferences

private struct ProgressBar: View {
    let progress: Double
    var body: some View {
        // GeometryReader is GREEDY: it takes ALL the space offered and tells you the size.
        // Its children are placed at the TOP-LEADING corner (not centered).
        GeometryReader { proxy in
            Capsule()
                .fill(Color.blue)
                .frame(width: proxy.size.width * progress)
        }
        .frame(height: 8)                              // so tame its height
    }
}

// Preferences send data UP the tree (child → ancestor), the opposite of the environment.
private struct MaxWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    // Several children can set the key. reduce MERGES their values into one.
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct AlignedLabels: View {
    let labels: [String]
    @State private var labelWidth: CGFloat = 0
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: MaxWidthKey.self, value: proxy.size.width)
                    })
                    .frame(width: labelWidth > 0 ? labelWidth : nil, alignment: .leading)
            }
        }
        .onPreferenceChange(MaxWidthKey.self) { labelWidth = $0 }
    }
}

#Playground("7. PreferenceKey.reduce") { demo {
    // What SwiftUI does with three children that report their widths:
    var merged = MaxWidthKey.defaultValue
    for width: CGFloat in [80, 120, 95] {
        MaxWidthKey.reduce(value: &merged) { width }
    }
    print("ancestor receives:", merged)      // 120.0 = the widest label
}}

// MARK: - 8. Animations and transitions

private struct DetailsToggle: View {
    @State private var showDetails = false
    @State private var liked = false

    var body: some View {
        VStack {
            // EXPLICIT: animate every change caused by this state update.
            Button("Details") {
                withAnimation(.spring) { showDetails.toggle() }
            }
            // A transition only plays when the insert/remove happens INSIDE an animation.
            // Toggle without withAnimation → the text just pops in, with no slide.
            if showDetails {
                Text("Sliding in").transition(.move(edge: .bottom))
            }

            // IMPLICIT: this part animates whenever `liked` changes, no matter who changed it.
            Image(systemName: "heart.fill")
                .scaleEffect(liked ? 1.3 : 1)
                .animation(.spring, value: liked)
                .onTapGesture { liked.toggle() }
        }
    }
}

// MARK: - 9. Performance

private struct Feed: View {
    let rows = Array(0..<10_000)
    var body: some View {
        ScrollView {
            // LazyVStack builds rows as they scroll into view. A plain VStack builds all 10,000 up front.
            LazyVStack {
                ForEach(rows, id: \.self) { Text("Row \($0)") }
            }
        }
    }
}

private struct Chart: View, Equatable {
    let points: [Double]
    let onTap: () -> Void                         // closures can't be compared…

    static func == (lhs: Chart, rhs: Chart) -> Bool {
        lhs.points == rhs.points                  // …so define "same" as "same data"
    }

    var body: some View {
        let _ = Self._printChanges()              // debug: logs WHY body ran
        Text("\(points.count) points").onTapGesture(perform: onTap)
    }
}
// Use it as Chart(...).equatable(). If == says equal, SwiftUI skips calling body.

#Playground("9. Equatable views") { demo {
    let a = Chart(points: [1, 2, 3], onTap: { print("a") })
    let b = Chart(points: [1, 2, 3], onTap: { print("b") })   // new closure, same data
    print("SwiftUI would skip body?", a == b)                // true
}}

// AnyView erases the concrete type, so SwiftUI loses structural identity and has to compare
// more at runtime. Fine occasionally. Prefer @ViewBuilder / `some View` / generics.
private func iconAnyView(_ online: Bool) -> AnyView {
    online ? AnyView(Image(systemName: "wifi")) : AnyView(Text("offline"))
}

// MARK: - 10. @ViewBuilder outside of body

private struct StatusView: View {
    let isOnline: Bool

    // Only `body` gets @ViewBuilder automatically (from the View protocol).
    // Without the attribute, an if/else returning Image vs Text won't compile:
    // `some View` needs ONE concrete type. Adding @ViewBuilder fixes it.
    @ViewBuilder var indicator: some View {
        if isOnline { Image(systemName: "wifi") } else { Text("offline") }
    }

    var body: some View { HStack { indicator; iconAnyView(isOnline) } }
}

// MARK: - 11. Wrapping UIKit: UIViewRepresentable + Coordinator

#if canImport(UIKit)
import MapKit

private struct MapView: UIViewRepresentable {
    @Binding var selectedTitle: String?

    // The struct is short-lived and can't be a delegate (delegates must be classes).
    // The Coordinator is a class SwiftUI keeps alive for as long as the UIKit view lives.
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> MKMapView {      // called ONCE
        let map = MKMapView()
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {  // called on every SwiftUI update
        context.coordinator.parent = self                     // keep the binding fresh
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(parent: MapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            parent.selectedTitle = annotation.title ?? nil   // talk back to SwiftUI via the binding
        }
    }
}
#endif

// MARK: - Quiz cheat sheet
//
// Q: What is @State for?                      A: Private storage SwiftUI keeps across re-renders. Changing it re-runs body.
// Q: Child must read+write the parent's Bool? A: @Binding var isOn: Bool. The parent passes $value.
// Q: Counter resets on every parent render?   A: The model was created with @ObservedObject. Use @StateObject (or @State + @Observable).
// Q: @EnvironmentObject never injected?       A: Runtime crash when it's read.
// Q: Dismiss a sheet from inside it?          A: @Environment(\.dismiss) private var dismiss → dismiss().
// Q: @Observable's big advantage?             A: Tracks per property, by what body READS. Fewer re-renders, no @Published needed.
// Q: $model.name on a handed-in @Observable?  A: Mark it @Bindable.
// Q: `@State var model = Model()` init cost?  A: Model() runs on every struct init (not lazy). @StateObject's init is an autoclosure, run once.
// Q: if/else toggle resets child state?       A: The branches have different structural identity (_ConditionalContent). Use a modifier instead.
// Q: .id(value) changes?                      A: It's a new view: state is reset, and onAppear/.task run again.
// Q: Why are views structs?                   A: They're cheap, throwaway descriptions. SwiftUI diffs them and owns the real UI.
// Q: Self._printChanges()?                    A: Debug log of what change made body run.
// Q: Blue behind text AND its padding?        A: .padding() first, then .background(...).
// Q: .border(.red).frame(200, 200)?           A: The border hugs the text. The frame centers it in a 200×200 area.
// Q: sheet(item:) vs sheet(isPresented:)?     A: item: is driven by an optional Identifiable and gives you the unwrapped value.
// Q: How does NavigationLink(value:) work?    A: NavigationStack finds a .navigationDestination(for: Type.self) matching the value's type.
// Q: Where to put .navigationDestination?     A: Outside lazy containers (on the List/stack), not inside the rows.
// Q: ForEach(…, id: \.self) with duplicates?  A: Broken identity. IDs must be unique and stable.
// Q: .task vs .onAppear for loading?          A: .task is async and auto-cancelled when the view disappears.
// Q: .task(id: query) while typing?           A: Each change cancels the previous task and starts a new one (cancellation is cooperative).
// Q: GeometryReader layout?                   A: Takes all offered space and places children top-leading.
// Q: PreferenceKey.reduce?                    A: Merges values from multiple children as they flow up the tree.
// Q: .animation(_:value:) vs withAnimation?   A: Implicit (on a subtree, triggered by that value) vs explicit (everything this state change causes).
// Q: Transition doesn't play?                 A: The insert/remove wasn't inside withAnimation (or an animation).
// Q: .equatable()?                            A: SwiftUI uses your == to skip body when "equal".
// Q: 10,000 rows in a ScrollView?             A: LazyVStack, which creates rows on demand.
// Q: Why avoid AnyView?                       A: It erases types, so SwiftUI loses identity info and has to compare more at runtime.
// Q: if/else in a computed property fails?    A: Add @ViewBuilder. Only body gets it implicitly.
// Q: Delegate callbacks in UIViewRepresentable? A: makeCoordinator() → a class Coordinator set as the delegate.
// Q: @AppStorage("key") var x = false?     A: Reads/writes UserDefaults and re-renders the view when it changes. Not secure: use Keychain for secrets.
