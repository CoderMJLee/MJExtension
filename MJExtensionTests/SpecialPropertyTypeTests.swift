//
//  SpecialPropertyTypeTests.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/12/9.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import XCTest
import MJExtension

class SpecialPropertyTypeTests: XCTestCase {
    func testLongDoubleType() {
        let bagDict = [
            "weight": 1.5,
            "price": 205,
            "price_longDouble": 205
        ]
        
        let bag = MJBag.mj_object(withKeyValues: bagDict)
        
        XCTAssertEqual(bag?.price_longDouble, 205)
    }
}
