//
//  MJCoreDataTester+CoreDataClass.swift
//  MJCoreDataTester
//
//  Created by Frank on 2021/9/8.
//  Copyright © 2021 MJ Lee. All rights reserved.
//
//

import Foundation
import CoreData
import MJExtension

@objc(MJCoreDataTester)
@objcMembers
public class MJCoreDataTester: NSManagedObject, MJEConfiguration {
    public static func mj_classInfoInCollection() -> [AnyHashable : Any]! {
        return [
            "relatives": MJCoreDataPerson.self
        ]
    }
}
