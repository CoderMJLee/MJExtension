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
    
    // MARK: 测试含有 UIColor 的属性
    func testUIColorPropertyModel() throws {
        let catDict: AnyDictType = [
            "name": "五更琉璃",
            "address": NSNull(),
            "nicknames": ["黑猫", "我老婆"],
            "color": [
                "systemColorName": "blackColor"
            ]
        ]
        
        guard let cat = MJCat.mj_object(withKeyValues: catDict) else {
            fatalError("cat conversion failed")
        }
        XCTAssertEqual(cat.name, catDict["name"] as? String)
        XCTAssertNil(cat.address)
        XCTAssert(cat.nicknames?.count == 2)
        // 这个 Color 是不能被正常当普通的 UIColor 使用的.
        XCTAssertNotNil(cat.color)
    }

    func testUIColor2JSON() throws {
        let ごこうるり = MJCat()
        ごこうるり.name = "五更瑠璃"
        ごこうるり.nicknames = ["黑猫", "我老婆"]
        ごこうるり.color = .black
        
        guard let JSON = ごこうるり.mj_JSONObject() as? AnyDictType else {
            fatalError("UIColor model to JSON conversion failed")
        }
        XCTAssertEqual(JSON["name"] as? String, ごこうるり.name)
        XCTAssert((JSON["nicknames"] as? [String])?.count == 2)
    }

    func testUIColorCoding() throws {
        // 创建模型
        let master = MJCat()
        master.name = "要变了";
        master.color = .white;
        master.nicknames = ["主人", "陛下"];
        
        let file = NSTemporaryDirectory().appending("/cat.data")
        let data = try NSKeyedArchiver.archivedData(withRootObject: master, requiringSecureCoding: true) as NSData
        let isFinished = data.write(toFile: file, atomically: true)
        XCTAssert(isFinished);

        // 解档
        let readData = FileManager.default.contents(atPath: file)
        XCTAssertNotNil(readData)
        let decodedMaster = try NSKeyedUnarchiver.unarchivedObject(ofClass: MJCat.self, from: readData!)
        
        XCTAssertEqual(decodedMaster?.name, master.name);
        XCTAssertEqual(decodedMaster?.nicknames?.count, 2);
        XCTAssertEqual(decodedMaster?.color, master.color);
    }
}
