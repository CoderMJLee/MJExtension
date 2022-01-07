//
//  DeprecatedAPITests.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/12/31.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import Foundation
import XCTest
import MJExtension;

class DeprecatedAPITests: XCTestCase {
    func testObjectClassInArray() throws {
        let dict: [String: Any] = [
            "name": "mo",
            "cats": [
                [
                    "name": "mo🐱"
                ],
                [
                    "name": "🐱mo"
                ]
            ]
        ]
        
        guard let user = MJFrenchUser.mj_object(withKeyValues: dict) else {
            fatalError("user conversion failed")
        }
        XCTAssertNotNil(user.cats)
        XCTAssertEqual(user.cats.count, 2)
        XCTAssert(user.cats.first!.isKind(of: MJCat.self))
    }
}
