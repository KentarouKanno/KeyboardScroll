//
//  CustomTextField.swift
//  KeyboardScroll
//
//  Created by Kentarou on 2017/07/16.
//  Copyright © 2017年 Kentarou. All rights reserved.
//

import Foundation
import UIKit

protocol CustomTextFieldDelegate: class {
    func tapDonehButton(textField: CustomTextField, text: String)
}

class CustomTextField: UITextField {

    weak var customTextFieldDelegate: CustomTextFieldDelegate?
    
    /// 初期化
    ///
    /// - parameter aDecoder: NSCoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override var inputAccessoryView: UIView? {
        get {
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = .black
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self,
                                             action: #selector(self.tapDoneButton))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                              target: nil,
                                              action: nil)
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()

            return toolBar
        }
        set {}
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 2, dy: 1)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 2, dy: 1)
    }

    // MARK: - Private Method
    
    /// Doneボタン押下処理
    func tapDoneButton() {
        if let text = self.text {
            customTextFieldDelegate?.tapDonehButton(textField: self, text: text)
        }
        self.resignFirstResponder()
    }
}
