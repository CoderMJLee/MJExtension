//
//  MJCredential.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/12/23.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import Foundation
@objc(MJCredential)
@objcMembers
class MJCredential: NSObject {
    var data: Data?
    var instanceClass: AnyClass?
    var selector: Selector?
}
