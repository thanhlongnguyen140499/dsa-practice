//
//  03-UIKit.swift
//  Interview
//
// UIKit for iOS interview quizzes.
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// This package targets macOS, where UIKit doesn't exist. So:
//   • The runnable demos model UIKit's RULES with plain Swift + CoreGraphics
//     (the frame/bounds math, hit testing, lifecycle order, cell reuse…).
//   • The real UIKit code sits inside `#if canImport(UIKit)` blocks. Read it. It compiles
//     when you paste it into an iOS project.
//
// ─────────────────────────────────────────────────────────────────────────
// THE BIG PICTURE
// ─────────────────────────────────────────────────────────────────────────
// UIKit is the "imperative" UI framework: you create view objects, keep them
// alive, and change them yourself when data changes.
//
//   UIApplication / AppDelegate  → process-level events (launch, push tokens…)
//   UIScene / SceneDelegate      → one window's lifecycle (iPad can have many)
//   UIViewController             → manages one screen. Its `view` is created LAZILY
//   UIView                       → a rectangle that draws and handles touches
//   CALayer                      → what actually gets rendered (UIView wraps one)
//
// Three ideas cover most quiz questions:
//   1. Coordinates: frame = in the PARENT's space, bounds = in my OWN space.
//   2. Layout: Auto Layout solves constraints. Layout happens once per run-loop
//      "update cycle". setNeedsLayout schedules it, layoutIfNeeded forces it now.
//   3. Everything UIKit runs on the MAIN THREAD only.

import Foundation
import CoreGraphics
import Playgrounds

// MARK: - 1. View controller lifecycle

// A tiny model of how UIViewController loads its view lazily.
private final class FakeViewController {
    private(set) var log: [String] = []
    private var loadedView: String?

    var view: String {                       // like UIViewController.view
        if loadedView == nil {               // first access → load it
            loadView()
            viewDidLoad()
        }
        return loadedView!
    }

    var isViewLoaded: Bool { loadedView != nil }

    private func loadView() { log.append("loadView"); loadedView = "root view" }
    private func viewDidLoad() { log.append("viewDidLoad") }

    func appear() {
        _ = view
        log += ["viewWillAppear", "viewIsAppearing",
                "viewWillLayoutSubviews", "viewDidLayoutSubviews", "viewDidAppear"]
    }

    func disappear() { log += ["viewWillDisappear", "viewDidDisappear"] }
}

#Playground("1. View controller lifecycle") { demo {
    let vc = FakeViewController()
    print("view loaded after init?", vc.isViewLoaded)    // false: init does NOT load the view

    vc.appear()          // pushed onto a navigation stack
    vc.disappear()       // another screen pushed on top
    vc.appear()          // popped back

    print(vc.log.joined(separator: "\n"))
    // PREDICT: how many times does viewDidLoad appear in the log?
    expect(vc.log.filter { $0 == "viewDidLoad" }.count, 1)

    // QUIZ:
    //   • loadView → viewDidLoad happen ONCE, the first time `view` is touched.
    //   • viewWillAppear / viewIsAppearing / viewDidAppear happen EVERY time it appears.
    //   • viewIsAppearing (iOS 13+, back-deployed with the iOS 17 SDK) runs when the view
    //     is already in the window, and size and traits are final. Use it for setup that
    //     depends on geometry. viewWillAppear runs too early for that.
    //   • Calling `vc.view` in init or in a test forces the load early. A common trick for
    //     testing outlets.
}}

// Scene (window) lifecycle, iOS 13+:
//   launch:           scene(_:willConnectTo:options:) → sceneWillEnterForeground → sceneDidBecomeActive
//   swipe home:       sceneWillResignActive → sceneDidEnterBackground
//   come back:        sceneWillEnterForeground → sceneDidBecomeActive
//   notification/Control Center pulled down: only sceneWillResignActive (stays in foreground)
// AppDelegate still handles process-wide things: launch setup, push token registration,
// and scene configuration. The UI lifecycle moved to SceneDelegate.

#if canImport(UIKit)
import UIKit

private final class ProfileViewController: UIViewController {
    // Building the whole UI in code: assign self.view. Do NOT call super.loadView().
    override func loadView() {
        let root = UIView()
        root.backgroundColor = .systemBackground
        view = root
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        // Size and trait collection are correct here, so geometry-based setup is safe.
    }
}
#endif

// MARK: - 2. frame vs bounds (and transforms)

#Playground("2. frame vs bounds") { demo {
    // A 100×100 view whose center is (150, 150) in its superview.
    let bounds = CGRect(x: 0, y: 0, width: 100, height: 100)   // its own space
    let center = CGPoint(x: 150, y: 150)

    let frame = CGRect(x: center.x - 50, y: center.y - 50, width: 100, height: 100)
    print("no transform → frame:", frame, " bounds:", bounds)

    // Rotate it 45°. `transform` changes how it's DRAWN. `bounds` is untouched.
    let rotation = CGAffineTransform(rotationAngle: .pi / 4)
    let box = bounds.applying(rotation)                  // axis-aligned box around the rotated square
    let rotatedFrame = CGRect(x: center.x - box.width / 2, y: center.y - box.height / 2,
                              width: box.width, height: box.height)

    // PREDICT: what happens to bounds.size and frame.size?
    print("rotated   → bounds.size:", bounds.size)
    print("rotated   → frame.size: ", String(format: "%.2f × %.2f", rotatedFrame.width, rotatedFrame.height))
    // bounds stays 100×100. frame grows to ≈141.42×141.42 (100·√2): the smallest
    // upright rectangle that contains the tilted square.

    // QUIZ: Apple says frame is UNDEFINED when transform isn't identity.
    //   Don't set frame on a transformed view. Use bounds + center instead.
}}

// MARK: - 3. Scrolling = moving bounds.origin

#Playground("3. contentOffset is bounds.origin") { demo {
    // A UIScrollView scrolls by changing its OWN bounds.origin (contentOffset IS bounds.origin).
    // Subview frames never change. Only the "window" into the content moves.
    let rowFrame = CGRect(x: 0, y: 500, width: 320, height: 44)   // a subview, in content coords

    for offsetY in [0.0, 300.0, 500.0] {
        let scrollBounds = CGRect(x: 0, y: offsetY, width: 320, height: 568)
        let onScreenY = rowFrame.minY - scrollBounds.minY           // where you SEE it
        print("contentOffset.y = \(Int(offsetY)) → row frame.y still \(Int(rowFrame.minY)), drawn at y = \(Int(onScreenY))")
    }
    // Same idea: a view's bounds.origin shifts what its subviews show.
}}

// MARK: - 4. Layout cycle + Auto Layout

// setNeedsLayout()   → "please re-layout soon" (async, runs once in the next update cycle,
//                      even if you call it 100 times)
// layoutIfNeeded()   → "if layout is pending, do it RIGHT NOW" (sync)
// layoutSubviews()   → override to position subviews manually. Never call it directly.
//
// The animation trap: changing constraint.constant only MARKS layout as needed. The new
// frames are calculated later, outside your animation block, so nothing animates.
// Fix: call layoutIfNeeded() on a common ancestor INSIDE the animation block.

#if canImport(UIKit)
private final class BannerViewController: UIViewController {
    private let banner = UIView()
    private var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Views created in code default this to true, and UIKit adds autoresizing-mask constraints
        // that fight yours → "Unable to simultaneously satisfy constraints".
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)

        heightConstraint = banner.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            // Safe area keeps content clear of the notch, Dynamic Island and home indicator.
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightConstraint,
        ])
    }

    func expand() {
        heightConstraint.constant = 200          // 1. change the constraint
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()           // 2. lay out NOW, inside the animation
        }
    }
}
#endif

// Intrinsic content size = the size a view "wants" from its content.
//   UILabel, UIButton, UISwitch, UIImageView (with an image) → have one.
//   Plain UIView → none (UIView.noIntrinsicMetric). You must constrain its size.
//
// Two priorities control how intrinsic size can bend:
//   content HUGGING        → resists growing bigger than its content
//   compression RESISTANCE → resists shrinking smaller than its content
// When a row is too narrow, the view with the LOWER compression resistance gets squeezed.

private func whoTruncates(left: (name: String, resistance: Float),
                          right: (name: String, resistance: Float)) -> String {
    if left.resistance == right.resistance { return "ambiguous layout (equal priorities)" }
    return left.resistance < right.resistance ? left.name : right.name
}

#Playground("4. Compression resistance") { demo {
    // Default compression resistance for a label is 750 (.defaultHigh).
    print(whoTruncates(left: ("titleLabel", 750), right: ("dateLabel", 751)))   // titleLabel
    print(whoTruncates(left: ("titleLabel", 750), right: ("dateLabel", 750)))   // ambiguous

    // QUIZ: constraint priorities can change at runtime between OPTIONAL values (e.g. 750 → 250),
    //   but NOT from .required (1000) to optional or back once installed. UIKit throws an exception.
    //   Instead, swap between two constraints (deactivate one, activate the other).
}}

// MARK: - 5. Hit testing: which view gets the touch?

// A small copy of UIView.hitTest(_:with:).
private final class FakeView {
    let name: String
    var frame: CGRect                         // in the superview's coordinates
    var isHidden = false
    var alpha: CGFloat = 1
    var isUserInteractionEnabled = true
    var subviews: [FakeView] = []

    init(_ name: String, frame: CGRect) {
        self.name = name
        self.frame = frame
    }

    var bounds: CGRect { CGRect(origin: .zero, size: frame.size) }

    func hitTest(_ point: CGPoint) -> FakeView? {
        // 1. Skip me (and my whole subtree) if I can't receive touches…
        guard !isHidden, alpha >= 0.01, isUserInteractionEnabled else { return nil }
        // 2. …or if the point isn't inside MY bounds (point(inside:with:)).
        guard bounds.contains(point) else { return nil }
        // 3. Ask subviews front-to-back (last added = on top).
        for sub in subviews.reversed() {
            let local = CGPoint(x: point.x - sub.frame.minX, y: point.y - sub.frame.minY)
            if let hit = sub.hitTest(local) { return hit }
        }
        return self
    }
}

#Playground("5. Hit testing") { demo {
    let window = FakeView("window", frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    let card = FakeView("card", frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    // The button sticks OUT of the card (x 150…250). The part outside still DRAWS
    // (clipsToBounds is false by default)…
    let button = FakeView("button", frame: CGRect(x: 150, y: 20, width: 100, height: 40))
    card.subviews = [button]
    window.subviews = [card]

    print("tap inside card part of button →", window.hitTest(CGPoint(x: 170, y: 40))?.name ?? "nil")
    print("tap outside card part of button →", window.hitTest(CGPoint(x: 230, y: 40))?.name ?? "nil")
    // PREDICT: the second tap returns "window". The card says "not inside my bounds",
    // so the hit test never reaches the button. Fix: enlarge the parent, or override
    // point(inside:with:) / hitTest in the parent.

    button.alpha = 0.005
    print("alpha 0.005 →", window.hitTest(CGPoint(x: 170, y: 40))?.name ?? "nil")   // card
    button.alpha = 0.5
    print("alpha 0.5   →", window.hitTest(CGPoint(x: 170, y: 40))?.name ?? "nil")   // button (still tappable)
}}

// Gesture recognizers: by default only ONE recognizer recognizes at a time.
// To pinch and rotate together, return true from
// gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:) in UIGestureRecognizerDelegate.

#if canImport(UIKit)
private final class PhotoViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        pinch.delegate = self
        rotate.delegate = self
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(rotate)
    }

    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {}
    @objc private func handleRotate(_ g: UIRotationGestureRecognizer) {}

    func gestureRecognizer(_ g: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }
}
#endif

// MARK: - 6. Cell reuse

// Table/collection views RECYCLE cells. A cell that scrolls off-screen gets reused for a
// new row. If an image request for the OLD row finishes late, it lands in the wrong row.

private final class FakeCell {
    var representedID: Int?        // which row this cell shows RIGHT NOW
    var image = "placeholder"
}

#Playground("6. Cell reuse bug") { demo {
    var pendingLoads: [() -> Void] = []

    func configure(_ cell: FakeCell, row: Int, safe: Bool) {
        cell.representedID = row
        cell.image = "placeholder"                   // always reset reused state
        pendingLoads.append {                        // "network" finishes later
            if safe && cell.representedID != row { return }   // ✅ still showing this row?
            cell.image = "photo-\(row)"
        }
    }

    for safe in [false, true] {
        let cell = FakeCell()
        pendingLoads = []
        configure(cell, row: 1, safe: safe)    // row 1 starts loading…
        configure(cell, row: 7, safe: safe)    // …user scrolls, the SAME cell is reused for row 7
        pendingLoads.reversed().forEach { $0() }   // row 7 finishes first, slow row 1 finishes last
        print(safe ? "with check:" : "no check:  ", "cell for row 7 shows", cell.image)
    }
    // no check:   photo-1  ❌ wrong image
    // with check: photo-7  ✅ (also cancel the old request in prepareForReuse)
}}

// dequeueReusableCell(withIdentifier:)       → optional, may return nil, no size info. Older API.
// dequeueReusableCell(withIdentifier:for:)   → non-optional, correct size. CRASHES if the
//                                              identifier wasn't registered. Prefer this one.

// MARK: - 7. Diffable data sources + compositional layout

#Playground("7. Diffable identifiers must be unique") { demo {
    // A snapshot diffs items by their Hashable identity, so every identifier must be unique.
    let ids = ["inbox", "sent", "inbox"]
    let isValid = Set(ids).count == ids.count
    print("snapshot valid?", isValid)   // false → UIKit throws an exception (crash) when applied
    // Fix: use a stable unique ID (database id / UUID), not display text.
}}

// reloadItems(_:)      → throws away the cell and dequeues a new one (flicker, loses state).
// reconfigureItems(_:) → iOS 15+. Runs your cell provider again on the EXISTING cell. Cheaper,
//                        smoother, keeps selection/animations. Use it for content updates.

#if canImport(UIKit)
private enum Section { case main }

private func makeGridLayout() -> UICollectionViewCompositionalLayout {
    // item → group → section → layout
    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5),
                                                        heightDimension: .fractionalHeight(1)))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                     heightDimension: .absolute(120)),
                                                   subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
}

private func applyUpdate(_ dataSource: UICollectionViewDiffableDataSource<Section, String>,
                         changedID: String) {
    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems([changedID])
    dataSource.apply(snapshot, animatingDifferences: true)
}
#endif

// MARK: - 8. Delegates must be weak (and the protocol must be class-only)

private protocol ProfileHeaderDelegate: AnyObject {     // AnyObject → only classes conform
    func didTapAvatar()
}

private final class ProfileHeader {
    weak var delegate: ProfileHeaderDelegate?           // `weak` needs a class-only protocol
    func tap() { delegate?.didTapAvatar() }
}

private final class ProfileScreen: ProfileHeaderDelegate {
    let header = ProfileHeader()                        // screen OWNS header (strong)
    init() { header.delegate = self }                   // header points back WEAKLY
    func didTapAvatar() { print("avatar tapped") }
    deinit { print("ProfileScreen deinit ✅ (no retain cycle)") }
}

#Playground("8. Weak delegate") { demo {
    var screen: ProfileScreen? = ProfileScreen()
    screen?.header.tap()
    screen = nil                                        // prints deinit
    // QUIZ: without `: AnyObject` on the protocol, `weak var delegate` doesn't compile:
    //   weak only works with reference types, and a plain protocol could be adopted by a struct.
}}

// MARK: - 9. Main thread, CALayer, containment, presentation (read-only examples)

#if canImport(UIKit)
import SwiftUI

private final class UserViewController: UIViewController {
    private let nameLabel = UILabel()

    // Completion handlers from URLSession and most SDKs run on a BACKGROUND queue.
    // Touching UIKit there is a bug (Main Thread Checker flags it). Hop to main first.
    func load(using fetchName: @escaping (@escaping (String) -> Void) -> Void) {
        fetchName { name in
            DispatchQueue.main.async {
                self.nameLabel.text = name
            }
        }
    }

    // Embedding a SwiftUI view as a CHILD view controller. Containment order matters:
    func embed<Content: View>(_ swiftUIView: Content) {
        let host = UIHostingController(rootView: swiftUIView)
        addChild(host)                                   // 1. (calls willMove(toParent:) for you)
        view.addSubview(host.view)                       // 2. add its view
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        host.didMove(toParent: self)                     // 3. YOU must call this one
    }

    func showDetail() {
        let detail = UIViewController()
        // iOS 13+: default modalPresentationStyle is .automatic → a page SHEET.
        // The presenter stays visible behind it, so ITS viewWillDisappear/viewDidDisappear
        // are NOT called. Use .fullScreen if you rely on those callbacks.
        present(detail, animated: true)
    }
}
#endif

// UIView vs CALayer:
//   • Every UIView is backed by a CALayer (view.layer) and is that layer's delegate.
//   • The LAYER holds the pixels/visual properties (cornerRadius, shadow, border) and does
//     the animation and compositing work (Core Animation).
//   • The VIEW adds the responder chain (touches, gestures), Auto Layout, and accessibility.

// MARK: - Quiz cheat sheet
//
// Q: Lifecycle order on first push?          A: loadView → viewDidLoad → viewWillAppear → viewIsAppearing → (layout) → viewDidAppear.
// Q: Which run once vs every appearance?     A: loadView/viewDidLoad once. The appear/disappear methods every time.
// Q: Why viewIsAppearing over viewWillAppear? A: The view is in the window, and size + traits are accurate. Good for geometry-based setup.
// Q: Custom loadView?                        A: Create the root view and assign self.view. Don't call super.loadView().
// Q: frame vs bounds?                        A: frame = position+size in the superview. bounds = own coordinate space (origin usually 0,0).
// Q: Rotate a view 45°?                      A: bounds unchanged. frame becomes the bigger enclosing box (and is officially undefined).
// Q: What is contentOffset really?           A: The scroll view's bounds.origin. Subviews' frames don't move.
// Q: setNeedsLayout vs layoutIfNeeded?       A: setNeedsLayout = schedule for the next cycle (async). layoutIfNeeded = lay out now (sync).
// Q: Constraint change doesn't animate?      A: Change the constant, then call layoutIfNeeded() on the superview INSIDE UIView.animate.
// Q: Unsatisfiable constraints in code?      A: Forgot translatesAutoresizingMaskIntoConstraints = false.
// Q: Which label truncates when space is short? A: The one with the LOWER compression resistance priority.
// Q: Which view has no intrinsic size?       A: Plain UIView. (Labels, buttons, switches, image views with an image have one.)
// Q: Change priority 1000 → 750 at runtime?  A: Not allowed once installed (exception). Optional ↔ optional is fine.
// Q: Avoid the notch / home indicator?       A: Constrain to safeAreaLayoutGuide.
// Q: Wrong images while scrolling fast?      A: Cell reuse. Reset in prepareForReuse, check the cell still shows that item, cancel old loads.
// Q: dequeue(withIdentifier:) vs (…, for:)?  A: The `for:` version is non-optional and sized, and crashes if not registered.
// Q: Duplicate IDs in a diffable snapshot?   A: Crash. Identifiers must be unique.
// Q: reconfigureItems vs reloadItems?        A: reconfigure updates the existing cell (cheaper, no flicker). reload replaces the cell.
// Q: Compositional layout hierarchy?         A: Item → Group (can nest) → Section → Layout.
// Q: Which views does hitTest skip?          A: Hidden, isUserInteractionEnabled == false, or alpha < 0.01.
// Q: Visible button doesn't respond?         A: It sits outside its superview's bounds, so hit testing never reaches it.
// Q: Two gestures at once?                   A: Return true from gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:).
// Q: SceneDelegate vs AppDelegate?           A: SceneDelegate = one UI instance's lifecycle (multi-window). AppDelegate = process-level events.
// Q: Swipe home from foreground?             A: sceneWillResignActive → sceneDidEnterBackground.
// Q: `weak var delegate` won't compile?      A: Make the protocol class-only: `protocol P: AnyObject`.
// Q: UIView vs CALayer?                      A: The view handles events/layout and is the layer's delegate. The layer renders and animates.
// Q: Updating a label in a URLSession callback? A: That callback runs on a background queue. Dispatch to main first.
// Q: Embed a SwiftUI view as a child VC?     A: addChild → addSubview(child.view) + constraints → child.didMove(toParent:).
// Q: present() default style on iOS 13+?     A: .automatic → page sheet. The presenter doesn't get viewWillDisappear/viewDidDisappear.
