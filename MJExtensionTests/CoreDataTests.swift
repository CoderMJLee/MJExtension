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
            "isJuan": isJuan,
            "identifier": identifier,
            "age": age,
            "name": name,
            "relatives": [
                [
                    "isJuan": isJuan,
                    "identifier": identifier,
                    "age": broAge,
                    "name": broName
                ],
                [
                    "isJuan": isJuan,
                    "identifier": "7355608",
                    "age": age,
                    "name": name
                ]
            ]
        ]
        
        static let name = "Niko"
        static let isJuan = true
        static let age: Int16 = 24
        static let identifier = "7355608"
        static var broAge = age + 1
        static let broName = "huNter"
        
        static func basicAssert(_ tester: MJCoreDataTester) {
            XCTAssert(tester.isJuan == Values.isJuan)
            XCTAssert(tester.identifier == Values.identifier)
            XCTAssert(tester.name == Values.name)
            XCTAssert(tester.age == Values.age)
        }
        
        static func coreDataObject(in context: NSManagedObjectContext) -> MJCoreDataTester {
            return NSEntityDescription.insertNewObject(forEntityName: MJCoreDataTester.entity().name!, into: context) as! MJCoreDataTester
        }
    }
    
    func testJson2CoreDataObject() {
        context.performAndWait {
            guard let tester = MJCoreDataTester.mj_object(withKeyValues: Values.testJSONObject, context: context) else {
                fatalError("conversion to core data object failed")
            }
            
            Values.basicAssert(tester)
            
            guard let relatives = tester.relatives else {
                fatalError("CoreData data structure damaged!")
            }
            XCTAssert(relatives.count != 0)
            
            for relative in relatives {
                switch relative.name {
                case Values.name:
                    Values.basicAssert(relative)
                case Values.broName:
                    XCTAssert(relative.isJuan == Values.isJuan)
                    XCTAssert(relative.identifier == Values.identifier)
                    XCTAssert(relative.name == Values.broName)
                    XCTAssert(relative.age == Values.broAge)
                default: break
                }
            }
        }
    }
    
    func testCoreDataObject2JSON() {
        context.performAndWait {
            let coreDataObject = Values.coreDataObject(in: context)
            coreDataObject.name = Values.name
            coreDataObject.isJuan = Values.isJuan
            coreDataObject.age = Values.age
            coreDataObject.identifier = Values.identifier
            
            guard let dict = coreDataObject.mj_keyValues() else {
                fatalError("conversion to core data object failed")
            }
            
            XCTAssert(dict["isJuan"] as? Bool == Values.isJuan)
            XCTAssert(dict["identifier"] as? String == Values.identifier)
            XCTAssert(dict["name"] as? String == Values.name)
            XCTAssert(dict["age"] as? Int16 == Values.age)
            // TODO: objects -> JSON (Set conversion)
            XCTAssertNotNil(dict["relatives"])
        }
    }
}
