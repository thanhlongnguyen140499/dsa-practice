// Valid Parentheses
// Easy · String, Stack, Bracket Sequences
// https://leetcode.com/problems/valid-parentheses
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

#Playground("Valid Parentheses") {
    class Solution {
        func isValid(_ s: String) -> Bool {
            let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
            var stack: [Character] = []
            
            // E.g: ([])
            // loop1: (
            //  -> no -> stack = '('
            
            // loop2: [
            //  -> no -> stack = '(', '['
            
            // loop3: ]
            // -> yes -> stack = '('
            
            // loop4: )
            // -> yes -> stack = ''
            
            for c in s {
                if let open = pairs[c] {
                    if stack.popLast() != open { return false }
                } else {
                    stack.append(c)
                }
            }
            
            return stack.isEmpty 
        }
    }

    let s = Solution()
    check(s.isValid("()"), true)
    //    check(s.isValid("()[]{}"), true)
    //    check(s.isValid("(]"), false)
    //    check(s.isValid("([])"), true)
    //    check(s.isValid("([)]"), false)
}
