//
//  ValueTransformingTests.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/12/23.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import XCTest
import CoreLocation

class ValueTransformingTests: XCTestCase {
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
    
    func testInfiniteDouble() throws {
        let dict: [String: Any] = [
            "nick_name": "旺财",
            "sale_price": "\(Double.greatestFiniteMagnitude)",
            "run_speed": "\(Float.greatestFiniteMagnitude)",
        ]
        
        guard let dog = MJDog.mj_object(withKeyValues: dict) else {  fatalError("dog conversion failed") }
        
        XCTAssertEqual(dog.nickName, (dict["nick_name"] as! String))
        XCTAssertEqual(dog.salePrice, Double(dict["sale_price"] as! String))
        XCTAssertEqual(dog.runSpeed, Float(dict["run_speed"] as! String))
    }
    
    func testClass() throws {
        let dict: [String: Any] = [
            "instanceClass": "MJCredential"
        ]
        
        guard let credential = MJCredential.mj_object(withKeyValues: dict) else { fatalError("credential conversion failed") }
        
        XCTAssert(credential.instanceClass === MJCredential.self)
    }
    
    func testSelector() throws {
        let dict: [String: Any] = [
            "selector": "verifyToken:"
        ]
        
        guard let credential = MJCredential.mj_object(withKeyValues: dict) else { fatalError("credential conversion failed") }
        
        XCTAssertEqual(credential.selector, Selector(dict["selector"] as! String))
    }
    
}
