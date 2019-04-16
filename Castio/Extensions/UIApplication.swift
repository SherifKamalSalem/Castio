//
//  UIApplication.swift
//  Castio
//
//  Created by Xpress Integration on 4/16/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
