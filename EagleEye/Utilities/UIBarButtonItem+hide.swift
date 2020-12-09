//
//  UIBarButtonItem+hide.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/1/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit

extension UIBarButtonItem{
    func hide(){
        self.isEnabled = false
        self.tintColor = .clear
    }
}
