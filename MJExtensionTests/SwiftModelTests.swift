//
//  SwiftModelTests.swift
//  MJExtensionTests
//
//  Created by Frank on 2020/8/21.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

import XCTest

class SwiftModelTests: XCTestCase {
    // MARK: 🌈 Use Swift model
    func testNormalModel() throws {
        let testerDict: [String: Any] = [
            "isSpecialAgent": true,
            "identifier": "007",
            "age": 22,
            "name": "Juan"
        ]
        
        guard let tester = MJTester.mj_object(withKeyValues: testerDict) else {
            XCTAssert(false, "conversion failed")
            return
        }
        XCTAssert(tester.isSpecialAgent)
        XCTAssert(tester.identifier == testerDict["identifier"] as? String)
        XCTAssert(tester.age == testerDict["age"] as! Int)
        XCTAssert(tester.name == testerDict["name"] as? String)
    }

    // MARK: 🌈 Use Objective-C model code
    func testOBJCModel() throws {
        let userDict: [String: Any] = [
            "rich": true,
            "name": "007",
            "age": 22,
            "price": "1.5"
        ]
        
        guard let user = MJUser.mj_object(withKeyValues: userDict) else {
            XCTAssert(false, "conversion failed")
            return
        }
        XCTAssert(user.rich)
        XCTAssert(user.price == Double(userDict["price"] as! String))
        XCTAssert(user.age == userDict["age"] as! Int)
        XCTAssert(user.name == userDict["name"] as? String)
    }
}
