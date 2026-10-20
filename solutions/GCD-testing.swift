//
//  GCD-testing.swift
//  Solutions
//
//  Created by Edward Nguyen on 20/10/26.
//
// Grand Central Dispatch (GCD): a beginner's tour for iOS quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Each #Playground block covers one idea. Before you run a block, read it
// and PREDICT the output. Then run it and compare.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// With GCD you don't create threads. You put closures ("tasks") on QUEUES,
// and GCD picks a thread from its thread pool to run them.
//
// A queue has two properties. Don't mix them up:
//
//   1. SERIAL or CONCURRENT: how the queue RUNS its tasks
//        serial     → one task at a time, in FIFO order
//        concurrent → many at once. They START in FIFO order, but can FINISH in any order
//
//   2. sync or async: how YOU SUBMIT a task (what the caller does)
//        sync  → the caller waits until the task is done
//        async → the caller returns right away. The task runs later
//
// The queues you'll use:
//   DispatchQueue.main                       serial. The only queue for UI work
//   DispatchQueue.global(qos: ...)           concurrent. Shared by the whole system
//   DispatchQueue(label: "x")                your own serial queue
//   DispatchQueue(label: "x", attributes: .concurrent)   your own concurrent queue
//
// QoS (priority), highest to lowest:
//   .userInteractive > .userInitiated > .default > .utility > .background
//
// The usual iOS pattern:
//   DispatchQueue.global(qos: .userInitiated).async {
//       let data = heavyWork()              // off the main thread
//       DispatchQueue.main.async {
//           self.label.text = data          // UI updates ALWAYS on main
//       }
//   }
//
// The demos below call group.wait() / semaphore.wait() so that every
// background task has finished before the block ends. That keeps the
// canvas output complete. In a real app, NEVER block the main thread like this.

import Foundation
import Playgrounds

// A #Playground body is an async context, and there Swift warns about blocking calls
// like wait() and Thread.sleep. Running each demo inside a plain closure avoids that.
func demo(_ body: () -> Void) { body() }

// MARK: - 1. sync vs async

#Playground("1. sync vs async") { demo {
    let queue = DispatchQueue(label: "demo.serial")

    print("A")
    queue.sync { print("B (sync: the caller waits for me)") }
    print("C")
    queue.async { print("E (async: runs later)") }
    print("D")

    queue.sync {}   // empty sync = "wait until everything before me is done"

    // Output: A, B, C, D, E  (D usually prints before E, but GCD doesn't promise that.)
    // QUIZ: "Does sync mean the task runs on the current thread?"
    //   Often yes, as an optimization, but the rule you must know is:
    //   sync BLOCKS THE CALLER until the task finishes.
}}

// MARK: - 2. Serial vs concurrent queue

#Playground("2. Serial vs concurrent") { demo {
    let serial = DispatchQueue(label: "demo.serial")
    let concurrent = DispatchQueue(label: "demo.concurrent", attributes: .concurrent)
    let group = DispatchGroup()

    print("— serial: always 1, 2, 3")
    for i in 1...3 {
        serial.async(group: group) {
            Thread.sleep(forTimeInterval: Double(4 - i) * 0.05)  // task 1 is the slowest
            print("serial \(i)")
        }
    }
    group.wait()

    print("— concurrent: they run at the same time, so the fastest (3) finishes first")
    for i in 1...3 {
        concurrent.async(group: group) {
            Thread.sleep(forTimeInterval: Double(4 - i) * 0.05)
            print("concurrent \(i)")
        }
    }
    group.wait()
    // Usual output: concurrent 3, 2, 1. The order isn't guaranteed.
}}

// MARK: - 3. DispatchGroup: wait for many tasks, then do something

#Playground("3. DispatchGroup") { demo {
    let group = DispatchGroup()
    let done = DispatchSemaphore(value: 0)   // only here to keep the playground alive

    for name in ["avatar", "feed", "settings"] {
        group.enter()                        // +1
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.05)
            print("downloaded \(name)")
            group.leave()                    // -1. Every enter() NEEDS exactly one leave()
        }
    }

    // notify does NOT block. It runs once the count reaches 0.
    group.notify(queue: .global()) {
        print("all downloads finished → reload UI (use queue: .main in an app)")
        done.signal()
    }
    print("notify registered, the caller keeps going")
    done.wait()

    // QUIZ:
    //   wait()   → blocks the current thread (never call it on main)
    //   notify() → async callback, the usual choice
    //   enter() without leave() → notify never fires
    //   leave() more often than enter() → crash
    //   queue.async(group: g) { } is shorthand for enter()/leave() around SYNC work
}}

// MARK: - 4. Race condition, and how to fix it

#Playground("4. Race condition") { demo {
    // ❌ Many threads write `unsafeCount` at the same time, so some updates get lost.
    var unsafeCount = 0
    DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
        unsafeCount += 1                     // read, add, write: not atomic!
    }
    print("unsafe:", unsafeCount, "(often less than 10000)")

    // ✅ Fix 1: send every access through one serial queue
    var safeCount = 0
    let lock = DispatchQueue(label: "demo.counter")
    DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
        lock.sync { safeCount += 1 }
    }
    print("serial-queue fix:", safeCount)

    // ✅ Fix 2: NSLock (faster, same idea)
    var lockedCount = 0
    let nsLock = NSLock()
    DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
        nsLock.lock(); lockedCount += 1; nsLock.unlock()
    }
    print("NSLock fix:", lockedCount)
}}

// MARK: - 5. Barrier: many readers OR one writer

#Playground("5. Barrier (reader-writer)") { demo {
    // Classic interview question: "Make this cache thread-safe but keep reads fast."
    final class SafeCache {
        private var storage: [String: Int] = [:]
        private let queue = DispatchQueue(label: "demo.cache", attributes: .concurrent)

        func get(_ key: String) -> Int? {
            queue.sync { storage[key] }      // reads run in parallel
        }

        func set(_ key: String, _ value: Int) {
            queue.async(flags: .barrier) {   // a write waits for running reads, then runs ALONE
                self.storage[key] = value
            }
        }
    }

    let cache = SafeCache()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
        cache.set("k\(i)", i)
        _ = cache.get("k\(i)")
    }
    print("k42 =", cache.get("k42") ?? -1)   // sync read runs after earlier barriers → 42

    // QUIZ: a barrier only works on a CUSTOM concurrent queue.
    //   On DispatchQueue.global() it does nothing special (it acts like plain async).
    //   On a serial queue it's pointless (tasks already run one at a time).
}}

// MARK: - 6. DispatchSemaphore: limit how many run at once

#Playground("6. Semaphore") { demo {
    let semaphore = DispatchSemaphore(value: 2)   // at most 2 at a time
    let group = DispatchGroup()

    for i in 1...5 {
        DispatchQueue.global().async(group: group) {
            semaphore.wait()                      // count - 1. Blocks if it's 0
            print("start \(i)")
            Thread.sleep(forTimeInterval: 0.1)
            print("end   \(i)")
            semaphore.signal()                    // count + 1
        }
    }
    group.wait()
    // You never see more than 2 "start"s without an "end" in between.
    // DispatchSemaphore(value: 0) is used to turn an async callback into a blocking wait.
}}

// MARK: - 7. asyncAfter and DispatchWorkItem (delay + cancel)

#Playground("7. asyncAfter + WorkItem") { demo {
    let queue = DispatchQueue(label: "demo.delay")

    queue.asyncAfter(deadline: .now() + 0.1) {
        print("ran after 0.1s")
    }

    // A WorkItem is a task you can cancel. Typical use: debouncing a search box.
    let search = DispatchWorkItem { print("searching… (you should NOT see this)") }
    queue.asyncAfter(deadline: .now() + 0.2, execute: search)
    search.cancel()                          // cancelled before it started → never runs

    Thread.sleep(forTimeInterval: 0.3)
    print("isCancelled:", search.isCancelled)

    // QUIZ: cancel() does NOT stop a work item that is already running.
    //   Long tasks should check `isCancelled` themselves.
}}

// MARK: - 8. Deadlock (read this, don't run it)

// ❌ Calling sync on the SAME serial queue you're already on:
//
//   let q = DispatchQueue(label: "q")
//   q.sync {
//       q.sync { print("never prints") }   // the inner task waits for the outer one,
//   }                                      // the outer one waits for the inner one → deadlock
//
// ❌ The most common quiz version:
//
//   // running on the main thread (e.g. in viewDidLoad)
//   DispatchQueue.main.sync { ... }       // deadlock / crash
//
// ✅ From a background thread, DispatchQueue.main.sync is allowed, but async is usually better.
// ✅ async never deadlocks like this, because the caller doesn't wait.

// MARK: - 9. Quiz cheat sheet
//
// Q: What does GCD run tasks on?             A: A system-managed thread pool. You manage queues, not threads.
// Q: Is the main queue serial or concurrent? A: Serial.
// Q: Are global queues serial or concurrent? A: Concurrent.
// Q: DispatchQueue(label:) by default?       A: Serial.
// Q: sync vs async?                          A: sync blocks the caller until done. async returns right away.
// Q: Where must UI updates happen?           A: DispatchQueue.main.
// Q: main.sync from the main thread?         A: Deadlock.
// Q: Wait for several async tasks?           A: DispatchGroup (enter/leave + notify).
// Q: Limit concurrency to N?                 A: DispatchSemaphore(value: N), or OperationQueue.maxConcurrentOperationCount.
// Q: Thread-safe reads + exclusive writes?   A: Custom concurrent queue: sync reads + async(flags: .barrier) writes.
// Q: Delay a task?                           A: asyncAfter(deadline:).
// Q: Cancel a pending task?                  A: DispatchWorkItem.cancel(). Or use OperationQueue (it also supports dependencies).
// Q: Run a loop in parallel and wait?        A: DispatchQueue.concurrentPerform(iterations:).
// Q: Highest QoS?                            A: .userInteractive (lowest: .background).
// Q: Serial queue = one thread?              A: No. One task at a time, but it may run on different threads.
// Q: GCD vs OperationQueue?                  A: GCD is lightweight and C-based. OperationQueue is built on GCD and
//                                               adds dependencies, cancellation, KVO state, and max concurrency.
// Q: GCD vs Swift concurrency (async/await)? A: async/await + actors is the modern replacement. Actors prevent the
//                                               data races in section 4 at compile time. @MainActor ≈ DispatchQueue.main.
