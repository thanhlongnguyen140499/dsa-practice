// First Unique Character in a String
// Easy · Hash Table, String, Queue, Counting
// https://leetcode.com/problems/first-unique-character-in-a-string
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

#Playground("First Unique Character in a String") {
    class Solution {
        // MARK: Using queue datastructure
        func firstUniqChar(_ s: String) -> Int {
            var count: [Character: Int] = [:]
            var queue: [(char: Character, index: Int)] = []
            
            for (i, c) in s.enumerated() {
                print("check: \(count[c, default: 0])")
                count[c, default: 0] += 1
                if count[c] == 1 {
                    queue.append((c, i))
                }
                
                while let front = queue.first,
                      count[front.char]! > 1 {
                    queue.removeFirst()
                }
            }
            return queue.first?.index ?? -1
        }
        

        // MARK: Second solution - count repeated number
        func firstUniqChar2(_ s: String) -> Int {
            let chars = Array(s.utf8)  // s -> lowercase a-z only
            var count = [Int](repeating: 0, count: 26)

            // Pass 1: count each letter
            for c in chars {
                count[Int(c - 97)] += 1
            }

            // Pass 2: first index whose letter appears once
            for (i, c) in chars.enumerated() {
                if count[Int(c - 97)] == 1 { return i }
            }

            return -1
        }
    }

    let s = Solution()
    check(s.firstUniqChar("leetcode"), 0)
    //    check(s.firstUniqChar("loveleetcode"), 2)
    //    check(s.firstUniqChar("aabb"), -1)
}
