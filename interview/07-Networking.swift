//
//  07-Networking.swift
//  Interview
//
// Networking & Persistence: a beginner's tour for iOS quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Every demo runs OFFLINE: JSON comes from string literals and HTTP responses
// are built by hand. PREDICT the output before you run each block.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// Almost every app does the same loop:
//
//   URLSession ──► (Data, URLResponse) ──► check the status code ──► JSONDecoder ──► model
//                                                                         │
//                       save it somewhere ◄───────────────────────────────┘
//      (memory: NSCache · small settings: UserDefaults · secrets: Keychain
//       · files: Documents/Caches · structured data: Core Data / SwiftData)
//
// Quiz traps live at each arrow:
//   - URLSession does NOT throw for a 404. You have to check the status yourself
//   - Decoding rules: CodingKeys, snake_case, dates, missing keys, error paths
//   - Where to store what (never put tokens in UserDefaults)
//   - Core Data objects belong to ONE context/thread

import Foundation
import Playgrounds

// MARK: - 1. Codable basics: CodingKeys

#Playground("1. CodingKeys") { demo {
    // When JSON keys don't match your property names, list the mapping in CodingKeys.
    // Leave a property out of CodingKeys and it won't be encoded/decoded
    // (then it needs a default value).
    struct Person: Codable {
        let fullName: String
        let age: Int
        var isSelected = false                   // not in the JSON

        enum CodingKeys: String, CodingKey {
            case fullName = "full_name"          // JSON key "full_name" → fullName
            case age
        }
    }

    let json = #"{ "full_name": "Ana Silva", "age": 30 }"#
    let person = try! JSONDecoder().decode(Person.self, from: Data(json.utf8))
    print(person.fullName, person.age, person.isSelected)   // Ana Silva 30 false
}}

// MARK: - 2. Key and date strategies

#Playground("2. snake_case + dates") { demo {
    // .convertFromSnakeCase: remove each "_" and capitalize the next letter.
    //   "user_id"    → "userId"   (NOT "userID"!)
    //   "avatar_url" → "avatarUrl"
    struct Account: Decodable { let userId: Int; let avatarUrl: String; let createdAt: Date }

    let json = #"{ "user_id": 7, "avatar_url": "a.png", "created_at": "2024-05-01T12:30:00Z" }"#
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601      // "2024-05-01T12:30:00Z" with no custom code

    let account = try! decoder.decode(Account.self, from: Data(json.utf8))
    print(account.userId, account.avatarUrl, account.createdAt.timeIntervalSince1970)
    // 7 a.png 1714566600.0

    // QUIZ trap: a property named `userID` would FAIL (keyNotFound), because
    // the converted key is "userId". Fix: rename it, or add CodingKeys.
    struct Wrong: Decodable { let userID: Int }
    do { _ = try decoder.decode(Wrong.self, from: Data(json.utf8)) }
    catch { print("userID fails:", error is DecodingError) }   // userID fails: true

    // .iso8601 doesn't handle fractional seconds ("…30:00.123Z"). For that, use
    // .custom / .formatted with your own formatter.
}}

// MARK: - 3. Flattening nested JSON

#Playground("3. nestedContainer") { demo {
    // JSON wraps the value we want two levels deep. nestedContainer lets us step
    // into inner objects WITHOUT writing a Swift type for each wrapper level.
    struct User: Decodable {
        let name: String
        enum RootKeys: String, CodingKey { case data }
        enum DataKeys: String, CodingKey { case user }
        enum UserKeys: String, CodingKey { case name }

        init(from decoder: Decoder) throws {
            let root = try decoder.container(keyedBy: RootKeys.self)
            let data = try root.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
            let user = try data.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
            name = try user.decode(String.self, forKey: .name)
        }
    }
    let json = #"{ "data": { "user": { "name": "Ana" } } }"#
    expect(try! JSONDecoder().decode(User.self, from: Data(json.utf8)).name, "Ana")
}}

// MARK: - 4. Missing keys: decode vs decodeIfPresent

#Playground("4. decodeIfPresent") { demo {
    // decode(_:forKey:)          key missing → throws keyNotFound
    // decodeIfPresent(_:forKey:) key missing OR null → returns nil
    // Synthesized Codable uses decodeIfPresent for Optional properties.
    struct Profile: Decodable { let name: String; let bio: String? }

    let noBio = #"{ "name": "Ana" }"#
    let nullBio = #"{ "name": "Ana", "bio": null }"#
    let noName = #"{ "bio": "hi" }"#

    let d = JSONDecoder()
    print(try! d.decode(Profile.self, from: Data(noBio.utf8)).bio as Any)    // nil
    print(try! d.decode(Profile.self, from: Data(nullBio.utf8)).bio as Any)  // nil
    do { _ = try d.decode(Profile.self, from: Data(noName.utf8)) }
    catch DecodingError.keyNotFound(let key, _) { print("keyNotFound:", key.stringValue) }  // keyNotFound: name
    catch { print("other") }
}}

// MARK: - 5. Reading DecodingError

#Playground("5. DecodingError path") { demo {
    // The 4 cases you should recognise:
    //   keyNotFound    the key is missing
    //   typeMismatch   the key exists but has the wrong JSON type ("9" instead of 9)
    //   valueNotFound  the value is null where a non-optional was expected
    //   dataCorrupted  not valid JSON at all (or a bad date string, etc.)
    // context.codingPath tells you WHERE it went wrong.
    struct Item: Decodable { let price: Int }
    struct Cart: Decodable { let items: [Item] }

    let json = #"{ "items": [ {"price": 1}, {"price": 2}, {"price": "9"} ] }"#
    do {
        _ = try JSONDecoder().decode(Cart.self, from: Data(json.utf8))
    } catch DecodingError.typeMismatch(let type, let context) {
        let path = context.codingPath.map(\.stringValue).joined(separator: ".")
        print("Expected \(type) at \(path)")     // Expected Int at items.Index 2.price
    } catch {
        print("other:", error)
    }

    do { _ = try JSONDecoder().decode(Cart.self, from: Data("not json".utf8)) }
    catch DecodingError.dataCorrupted { print("dataCorrupted") }          // dataCorrupted
    catch { print("other") }
}}

// MARK: - 6. HTTP status codes: URLSession won't check them for you

#Playground("6. HTTP status") { demo {
    // URLSession only THROWS for transport failures (offline, timeout, bad TLS…).
    // A 404 or 500 is a "successful" response: you get Data (maybe an HTML error page)
    // and a URLResponse. Cast it to HTTPURLResponse and check statusCode yourself.
    enum APIError: Error, Equatable { case badStatus(Int), notHTTP }

    func validate(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let http = response as? HTTPURLResponse else { throw APIError.notHTTP }
        guard (200...299).contains(http.statusCode) else { throw APIError.badStatus(http.statusCode) }
        return data
    }

    // Simulate what `try await URLSession.shared.data(from: url)` would give back
    let url = URL(string: "https://example.com/user/1")!
    let html = Data("<html>Not Found</html>".utf8)
    let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!

    do { _ = try validate(html, response) }
    catch { print("caught:", error) }            // caught: badStatus(404)

    // Without validate(), you'd pass the HTML to JSONDecoder and get a confusing
    // dataCorrupted error instead of "404".
}}

// MARK: - 7. URLSession task types and background transfers

// dataTask      → body in memory (Data). Normal API calls
// downloadTask  → body written to a TEMPORARY FILE. Supports resume data after a failure.
//                 Move the file in the completion handler, because it's deleted afterwards
// uploadTask    → send a body/file. Required for background uploads
// streamTask / webSocketTask → long-lived connections
//
// Background transfers (keep going while the app is suspended or even terminated):
//   let config = URLSessionConfiguration.background(withIdentifier: "com.app.sync")
//   - must use a DELEGATE (no completion-handler closures)
//   - only download/upload tasks (uploads from a FILE)
//   - the system relaunches your app and calls
//     application(_:handleEventsForBackgroundURLSession:completionHandler:)
//
// WebSocket (URLSessionWebSocketTask):
//   let task = session.webSocketTask(with: url); task.resume()
//   try await task.send(.string("hello"))
//   let message = try await task.receive()   // ONE message (.string or .data) per call → loop
//   Reconnecting, heartbeats (sendPing) and backoff are YOUR job.

// MARK: - 8. NSCache

#Playground("8. NSCache") { demo {
    // NSCache: in-memory, thread-safe, and it EVICTS entries on its own (count/cost
    // limits, or when the system is low on memory). Keys must be objects (NSString…).
    // Unlike a Dictionary, it doesn't copy keys, and an entry can vanish at any time.
    // Always be ready for a miss.
    final class Box { let value: String; init(_ v: String) { value = v } }
    let cache = NSCache<NSString, Box>()
    cache.countLimit = 2

    cache.setObject(Box("a"), forKey: "1")
    print(cache.object(forKey: "1")?.value ?? "miss")   // a
    print(cache.object(forKey: "x")?.value ?? "miss")   // miss
    // Use it for re-creatable things (decoded images, thumbnails), never as the only copy.
}}

// MARK: - 9. Security: ATS, pinning, Keychain

// App Transport Security (ATS): by default it blocks plain http:// and weak TLS.
//   Exceptions go in Info.plist (NSAppTransportSecurity), per domain if possible.
//
// Certificate / public-key pinning: implement
//   urlSession(_:didReceive challenge:completionHandler:)
//   For NSURLAuthenticationMethodServerTrust, get challenge.protectionSpace.serverTrust,
//   evaluate it, compare the server's key with your pinned one, then call
//   completionHandler(.useCredential, URLCredential(trust:)) or
//   (.cancelAuthenticationChallenge, nil).
//
// Where to store a token / password?
//   ✅ Keychain: encrypted, can require device unlock
//      (kSecAttrAccessibleAfterFirstUnlock / WhenUnlocked …)
//   ❌ UserDefaults: a plain plist in the app container. Fine for settings only
//
//   Keychain in short (SecItem* API):
//     let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
//                                 kSecAttrAccount as String: "refreshToken",
//                                 kSecValueData as String: tokenData,
//                                 kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock]
//     SecItemAdd(query as CFDictionary, nil)

// MARK: - 10. Where do files go?

#Playground("10. File locations") { demo {
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    print(docs.lastPathComponent, caches.lastPathComponent)   // Documents Caches

    // Documents/          user-created data. Backed up to iCloud
    // Library/Caches/     re-downloadable data. NOT backed up. The system may purge it when space is low
    // Library/Application Support/  app data the user doesn't see. Backed up
    // tmp/                short-lived scratch. Can be deleted any time
    // QUIZ: a big re-downloadable file in Documents → backup bloat (App Review may reject it).
    //       Put it in Caches, or set isExcludedFromBackup.
}}

// MARK: - 11. Core Data and SwiftData

// Core Data rules quizzes love:
//   • A managed object belongs to ONE context, and is used only on that context's queue.
//       ❌ fetch on a background context, then use the objects on the main thread
//       ✅ pass the NSManagedObjectID, then: mainContext.object(with: id)
//       ✅ always touch a context inside context.perform { } / performAndWait { }
//   • Faults: fetched objects are lightweight placeholders. Their row data loads
//     lazily the first time you access a property. That saves memory.
//     (Firing faults one by one in a loop = slow. Use relationshipKeyPathsForPrefetching.)
//   • Merge conflicts on save (two contexts changed the same object):
//       NSMergeByPropertyObjectTrumpMergePolicy  → the SAVING context's in-memory values win
//       NSMergeByPropertyStoreTrumpMergePolicy   → what's already in the store wins
//       NSErrorMergePolicy (default)             → save fails with an error
//     viewContext.automaticallyMergesChangesFromParent = true keeps the UI context up to date.
//
// SwiftData (iOS 17+):
//   @Model final class Note { var text: String; init(text: String) { self.text = text } }
//   App: WindowGroup { ContentView() }.modelContainer(for: Note.self)   ← REQUIRED
//   View: @Query(sort: \Note.text) var notes: [Note]
//   @Query reads the modelContext from the environment. Without a .modelContainer
//   above it, there's nothing to query.

// MARK: - 12. Pagination: offset vs cursor

#Playground("12. Cursor pagination") { demo {
    // Server data (newest first). A new post (id 6) arrives between page loads.
    var feed = [5, 4, 3, 2, 1]

    // Offset pagination: "give me 2 items starting at index N"
    func pageByOffset(_ offset: Int) -> [Int] { Array(feed.dropFirst(offset).prefix(2)) }
    // Cursor pagination: "give me 2 items older than id X"
    func pageByCursor(after cursor: Int?) -> [Int] {
        Array(feed.filter { cursor == nil || $0 < cursor! }.prefix(2))
    }

    let offsetPage1 = pageByOffset(0)            // [5, 4]
    let cursorPage1 = pageByCursor(after: nil)   // [5, 4]
    feed.insert(6, at: 0)                        // new post shifts everything down
    let offsetPage2 = pageByOffset(2)            // [4, 3] ← 4 shows up AGAIN (duplicate)
    let cursorPage2 = pageByCursor(after: cursorPage1.last)   // [3, 2] ← correct

    print("offset:", offsetPage1, offsetPage2)   // offset: [5, 4] [4, 3]
    print("cursor:", cursorPage1, cursorPage2)   // cursor: [5, 4] [3, 2]
    // With offsets, inserts/deletes shift later pages → duplicates or missed items.
    // A cursor ("after id X") stays stable.
}}

// MARK: - 13. Offline and retries

#Playground("13. Retry with backoff") { demo {
    // Apple's guidance:
    //   • DON'T check reachability before a request. It can be stale. Just try.
    //   • config.waitsForConnectivity = true → the request waits for a connection
    //     instead of failing right away with notConnectedToInternet.
    //   • Or watch NWPathMonitor and retry when path.status == .satisfied.
    //   • Transient server errors (503, 429): retry with EXPONENTIAL BACKOFF + JITTER,
    //     and honor the Retry-After header. Never hammer the server with instant retries.
    func backoff(attempt: Int, base: Double = 0.5, jitter: Double) -> Double {
        base * pow(2, Double(attempt)) + jitter  // jitter = random 0..<base in real code
    }
    let delays = (0..<4).map { backoff(attempt: $0, jitter: 0) }
    print(delays)                                // [0.5, 1.0, 2.0, 4.0]

    // What to retry?
    let retryable: Set<Int> = [408, 429, 500, 502, 503, 504]
    print([404, 503].map { retryable.contains($0) })   // [false, true]: 4xx = your bug, don't retry
}}

// MARK: - 14. REST vs GraphQL

// GraphQL: ONE endpoint and a typed schema. The client asks for exactly the fields
//   it needs → no over-fetching, and no chain of round trips to build one screen.
//   Cost: harder HTTP caching, more complex server.
// REST: one URL per resource. Simple, and HTTP caching works out of the box.

// MARK: - Quiz cheat sheet
//
// Q: Task that saves the body to a temp file + can resume?  A: downloadTask (move the file before the handler returns).
// Q: Transfers that survive suspension/termination?         A: URLSessionConfiguration.background(withIdentifier:) + delegate,
//                                                              download/upload-from-file tasks only.
// Q: Server answers 404 with HTML: does URLSession throw?   A: No. Cast to HTTPURLResponse and check statusCode yourself.
// Q: What do CodingKeys do?                                 A: Map property names ↔ JSON keys (and pick which properties are coded).
// Q: convertFromSnakeCase: "user_id" maps to?               A: userId (not userID).
// Q: Decode "2024-05-01T12:30:00Z" with no custom code?     A: dateDecodingStrategy = .iso8601.
// Q: nestedContainer(keyedBy:forKey:)?                      A: Step into a nested JSON object to flatten it into one type.
// Q: decode vs decodeIfPresent on a missing key?            A: decode throws keyNotFound. decodeIfPresent returns nil.
// Q: typeMismatch at [items, Index 2, price]?               A: The 3rd item's price exists but has the wrong type (e.g. a string).
// Q: NSCache?                                               A: In-memory, thread-safe, auto-evicts (limits/memory pressure).
// Q: GraphQL's main advantage?                              A: Client picks the fields → no over-fetching, fewer round trips.
// Q: ATS default?                                           A: Blocks plain HTTP and weak TLS. Exceptions in Info.plist.
// Q: Where to implement pinning?                            A: urlSession(_:didReceive:completionHandler:), server trust challenge.
// Q: Where to store a refresh token?                        A: Keychain. Never UserDefaults.
// Q: Using managed objects across threads?                  A: Wrong. Pass NSManagedObjectID, use objects inside context.perform.
// Q: Merge policy where the saving context's values win?    A: NSMergeByPropertyObjectTrumpMergePolicy.
// Q: Core Data fault?                                       A: A placeholder whose data loads lazily on first property access.
// Q: @Query shows nothing?                                  A: Add .modelContainer(for:) above it so there's a modelContext.
// Q: Re-downloadable cache files go where?                  A: Library/Caches (not backed up, can be purged).
// Q: Why cursor over offset pagination?                     A: New/deleted items shift offsets → duplicates/misses. Cursors stay stable.
// Q: Offline + 503 errors?                                  A: waitsForConnectivity / NWPathMonitor to resume, exponential backoff
//                                                              + jitter (honor Retry-After) for 5xx. Don't preflight reachability.
// Q: URLSessionWebSocketTask?                               A: receive() returns one message per call → loop. Reconnect/ping is on you.
