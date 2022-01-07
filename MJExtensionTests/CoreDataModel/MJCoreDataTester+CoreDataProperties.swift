//
//  MJCoreDataTester+CoreDataProperties.swift
//  MJExtension
//
//  Created by Frank on 2022/1/4.
//  Copyright © 2022 MJ Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension MJCoreDataTester {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MJCoreDataTester> {
        return NSFetchRequest<MJCoreDataTester>(entityName: "Tester")
    }

    @NSManaged public var age: Int16
    @NSManaged public var identifier: String?
    @NSManaged public var isJuan: Bool
    @NSManaged public var name: String?
    @NSManaged public var relatives: Set<MJCoreDataPerson>?

}

// MARK: Generated accessors for relatives
extension MJCoreDataTester {

    @objc(addRelativesObject:)
    @NSManaged public func addToRelatives(_ value: MJCoreDataPerson)

    @objc(removeRelativesObject:)
    @NSManaged public func removeFromRelatives(_ value: MJCoreDataPerson)

    @objc(addRelatives:)
    @NSManaged public func addToRelatives(_ values: NSSet)

    @objc(removeRelatives:)
    @NSManaged public func removeFromRelatives(_ values: NSSet)

}
