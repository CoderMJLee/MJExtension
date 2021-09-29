//
//  CoreDataTests.swift
//  CoreDataTests
//
//  Created by Frank on 2021/9/8.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import XCTest
import CoreData

class CoreDataTests: XCTestCase {
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let container = NSPersistentContainer(name: "MJCoreDataTestModel")
        // Test in memory. This is important.
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { description, error in
            XCTAssertNil(error)
        }
        self.container = container
        context = container.newBackgroundContext()
    }
    
    struct Values {
        static let testJSONObject: [String : Any] = [
            "isJuan": true,
            "identifier": "7355608",
            "age": 24,
            "name": "Niko"
        ]
        
        static var name: String {
            testJSONObject["name"] as! String
        }
        static var isJuan: Bool {
            testJSONObject["isJuan"] as! Bool
        }
        static var age: Int {
            testJSONObject["age"] as! Int
        }
        static var identifier: String {
            testJSONObject["identifier"] as! String
        }
    }

    func testConversions() {
        json2CoreDataObject()
        
        coreDataObject2JSON()
    }
    
    func json2CoreDataObject() {
        context.performAndWait {
            guard let tester = MJCoreDataTester.mj_object(withKeyValues: Values.testJSONObject, context: context) else {
                XCTAssert(false, "conversion to core data object failed")
                return
            }
            
            XCTAssert(tester.isJuan == Values.isJuan)
            XCTAssert(tester.identifier == Values.identifier)
            XCTAssert(tester.name == Values.name)
            XCTAssert(tester.age == Values.age)
        }
    }
    
    func coreDataObject2JSON() {
        context.performAndWait {
            let coreDataObject =  NSEntityDescription.insertNewObject(forEntityName: MJCoreDataTester.entity().name!, into: context) as! MJCoreDataTester
            coreDataObject.name = Values.name
            coreDataObject.age = Int16(Values.age)
            coreDataObject.isJuan = Values.isJuan
            coreDataObject.identifier = Values.identifier
            
            guard let dict = coreDataObject.mj_keyValues() else {
                XCTAssert(false, "conversion to keyValues failed")
                return
            }
            
            XCTAssert(dict["isJuan"] as! Bool == Values.isJuan)
            XCTAssert(dict["identifier"] as? String == Values.identifier)
            XCTAssert(dict["name"] as? String == Values.name)
            XCTAssert(dict["age"] as! Int == Values.age)
        }
    }

}
