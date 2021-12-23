//
//  ValueTransformingTest.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/12/23.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import XCTest

class ValueTransformingTest: XCTestCase {
    func testString2Data() throws {
        let dict: [String: Any] = [
            "data": "7355608"
        ]
        
        guard let credential = MJCredential.mj_object(withKeyValues: dict) else {  fatalError("credential conversion failed") }
        guard let testString = dict["data"] as? String,
              let testData = testString.data(using: .utf8) else { fatalError("8 bad data😭") }
        
        XCTAssertEqual(credential.data, testData)
    }
    
    @available(iOS 15, *)
    func testAttributedString2String() throws {
        let article = MJArticle()
        article.attributedTitle = try? NSAttributedString(markdown: "**m0nesy may help Niko get major trophy.**")
        
        guard let JSON = article.mj_JSONString() else {
            fatalError("Object to JSON conversion failed")
        }
        
        XCTAssertEqual(JSON, "{\"attributedTitle\":\"m0nesy may help Niko get major trophy.\"}")
    }
}
