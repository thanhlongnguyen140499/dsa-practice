# DSA practice

Problem lists come from [`leetcode-company-wise-problems`](leetcode-company-wise-problems). This folder is a Swift package. Each file in `solutions/` has a `#Playground` block that runs in Xcode's canvas. My progress is tracked in `progress.json`.

```bash
./dsa companies goo                  # find a company name
./dsa list Google -p 30d -d medium   # browse problems (✅ = solved)
./dsa pick Google -p 3m -n 3         # 3 most-frequent unsolved → solutions/<slug>.swift
./dsa pick Meta -t graph -r          # 1 random unsolved graph problem
./dsa new <leetcode link> --dir Hashmap   # any problem → solutions/Hashmap/<slug>.swift
./dsa open two-sum                   # open the package + that file in Xcode
./dsa done two-sum                   # mark solved (./dsa undo two-sum to revert)
./dsa status Google                  # overall + per-company progress
```

Filters: `-p 30d|3m|6m|older|all`, `-d easy|medium|hard`, `-t <topic substring>`.
SQL (Database) and Shell problems are skipped automatically.

## Workflow
1. `./dsa pick Google`, then `./dsa open <slug>` (or open this folder in Xcode and click the file).
2. Show the canvas with **Editor → Canvas** (⌥⌘↩). It runs the `#Playground` block and shows the ✅/❌ output.
3. Each file already has LeetCode's Swift signature and the examples as `check(got, want)` tests. Write the solution until every line is ✅.
   (Premium or in-place problems: paste the signature / write the checks yourself. `./dsa regen` refills untouched files.)
4. Submit only `class Solution { ... }` on LeetCode, fill in Approach / Time / Space, then `./dsa done <slug>`.

`solutions/_Helpers.swift` provides `check`, LeetCode's `ListNode` / `TreeNode`, and the test builders
`list([1,2,3])`, `array(of:)`, `tree([3,9,20,nil,nil,15,7])` and `levelOrder(of:)`.

The problem lists are a git submodule. Clone this repo with:

```bash
git clone --recursive https://github.com/thanhlongnguyen140499/dsa-practice.git
```

Update the lists with `git submodule update --remote`.
