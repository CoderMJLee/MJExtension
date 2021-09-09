//
//  MJCoreDataTester+CoreDataProperties.swift
//  MJCoreDataTester
//
//  Created by Frank on 2021/9/8.
//  Copyright © 2021 MJ Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension MJCoreDataTester {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MJCoreDataTester> {
        return NSFetchRequest<MJCoreDataTester>(entityName: "MJCDTester")
    }

    @NSManaged public var name: String?
    @NSManaged public var age: Int16
    @NSManaged public var identifier: String?
    @NSManaged public var isJuan: Bool
}
