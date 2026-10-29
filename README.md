# DSA practice

<a href="https://dsa-tracker-sandy-kappa.vercel.app/">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://dsa-tracker-sandy-kappa.vercel.app/card-dark.svg">
    <img alt="DSA Tracker: streak, problems solved and the last 16 weeks" src="https://dsa-tracker-sandy-kappa.vercel.app/card-light.svg">
  </picture>
</a>

**[Open the live tracker →](https://dsa-tracker-sandy-kappa.vercel.app/)** (3D robot, streak celebrations, full history)

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
./dsa site --open                    # build + open the tracker page locally
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

## Tracker

Deployed to Vercel (project `dsa-tracker`) by GitHub Actions on every push to `main`, and once a day at 00:05 (Vietnam time)
so the streak rolls over. The card at the top of this README is `card-dark.svg` / `card-light.svg` from the same deploy.
Needs a `VERCEL_TOKEN` repo secret (vercel.com/account/tokens → GitHub repo Settings → Secrets and variables → Actions).

A problem counts as finished on the day its file in `solutions/<Category>/` is first committed; the folder is its category.
The streak counts days with at least 3 finished problems. Files directly in `solutions/` aren't counted.

The problem lists are a git submodule. Clone this repo with:

```bash
git clone --recursive https://github.com/thanhlongnguyen140499/dsa-practice.git
```

Update the lists with `git submodule update --remote`.
