// Pascal's Triangle II
// Easy · Array, Dynamic Programming
// https://leetcode.com/problems/pascals-triangle-ii
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

#Playground("Pascal's Triangle II") {
    class Solution {

        // MARK: Solution 1
        // Time + Space: Big O(n^2)
        func getRow1(_ rowIndex: Int) -> [Int] {
            if rowIndex == 0 { return [1] }
            if rowIndex == 1 { return [1, 1] }

            var A: [[Int]] = []
            for i in 0...rowIndex {
                var row = [Int](repeating: 1, count: i + 1)

                if i >= 2 {
                    for j in 1..<i {
                        row[j] = A[i - 1][j - 1] + A[i - 1][j]
                    }
                }

                A.append(row)
            }

            return A[rowIndex]
        }

        // MARK: Solution 2
        // Time + Space: Big O(n)
        func getRow(_ rowIndex: Int) -> [Int] {
            if rowIndex == 0 { return [1] }
            if rowIndex == 1 { return [1, 1] }

            var A: [[Int]] = []
            var row = [Int](repeating: 1, count: rowIndex + 1)

            for i in 2...rowIndex {
                for j in stride(from: i - 1, through: 1, by: -1) {
                    row[j] = row[j] + row[j - 1]
                }
            }

            return row
        }
    }

    let s = Solution()
    check(s.getRow(3), [1, 3, 3, 1])
    check(s.getRow(0), [1])
    check(s.getRow(1), [1, 1])
}
