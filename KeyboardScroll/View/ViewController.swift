//
//  ViewController.swift
//  KeyboardScroll
//
//  Created by Kentarou on 2017/07/16.
//  Copyright © 2017年 Kentarou. All rights reserved.
//

import UIKit


extension Notification.Name {
    static let textFieldFocus = Notification.Name("textFieldFocus")
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 各TableViewCellの高さを保持する配列
    var heightAtIndexPath = NSMutableDictionary()
    
    @IBOutlet weak var tableView: UITableView!
    let sectionTitleArray = ["Alphabet Num","Number","Alphabet"," "]
    
    // Data Array
    var dataArray1 = ["One","Two","Three","Four","Five"]
    var dataArray2 = ["1","2","3"]
    var dataArray3 = ["a","b","c","d"]
    var dataArray4 = ["A","B","C","D","E"]
    var dataArrayGroup: [[String]] = []
    
    /// 現在キーボードが表示されているかどうかのフラグ
    var isShowKeyboard = false
    
    var focusCellRect = CGRect.zero
    var targetCellIndexPath: IndexPath?
    
    /// TableView Bottom Constraint
    @IBOutlet weak var baseViewBottomConstraint: NSLayoutConstraint!
    
    var footerHight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Data
        dataArrayGroup = [dataArray1, dataArray2, dataArray3, dataArray4]
        
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "CustomTextFieldCell", bundle: nil), forCellReuseIdentifier: "CustomTextFieldCell")
        addKeyboardNotification()
    }
    
    func addKeyboardNotification() {
        
        // Set Notification
        let notificationCenter = NotificationCenter.default
        
        // キーボードが表示される直前の通知
        notificationCenter.addObserver(self, selector: #selector(self.willShowKeyboard(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillShow,
                                       object: nil)
        
        // キーボードが表示された直後の通知
        notificationCenter.addObserver(self, selector: #selector(self.didShowKeyboard(notification:)),
                                       name: NSNotification.Name.UIKeyboardDidShow,
                                       object: nil)
        
        // キーボードが非表示になる直前の通知
        notificationCenter.addObserver(self, selector: #selector(self.willHideKeyboard(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillHide,
                                       object: nil)
        
        // キーボードが非表示になった直後の通知
        notificationCenter.addObserver(self, selector: #selector(self.didHideKeyboard(notification:)),
                                       name: NSNotification.Name.UIKeyboardDidHide,
                                       object: nil)
        
        // キーボードの高さが変更された時の通知
        notificationCenter.addObserver(self, selector: #selector(self.willChangeKeyboard(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                       object: nil)
        
        // テキストフィールドにフォーカスが入った時の通知
        notificationCenter.addObserver(self, selector: #selector(self.textFieldFocusNotification(notification:)),
                                       name: NSNotification.Name.textFieldFocus,
                                       object: nil)
        
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - TableView Delegate & DataSource
    
    // Section Title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleArray[section]
    }
    
    // Section Count
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArrayGroup.count
    }
    
    // Row Count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArrayGroup[section].count
    }
    
    // Generate Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextFieldCell", for: indexPath) as? CustomTextFieldCell {
            cell.textLabel?.text = dataArrayGroup[indexPath.section][indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // Select Cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let height = heightAtIndexPath.object(forKey: indexPath) as? CGFloat else {
            return UITableViewAutomaticDimension
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    
    // WillShow Keyboad
    func willShowKeyboard(notification: Notification) {
        
        guard !isShowKeyboard else {
            return
        }
        
        isShowKeyboard = true
        
        if let userInfo = (notification as NSNotification).userInfo,
            let keyBoardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            let keyBoardHeight = keyBoardRect.height
            self.baseViewBottomConstraint.constant = keyBoardHeight - footerHight
            
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                
            })
        }
    }
    
    func didShowKeyboard(notification: Notification) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            if self.checkTableScroll() {
                
                if let targetCellIndexPath = self.targetCellIndexPath {
                    self.tableView.scrollToRow(at: targetCellIndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    // WillChange Keyboad
    func willChangeKeyboard(notification: Notification) {
        
        guard isShowKeyboard else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            if self.checkTableScroll() {
                
                if let targetCellIndexPath = self.targetCellIndexPath {
                    self.tableView.scrollToRow(at: targetCellIndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    // WillHide Keyboard
    func willHideKeyboard(notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                
                self.baseViewBottomConstraint.constant = 0
                
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (finished) in
                    
                })
            }
        }
    }
    
    // DidHide Keyboard
    func didHideKeyboard(notification: Notification) {
        // キーボード表示フラグ false
        isShowKeyboard = false
    }
    
    // TextField Focus
    func textFieldFocusNotification(notification: Notification) {
        
        if let cell = notification.object as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                
                self.focusCellRect = tableView.rectForRow(at: indexPath)
                targetCellIndexPath = indexPath
            }
        }
    }
    
    func checkTableScroll(bottomConstraint: CGFloat = 0) -> Bool {
        
        if let indexPaht = targetCellIndexPath {
            
            let cellRect = tableView.rectForRow(at: indexPaht)
            let cellRectInView = tableView.convert(cellRect, to: self.navigationController?.view)
            
            if tableView.frame.minY + tableView.scrollIndicatorInsets.top <= cellRectInView.minY
                && cellRectInView.maxY <= tableView.frame.maxY - bottomConstraint {
                
                // 範囲内の為スクロール不必要
                return false
                
            } else {
                // 範囲外の為スクロール必要
                return true
            }
        }
        return false
    }
}


