import XCTest
@testable import Components

final class CustomImageBackgroundLayoutTests: XCTestCase {
    func testFixedStyleKeepsImageInPlace() {
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .fixed, scrollOffset: 48),
            CustomImageBackgroundLayout(yOffset: 0, extraHeight: 0)
        )
    }

    func testScrollStyleFollowsContentInBothDirections() {
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .scroll, scrollOffset: 60),
            CustomImageBackgroundLayout(yOffset: -60, extraHeight: 0)
        )
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .scroll, scrollOffset: -24),
            CustomImageBackgroundLayout(yOffset: 24, extraHeight: 0)
        )
    }

    func testStickyTopClampsDownwardPull() {
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .stickyTop, scrollOffset: 32),
            CustomImageBackgroundLayout(yOffset: -32, extraHeight: 0)
        )
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .stickyTop, scrollOffset: -24),
            CustomImageBackgroundLayout(yOffset: 0, extraHeight: 0)
        )
    }

    func testStretchyTopAddsHeightOnlyOnPullDown() {
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .stretchyTop, scrollOffset: 28),
            CustomImageBackgroundLayout(yOffset: -28, extraHeight: 0)
        )
        XCTAssertEqual(
            CustomImageBackgroundLayout.make(style: .stretchyTop, scrollOffset: -36),
            CustomImageBackgroundLayout(yOffset: 0, extraHeight: 36)
        )
    }

    func testResolvedHeightKeepsBaseHeightForFixedStyle() {
        let layout = CustomImageBackgroundLayout.make(style: .fixed, scrollOffset: 20)

        XCTAssertEqual(layout.resolvedHeight(baseHeight: 280), 280)
    }

    func testResolvedHeightAddsPullDownDistanceForStretchyTop() {
        let layout = CustomImageBackgroundLayout.make(style: .stretchyTop, scrollOffset: -52)

        XCTAssertEqual(layout.resolvedHeight(baseHeight: 280), 332)
    }
}
