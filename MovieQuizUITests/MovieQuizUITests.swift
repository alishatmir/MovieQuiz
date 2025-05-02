//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Алина Тихомирова on 29.04.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
                
        app.terminate()
        app = nil
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testScreenCast() throws { }
}
