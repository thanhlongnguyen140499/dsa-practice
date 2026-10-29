// Find the Index of the First Occurrence in a String
// Easy · Two Pointers, String, String Matching, Z Algorithm, Knuth–Morris–Pratt Algorithm, Boyer–Moore String-Search Algorithm
// https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string
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

#Playground("Find the Index of the First Occurrence in a String") {
    class Solution {
        
        // Input: both inputs are string
        // Output: return the index
        //      - if needle is a part of input
        //      - if not -1
        
        // Plan:
        // - Using 2 pointers to compare both inputs
        //  + 1 pointer is at first input
        //  + 1 pointer is at needle
        // + move these into array
        
        // -> Question:
        // - maybe the needle not always at first of haystack
        // - when mathc a first char, have to check all chars,
        //      + if not match, we have to keep track next char until end of string
        // - return -1 if not found
        func strStr(_ haystack: String, _ needle: String) -> Int {
            guard !needle.isEmpty else { return -1 }
            
            var pointerOne: Int = 0
            let arrayOne = Array(haystack)
            let needleFlag: String = String(needle.prefix(1))
        
            while pointerOne <= haystack.count - needle.count {
                if String(arrayOne[pointerOne]) == needleFlag {
                    let check = String(arrayOne[pointerOne...(pointerOne + needle.count - 1)])
                    
                    if check == needle {
                        return pointerOne
                    }
                }
                
                pointerOne += 1
            }
             
            return -1
        }
    }

    let s = Solution()
    check(s.strStr("hello", "ll"), 2)           // catches return 0
    check(s.strStr("sad", "sad"), 0)            // catches <
    check(s.strStr("butsad", "sad"), 3)         // match at last position
    check(s.strStr("a", "abc"), -1)             // needle longer
    check(s.strStr("mississippi", "issip"), 4)  // false start first
}
