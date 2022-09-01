//
//  Seattle_Bridge_TrackerUITests.swift
//  Seattle Bridge TrackerUITests
//
//  Created by Morris Richman on 8/20/22.
//

import XCTest

class Seattle_Bridge_TrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let seattleStaticText = app.tables.staticTexts["Seattle, Wa"]
        
        XCTAssert(seattleStaticText.waitForExistence(timeout: 15))
        snapshot("01Bridges")
        app.tables.cells["Ballard Bridge, Seattle, WA 98199, United States, Down"].children(matching: .other).element(boundBy: 2).children(matching: .other).element.tap()
        snapshot("02BridgeDetails")
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
