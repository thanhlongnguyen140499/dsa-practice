// Shared helpers for the interview playgrounds.

/// A #Playground body is an async context, where Swift warns about blocking calls
/// like wait() and Thread.sleep. Running a demo inside this plain closure avoids that.
func demo(_ body: () -> Void) { body() }

/// Prints ✅ or ❌ with the line number, so you can check your predictions.
func expect<T: Equatable>(_ got: T, _ want: T, line: Int = #line) {
    print(got == want ? "✅ line \(line)" : "❌ line \(line): got \(got), want \(want)")
}
