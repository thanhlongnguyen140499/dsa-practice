// Finding 3-Digit Even Numbers
// Easy · Array, Hash Table, Recursion, Sorting, Enumeration
// https://leetcode.com/problems/finding-3-digit-even-numbers
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

#Playground("Finding 3-Digit Even Numbers") {
    class Solution {
        func findEvenNumbers(_ digits: [Int]) -> [Int] {
            var cnt = [Int](repeating: 0, count: 10)
            for d in digits { cnt[d] += 1 }
            var result: [Int] = []

            func build(_ pos: Int, _ num: Int) {
                if pos == 3 { result.append(num); return }
                for d in 0...9 {
                    if cnt[d] == 0 { continue }
                    if pos == 0 && d == 0 { continue }
                    if pos == 2 && d % 2 != 0 { continue }
                    cnt[d] -= 1
                    build(pos + 1, num * 10 + d)
                    cnt[d] += 1
                }
            }

            build(0, 0)
            return result
        }
    }

    let s = Solution()
//    check(
//        s.findEvenNumbers([2, 1, 3, 0]),
//        [102, 120, 130, 132, 210, 230, 302, 310, 312, 320]
//    )
//    check(
//        s.findEvenNumbers([2, 2, 8, 8, 2]),
//        [222, 228, 282, 288, 822, 828, 882]
//    )
    check(s.findEvenNumbers([3, 7, 5]), [])
}
