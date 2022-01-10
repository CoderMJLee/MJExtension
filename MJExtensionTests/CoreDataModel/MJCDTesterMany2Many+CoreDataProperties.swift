//
//  MJCDTesterMany2Many+CoreDataProperties.swift
//  MJExtensionTests
//
//  Created by Frank on 2022/1/10.
//  Copyright © 2022 MJ Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension MJCDTesterMany2Many {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MJCDTesterMany2Many> {
        return NSFetchRequest<MJCDTesterMany2Many>(entityName: "MJCDTesterMany2Many")
    }

    @NSManaged public var age: Int16
    @NSManaged public var identifier: String?
    @NSManaged public var isJuan: Bool
    @NSManaged public var name: String?
    @NSManaged public var bloods: Set<MJCDTesterInverseSelf>?
    @NSManaged public var relatives: Set<MJCDTesterInverseSelf>?

}

// MARK: Generated accessors for bloods
extension MJCDTesterMany2Many {

    @objc(addBloodsObject:)
    @NSManaged public func addToBloods(_ value: MJCDTesterMany2Many)

    @objc(removeBloodsObject:)
    @NSManaged public func removeFromBloods(_ value: MJCDTesterMany2Many)

    @objc(addBloods:)
    @NSManaged public func addToBloods(_ values: NSSet)

    @objc(removeBloods:)
    @NSManaged public func removeFromBloods(_ values: NSSet)

}

// MARK: Generated accessors for relatives
extension MJCDTesterMany2Many {

    @objc(addRelativesObject:)
    @NSManaged public func addToRelatives(_ value: MJCDTesterMany2Many)

    @objc(removeRelativesObject:)
    @NSManaged public func removeFromRelatives(_ value: MJCDTesterMany2Many)

    @objc(addRelatives:)
    @NSManaged public func addToRelatives(_ values: NSSet)

    @objc(removeRelatives:)
    @NSManaged public func removeFromRelatives(_ values: NSSet)

}
