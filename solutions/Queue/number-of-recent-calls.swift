// Number of Recent Calls
// Easy · Design, Queue, Data Stream
// https://leetcode.com/problems/number-of-recent-calls
// Picked from: —

// Approach: Queue of ping times (sliding window). Append t to the back, then
//           remove from the front while it is older than t - 3000. Times only
//           increase, so an expired ping never comes back. Answer = queue size.

// Time:  amortized O(1) per ping (each time is added and removed at most once)
// Space: O(W), W = pings inside a 3000 ms window (at most 3001)

// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Number of Recent Calls") {

    class RecentCounter {
        private var queue: [Int] = []

        init() {}

        func ping(_ t: Int) -> Int {
            queue.append(t)
            
            // Todo: drop pings older than range [t - 3000]
            while let oldest = queue.first, oldest < t - 3000 {
                queue.removeFirst()
            }
            
            return queue.count
        }
    }

    /**
     * Your RecentCounter object will be instantiated and called as such:
     * let obj = RecentCounter()
     * let ret_1: Int = obj.ping(t)
     */

    // Examples from LeetCode:
    // Input:  ["RecentCounter","ping","ping","ping","ping"], [[],[1],[100],[3001],[3002]]
    // Output: [null,1,2,3,3]
    let c1 = RecentCounter()
    check(c1.ping(1), 1)       // [-2999, 1]   -> 1
    check(c1.ping(100), 2)     // [-2900, 100] -> 1, 100
    check(c1.ping(3001), 3)    // [1, 3001]    -> 1, 100, 3001
    check(c1.ping(3002), 3)    // [2, 3002]    -> 100, 3001, 3002 (1 expired)

//    // Single ping
//    let c2 = RecentCounter()
//    check(c2.ping(5), 1)
//
//    // Boundary is inclusive: exactly 3000 apart still counts
//    let c3 = RecentCounter()
//    check(c3.ping(1), 1)
//    check(c3.ping(3001), 2)    // [1, 3001]    -> 1 still inside
//    check(c3.ping(3002), 2)    // [2, 3002]    -> 1 drops out
//
//    // Pings far apart: each old one expires before the next
//    let c4 = RecentCounter()
//    check(c4.ping(1), 1)
//    check(c4.ping(5000), 1)
//    check(c4.ping(10000), 1)
//
//    // Burst of close pings: all stay in the window
//    let c5 = RecentCounter()
//    check(c5.ping(1), 1)
//    check(c5.ping(2), 2)
//    check(c5.ping(3), 3)
//    check(c5.ping(4), 4)
//
//    // Several expire at once
//    let c6 = RecentCounter()
//    check(c6.ping(1), 1)
//    check(c6.ping(2), 2)
//    check(c6.ping(3), 3)
//    check(c6.ping(3003), 2)    // [3, 3003]    -> 3, 3003 (1 and 2 expired)
//
//    // Large t values (up to 10^9)
//    let c7 = RecentCounter()
//    check(c7.ping(999_997_000), 1)
//    check(c7.ping(1_000_000_000), 2)
}
