//
//  MJTester.swift
//  MJExtensionTests
//
//  Created by Frank on 2020/8/21.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

import Foundation

@objc(MJTester)
class MJTester: NSObject {
    var isSpecialAgent: Bool { _isSpecialAgent?.boolValue ?? false }
    var age: Int { _age?.intValue ?? 0 }
    
    @objc private var _isSpecialAgent: NSNumber?
    @objc private var _age: NSNumber?
    @objc var name: String?
    @objc var identifier: String?
    
    override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return [
            "_isSpecialAgent": "isSpecialAgent",
            "_age": "age"
        ]
    }
}
