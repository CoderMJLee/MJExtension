//
//  MultiThreadTests.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/3/10.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import XCTest

class MultiThreadTests: XCTestCase {
    private func testerJSON(_ id: Int) -> [String: Any] {
        return
            [
                "isSpecialAgent": true,
                "identifier": "\(id)",
                "age": 22,
                "name": "Juan"
            ]
    }
    
    private func catJSON(_ id: Int) -> [String: Any] {
        return
            [
                "name": "Tom",
                "identifier": "\(id)",
                "nicknames" : [
                    "Jerry's Heart",
                    "Cowboy Tom",
                ],
            ]
    }
    
    func testMultiThread() throws {
        let concurrentQueue = DispatchQueue.init(label: "MJExtension.MultiThread.UnitTests", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit)
        let expectation4Tester = self.expectation(description: "Tester conversion successs")
        let expectation4Cat = self.expectation(description: "Cat conversion successs")
        
        for id in 0..<100 {
            concurrentQueue.async {
                sleep(1)
                let testerDict = self.testerJSON(id)
                guard let tester = MJTester.mj_object(withKeyValues: testerDict) else {
                    XCTAssert(false, "conversion failed")
                    return
                }
                print("tester: \(id)")
//                XCTAssert(tester.isSpecialAgent)
//                XCTAssert(tester.identifier == testerDict["identifier"] as? String)
//                XCTAssert(tester.age == testerDict["age"] as! Int)
//                XCTAssert(tester.name == testerDict["name"] as? String)
                
                if id == 99 {
                    expectation4Tester.fulfill()
                }
            }
            
            concurrentQueue.async {
                sleep(1)
                let catDict = self.catJSON(id)
                guard let cat = MJCat.mj_object(withKeyValues: catDict) else {
                    XCTAssert(false, "convertion failed")
                    return
                }
                print("cat: \(id)")
//                cat.nicknames?.forEach({ (nickname) in
//                    XCTAssert((catDict["nicknames"] as! [String]?)?.contains(nickname) ?? false)
//                })
//                XCTAssert(cat.identifier == catDict["identifier"] as? String)
//                XCTAssert(cat.name == catDict["name"] as? String)
                
                if id == 99 {
                    expectation4Cat.fulfill()
                }
            }
            
            concurrentQueue.async {
                sleep(1)
                MJTester.mj_setupAllowedPropertyNames { () -> [Any]? in
                    ["name", "identifier"]
                }
                print("change allowPropertyNames: (name, identifier) \(id)")
            }
            
            concurrentQueue.async {
                sleep(1)
                MJTester.mj_setupAllowedPropertyNames { () -> [Any]? in
                    ["name"]
                }
                print("change allowPropertyNames: (name) \(id)")
            }
            
            concurrentQueue.async {
                sleep(1)
                MJTester.mj_setupAllowedPropertyNames { () -> [Any]? in
                    ["isSpecialAgent", "age"]
                }
                print("change allowPropertyNames: (isSpecialAgent, age) \(id)")
            }
            
            concurrentQueue.async {
                sleep(1)
                MJUser.mj_setupAllowedPropertyNames { () -> [Any]? in
                    ["name", "nicknames"]
                }
                print("change allowPropertyNames: (name, nicknames) \(id)")
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}
