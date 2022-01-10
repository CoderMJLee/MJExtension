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
                    "age": cousinAge,
                    "name": cousinName
                ],
                [
                    "age": age,
                    "name": name
                ],
                [
                    "age": sisAge,
                    "name": sisName
                ],
                [
                    "age": broAge,
                    "name": broName
                ]
            ],
            "blood": [
                [
                    "age": cousinAge,
                    "name": cousinName
                ],
                [
                    "age": sisAge,
                    "name": sisName
                ]
            ]
        ]
        
        static let name = "Niko"
        static let isJuan = true
        static let age: Int16 = 24
        static let identifier = "7355608"
        static var cousinAge = age + 1
        static let cousinName = "huNter"
        static let sisName = "Jovana"
        static var sisAge = age - 5
        static let broName = "YNK"
        static let broAge = age + 5
        
        static func basicAssert(_ tester: MJCoreDataTester) {
            XCTAssert(tester.isJuan == Values.isJuan)
            XCTAssert(tester.identifier == Values.identifier)
            XCTAssert(tester.name == Values.name)
            XCTAssert(tester.age == Values.age)
        }
        
        static func coreDataObject<T: NSManagedObject>(for type: T.Type, in context: NSManagedObjectContext) -> T {
            return NSEntityDescription.insertNewObject(forEntityName: T.entity().name!, into: context) as! T
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
            XCTAssertEqual(relatives.count, 4)
            
            for relative in relatives {
                switch relative.name {
                case Values.name:
                    XCTAssert(relative.age == Values.age)
                case Values.broName:
                    XCTAssert(relative.age == Values.broAge)
                case Values.sisName:
                    XCTAssert(relative.age == Values.sisAge)
                case Values.cousinName:
                    XCTAssert(relative.age == Values.cousinAge)
                default: break
                }
            }
        }
    }
    
    func testCoreDataObject2JSON() {
        context.performAndWait {
            let niko = Values.coreDataObject(for: MJCoreDataTester.self, in: context)
            niko.name = Values.name
            niko.isJuan = Values.isJuan
            niko.age = Values.age
            niko.identifier = Values.identifier
            
            let cousin = Values.coreDataObject(for: MJCoreDataPerson.self, in: context)
            cousin.name = Values.broName
            cousin.age = Values.broAge
            niko.addToRelatives(cousin)
            
            guard let dict = niko.mj_JSONObject() as? [String: Any] else {
                fatalError("conversion to core data object failed")
            }
            
            XCTAssert(dict["isJuan"] as? Bool == Values.isJuan)
            XCTAssert(dict["identifier"] as? String == Values.identifier)
            XCTAssert(dict["name"] as? String == Values.name)
            XCTAssert(dict["age"] as? Int16 == Values.age)
            
            XCTAssertNotNil(dict["relatives"])
            XCTAssertEqual((dict["relatives"] as! [Any]).count, 1)
            guard let relatives = dict["relatives"] as? [[String: Any]] else {
                fatalError("relatives cast error")
            }
            let cousinInfo = relatives[0]
            XCTAssert(cousinInfo["name"] as? String == Values.broName)
            XCTAssert(cousinInfo["age"] as? Int16 == Values.broAge)
            XCTAssertNil(cousinInfo["tester"])
        }
    }
    
    func testCoreData2JSON_InverseSelf() {
        context.performAndWait {
            let niko = Values.coreDataObject(for: MJCDTesterInverseSelf.self, in: context)
            niko.name = Values.name
            niko.isJuan = Values.isJuan
            niko.age = Values.age
            niko.identifier = Values.identifier
            
            let bro = Values.coreDataObject(for: MJCDTesterInverseSelf.self, in: context)
            bro.name = Values.broName
            bro.age = Values.broAge
            bro.isJuan = Values.isJuan
            bro.identifier = Values.identifier
            niko.addToRelatives(bro)
            
            let sis = Values.coreDataObject(for: MJCDTesterInverseSelf.self, in: context)
            sis.name = Values.sisName
            sis.age = Values.sisAge
            sis.isJuan = !Values.isJuan
            sis.identifier = Values.identifier
            niko.addToRelatives(sis)
            
            let cousin = Values.coreDataObject(for: MJCDTesterInverseSelf.self, in: context)
            cousin.name = Values.cousinName
            cousin.age = Values.cousinAge
            cousin.isJuan = Values.isJuan
            cousin.identifier = Values.identifier
            niko.addToRelatives(cousin)
            
            guard let nikoInfo = niko.mj_JSONObject() as? [String: Any] else {
                fatalError("conversion to core data object failed")
            }
            
            XCTAssert(nikoInfo["isJuan"] as? Bool == Values.isJuan)
            XCTAssert(nikoInfo["identifier"] as? String == Values.identifier)
            XCTAssert(nikoInfo["name"] as? String == Values.name)
            XCTAssert(nikoInfo["age"] as? Int16 == Values.age)
            // check relatives
            do {
                XCTAssertNotNil(nikoInfo["relatives"])
                XCTAssertEqual((nikoInfo["relatives"] as! [Any]).count, 3)
                guard let relatives = nikoInfo["relatives"] as? [[String: Any]] else {
                    fatalError("relatives cast error")
                }
                for info in relatives {
                    let name = info["name"] as! String
                    switch name {
                    case Values.sisName:
                        XCTAssertEqual(info["age"] as? Int16, Values.sisAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, !Values.isJuan)
                    case Values.cousinName:
                        XCTAssertEqual(info["age"] as? Int16, Values.cousinAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, Values.isJuan)
                    case Values.broName:
                        XCTAssertEqual(info["age"] as? Int16, Values.broAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, Values.isJuan)
                    default: break
                    }
                    
                    XCTAssertEqual(info["identifier"] as? String, Values.identifier)
                }
            }
        }
    }
    
    func testCoreData2JSON_Many2Many() {
        context.performAndWait {
            let niko = Values.coreDataObject(for: MJCDTesterMany2Many.self, in: context)
            niko.name = Values.name
            niko.isJuan = Values.isJuan
            niko.age = Values.age
            niko.identifier = Values.identifier
            
            let bro = Values.coreDataObject(for: MJCDTesterMany2Many.self, in: context)
            bro.name = Values.broName
            bro.age = Values.broAge
            bro.isJuan = Values.isJuan
            bro.identifier = Values.identifier
            niko.addToRelatives(bro)
            
            let sis = Values.coreDataObject(for: MJCDTesterMany2Many.self, in: context)
            sis.name = Values.sisName
            sis.age = Values.sisAge
            sis.isJuan = !Values.isJuan
            sis.identifier = Values.identifier
            niko.addToRelatives(sis)
            niko.addToBloods(sis)
            
            let cousin = Values.coreDataObject(for: MJCDTesterMany2Many.self, in: context)
            cousin.name = Values.cousinName
            cousin.age = Values.cousinAge
            cousin.isJuan = Values.isJuan
            cousin.identifier = Values.identifier
            niko.addToRelatives(cousin)
            niko.addToBloods(cousin)
            
            guard let nikoInfo = niko.mj_JSONObject() as? [String: Any] else {
                fatalError("conversion to core data object failed")
            }
            
            XCTAssert(nikoInfo["isJuan"] as? Bool == Values.isJuan)
            XCTAssert(nikoInfo["identifier"] as? String == Values.identifier)
            XCTAssert(nikoInfo["name"] as? String == Values.name)
            XCTAssert(nikoInfo["age"] as? Int16 == Values.age)
            // check relatives
            do {
                XCTAssertNotNil(nikoInfo["relatives"])
                XCTAssertEqual((nikoInfo["relatives"] as! [Any]).count, 3)
                guard let relatives = nikoInfo["relatives"] as? [[String: Any]] else {
                    fatalError("relatives cast error")
                }
                for info in relatives {
                    let name = info["name"] as! String
                    switch name {
                    case Values.sisName:
                        XCTAssertEqual(info["age"] as? Int16, Values.sisAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, !Values.isJuan)
                    case Values.cousinName:
                        XCTAssertEqual(info["age"] as? Int16, Values.cousinAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, Values.isJuan)
                    case Values.broName:
                        XCTAssertEqual(info["age"] as? Int16, Values.broAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, Values.isJuan)
                    default: break
                    }
                    
                    XCTAssertEqual(info["identifier"] as? String, Values.identifier)
                }
            }
            // check bloods
            do {
                XCTAssertNotNil(nikoInfo["bloods"])
                XCTAssertEqual((nikoInfo["bloods"] as! [Any]).count, 2)
                guard let bloods = nikoInfo["bloods"] as? [[String: Any]] else {
                    fatalError("bloods cast error")
                }
                for info in bloods {
                    let name = info["name"] as! String
                    switch name {
                    case Values.sisName:
                        XCTAssertEqual(info["age"] as? Int16, Values.sisAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, !Values.isJuan)
                    case Values.cousinName:
                        XCTAssertEqual(info["age"] as? Int16, Values.cousinAge)
                        XCTAssertEqual(info["isJuan"] as? Bool, Values.isJuan)
                    default: break
                    }
                    
                    XCTAssertEqual(info["identifier"] as? String, Values.identifier)
                }
            }
        }
    }
}
