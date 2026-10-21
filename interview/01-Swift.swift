//
//  01-Swift.swift
//  Interview
//
// Swift language fundamentals for iOS interview quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Each #Playground block covers one idea. Before you run a block, read it
// and PREDICT the output. Then run it and compare.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// Most Swift quiz questions test one of these ideas:
//
//   1. VALUE vs REFERENCE types
//        struct / enum / tuple → copied when assigned ("my own copy")
//        class / closure       → shared when assigned ("same object, two names")
//
//   2. OPTIONALS: a value that might be missing (nil). Unwrap it safely with
//      if let, guard let, ?? or ?. . Unwrapping with ! crashes when the value is nil.
//
//   3. PROTOCOLS + GENERICS: describe what a type can do, then write code that
//      works for any type that can do it. some = one hidden concrete type,
//      any = a box that can hold any conforming type.
//
//   4. CLOSURES: functions you can store and pass around. They CAPTURE the
//      variables they use (by reference, unless you use a capture list).
//
//   5. SWIFT FEATURES that change what happens at compile time or at run time:
//      defer, lazy, property observers, property wrappers, result builders, macros.
//
// Remember: struct = copy, class = share. That answers many quiz questions.

import Foundation
import Playgrounds

// Protocols, extensions and attribute types (property wrappers, result builders) must
// be declared at file level, so they're `private` here to avoid name clashes with other files.

// MARK: - 1. Value types vs reference types

#Playground("1. Value vs reference") { demo {
    struct Size { var width: Int }        // value type
    final class Counter { var n = 0 }     // reference type

    var s1 = Size(width: 1)
    var s2 = s1                           // COPY
    s2.width = 99
    print("struct:", s1.width, s2.width)  // PREDICT → 1 99

    let c1 = Counter()
    let c2 = c1                           // SAME object
    c2.n = 99                             // allowed! `let` freezes the reference, not the object
    print("class:", c1.n, c2.n)           // PREDICT → 99 99
    print("same instance?", c1 === c2)    // === compares identity (classes only) → true

    s1.width += 0                         // (keeps `var s1` used as a var)

    // Things only CLASSES can do:
    //   inheritance, deinit, identity checks (===), more than one reference to the same instance.
    // Things BOTH can do: methods, initializers, protocols, extensions, generics.
    //
    // QUIZ: "let b = a; b.value = 5" compiles for a class (b is a constant REFERENCE),
    //   but NOT for a struct (a let struct is completely immutable).
}}

// MARK: - 2. Optionals: ??, optional chaining, try?

#Playground("2. Optionals") { demo {
    let nickname: String? = nil
    print(nickname ?? "Anonymous")                    // ?? gives a default → Anonymous

    struct Street { var name: String }
    struct Home { var street: Street? }
    struct Person { var home: Home? }

    let p: Person? = Person(home: Home(street: nil))
    let streetName = p?.home?.street?.name            // many ?. links...
    print(type(of: streetName))                       // ...still ONE level: Optional<String>
    print(streetName ?? "no street")                  // → no street

    enum ParseError: Error { case empty }
    func parse(_ s: String) throws -> Int {
        guard !s.isEmpty else { throw ParseError.empty }
        return s.count
    }
    let a = try? parse("")                            // error → nil (no crash)
    let b = try? parse("abc")                         // success → Optional(3)
    print(a as Any, b as Any)                         // → nil Optional(3)
    // try!  → crashes on error.  try (inside do/catch) → you handle the error.
}}

// MARK: - 3. Protocol extensions: static vs dynamic dispatch

private protocol Speaker {
    func hello()                         // a REQUIREMENT: listed in the protocol
}

private extension Speaker {
    func hello() { print("default hello") }
    func bye() { print("default bye") }  // NOT a requirement, only in the extension
}

private struct Robot: Speaker {
    func hello() { print("robot hello") }
    func bye() { print("robot bye") }
}

#Playground("3. Protocol extension dispatch") { demo {
    let concrete = Robot()
    concrete.hello()                     // → robot hello
    concrete.bye()                       // → robot bye

    let asProtocol: any Speaker = Robot()
    asProtocol.hello()                   // requirement → dynamic dispatch → robot hello
    asProtocol.bye()                     // extension-only → static dispatch → default bye  (!)

    // QUIZ: When the variable's type is the PROTOCOL, a method that's ONLY in the
    //   extension uses the extension's version, even if the real type has its own.
    //   Fix: add bye() to the protocol's requirements.
}}

// MARK: - 4. Generics, associated types, some vs any

private protocol Bag {
    associatedtype Element               // each conforming type picks its own Element
    var elements: [Element] { get }
}

private struct IntBag: Bag { var elements = [3, 1, 2] }
private struct WordBag: Bag { var elements = ["hi", "yo"] }

// Generic function: B is "some Bag", so B.Element is known.
private func firstElement<B: Bag>(of bag: B) -> B.Element? { bag.elements.first }

private protocol Shape { func area() -> Double }
private struct Square: Shape { var side: Double; func area() -> Double { side * side } }
private struct Circle: Shape { var r: Double; func area() -> Double { 3.14 * r * r } }

// some Shape: an OPAQUE type. ONE concrete type, hidden from the caller.
private func makeShape() -> some Shape { Square(side: 2) }

// any Shape: an EXISTENTIAL. A box that can hold a different type each time.
private func randomShape(_ flag: Bool) -> any Shape {
    flag ? Square(side: 1) : Circle(r: 1)    // ✅ different types are fine with `any`
}

#Playground("4. Generics + some/any") { demo {
    print(firstElement(of: IntBag()) as Any)     // → Optional(3)
    print(firstElement(of: WordBag()) as Any)    // → Optional("hi")

    print(makeShape().area())                    // → 4.0
    let shapes: [any Shape] = [Square(side: 1), Circle(r: 1)]   // mixed array needs `any`
    print(shapes.map { $0.area() })              // → [1.0, 3.14]
    print(randomShape(false).area())             // → 3.14

    // ❌ Doesn't compile: an opaque type must be the SAME concrete type on every path
    //   func bad(_ f: Bool) -> some Shape { f ? Square(side: 1) : Circle(r: 1) }
    //
    // QUIZ: some = faster (static dispatch, no boxing) but fixed to one type.
    //       any  = flexible, but values are boxed and calls go through dynamic dispatch.
}}

// MARK: - 5. Closures: @escaping, capturing, capture lists, @autoclosure

#Playground("5. Closures") { demo {
    // Capturing BY REFERENCE: the closure sees the variable, not a snapshot.
    var score = 1
    let live = { print("live:", score) }
    score = 2
    live()                                       // PREDICT → live: 2

    // Capture LIST: copies the value when the closure is CREATED.
    var level = 1
    let snapshot = { [level] in print("snapshot:", level) }
    level = 2
    snapshot()                                   // PREDICT → snapshot: 1
    _ = level

    // @escaping: needed when the closure OUTLIVES the function call
    // (stored in a property, or called later asynchronously).
    var handlers: [() -> Void] = []
    func register(_ h: @escaping () -> Void) { handlers.append(h) }   // stored → @escaping
    func runNow(_ h: () -> Void) { h() }                              // called right away → no attribute
    register { print("ran later") }
    runNow { print("ran now") }
    handlers.forEach { $0() }

    // @autoclosure: the argument expression is wrapped in a closure → evaluated LAZILY.
    func expensive() -> String { print("  (expensive called)"); return "data" }
    func log(_ msg: @autoclosure () -> String, enabled: Bool) {
        if enabled { print("log:", msg()) }
    }
    log(expensive(), enabled: false)             // prints NOTHING: expensive() never runs
    log(expensive(), enabled: true)              // → (expensive called), log: data
    // That's how assert() and ?? avoid evaluating their right side when they don't need it.
}}

// MARK: - 6. Enums: associated values, pattern matching, indirect

private indirect enum Expr {                     // `indirect`: the enum contains itself
    case number(Int)
    case add(Expr, Expr)
    case mul(Expr, Expr)
}

private func eval(_ e: Expr) -> Int {
    switch e {
    case .number(let n): return n
    case let .add(a, b): return eval(a) + eval(b)
    case let .mul(a, b): return eval(a) * eval(b)
    }
}

#Playground("6. Enums") { demo {
    enum Payment {
        case cash
        case card(last4: String, amount: Double)
    }
    let pay = Payment.card(last4: "4242", amount: 9.5)
    switch pay {
    case .cash: print("cash")
    case let .card(digits, amount):              // labels can be left out in the pattern
        print("card", digits, amount)            // → card 4242 9.5
    }

    // (2 + 3) * 4
    print(eval(.mul(.add(.number(2), .number(3)), .number(4))))   // → 20

    // QUIZ: Why `indirect`? A value type has a fixed size. An enum that contains itself
    //   would need infinite size. `indirect` stores that case in a heap box instead.
}}

// MARK: - 7. Errors, defer, typed throws

private enum NetErr: Error { case offline, timeout }

private func load(_ fail: Bool) throws(NetErr) -> String {    // typed throws (Swift 6 compiler)
    if fail { throw .offline }
    return "ok"
}

#Playground("7. Errors + defer") { demo {
    func steps() {
        defer { print("defer 1") }
        defer { print("defer 2") }
        print("body")
    }
    steps()                                      // PREDICT → body, defer 2, defer 1  (REVERSE order)

    // In Swift 6 language mode the compiler infers `throws(NetErr)` for this do block.
    // This package uses Swift 5 mode, so we write it out.
    do throws(NetErr) {
        _ = try load(true)
    } catch {
        // `error` has the static type NetErr here, not `any Error`,
        // so the switch is exhaustive and needs no default.
        switch error {
        case .offline: print("caught offline")
        case .timeout: print("caught timeout")
        }
    }
    // QUIZ: defer runs when the scope exits for ANY reason (return, throw, end of block).
    //   Typed throws (SE-0413): `throws(E)` → a catch gets `error: E`.
}}

// MARK: - 8. Properties: lazy, observers, mutating, access control

#Playground("8. Properties") { demo {
    final class Report {
        lazy var body: String = {
            print("  building body…")            // runs on FIRST access only
            return "report"
        }()
    }
    let r = Report()
    print("created")
    print(r.body)                                // → building body…, report
    print(r.body)                                // → report (no rebuild)
    // QUIZ: lazy is NOT thread-safe: two threads may initialize it twice. It must be a `var`.

    struct Volume {
        var level = 5 {
            willSet { print("  will change \(level) → \(newValue)") }
            didSet  { print("  did change \(oldValue) → \(level)") }
        }
    }
    var v = Volume()
    v.level = 8                                  // → will change 5 → 8, did change 5 → 8
    // QUIZ: observers do NOT fire for the default value or during the type's OWN init.

    struct Tally {
        var count = 0
        mutating func bump() { count += 1 }      // changes self → must be `mutating`
    }
    var t = Tally()
    t.bump()
    print("tally:", t.count)                     // → 1
    // let fixed = Tally(); fixed.bump()         // ❌ compile error: cannot mutate a `let` struct

    // ACCESS CONTROL (most open → most closed):
    //   open      → visible + subclassable/overridable outside the module
    //   public    → visible outside the module (not subclassable outside)
    //   internal  → DEFAULT. Visible in the whole module
    //   fileprivate → this file only
    //   private   → this declaration (+ its extensions in the same file)
}}

// MARK: - 9. Property wrappers and $projectedValue

@propertyWrapper
private struct Clamp {
    private var value: Int
    private let range: ClosedRange<Int>
    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
    var wrappedValue: Int {                      // what `x` reads and writes
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
    var projectedValue: String { "clamped to \(range)" }   // what `$x` gives you
}

private struct Stereo {
    @Clamp(0...10) var volume: Int = 42          // init(wrappedValue:) → clamped to 10
}

#Playground("9. Property wrappers") { demo {
    var s = Stereo()
    print(s.volume)                              // → 10
    s.volume = -5                                // goes through the wrapper's setter
    print(s.volume)                              // → 0
    print(s.$volume)                             // → clamped to 0...10
    // QUIZ: `$name` is the wrapper's projectedValue (only if the wrapper defines one).
    //   `_name` (private) is the wrapper instance itself.
    //   In SwiftUI: $state → Binding, because @State's projectedValue is a Binding.
}}

// MARK: - 10. Copy-on-write

private final class Storage { var items: [Int]; init(_ i: [Int]) { items = i } }

private struct CowList {
    private var storage = Storage([])
    var items: [Int] { storage.items }
    mutating func append(_ x: Int) {
        if !isKnownUniquelyReferenced(&storage) {    // shared? → copy before writing
            print("  copying buffer")
            storage = Storage(storage.items)
        }
        storage.items.append(x)
    }
}

#Playground("10. Copy-on-write") { demo {
    var a = CowList()
    a.append(1)                                  // a is the only owner → no copy
    var b = a                                    // shares the buffer (cheap)
    b.append(2)                                  // → copying buffer (now b gets its own)
    print(a.items, b.items)                      // → [1] [1, 2]
    a.append(3)                                  // unique again → no copy
    print(a.items)                               // → [1, 3]
    // Array, Dictionary, Set and String already do this for you.
}}

// MARK: - 11. final, Hashable, key paths

#Playground("11. final, Hashable, key paths") { demo {
    // final: no subclass can override → the compiler can call methods directly
    // (static dispatch) instead of through the vtable. It's faster and shows intent.
    final class Engine { func start() -> String { "vroom" } }
    print(Engine().start())

    // Hashable RULE: if a == b, then hash(a) MUST equal hash(b).
    struct User: Hashable {
        let id: Int
        var name: String
        static func == (l: User, r: User) -> Bool { l.id == r.id }
        func hash(into h: inout Hasher) { h.combine(id) }   // ✅ hash the SAME fields as ==
        // ❌ combining `name` too would break the rule: equal users could get different
        //   hashes, so Set/Dictionary would contain "duplicates" or miss lookups.
    }
    let set: Set = [User(id: 1, name: "An"), User(id: 1, name: "Anh")]
    print("set count:", set.count)               // → 1

    // A key path can be used as a function (Swift 5.2+)
    struct Pet { let name: String; let age: Int }
    let pets = [Pet(name: "Mo", age: 3), Pet(name: "Bo", age: 7)]
    print(pets.map(\.age))                       // → [3, 7]
    print(pets.map(\.name).sorted())             // → ["Bo", "Mo"]
}}

// MARK: - 12. Result builders (how SwiftUI's body works)

@resultBuilder
private enum ListBuilder {
    static func buildBlock(_ parts: [String]...) -> [String] { parts.flatMap { $0 } }
    static func buildExpression(_ s: String) -> [String] { [s] }
    static func buildOptional(_ p: [String]?) -> [String] { p ?? [] }        // `if` without else
    static func buildEither(first p: [String]) -> [String] { p }             // `if` branch of if/else
    static func buildEither(second p: [String]) -> [String] { p }            // `else` branch
}

@ListBuilder private func menu(isAdmin: Bool, isBeta: Bool) -> [String] {
    "Home"
    if isAdmin { "Admin panel" } else { "Profile" }
    if isBeta { "Beta lab" }
}

#Playground("12. Result builders") { demo {
    print(menu(isAdmin: true, isBeta: false))    // → ["Home", "Admin panel"]
    print(menu(isAdmin: false, isBeta: true))    // → ["Home", "Profile", "Beta lab"]
    // QUIZ: if/else (and switch) → buildEither(first:/second:)
    //       if without else      → buildOptional
    //       for loops            → buildArray
}}

// MARK: - 13. Macros (read only)
//
// Swift macros (5.9+) generate code at COMPILE time:
//   - They're written with SwiftSyntax and run in a sandboxed compiler plugin.
//   - Their input is type-checked, and the expansion is ADDED to your code (never removes it).
//   - You can see what they generate: right-click → "Expand Macro" in Xcode.
//   Freestanding:  #Preview { ... }, #expect(x == 1), #Playground { ... }
//   Attached:      @Observable, @Model (SwiftData)

// MARK: - Quiz cheat sheet
//
// Q: Struct copied, then the copy is mutated. Does the original change?   A: No. Value types are copied.
// Q: Class instance assigned to another let, then mutated?               A: Both see it. Same instance; let freezes only the reference.
// Q: What can a class do that a struct can't?                            A: Inheritance, deinit, identity (===).
// Q: nil ?? "Guest"?                                                     A: "Guest".
// Q: Type of a?.b?.c?.name (name: String)?                               A: String? (optional chaining flattens to one level).
// Q: Protocol variable calls a method that's only in the protocol EXTENSION? A: The extension's version (static dispatch).
// Q: Return the first associated-type item of any container?             A: func first<C: Container>(_ c: C) -> C.Item?
// Q: some vs any?                                                        A: some = one hidden concrete type. any = a box holding any conforming type.
// Q: some Shape returning Circle on one path, Square on another?         A: Compile error. An opaque type must be one concrete type.
// Q: When is @escaping required?                                         A: When the closure outlives the call (stored, or called async later).
// Q: Closure prints x after x changed (no capture list)?                 A: The NEW value (captured by reference).
// Q: Same with [x] in?                                                   A: The OLD value (copied at creation).
// Q: @autoclosure?                                                       A: Wraps the argument expression and evaluates it only if/when it's called.
// Q: Enum case that contains the enum itself?                            A: Needs `indirect` (otherwise its size would be infinite).
// Q: try? on a throwing call that fails?                                 A: nil (try! would crash).
// Q: Multiple defers?                                                    A: Run at scope exit in REVERSE order.
// Q: Swift 6 typed throws: type of `error` in catch?                     A: The concrete error type (e.g. NetworkError), not any Error.
// Q: $name for @Wrapper var name?                                        A: The wrapper's projectedValue.
// Q: Assigning out-of-range to a clamping wrapper?                       A: Goes through wrappedValue's setter → clamped.
// Q: Default access level?                                               A: internal (whole module).
// Q: Calling a mutating method on a let struct?                          A: Compile error.
// Q: lazy var?                                                           A: Initialized on first access, once. Not thread-safe. Must be var.
// Q: willSet / didSet?                                                   A: newValue before, oldValue after. Not called during the type's own init.
// Q: Copy-on-write for a custom struct?                                  A: isKnownUniquelyReferenced(&storage) → copy only if shared.
// Q: What does `final` do?                                               A: No subclassing/overriding → static dispatch, faster.
// Q: == uses id but hash uses id + name?                                 A: Breaks the Hashable contract (equal values must hash equal).
// Q: users.map(\.age)?                                                   A: Key path as a function → [ages].
// Q: Result builder method for if/else?                                  A: buildEither(first:) / buildEither(second:).
// Q: Swift macros?                                                       A: Compile-time, type-checked, sandboxed, additive, expandable in Xcode.
