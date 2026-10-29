// First Bad Version
// Easy · Binary Search, Interactive
// https://leetcode.com/problems/first-bad-version
// Picked from: —
//
// Approach:
//
// Time:  O(?)
// Space: O(?)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("First Bad Version") {
    class Solution: VersionControl {
        func firstBadVersion(_ n: Int) -> Int {
            // Input: n version [1, 2,...n]
            // Output: first error version

            // Plan:
            //  - versions look like ✅ ✅ ✅ ❌ ❌ → sorted, so binary search
            //  - lo...hi = range that still contains the answer
            //  - mid bad  → answer is mid or earlier → hi = mid (keep mid!)
            //  - mid good → answer is after mid     → lo = mid + 1
            //  - stop when lo == hi → that's the first bad version

            var lo: Int = 0
            var hi: Int = n

            while lo < hi {
                let mid = lo + (hi - lo) / 2

                if isBadVersion(mid) {
                    hi = mid
                } else {
                    lo = mid + 1
                }
            }

            return lo
        }
    }

    // run(n, bad: x) → your answer for versions 1...n where x is the first bad one.
    // Also fails if isBadVersion was called more than ~log2(n) + 2 times (no linear scans).
    func run(_ n: Int, bad: Int, line: Int = #line) -> Int {
        let s = Solution()
        s.bad = bad
        let got = s.firstBadVersion(n)
        let limit = (Int.bitWidth - n.leadingZeroBitCount) + 1  // floor(log2(n)) + 2
        if s.calls > limit {
            print(
                "⚠️ line \(line): \(s.calls) isBadVersion calls, want ≤ \(limit)"
            )
        }
        return got
    }

    // Examples from LeetCode
    check(run(5, bad: 4), 4)
    check(run(1, bad: 1), 1)

    // Edges: bad is the first or the last version
    check(run(5, bad: 1), 1)
    check(run(5, bad: 5), 5)
    check(run(2, bad: 1), 1)
    check(run(2, bad: 2), 2)

    // Even and odd sizes
    //    check(run(10, bad: 7), 7)
    //    check(run(9, bad: 3), 3)

    // Huge n: a linear scan is too slow, and (lo + hi) / 2 overflows on 32-bit Int
    //    check(run(2_126_753_390, bad: 1_702_766_719), 1_702_766_719)
    //    check(run(Int(Int32.max), bad: Int(Int32.max)), Int(Int32.max))
}
