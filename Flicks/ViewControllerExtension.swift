//
//  ViewControllerExtension.swift
//  Flicks
//
//  Created by randy_zhao on 5/17/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    public func dismissKeyboard() {
        view.endEditing(true)
    }
}