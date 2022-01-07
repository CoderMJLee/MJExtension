//
//  SwiftModelTests.swift
//  MJExtensionTests
//
//  Created by Frank on 2020/8/21.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

import XCTest

typealias AnyDictType = [String : Any]

class SwiftModelTests: XCTestCase {
    
    // MARK: 🌈 Use Swift model
    func testNormalModel() throws {
        let testerDict: AnyDictType = [
            "isSpecialAgent": true,
            "identifier": "007",
            "age": 22,
            "name": "Juan",
            "child": "im",
            "nicknames": [
                "Juan",
                "尼公子",
                "夜店小王子",
                "s1mple✨🔫Niko"
            ]
        ]
        
        guard let tester1 = MJSuperTester.mj_object(withKeyValues: testerDict) else {
            fatalError("conversion failed")
        }
        XCTAssert(tester1.isSpecialAgent)
        XCTAssert(tester1.identifier == testerDict["identifier"] as? String)
        XCTAssert(tester1.age == testerDict["age"] as! Int)
        XCTAssert(tester1.name == testerDict["name"] as? String)
        
        let nicknames = testerDict["nicknames"] as! [String]
        guard let names = tester1.nicknames else {
            fatalError("Could not convert to Set")
        }
        XCTAssert(names.contains(nicknames[0]))
        XCTAssert(names.contains(nicknames[1]))
        XCTAssert(names.contains(nicknames[2]))
        XCTAssert(names.contains(nicknames[3]))
        
        guard let tester = MJTester.mj_object(withKeyValues: testerDict) else {
            fatalError("conversion subclass failed")
        }
        
        XCTAssert(tester.isSpecialAgent)
        XCTAssert(tester.identifier == testerDict["identifier"] as? String)
        XCTAssert(tester.age == testerDict["age"] as! Int)
        XCTAssert(tester.name == testerDict["name"] as? String)
        XCTAssertEqual(tester.child, testerDict["child"] as? String)
    }

    // MARK: 🌈 Use Objective-C model code
    func testOBJCModel() throws {
        let userDict: AnyDictType = [
            "rich": true,
            "name": "007",
            "age": 22,
            "price": "1.5"
        ]
        
        guard let user = MJUser.mj_object(withKeyValues: userDict) else {
            fatalError("conversion failed")
        }
        XCTAssert(user.rich)
        XCTAssert(user.price == Double(userDict["price"] as! String))
        XCTAssert(user.age == userDict["age"] as! Int)
        XCTAssert(user.name == userDict["name"] as? String)
    }
}
