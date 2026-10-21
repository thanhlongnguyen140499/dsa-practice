//
//  09-Combine.swift
//  Interview
//
// Combine: a beginner's tour for iOS quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Before you run a block, PREDICT the output. Then run it and compare.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// Combine models "values over time" as a pipeline:
//
//   PUBLISHER  ──►  OPERATORS  ──►  SUBSCRIBER
//   (emits)         map, filter,     sink { } / assign(to:)
//                   debounce...
//
// A publisher sends 0 or more values, then AT MOST ONE completion:
//   .finished             normal end
//   .failure(error)       error end. After a completion, NOTHING more is sent, ever.
//
// Publisher<Output, Failure>: Failure == Never means "can't fail".
//
// Subscribing returns an AnyCancellable. The subscription lives exactly as long as
// that object. Keep it (usually in `var bag = Set<AnyCancellable>()`), or it stops.
//
// Common sources:
//   Just(1)                      one value, then finished
//   [1, 2, 3].publisher          each element, then finished
//   PassthroughSubject           you call send(). No stored value
//   CurrentValueSubject          you call send(). Stores the latest value
//   @Published var x             in an ObservableObject. $x is its publisher
//   Future                       one async result
//
// Today, Swift concurrency (async/await, AsyncSequence) and @Observable replace a
// lot of Combine, but it's still common in existing code and in interviews.

import Combine
import Foundation
import Playgrounds

// MARK: - 1. AnyCancellable: no reference, no subscription

#Playground("1. AnyCancellable lifetime") { demo {
    let subject = PassthroughSubject<Int, Never>()

    _ = subject.sink { print("discarded sink got", $0) }   // cancelled immediately
    var bag = Set<AnyCancellable>()
    subject.sink { print("stored sink got", $0) }.store(in: &bag)

    subject.send(1)
    // PREDICT: only "stored sink got 1".
    // AnyCancellable calls cancel() in its deinit. `_ =` (or a local `let` that goes out
    // of scope) deallocates it at once.

    bag.removeAll()                          // cancel = drop the cancellables
    subject.send(2)                          // nobody listens anymore
    print("after removeAll: nothing printed for 2")
}}

// QUIZ trap: a method like
//   func start() { timer.sink { ... } }      // result not stored
// "never receives values": the subscription dies at the end of start().
// Fix: `.store(in: &cancellables)` where `cancellables` is a property.

// MARK: - 2. @Published emits BEFORE the property changes (willSet)

#Playground("2. @Published uses willSet") { demo {
    final class Counter: ObservableObject {
        @Published var count = 0
    }

    let counter = Counter()
    let c = counter.$count.sink { value in
        print("emitted \(value), property still reads \(counter.count)")
    }
    counter.count = 5
    c.cancel()

    // PREDICT:
    //   emitted 0, property still reads 0     ← the current value on subscribe
    //   emitted 5, property still reads 0     ← sent in willSet, before the store
    // Rule: use the value the closure receives, don't read the property.
}}

// MARK: - 3. PassthroughSubject vs CurrentValueSubject

#Playground("3. Subjects") { demo {
    var bag = Set<AnyCancellable>()

    let events = PassthroughSubject<String, Never>()     // no memory
    events.send("lost")                                  // no subscriber → gone
    events.sink { print("event:", $0) }.store(in: &bag)
    events.send("tap")

    let state = CurrentValueSubject<Int, Never>(1)       // remembers the latest value
    state.send(20)
    state.sink { print("state:", $0) }.store(in: &bag)   // gets 20 right away
    print("state.value =", state.value)

    // PREDICT: event: tap, state: 20, state.value = 20
    // Passthrough = events (taps, notifications). CurrentValue = state (has a "now" value).
}}

// MARK: - 4. map vs flatMap vs switchToLatest

#Playground("4. map, flatMap, switchToLatest") { demo {
    var bag = Set<AnyCancellable>()

    // map: value → value
    [1, 2, 3].publisher.map { $0 * 10 }.sink { print("map:", $0) }.store(in: &bag)

    // flatMap: value → PUBLISHER, and it subscribes to every inner publisher.
    // Simulate search-as-you-type: each query starts a "request" we answer by hand.
    var requests: [String: PassthroughSubject<String, Never>] = [:]
    func search(_ q: String) -> AnyPublisher<String, Never> {
        let request = PassthroughSubject<String, Never>()
        requests[q] = request
        return request.eraseToAnyPublisher()
    }

    let flatQuery = PassthroughSubject<String, Never>()
    flatQuery.flatMap { search($0) }
        .sink { print("flatMap shows:", $0) }.store(in: &bag)

    flatQuery.send("sw")
    flatQuery.send("swift")
    requests["swift"]?.send("results for swift")
    requests["sw"]?.send("results for sw")    // old, slow response arrives LAST
    // flatMap shows BOTH, so the screen ends up showing stale "sw" results. ❌

    // map + switchToLatest: keep only the NEWEST inner publisher, cancel older ones.
    let latestQuery = PassthroughSubject<String, Never>()
    latestQuery.map { search($0) }.switchToLatest()
        .sink { print("switchToLatest shows:", $0) }.store(in: &bag)

    latestQuery.send("sw")
    latestQuery.send("swift")
    requests["swift"]?.send("results for swift")
    requests["sw"]?.send("results for sw")    // ignored: that request was cancelled ✅
}}

// MARK: - 5. debounce vs throttle

#Playground("5. debounce") { demo {
    let queue = DispatchQueue(label: "demo.debounce")
    let typing = PassthroughSubject<String, Never>()
    var bag = Set<AnyCancellable>()

    typing
        .debounce(for: .milliseconds(150), scheduler: queue)
        .sink { print("search for:", $0) }
        .store(in: &bag)

    // Burst 1: "s", "sw", "swi" typed quickly, then a pause
    for text in ["s", "sw", "swi"] { typing.send(text); Thread.sleep(forTimeInterval: 0.02) }
    Thread.sleep(forTimeInterval: 0.4)
    // Burst 2
    for text in ["swif", "swift"] { typing.send(text); Thread.sleep(forTimeInterval: 0.02) }
    Thread.sleep(forTimeInterval: 0.4)

    // PREDICT: "search for: swi", then "search for: swift". One per pause.
}}

// debounce(for: 0.3s)  waits until input has been QUIET for 0.3s, then sends the last value.
//                      Restarts the timer on every value. Use for: search box, autosave.
// throttle(for: 0.3s, latest:)  sends at most ONE value per 0.3s window, even while
//                      values keep coming. Use for: scroll events, button spam, location.
// Typing nonstop for 5s: debounce sends nothing until you stop. throttle sends ~every 0.3s.

// MARK: - 6. zip vs combineLatest vs merge

#Playground("6. zip, combineLatest, merge") { demo {
    var bag = Set<AnyCancellable>()

    let a = PassthroughSubject<Int, Never>()
    let b = PassthroughSubject<String, Never>()
    a.zip(b).sink { print("zip:", $0.0, $0.1) }.store(in: &bag)
    a.combineLatest(b).sink { print("combineLatest:", $0.0, $0.1) }.store(in: &bag)

    a.send(1)
    a.send(2)
    b.send("x")
    b.send("y")
    // PREDICT:
    //   zip pairs by INDEX (1st with 1st, 2nd with 2nd): zip 1 x, zip 2 y
    //   combineLatest pairs each new value with the LATEST of the other side,
    //   after both have sent once: combineLatest 2 x, combineLatest 2 y
    // (zip and combineLatest lines interleave, because both listen to the same sends.)

    // merge: SAME output type, values interleaved as they arrive. No pairing.
    let taps = PassthroughSubject<String, Never>()
    let swipes = PassthroughSubject<String, Never>()
    taps.merge(with: swipes).sink { print("merge:", $0) }.store(in: &bag)
    taps.send("tap")
    swipes.send("swipe")
    taps.send("tap again")
}}

// MARK: - 7. receive(on:) vs subscribe(on:)

#Playground("7. receive(on:) vs subscribe(on:)") { demo {
    func currentQueue() -> String { String(cString: __dispatch_queue_get_label(nil)) }

    let background = DispatchQueue(label: "demo.background")
    let ui = DispatchQueue(label: "demo.ui")       // stands in for DispatchQueue.main
    let done = DispatchSemaphore(value: 0)

    let c = Deferred { () -> Just<Int> in
        print("upstream work on:", currentQueue())
        return Just(1)
    }
    .subscribe(on: background)   // where the UPSTREAM subscription/work happens
    .receive(on: ui)             // where values are DELIVERED downstream from here on
    .sink { _ in
        print("sink runs on:", currentQueue())
        done.signal()
    }
    done.wait()
    c.cancel()

    // PREDICT: upstream work on demo.background, sink runs on demo.ui.
    // In an app: .receive(on: DispatchQueue.main) right before updating UI.
    // The position of subscribe(on:) in the chain doesn't matter much. receive(on:) does.
}}

// MARK: - 8. Errors end the stream: tryMap, replaceError, catch

#Playground("8. Errors") { demo {
    struct DivideByZero: Error {}
    var bag = Set<AnyCancellable>()

    [1, 2, 0, 4].publisher
        .tryMap { n -> Int in
            guard n != 0 else { throw DivideByZero() }
            return 100 / n
        }
        .replaceError(with: -1)
        .sink(receiveCompletion: { print("completion:", $0) },
              receiveValue: { print("value:", $0) })
        .store(in: &bag)
    // PREDICT: 100, 50, -1, finished. 4 is NEVER processed: the error ended the stream.

    // catch at the END of a long-lived pipeline: one failure kills it forever.
    func load(_ ok: Bool) -> AnyPublisher<String, DivideByZero> {
        ok ? Just("data").setFailureType(to: DivideByZero.self).eraseToAnyPublisher()
           : Fail(error: DivideByZero()).eraseToAnyPublisher()
    }

    let refreshA = PassthroughSubject<Bool, Never>()
    refreshA
        .setFailureType(to: DivideByZero.self)
        .flatMap { load($0) }
        .catch { _ in Just("fallback") }               // ❌ outside flatMap
        .sink(receiveCompletion: { print("A completion:", $0) },
              receiveValue: { print("A:", $0) })
        .store(in: &bag)
    refreshA.send(false)                               // fallback, then finished
    refreshA.send(true)                                // nothing: pipeline is dead

    let refreshB = PassthroughSubject<Bool, Never>()
    refreshB
        .flatMap { load($0).catch { _ in Just("fallback") } }   // ✅ catch INSIDE flatMap
        .sink { print("B:", $0) }
        .store(in: &bag)
    refreshB.send(false)                               // B: fallback
    refreshB.send(true)                                // B: data (still alive)
}}

// MARK: - 9. eraseToAnyPublisher

#Playground("9. eraseToAnyPublisher") { demo {
    let raw = PassthroughSubject<Int, Never>().map { $0 * 2 }.filter { $0 > 2 }
    print(type(of: raw))      // Filter<Map<PassthroughSubject<Int, Never>, Int>>: leaks implementation details

    let erased: AnyPublisher<Int, Never> = raw.eraseToAnyPublisher()
    print(type(of: erased))   // AnyPublisher<Int, Never>: a stable public API

    // Return AnyPublisher<Output, Failure> from functions so callers don't depend on
    // (and don't break when you change) the operator chain inside.
}}

// MARK: - 10. Retain cycles in sink

#Playground("10. [weak self] in sink") { demo {
    final class LeakyVM {
        @Published var text = ""
        var bag = Set<AnyCancellable>()
        init() {
            $text.sink { value in self.handle(value) }.store(in: &bag)   // ❌ strong self
        }
        func handle(_ value: String) {}
        deinit { print("LeakyVM deinit") }
    }

    final class SafeVM {
        @Published var text = ""
        var bag = Set<AnyCancellable>()
        init() {
            $text.sink { [weak self] value in self?.handle(value) }.store(in: &bag)   // ✅
        }
        func handle(_ value: String) {}
        deinit { print("SafeVM deinit") }
    }

    var leaky: LeakyVM? = LeakyVM()
    var safe: SafeVM? = SafeVM()
    leaky = nil
    safe = nil
    _ = (leaky, safe)
    // PREDICT: only "SafeVM deinit".
    // Cycle: self → bag → AnyCancellable → closure → self.
    // Also: .assign(to: \.text, on: self) retains self. Prefer .assign(to: &$text).
}}

// MARK: - 11. Future is eager, Deferred makes it lazy

#Playground("11. Future vs Deferred") { demo {
    let future = Future<Int, Never> { promise in
        print("Future work runs")
        promise(.success(42))
    }
    print("Future created")
    let c1 = future.sink { print("Future value", $0) }

    let deferred = Deferred {
        Future<Int, Never> { promise in
            print("Deferred work runs")
            promise(.success(7))
        }
    }
    print("Deferred created")
    let c2 = deferred.sink { print("Deferred value", $0) }
    _ = (c1, c2)

    // PREDICT:
    //   Future work runs      ← at CREATION, before anyone subscribed
    //   Future created
    //   Future value 42       ← Future replays its single result to subscribers
    //   Deferred created
    //   Deferred work runs    ← only on subscribe (and again for every new subscriber)
    //   Deferred value 7
}}

// MARK: - Quiz cheat sheet
//
// Q: AnyCancellable deallocated?                    A: cancel() runs in deinit. Store it (Set<AnyCancellable>).
// Q: sink result discarded inside start()?          A: Subscription dies immediately. No values arrive.
// Q: Reading the @Published property inside its sink?  A: Old value. @Published emits in willSet. Use the emitted value.
// Q: PassthroughSubject vs CurrentValueSubject?     A: Passthrough drops values with no subscriber. CurrentValue stores
//                                                      the latest and gives it to new subscribers (.value too).
// Q: map vs flatMap?                                A: map: value → value. flatMap: value → publisher, subscribes to each.
// Q: Search-as-you-type requests?                   A: map + switchToLatest: cancels the old request, no stale results.
// Q: debounce vs throttle?                          A: debounce waits for a quiet period, then the last value.
//                                                      throttle: at most one value per interval.
// Q: zip vs combineLatest?                          A: zip pairs by index (buffers). combineLatest pairs with the latest of each.
// Q: Interleave same-type publishers?               A: merge.
// Q: receive(on:) vs subscribe(on:)?                A: receive(on:) = where downstream gets values (use .main for UI).
//                                                      subscribe(on:) = where the upstream subscription/work happens.
// Q: tryMap throws on the 3rd value + replaceError? A: Values before it, then the replacement, then finished. Rest dropped.
// Q: catch at the end of a long-lived pipeline?     A: Fallback once, then the pipeline completes. Put catch inside flatMap.
// Q: Why eraseToAnyPublisher()?                     A: Hide the nested operator type behind a stable AnyPublisher API.
// Q: sink { self.x } stored in self's bag?          A: Retain cycle. Use [weak self] (or assign(to: &$prop)).
// Q: When does a Future's closure run?              A: Immediately at creation. Wrap in Deferred to run on subscribe.
