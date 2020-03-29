//
//  HTTPTests.swift
//  
//
//  Created by Miso Lubarda on 25.03.20.
//

import XCTest
@testable import Networking

final class HTTPTests: XCTestCase {
    func test_rawValue_forHeaderKey__generatesPredefinedString() {
        XCTAssertEqual(HTTP.Header.Key.authorization.rawValue, "Authorization")
        XCTAssertEqual(HTTP.Header.Key.contentType.rawValue, "Content-Type")
    }

    func test_rawValue_forCustomHeaderKey__generatesPredefinedString() {
        let expectedCustomString = "expectedCustomString"
        let customKey = HTTP.Header.Key.custom(key: expectedCustomString)

        XCTAssertEqual(customKey.rawValue, expectedCustomString)
    }

    func test_rawValue_forHeaderValue__generatesPredefinedString() {
        XCTAssertEqual(HTTP.Header.Value.applicationJSON.rawValue, "application/json")
    }

    func test_rawValue_forCustomHeaderValue__generatesPredefinedString() {
        let expectedCustomString = "expectedCustomString"
        let customValue = HTTP.Header.Value.custom(value: expectedCustomString)

        XCTAssertEqual(customValue.rawValue, expectedCustomString)
    }
}
