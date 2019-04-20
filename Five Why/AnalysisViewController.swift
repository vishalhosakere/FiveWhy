//
//  AnalysisViewController.swift
//  Five Why
//
//  Created by Vishal Hosakere on 14/04/19.
//  Copyright © 2019 Vishal Hosakere. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    var nameField: UITextField!
    var name: UILabel!
    var departmentField: UITextField!
    var department: UILabel!
    var equipmentField: UITextField!
    var equipment: UILabel!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var tempMeasures: UITextView!
    var permMeasures: UITextView!
    var verification: UITextView!
    
    var activeField: UITextView?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        print("view loaded")
        super.viewDidLoad()
        configureViews()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        checkLoadData()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        var data: [String] = []
        data.append(nameField.text ?? "")
        data.append(departmentField.text ?? "")
        data.append(equipmentField.text ?? "")
        
        data.append(tempMeasures.text)
        data.append(permMeasures.text)
        data.append(verification.text)
        HomeViewController.analysisData = data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func configureViews(){
        
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.scrollView.delegate = self
        self.view.addSubview(scrollView)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.contentView = UIView()
        self.scrollView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        self.contentView.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(contentView)
        
        name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = "Name:"
        name.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.contentView.addSubview(name)
        nameField = UITextField()
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = "Enter Name"
        nameField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.contentView.addSubview(nameField)
        
        department = UILabel()
        department.translatesAutoresizingMaskIntoConstraints = false
        department.text = "Department:"
        department.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.contentView.addSubview(department)
        departmentField = UITextField()
        departmentField.translatesAutoresizingMaskIntoConstraints = false
        departmentField.placeholder = "Enter Department"
        departmentField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.contentView.addSubview(departmentField)
        
        equipment = UILabel()
        equipment.translatesAutoresizingMaskIntoConstraints = false
        equipment.text = "Equipment:"
        equipment.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.contentView.addSubview(equipment)
        equipmentField = UITextField()
        equipmentField.translatesAutoresizingMaskIntoConstraints = false
        equipmentField.placeholder = "Enter Equipment"
        equipmentField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.contentView.addSubview(equipmentField)
        
        tempMeasures = UITextView()
        tempMeasures.translatesAutoresizingMaskIntoConstraints = false
        tempMeasures.delegate = self
        tempMeasures.textContainer.maximumNumberOfLines = 4
        tempMeasures.text = "Temporary Countermeasures:\n"
        tempMeasures.backgroundColor = .white
        tempMeasures.font = tempMeasures.font?.withSize(20)
        tempMeasures.textColor = .black
        tempMeasures.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tempMeasures.layer.borderWidth = 2
        tempMeasures.addDoneButtonOnKeyboard()
        tempMeasures.isScrollEnabled = false
        self.contentView.addSubview(tempMeasures)
        
        permMeasures = UITextView()
        permMeasures.translatesAutoresizingMaskIntoConstraints = false
        permMeasures.textContainer.maximumNumberOfLines = 4
        permMeasures.delegate = self
        permMeasures.text = "Permanent Countermeasures:\n"
        permMeasures.backgroundColor = .white
        permMeasures.font = permMeasures.font?.withSize(20)
        permMeasures.textColor = .black
        permMeasures.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        permMeasures.layer.borderWidth = 2
        permMeasures.addDoneButtonOnKeyboard()
        permMeasures.isScrollEnabled = false
        self.contentView.addSubview(permMeasures)
        
        verification = UITextView()
        verification.translatesAutoresizingMaskIntoConstraints = false
        verification.textContainer.maximumNumberOfLines = 5
        verification.delegate = self
        verification.text = "Verification:\n"
        verification.backgroundColor = .white
        verification.font = verification.font?.withSize(20)
        verification.textColor = .black
        verification.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        verification.layer.borderWidth = 2
        verification.addDoneButtonOnKeyboard()
        verification.isScrollEnabled = false
        self.contentView.addSubview(verification)
        
        setConstraints()
    }

    
    func setConstraints(){
        let width_15 = self.view.frame.width/15
        let height_15 = self.view.frame.height/15
        
        name.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: height_15).isActive = true
        name.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        name.rightAnchor.constraint(equalTo: name.leftAnchor, constant: 4*width_15).isActive = true
        nameField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: height_15).isActive = true
        nameField.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 0).isActive = true
        nameField.rightAnchor.constraint(equalTo: nameField.leftAnchor, constant: 9*width_15).isActive = true
    
        
        department.topAnchor.constraint(equalTo: name.bottomAnchor, constant: height_15).isActive = true
        department.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        department.rightAnchor.constraint(equalTo: department.leftAnchor, constant: 4*width_15).isActive = true
        departmentField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: height_15).isActive = true
        departmentField.leftAnchor.constraint(equalTo: department.rightAnchor, constant: 0).isActive = true
        departmentField.rightAnchor.constraint(equalTo: departmentField.leftAnchor, constant: 9*width_15).isActive = true
        
        
        equipment.topAnchor.constraint(equalTo: department.bottomAnchor, constant: height_15).isActive = true
        equipment.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        equipment.rightAnchor.constraint(equalTo: equipment.leftAnchor, constant: 4*width_15).isActive = true
        equipmentField.topAnchor.constraint(equalTo: departmentField.bottomAnchor, constant: height_15).isActive = true
        equipmentField.leftAnchor.constraint(equalTo: equipment.rightAnchor, constant: 0).isActive = true
        equipmentField.rightAnchor.constraint(equalTo: equipmentField.leftAnchor, constant: 9*width_15).isActive = true
        
        tempMeasures.topAnchor.constraint(equalTo: equipment.bottomAnchor, constant: height_15).isActive = true
        tempMeasures.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        tempMeasures.rightAnchor.constraint(equalTo: tempMeasures.leftAnchor, constant: 13*width_15).isActive = true
        
        permMeasures.topAnchor.constraint(equalTo: tempMeasures.bottomAnchor, constant: height_15).isActive = true
        permMeasures.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        permMeasures.rightAnchor.constraint(equalTo: permMeasures.leftAnchor, constant: 13*width_15).isActive = true
        
        verification.topAnchor.constraint(equalTo: permMeasures.bottomAnchor, constant: height_15).isActive = true
        verification.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        verification.rightAnchor.constraint(equalTo: verification.leftAnchor, constant: 13*width_15).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0).isActive = true
        contentView.rightAnchor.constraint(equalTo: scrollView.leftAnchor, constant: scrollView.frame.width).isActive = true
        contentView.bottomAnchor.constraint(equalTo: verification.bottomAnchor, constant: height_15).isActive = true
        
    }
    
    func checkLoadData(){
        if HomeViewController.analysisData.count == 6{
            let data = HomeViewController.analysisData
            nameField.text = data[0] == "" ? nil : data[0]
            departmentField.text = data[1] == "" ? nil : data[1]
            equipmentField.text = data[2] == "" ? nil : data[2]
            
            tempMeasures.text = data[3]
            permMeasures.text = data[4]
            verification.text = data[5]
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        //        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
        let collapseSpace = keyboardHeight - distanceToBottom
        if collapseSpace > 0 {
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
        print("In text view: ",self.contentView.frame)
        //Update the scrollView content size to account for the increased contentView
        let size = self.contentView.frame.size
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height + keyboardHeight)

    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeField = textView
        lastOffset = self.scrollView.contentOffset
        return true
    }
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != 0 {
            print("keyboard height 0")
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            //Increase the scrollView contentsize so it is scrollable beyond the keyboard
            let size = self.scrollView.contentSize
            self.scrollView.contentSize = CGSize(width: size.width, height: size.height + keyboardHeight)
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y ?? 0) - (activeField?.frame.size.height ?? 0)
            let collapseSpace = keyboardHeight - distanceToBottom
            if collapseSpace < 0 {
                return
            }
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = self.lastOffset
        }
        let size = self.contentView.frame.size
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height)
        keyboardHeight = 0
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
