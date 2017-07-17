//
//  CustomTextFieldCell.swift
//  KeyboardScroll
//
//  Created by Kentarou on 2017/07/16.
//  Copyright © 2017年 Kentarou. All rights reserved.
//

import UIKit

class CustomTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textfield: CustomTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textfield.delegate = self 
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // TextFieldにフォーカスが入った時に通知を送る
        NotificationCenter.default.post(name: NSNotification.Name.textFieldFocus, object: self)
        return true
    }
}
