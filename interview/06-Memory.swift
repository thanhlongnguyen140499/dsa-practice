//
//  06-Memory.swift
//  Interview
//
// Memory (ARC, retain cycles, copy-on-write) and Performance (hangs, launch,
// scrolling, energy, Instruments).
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Before you run a block, PREDICT the output. Then run it and compare.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// Swift manages class memory with ARC (Automatic Reference Counting):
//   - every class instance has a count of STRONG references to it
//   - when that count reaches 0, deinit runs and the memory is freed right away
//   - this is NOT a garbage collector. Nothing scans memory later. It's immediate
//     and predictable.
//
// The one big problem: a RETAIN CYCLE. A holds B strongly and B holds A strongly.
// Neither count ever reaches 0 → both leak forever.
//
// How to break one:
//   strong   (default)  keeps the object alive
//   weak                doesn't keep it alive. Becomes nil when the object dies.
//                       Always Optional (`weak let` is allowed since Swift 6.2)
//   unowned             doesn't keep it alive, and is NOT optional. If you touch it
//                       after the object died → crash. Only use it when the other object
//                       is guaranteed to live at least as long
//
// Where cycles hide: closures stored on self, delegates, Timer, NotificationCenter
// block observers, Combine sinks.
//
// Value types (struct, enum) aren't reference counted. Each copy is independent.
// Array/String/Dictionary still use heap buffers, shared cheaply with COPY-ON-WRITE.

import Foundation
import Playgrounds

// MARK: - 1. ARC basics: deinit runs when the last strong reference goes

private final class Person {
    let name: String
    var apartment: Apartment?
    init(_ name: String) { self.name = name; print("  + \(name) init") }
    deinit { print("  - \(name) deinit") }
}

private final class Apartment {
    let unit: String
    var tenant: Person?                 // ❌ strong back-reference → cycle
    weak var weakTenant: Person?        // ✅ weak back-reference
    init(_ unit: String) { self.unit = unit; print("  + apt \(unit) init") }
    deinit { print("  - apt \(unit) deinit") }
}

#Playground("1. ARC basics") { demo {
    var a: Person? = Person("Ann")
    var b: Person? = a                  // 2 strong refs
    print("a = nil")
    a = nil                             // 1 left → still alive
    print("b = nil")
    b = nil                             // 0 → deinit right now
    print("done", b == nil)
    // Output: + Ann init, a = nil, b = nil, - Ann deinit, done true
}}

// MARK: - 2. Retain cycle between two objects, fixed with weak

#Playground("2. Object retain cycle") { demo {
    print("❌ strong both ways:")
    do {
        let bob = Person("Bob")
        let apt = Apartment("1A")
        bob.apartment = apt
        apt.tenant = bob                // Bob → apt → Bob ...
    }                                   // no deinit printed: LEAK

    print("✅ weak back-reference:")
    do {
        let cat = Person("Cat")
        let apt = Apartment("2B")
        cat.apartment = apt
        apt.weakTenant = cat
    }                                   // both deinit
}}

// MARK: - 3. Closure retain cycles: [weak self] / [unowned self]

private final class Downloader {
    var onFinish: (() -> Void)?         // self owns the closure
    let name: String
    init(_ name: String) { self.name = name }
    deinit { print("  - Downloader \(name) deinit") }

    func bindLeaky() {
        onFinish = { print("finished", self.name) }          // closure owns self → cycle
    }
    func bindWeak() {
        onFinish = { [weak self] in
            guard let self else { return }                    // may already be gone
            print("finished", self.name)
        }
    }
}

#Playground("3. Closure cycles") { demo {
    print("❌ leaky:")
    do { let d = Downloader("leaky"); d.bindLeaky() }   // no deinit
    print("✅ [weak self]:")
    do { let d = Downloader("weak"); d.bindWeak() }     // deinit prints
    // QUIZ: a cycle needs BOTH directions. A non-escaping closure (map, filter) or a
    //   closure self doesn't store (UIView.animate, a one-shot DispatchQueue.main.async)
    //   doesn't create a cycle. At most it keeps self alive a little longer.
    // QUIZ: [unowned self] is like weak but not optional. It CRASHES if self is gone.
    //   Use it only when self is guaranteed to outlive every call of the closure.
}}

// MARK: - 4. Capture lists: by reference vs copied value

#Playground("4. Capture lists") { demo {
    var count = 0
    let byReference = { count }         // captures the VARIABLE
    let byValue = { [count] in count }  // copies the VALUE (0) right now
    count = 5
    expect(byReference(), 5)
    expect(byValue(), 0)
}}

// MARK: - 5. Delegates must be weak

private protocol PlayerDelegate: AnyObject {       // AnyObject → only classes → `weak` allowed
    func didFinish()
}

private final class Player {
    weak var delegate: PlayerDelegate?             // ✅ weak. Without AnyObject this doesn't compile
    deinit { print("  - Player deinit") }
}

private final class PlayerScreen: PlayerDelegate {
    let player = Player()                          // screen owns the player
    init() { player.delegate = self }              // player points back (weakly)
    func didFinish() {}
    deinit { print("  - PlayerScreen deinit") }
}

#Playground("5. Weak delegate") { demo {
    do { _ = PlayerScreen() }                      // both deinit
    // QUIZ: "weak may only be applied to class types" → add `: AnyObject` to the protocol.
}}

// MARK: - 6. Timer and NotificationCenter keep things alive

private final class Ticker: NSObject {
    var timer: Timer?
    override init() {
        super.init()
        // target: self → the timer retains self, and the run loop retains the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: #selector(tick), userInfo: nil, repeats: true)
    }
    @objc private func tick() {}
    func stop() { timer?.invalidate() }            // the run loop drops the timer → it drops self
    deinit { print("  - Ticker deinit") }
}

private final class Listener {
    var token: NSObjectProtocol?
    init() {
        token = NotificationCenter.default.addObserver(
            forName: .init("demo.ping"), object: nil, queue: nil
        ) { [weak self] _ in self?.handle() }      // ✅ weak. Strong self here would leak
    }
    private func handle() {}
    deinit {
        if let token { NotificationCenter.default.removeObserver(token) }
        print("  - Listener deinit")
    }
}

#Playground("6. Timer + NotificationCenter") { demo {
    var ticker: Ticker? = Ticker()
    weak let weakTicker = ticker
    ticker = nil
    print("ticker still alive after = nil:", weakTicker != nil)   // true: the timer holds it
    weakTicker?.stop()                                             // invalidate → deinit
    print("alive after invalidate:", weakTicker != nil)

    do { _ = Listener() }                                          // deinit prints
    // QUIZ: a repeating Timer keeps its target alive until invalidate().
    //   Calling invalidate() from deinit never works, because deinit never runs.
    //   Fix: invalidate in viewWillDisappear, or use the block API with [weak self].
    // QUIZ: block-based observers are retained by NotificationCenter until removeObserver.
}}

// MARK: - 7. weak becomes nil, unowned crashes

#Playground("7. weak vs unowned") { demo {
    var owner: Person? = Person("Dan")
    weak let weakRef = owner
    owner = nil
    print("weak after dealloc:", weakRef as Any)       // nil (zeroed by the runtime)
    // unowned let u = Person("Eve"); ...after it's freed... print(u.name) → 💥 crash
}}

// MARK: - 8. Copy-on-write (COW)

private func address(of array: [Int]) -> UnsafeRawPointer? {
    array.withUnsafeBufferPointer { UnsafeRawPointer($0.baseAddress) }
}

/// Your own COW type: a struct wrapping a class buffer.
private struct Notes {
    private final class Storage { var items: [String] = [] }
    private var storage = Storage()

    var items: [String] { storage.items }

    mutating func append(_ note: String) {
        if !isKnownUniquelyReferenced(&storage) {     // shared? copy first
            let copy = Storage()
            copy.items = storage.items
            storage = copy
            print("  (copied buffer)")
        }
        storage.items.append(note)
    }
}

#Playground("8. Copy-on-write") { demo {
    let big = Array(repeating: 0, count: 1_000_000)
    var copy = big                                         // no copy yet: shared buffer
    print("same buffer after assign:", address(of: big) == address(of: copy))   // true
    copy[0] = 1                                            // FIRST mutation → real copy
    print("same buffer after write: ", address(of: big) == address(of: copy))   // false

    var a = Notes()
    a.append("x")                    // unique → no copy
    var b = a
    b.append("y")                    // shared → copies
    print(a.items, b.items)          // ["x"] ["x", "y"]
}}

// MARK: - 9. autoreleasepool in big loops

#Playground("9. autoreleasepool") { demo {
    var total = 0
    for i in 0..<1_000 {
        autoreleasepool {
            // Foundation/UIKit APIs (UIImage(contentsOfFile:), NSString bridging, Data...)
            // can return AUTORELEASED objects. They're freed only when the pool drains.
            // Without this inner pool, a 10,000-file loop on a background thread piles them up.
            let s = NSString(format: "file-%d", i)
            total += s.length
        }
    }
    print("total:", total)
}}

// MARK: - 10. Stack vs heap, struct copy cost (read)
//
// Heap:  class instances, closures that capture, the buffers inside Array/String/Dictionary.
//        Allocation + reference counting (atomic) = slower.
// Stack (or inline): simple structs/enums (Int, Double, CGPoint). Very cheap.
//
// A struct isn't automatically "cheap to copy": copying a struct with 3 Strings, an
// Array and a class reference does 5 retain/release operations, because each of those
// fields points to heap storage.
//
// `final` on a class → no subclass can override → static dispatch (faster) instead of
// a vtable lookup.

// MARK: - 11. Performance: hangs, launch, images, scrolling, energy

#Playground("11. Decoded image memory") { demo {
    // Memory depends on PIXELS, not file size: width × height × 4 bytes (RGBA).
    let bytes = 4_000 * 3_000 * 4
    print("decoded 4000×3000:", bytes / 1_000_000, "MB")       // 48 MB (the 2 MB JPEG doesn't matter)
    expect(bytes, 48_000_000)
    // Fix: downsample to the display size (ImageIO CGImageSourceCreateThumbnailAtIndex
    // or UIImage.preparingThumbnail(of:)). A 200×150 view needs only ~120 KB.
}}

#if canImport(UIKit)
import UIKit

private func configureCard(_ view: UIView) {
    // ❌ shadow + masksToBounds/cornerRadius with no shadowPath → offscreen rendering every frame
    // ✅ give the shadow its shape so Core Animation doesn't have to calculate it
    view.layer.shadowOpacity = 0.2
    view.layer.shadowRadius = 4
    view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 12).cgPath
}
#endif

// Hangs: the main thread must stay free (one frame = ~16 ms at 60 Hz). Don't do
//   sync networking, big JSON decoding, Data(contentsOf:) on big files, or image decoding there.
// Launch time: measured until the FIRST FRAME. Do less in didFinishLaunching, defer SDK
//   setup, load lazily, fewer dynamic frameworks.
// Scrolling: reuse cells, set shadowPath, avoid offscreen rendering, decode/resize images
//   off main, keep cellForRow cheap.
// Energy: batch network calls, avoid timers that poll. Location: use
//   startMonitoringSignificantLocationChanges (cell/Wi-Fi based) instead of continuous GPS.
//
// Tools:
//   Memory Graph Debugger (Debug bar button) → who's holding my object? Leaks marked with "!"
//   Instruments → Leaks, Allocations (growth), Time Profiler (CPU hot functions),
//                 Hangs/Animation Hitches, Energy Log, App Launch

// MARK: - Quiz cheat sheet
//
// Q: When does ARC free an object?           A: Immediately, when its strong reference count hits 0. Not a GC.
// Q: Access unowned after dealloc?           A: Crash (it's non-optional and not zeroed).
// Q: Access weak after dealloc?              A: It's nil. Weak refs are zeroed by the runtime.
// Q: Stored closure that uses self?          A: A retain cycle → use [weak self] (or unowned if self surely outlives it).
// Q: Why are delegates weak?                 A: The owner usually is the delegate → strong both ways = cycle.
// Q: Protocol for a weak delegate?           A: `protocol P: AnyObject` (class-only).
// Q: Repeating Timer with target: self?      A: The run loop → timer → self. Leaks until invalidate().
// Q: Block observer capturing self?          A: NotificationCenter retains it → leak until removeObserver / use weak.
// Q: unowned vs weak?                        A: unowned only when self is guaranteed to outlive the closure.
// Q: { count } vs { [count] in count }?      A: The first reads the current value. The capture list copies it at creation.
// Q: Find what retains a leaked VC?          A: Xcode Memory Graph Debugger.
// Q: Which tool finds CPU hot spots?         A: Instruments → Time Profiler.
// Q: Memory spike looping over files?        A: Wrap the loop body in autoreleasepool { }.
// Q: When is `var b = a` (array) copied?     A: On the first mutation (copy-on-write).
// Q: Usually on the heap?                    A: Class instances (and the buffers of Array/String).
// Q: Struct copy unexpectedly costly?        A: Its String/Array/class fields mean retain/release on heap storage.
// Q: Common cause of main-thread hangs?      A: Sync I/O / heavy work on main.
// Q: 4000×3000 image in memory?              A: ~48 MB (w × h × 4). File size doesn't matter. Downsample.
// Q: Improve launch time?                    A: Defer non-critical work past the first frame / off main.
// Q: Stutter with shadows + rounded corners? A: Offscreen rendering → set shadowPath, avoid masksToBounds with shadows.
// Q: Track big moves energy-efficiently?     A: Significant-location-change monitoring.
