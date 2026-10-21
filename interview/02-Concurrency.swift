//
//  02-Concurrency.swift
//  Interview
//
// Swift Concurrency (async/await, actors, tasks) + the GCD traps quizzes love.
// GCD basics (queues, sync/async, groups, barriers, semaphores) are in
// solutions/GCD-testing.swift. Do that one first.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Before you run a block, PREDICT the output. Then run it and compare.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// GCD:   "run this closure on that queue". You think in queues and threads.
// Swift: "this function is async". You think in TASKS, and the compiler
//        checks your code for data races.
//
//   async func      → a function that can PAUSE (suspend) in the middle
//   await           → marks a place where it MAY pause. While paused, the thread
//                     is free to run other work. It is not blocked.
//   Task { }        → starts new async work from normal (sync) code
//   async let       → starts a child task now, and you await its result later
//   TaskGroup       → starts a dynamic number of child tasks
//   actor           → a class-like type that protects its state: only one task
//                     can use it at a time, so its data can't race
//   @MainActor      → "run on the main thread". Use it for UI code
//   Sendable        → "this value is safe to pass between tasks/actors"
//
// Structured (async let, TaskGroup): a child can't outlive its parent scope.
//   If the parent ends, it cancels the children and waits for them.
// Unstructured (Task { }, Task.detached { }): lives on its own. You manage it.
//
// The demos call runAsync { } so that all async work finishes before the
// block ends. runAsync blocks the calling thread, which is fine in a demo
// and NEVER okay on the main thread in a real app.

import Foundation
import Playgrounds

/// Runs async code from a sync demo and waits for it to finish.
private func runAsync(_ operation: @escaping @Sendable () async -> Void) {
    let done = DispatchSemaphore(value: 0)
    Task.detached {
        await operation()
        done.signal()
    }
    done.wait()
}

private func sleep(ms: UInt64) async {
    try? await Task.sleep(nanoseconds: ms * 1_000_000)
}

// MARK: - 1. async / await: suspension, not blocking

private func loadNumber(_ n: Int, delayMs: UInt64) async -> Int {
    print("  start \(n)")
    await sleep(ms: delayMs)          // suspension point: the thread goes off to do other work
    print("  end   \(n)")
    return n
}

#Playground("1. async/await") { demo {
    runAsync {
        print("A")
        let x = await loadNumber(1, delayMs: 50)   // waits HERE, but doesn't block a thread
        print("B got", x)
        let y = await loadNumber(2, delayMs: 50)   // starts only after 1 has finished
        print("C got", y)
    }
    // Output: A, start 1, end 1, B got 1, start 2, end 2, C got 2
    // QUIZ: `await` marks a POSSIBLE suspension point. It doesn't create a thread,
    //   and it doesn't block one. Plain `await a(); await b()` runs one after the other.
}}

// MARK: - 2. async let: run things in parallel

#Playground("2. async let") { demo {
    runAsync {
        let clock = ContinuousClock()

        let sequential = await clock.measure {
            _ = await loadNumber(1, delayMs: 200)
            _ = await loadNumber(2, delayMs: 200)
        }
        let parallel = await clock.measure {
            async let a = loadNumber(3, delayMs: 200)   // starts NOW
            async let b = loadNumber(4, delayMs: 200)   // also starts NOW
            _ = await (a, b)                            // wait for both
        }
        print("sequential ≈ 0.4s:", sequential > .milliseconds(380))
        print("parallel   ≈ 0.2s:", parallel < .milliseconds(350))
    }
    // QUIZ: with async let, the total time ≈ the SLOWEST child, not the sum.
    // QUIZ: if you never await an async let, it's cancelled and awaited when the
    //   scope ends. A child task can never outlive its scope (see section 6).
}}

// MARK: - 3. TaskGroup: results arrive in FINISH order

#Playground("3. TaskGroup") { demo {
    runAsync {
        let delays: [UInt64] = [150, 50, 100]          // index 1 is the fastest

        let finishOrder = await withTaskGroup(of: Int.self) { group in
            for (index, delay) in delays.enumerated() {
                group.addTask {
                    await sleep(ms: delay)
                    return index
                }
            }
            var order: [Int] = []
            for await index in group { order.append(index) }   // order of completion
            return order
        }
        print("finish order:", finishOrder)                    // [1, 2, 0]

        // Need the original order? Return (index, value) and put it back in place.
        let inOrder = await withTaskGroup(of: (Int, String).self) { group in
            for (index, delay) in delays.enumerated() {
                group.addTask {
                    await sleep(ms: delay)
                    return (index, "result\(index)")
                }
            }
            var results = Array(repeating: "", count: delays.count)
            for await (index, value) in group { results[index] = value }
            return results
        }
        print("restored order:", inOrder)                      // [result0, result1, result2]
    }
}}

// MARK: - 4. Actors and REENTRANCY (classic hard question)

private actor Counter {
    private(set) var value = 0
    func increment() { value += 1 }
}

private actor BankAccount {
    private(set) var balance = 100

    // ❌ The check and the update are split by an `await`.
    func withdrawBuggy(_ amount: Int) async -> Bool {
        guard balance >= amount else { return false }
        await sleep(ms: 50)            // suspension: the actor can run OTHER calls now
        balance -= amount
        return true
    }

    // ✅ Check and update with no `await` in between (or check again after the await).
    func withdrawSafe(_ amount: Int) async -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        await sleep(ms: 50)            // slow work AFTER the state change is fine
        return true
    }
}

#Playground("4. Actors + reentrancy") { demo {
    runAsync {
        let counter = Counter()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1_000 { group.addTask { await counter.increment() } }
        }
        print("actor counter:", await counter.value)          // always 1000 (no race)

        let buggy = BankAccount()
        async let w1 = buggy.withdrawBuggy(80)
        async let w2 = buggy.withdrawBuggy(80)
        print("buggy:", await w1, await w2, "balance", await buggy.balance)   // true true -60 😱

        let safe = BankAccount()
        async let s1 = safe.withdrawSafe(80)
        async let s2 = safe.withdrawSafe(80)
        print("safe: ", await s1, await s2, "balance", await safe.balance)    // one false, balance 20
    }
    // QUIZ: an actor removes DATA RACES (two threads touching memory at once),
    //   but NOT logic races across an `await`. Actors are REENTRANT: while one call
    //   is suspended, other calls can run and change the state.
    // QUIZ: outside the actor you must `await` to touch its state (actor.balance).
}}

// MARK: - 5. Task vs Task.detached, priority and task-locals

// Usually written `@TaskLocal static var id = "none"` and read as `$id.withValue`.
// @TaskLocal is itself a macro, and its `$id` isn't visible inside #Playground, so this
// uses the TaskLocal type it expands to.
private enum RequestContext {
    static let id = TaskLocal(wrappedValue: "none")
}

#Playground("5. Task vs Task.detached") { demo {
    runAsync {
        await RequestContext.id.withValue("req-42") {
            let inherited = Task { RequestContext.id.get() }            // copies the context
            let detached = Task.detached { RequestContext.id.get() }    // starts with nothing
            print("Task:", await inherited.value, "| detached:", await detached.value)
        }
    }
    // Output: Task: req-42 | detached: none
    //
    // Task { }          inherits: the ACTOR (e.g. stays on @MainActor), priority, task-locals
    // Task.detached { } inherits: nothing. Use it rarely
    //
    // QUIZ: Task { } inside a @MainActor method still runs on the MAIN actor.
    //   To move heavy work off main: call a nonisolated async func, or use Task.detached.
    // QUIZ: dropping the handle (`_ = Task { ... }`) does NOT cancel the task.
    //   Unstructured tasks keep running until they finish or you call cancel().
}}

// MARK: - 6. Cancellation is COOPERATIVE

#Playground("6. Cancellation") { demo {
    runAsync {
        // PREDICT: we cancel after ~120ms. Which numbers print?
        let ignoresCancel = Task {
            for i in 1...5 {
                print("  ignoring:", i)
                try? await Task.sleep(nanoseconds: 50_000_000)   // throws at once when cancelled, but try? swallows it
            }
        }
        await sleep(ms: 120)
        ignoresCancel.cancel()
        await ignoresCancel.value          // prints all of 1...5: 4 and 5 come instantly

        let respectsCancel = Task {
            for i in 1...5 {
                if Task.isCancelled { print("  stopped before", i); return }
                print("  checking:", i)
                await sleep(ms: 50)
            }
        }
        await sleep(ms: 120)
        respectsCancel.cancel()
        await respectsCancel.value         // 1, 2, 3, stopped before 4

        // An async let that's never awaited is cancelled when the scope ends.
        func neverAwaited() async {
            async let _ = {
                await sleep(ms: 100)
                print("  child saw isCancelled =", Task.isCancelled)   // true
            }()
        }
        await neverAwaited()
    }
    // QUIZ: cancel() only sets a flag. Your code must check Task.isCancelled /
    //   try Task.checkCancellation(), or call APIs that throw CancellationError (Task.sleep).
}}

// MARK: - 7. AsyncStream + continuations: wrapping callback APIs

private final class FakeLocationManager {
    var onUpdate: ((Int) -> Void)?
    var onFinish: (() -> Void)?
    func start() {
        DispatchQueue.global().async {
            for meters in [10, 20, 30] { self.onUpdate?(meters) }
            self.onFinish?()
        }
    }
}

private func legacyFetch(completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { completion("data") }
}

#Playground("7. AsyncStream + continuation") { demo {
    runAsync {
        // ONE callback → withCheckedContinuation. Resume EXACTLY once.
        let value = await withCheckedContinuation { continuation in
            legacyFetch { continuation.resume(returning: $0) }
        }
        print("continuation:", value)

        // MANY callbacks (delegate, observer) → AsyncStream.
        let manager = FakeLocationManager()
        let updates = AsyncStream<Int> { continuation in
            manager.onUpdate = { continuation.yield($0) }
            manager.onFinish = { continuation.finish() }   // ends the for-await loop
            manager.start()
        }
        for await meters in updates { print("moved", meters, "m") }
        print("stream finished")
    }
    // QUIZ: a for-await loop ends when the sequence returns nil (finish()),
    //   or when it throws (AsyncThrowingStream).
    // QUIZ: resuming a CheckedContinuation twice → crash (trap).
    //   Never resuming it → the caller waits forever (a runtime warning is logged).
}}

// MARK: - 8. Sendable, @MainActor, Swift 6 strict checking (read)

// A data race = two threads touch the same memory at the same time, at least one
// of them writes, and nothing synchronizes them → undefined behavior.
//
// Sendable = safe to share across tasks/actors. Checked at COMPILE time.
//   ✅ structs/enums whose properties are all Sendable (Int, String, ...)
//   ✅ actors
//   ✅ final classes with only `let` Sendable properties
//   ❌ a class with `var` properties (unless you mark it @unchecked Sendable and lock it yourself)
//
//   final class Counter { var count = 0 }          // not Sendable
//
//   func f() async {
//       let c = Counter()
//       Task { c.count += 1 }    // Swift 6: OK only if `c` is never used here again
//       print(c.count)           //   ❌ error: `c` was sent into the task, then used here
//   }
//
// Swift 6 "region-based isolation" (SE-0414): you CAN send a non-Sendable value
// into another task, IF the compiler can prove the sender never touches it again.
//
// @MainActor class ViewModel { var title = "" }
//   - every member runs on the main thread
//   - from other code you call it with `await`
//   - @MainActor ≈ DispatchQueue.main.async, checked by the compiler

@MainActor private final class ProfileViewModel {
    var title = "Loading…"
    func load() async {
        let name = await fetchName()        // runs off the main actor (nonisolated)
        title = "Hello, \(name)"            // back on the main actor
    }
    nonisolated private func fetchName() async -> String { "Edward" }
}

// MARK: - 9. GCD & OperationQueue traps

#Playground("9. Serial queue: impossible outputs") { demo {
    let queue = DispatchQueue(label: "trap.serial")
    queue.async { print("1") }
    print("2")
    queue.sync { print("3") }
    print("4")
    // Rules: serial → 1 before 3. sync waits for 3 → 4 is last.
    //   "2" can come before or after "1".
    // Possible: 1 2 3 4 · 2 1 3 4      IMPOSSIBLE: anything with 3 before 1, or 4 not last
}}

#Playground("9b. OperationQueue dependencies") { demo {
    let queue = OperationQueue()
    let a = BlockOperation { print("A") }
    let b = BlockOperation { print("B") }
    let c = BlockOperation { print("C (always last)") }
    c.addDependency(a)
    c.addDependency(b)
    queue.addOperations([a, b, c], waitUntilFinished: true)
    // A and B can print in either order. C waits for both.
    // OperationQueue also has cancel(), maxConcurrentOperationCount and KVO state (isFinished…).
}}

// Read-only traps (running these would hang or misbehave):
//
// ❌ DispatchQueue.main.sync { } called FROM the main thread → deadlock.
//    The main queue is busy waiting for the block, and the block waits for the main queue.
//
// ❌ DispatchQueue.global().async(flags: .barrier) { } → NOT exclusive.
//    Barriers only work on a concurrent queue YOU created.
//
// ❌ Thread explosion: thousands of blocking items (sleep, sync I/O, semaphore.wait)
//    on a concurrent queue. GCD keeps adding threads while the others are blocked → hundreds
//    of threads, memory and context-switch overhead. Fix: don't block, limit the work, or use
//    Swift concurrency (its thread pool has one thread per core and never blocks).
//
// ❌ Semaphore priority inversion: a high-priority thread waits on a semaphore, but the
//    system doesn't know WHICH thread will signal it, so it can't boost that low-priority
//    thread. Locks with an owner (os_unfair_lock, NSLock) and serial-queue sync let the
//    system boost the owner.

// MARK: - Quiz cheat sheet
//
// Q: What does `await` mean?                 A: A possible suspension point. The thread is freed, not blocked.
// Q: Why use an actor?                       A: It isolates mutable state and runs one call at a time → no data races.
// Q: Actor + `await` inside a method?        A: Reentrancy: other calls can run during the await. Re-check state after it.
// Q: Sendable?                               A: A compile-time promise that a value can cross tasks/actors safely.
// Q: @MainActor on a class?                  A: All its members run on the main thread. Callers from elsewhere must await.
// Q: Task { } vs Task.detached { }?          A: Task inherits the actor/priority/task-locals. detached inherits nothing.
// Q: Task handle goes out of scope?          A: The task keeps running. Cancel it explicitly (e.g. in onDisappear/deinit).
// Q: TaskGroup result order?                 A: Completion order. Return an index to restore the original order.
// Q: Is cancel() immediate?                  A: No. It's cooperative: check isCancelled / checkCancellation().
// Q: Task.sleep when cancelled?              A: Throws CancellationError right away (try? hides it → the loop continues).
// Q: async let a; async let b; await both?   A: They run in parallel: total ≈ max(a, b), not a + b.
// Q: async let never awaited?                A: Cancelled and implicitly awaited when the scope ends.
// Q: Callback with many values → async?      A: AsyncStream / AsyncThrowingStream (yield + finish).
// Q: Single callback → async?                A: withCheckedContinuation / withCheckedThrowingContinuation.
// Q: When does `for await` end?              A: When next() returns nil (finish), or it throws.
// Q: Continuation resumed twice?             A: Crash (the checked one traps). It must be resumed exactly once.
// Q: Swift 6: send a non-Sendable into Task? A: Allowed only if the caller never uses it afterwards (region isolation).
// Q: main.sync on the main thread?           A: Deadlock.
// Q: Serial queue async(1), sync(3)?         A: 1 always before 3. Code after sync runs after 3.
// Q: Serial vs concurrent queue?             A: Both start in FIFO order. Serial runs one at a time. Concurrent overlaps.
// Q: Barrier on a global queue?              A: No effect. Only on your own concurrent queue.
// Q: group.notify(queue: .main)?             A: Runs the block on main when all group work is done. Doesn't block.
// Q: QoS for animations/UI events?           A: .userInteractive.
// Q: OperationQueue dependency?              A: An op waits until all its dependencies finish. Independent ops: any order.
// Q: What is a data race?                    A: Unsynchronized concurrent access where at least one access is a write.
// Q: Thread explosion cause?                 A: Many work items blocking on a concurrent queue → GCD spawns more threads.
// Q: Why can semaphores cause priority inversion? A: No owner → the system can't boost the thread that will signal.
