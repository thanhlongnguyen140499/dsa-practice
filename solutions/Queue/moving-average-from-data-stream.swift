// Moving Average from Data Stream
// Easy · Array, Design, Queue, Data Stream
// https://leetcode.com/problems/moving-average-from-data-stream  (Premium)
// Free copy: https://www.lintcode.com/problem/642/
// Picked from: —
//
// Problem:
//   Given a stream of integers and a window size, calculate the moving average
//   of all integers in the sliding window.
//
//   MovingAverage(size) initializes the object with the window size.
//   next(val) adds val to the stream and returns the average of the last
//   `size` values (or of all values, if fewer than `size` have arrived).
//
//   Constraints: 1 <= size <= 1000, -10^5 <= val <= 10^5,
//                at most 10^4 calls to next.
//
// Approach: Queue holding the last `size` values + a running sum. Each call
//           appends val (sum += val); if the queue grows past `size`, remove
//           the oldest from the front (sum -= oldest). Average = sum / count.

// Time:  O(1) per next (Swift's Array.removeFirst shifts up to `size` items,
//        fine for size <= 1000; a head index or ring buffer makes it true O(1))
// Space: O(size)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class MovingAverage { ... }` to LeetCode / LintCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Moving Average from Data Stream") {

    class MovingAverage {

        // Input: size + value
        // Output: double

        // Plan:
        // rely on size of MovingAverage to calculate
        // Apply queue (FIFO) to get these first 3 value in queue

        // E.g: val = [1, 10, 3, 5]
        //
        // size = 3
        //
        // -> 1 , result: 1
        // -> [1, 10], result: 1 + 10 / 2
        // -> [1, 10, 3], result: 1 + 10 + 3 / 3

        // -> [1, 10, 3, 5]
        // -> [10, 3, 5] -> result: 10 + 3 + 5

        private let size: Int
        private var sum = 0
        private var queue: [Int] = []

        init(_ size: Int) {
            self.size = size
        }

        func next(_ val: Int) -> Double {
            
            sum += val
            queue.append(val)
            
            if queue.count > self.size {
                sum -= queue.removeFirst()
            }
            
            return Double(sum) / Double(queue.count)
        }
    }

    /**
     * Your MovingAverage object will be instantiated and called as such:
     * let obj = MovingAverage(size)
     * let ret_1: Double = obj.next(val)
     */

    // Examples from LeetCode / LintCode:
    // Input:  ["MovingAverage","next","next","next","next"], [[3],[1],[10],[3],[5]]
    // Output: [null,1.0,5.5,4.66667,6.0]
    let m1 = MovingAverage(3)
    check(m1.next(1), 1.0)  // [1]         -> 1 / 1
    check(m1.next(10), 5.5)  // [1, 10]     -> 11 / 2
    check(m1.next(3), 14.0 / 3.0)  // [1, 10, 3]  -> 14 / 3
    check(m1.next(5), 6.0)  // [10, 3, 5]  -> 18 / 3 (1 dropped)

    // Window of 1: the average is always the latest value
    let m2 = MovingAverage(1)
    check(m2.next(4), 4.0)
    check(m2.next(-7), -7.0)

    // Negative values
    let m3 = MovingAverage(2)
    check(m3.next(-3), -3.0)
    check(m3.next(-4), -3.5)   // [-3, -4]
    check(m3.next(6), 1.0)     // [-4, 6]  (-3 dropped)
}
