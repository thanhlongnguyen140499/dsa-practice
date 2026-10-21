# iOS interview study plan

This plan is built from the 212 questions on [ios-interview-quiz.vercel.app](https://ios-interview-quiz.vercel.app/).
Each topic has one file here, made of `#Playground` blocks you run in Xcode's canvas (Editor → Canvas, ⌥⌘↩).

**How to use each file:** read a block, **guess the output**, run it, then read the `// QUIZ:` notes.
The cheat sheet at the bottom of each file sums up the topic in one-line answers. Reread it the day before.
Then take the quiz for that topic only (pick it under Topics, **Practice** mode) and come back for anything you got wrong.

## Order to study

The order goes from fundamentals to frameworks, because later topics build on earlier ones
(for example, SwiftUI and Combine questions assume you know closures, ARC and threads).

| Week | File | Quiz topic | Qs | What to focus on |
|---|---|---|---|---|
| 1 | [01-Swift.swift](01-Swift.swift) | Swift Language | 30 | value vs reference types, optionals, protocols + generics, `some` vs `any`, closures + capture lists, enums, errors, property wrappers, COW |
| 1 | [06-Memory.swift](06-Memory.swift) | Memory & Performance | 20 | ARC, `weak` / `unowned`, retain cycles (closures, delegates, Timer), COW, Instruments |
| 2 | [../solutions/GCD-testing.swift](../solutions/GCD-testing.swift) | Concurrency (GCD part) | ~10 | queues, sync/async, groups, barriers, semaphores, deadlocks |
| 2 | [02-Concurrency.swift](02-Concurrency.swift) | Concurrency & GCD | 25 | `async/await`, actors + reentrancy, `Sendable`, `@MainActor`, Task / TaskGroup / `async let`, cancellation |
| 3 | [03-UIKit.swift](03-UIKit.swift) | UIKit | 28 | VC lifecycle, frame vs bounds, Auto Layout, cell reuse, diffable data source, hit testing, scenes |
| 3 | [04-SwiftUI.swift](04-SwiftUI.swift) | SwiftUI | 30 | state ownership (`@State`, `@Binding`, `@StateObject`, `@Observable`), identity, navigation, `.task`, layout, performance |
| 4 | [05-Architecture.swift](05-Architecture.swift) | Architecture & Patterns | 22 | MVVM, VIPER, TCA, Coordinator, SOLID, dependency injection, design patterns |
| 4 | [07-Networking.swift](07-Networking.swift) | Networking & Persistence | 22 | URLSession, Codable, Keychain, Core Data / SwiftData, caching, pagination |
| 5 | [09-Combine.swift](09-Combine.swift) | Combine | 15 | `AnyCancellable` lifetime, subjects, `flatMap` / `switchToLatest`, `debounce`, `zip` vs `combineLatest` |
| 5 | [08-Testing.swift](08-Testing.swift) | Testing & Tooling | 20 | XCTest vs Swift Testing, test doubles, DI for testability, signing, dSYMs, LLDB |

Short on time? Do **Swift → Memory → Concurrency → SwiftUI → UIKit** first. Those five topics cover about 63% of the questions,
and they're what interviewers ask about most.

## Difficulty

About 1 in 3 questions is *easy*, 2 in 5 are *medium*, and 1 in 4 are *hard*. The hard ones are mostly
"what does this print" traps: protocol extension dispatch, actor reentrancy, `@Published` emitting in `willSet`,
impossible queue orderings, `@State` initializers, and so on. The `PREDICT` demos in each file are built for exactly these.

## Daily routine (30–45 min)

1. One file section: guess, run, read the notes (15 min).
2. 10 Practice-mode questions on that topic (10 min).
3. For each miss, find the matching section and change the code until the answer makes sense (10–15 min).
4. Friday: a 20-question **Exam** run across every topic you've covered so far.
