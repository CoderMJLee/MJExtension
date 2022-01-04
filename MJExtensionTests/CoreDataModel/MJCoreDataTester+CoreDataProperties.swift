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
        return NSFetchRequest<MJCoreDataTester>(entityName: "MJCDTester")
    }

    @NSManaged public var age: Int16
    @NSManaged public var identifier: String?
    @NSManaged public var isJuan: Bool
    @NSManaged public var name: String?
    @NSManaged public var relatives: Set<MJCoreDataTester>?

}

// MARK: Generated accessors for relatives
extension MJCoreDataTester {

    @objc(addRelativesObject:)
    @NSManaged public func addToRelatives(_ value: MJCoreDataTester)

    @objc(removeRelativesObject:)
    @NSManaged public func removeFromRelatives(_ value: MJCoreDataTester)

    @objc(addRelatives:)
    @NSManaged public func addToRelatives(_ values: NSSet)

    @objc(removeRelatives:)
    @NSManaged public func removeFromRelatives(_ values: NSSet)

}
