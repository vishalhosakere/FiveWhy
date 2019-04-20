//
//  HomeViewController.swift
//  Main
//
//  Created by Gaurav Pai on 17/03/19.
//  Copyright © 2019 Gaurav Pai. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData {
    
    
    // MARK: - Properties
    
    static var delegate: HomeControllerDelegate?
    
    var jsonData : Data?
    var oldjSONData : Data?
    static var uniqueProcessID = 0
    private var scrollView : UIScrollView!
    private var contentView : UIView!
    var problemStatement : UITextView!
    var fiveWhy1 : UITextView!
    var fiveWhy2 : UITextView!
    var fiveWhy3 : UITextView!
    var fiveWhy4 : UITextView!
    var fiveWhy5 : UITextView!
    var activeField: UITextView?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat = 0
    var labels: [UILabel] = []
    static var analysisData : [String] = []
    static var analysisVC = AnalysisViewController()
    static var pdfData: NSMutableData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        configureNavigationBar()
        configureScrollView()
        configureFiveWhy()
        ContainerViewController.menuDelegate = self
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        load_action()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    // MARK: - Handlers
    
    // To add the left bar button to bring up the Menu
    func configureNavigationBar()
    {
        
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationItem.title = "Excelsior: 5 Why Analysis"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "options")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickMenu))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "exit")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickExit))
    }

    func configureScrollView()
    {
        self.scrollView = UIScrollView()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.delegate = self
        self.view.addSubview(scrollView)
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        self.contentView = UIView()
        self.scrollView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        self.contentView.backgroundColor = .clear
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(contentView)
        
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        
    }
    
    func configureFiveWhy()
    {
        problemStatement = UITextView()
        problemStatement.backgroundColor = #colorLiteral(red: 0.8868028951, green: 0.8868028951, blue: 0.8868028951, alpha: 1)
        problemStatement.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        problemStatement.text = "Enter the Problem Statement"
        problemStatement.isScrollEnabled = false
        problemStatement.delegate = self
        problemStatement.font = problemStatement.font?.withSize(20)
        problemStatement.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        problemStatement.layer.borderWidth = 2
        problemStatement.layer.cornerRadius = 3
        problemStatement.addDoneButtonOnKeyboard()
        problemStatement.translatesAutoresizingMaskIntoConstraints = false
        problemStatement.textContainer.maximumNumberOfLines = 3
        self.contentView.addSubview(problemStatement)
        
        fiveWhy1 = UITextView()
        fiveWhy1.text = "First Why"
        fiveWhy1.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        fiveWhy1.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        fiveWhy1.translatesAutoresizingMaskIntoConstraints = false
        fiveWhy1.delegate = self
        fiveWhy1.font = problemStatement.font?.withSize(18)
        fiveWhy1.isScrollEnabled = false
        fiveWhy1.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        fiveWhy1.layer.borderWidth = 2
        fiveWhy1.addDoneButtonOnKeyboard()
        fiveWhy1.isHidden = true
        fiveWhy1.textContainer.maximumNumberOfLines = 3
        self.contentView.addSubview(fiveWhy1)
        
        fiveWhy2 = UITextView()
        fiveWhy2.text = "Second Why"
        fiveWhy2.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        fiveWhy2.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        fiveWhy2.translatesAutoresizingMaskIntoConstraints = false
        fiveWhy2.delegate = self
        fiveWhy2.font = problemStatement.font?.withSize(18)
        fiveWhy2.isScrollEnabled = false
        fiveWhy2.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        fiveWhy2.layer.borderWidth = 2
        fiveWhy2.addDoneButtonOnKeyboard()
        fiveWhy2.isHidden = true
        fiveWhy2.textContainer.maximumNumberOfLines = 3
        self.contentView.addSubview(fiveWhy2)
        
        fiveWhy3 = UITextView()
        fiveWhy3.text = "Third Why"
        fiveWhy3.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        fiveWhy3.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        fiveWhy3.translatesAutoresizingMaskIntoConstraints = false
        fiveWhy3.delegate = self
        fiveWhy3.font = problemStatement.font?.withSize(18)
        fiveWhy3.isScrollEnabled = false
        fiveWhy3.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        fiveWhy3.layer.borderWidth = 2
        fiveWhy3.addDoneButtonOnKeyboard()
        fiveWhy3.isHidden = true
        fiveWhy3.textContainer.maximumNumberOfLines = 3
        self.contentView.addSubview(fiveWhy3)
        
        fiveWhy4 = UITextView()
        fiveWhy4.text = "Fourth Why"
        fiveWhy4.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        fiveWhy4.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        fiveWhy4.translatesAutoresizingMaskIntoConstraints = false
        fiveWhy4.delegate = self
        fiveWhy4.font = problemStatement.font?.withSize(18)
        fiveWhy4.isScrollEnabled = false
        fiveWhy4.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        fiveWhy4.layer.borderWidth = 2
        fiveWhy4.addDoneButtonOnKeyboard()
        fiveWhy4.isHidden = true
        fiveWhy4.textContainer.maximumNumberOfLines = 3
        self.contentView.addSubview(fiveWhy4)
        
        fiveWhy5 = UITextView()
        fiveWhy5.text = "Fifth Why"
        fiveWhy5.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        fiveWhy5.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        fiveWhy5.translatesAutoresizingMaskIntoConstraints = false
        fiveWhy5.delegate = self
        fiveWhy5.font = problemStatement.font?.withSize(18)
        fiveWhy5.isScrollEnabled = false
        fiveWhy5.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        fiveWhy5.layer.borderWidth = 2
        fiveWhy5.addDoneButtonOnKeyboard()
        fiveWhy5.isHidden = true
        fiveWhy5.textContainer.maximumNumberOfLines = 3
        self.contentView.addSubview(fiveWhy5)
        
        setConstraints()
        let size = self.contentView.frame.size
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height)
        
        setTitles()
    }
    
    private func setTitles(){
        var str = ["PROBLEM STATEMENT", "FIRST WHY", "SECOND WHY", "THIRD WHY", "FOUTH WHY", "FIFTH WHY"]
        var views = [problemStatement, fiveWhy1, fiveWhy2, fiveWhy3, fiveWhy4, fiveWhy5]
        for idx in 0...5{
            let label = UILabel()
            label.text = str[idx]
            label.textColor = .black
            label.font = label.font.withSize(21)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isHidden = true
            contentView.addSubview(label)
            label.bottomAnchor.constraint(equalTo: views[idx]!.topAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: views[idx]!.centerXAnchor).isActive = true
            self.labels.append(label)
        }
        self.labels[0].isHidden = false
    }
    
    
    private func setConstraints(){
        let width_15 = self.view.frame.width/15
//        let width_10 = self.view.frame.width/10
        let height_15 = self.view.frame.height/15
//        let height_10 = self.view.frame.height/10
        
        
        problemStatement.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: height_15).isActive = true
        problemStatement.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        problemStatement.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*width_15).isActive = true
        
        fiveWhy1.topAnchor.constraint(equalTo: problemStatement.bottomAnchor, constant: height_15).isActive = true
        fiveWhy1.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        fiveWhy1.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*width_15).isActive = true
        
        fiveWhy2.topAnchor.constraint(equalTo: fiveWhy1.bottomAnchor, constant: height_15).isActive = true
        fiveWhy2.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        fiveWhy2.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*width_15).isActive = true
        
        fiveWhy3.topAnchor.constraint(equalTo: fiveWhy2.bottomAnchor, constant: height_15).isActive = true
        fiveWhy3.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        fiveWhy3.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*width_15).isActive = true
        
        fiveWhy4.topAnchor.constraint(equalTo: fiveWhy3.bottomAnchor, constant: height_15).isActive = true
        fiveWhy4.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        fiveWhy4.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*width_15).isActive = true
        
        fiveWhy5.topAnchor.constraint(equalTo: fiveWhy4.bottomAnchor, constant: height_15).isActive = true
        fiveWhy5.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: width_15).isActive = true
        fiveWhy5.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*width_15).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: fiveWhy5.bottomAnchor, constant: height_15).isActive = true
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if problemStatement.isFirstResponder {
            if problemStatement.text == "Enter the Problem Statement"{
                problemStatement.text = ""
                problemStatement.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        
        if fiveWhy1.isFirstResponder{
            if fiveWhy1.text == "First Why"{
                fiveWhy1.text = ""
                fiveWhy1.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        if fiveWhy2.isFirstResponder{
            if fiveWhy2.text == "Second Why"{
                fiveWhy2.text = ""
                fiveWhy2.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        if fiveWhy3.isFirstResponder{
            if fiveWhy3.text == "Third Why"{
                fiveWhy3.text = ""
                fiveWhy3.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        if fiveWhy4.isFirstResponder{
            if fiveWhy4.text == "Fourth Why"{
                fiveWhy4.text = ""
                fiveWhy4.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        if fiveWhy5.isFirstResponder{
            if fiveWhy5.text == "Fifth Why"{
                fiveWhy5.text = ""
                fiveWhy5.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updateTextFields()
    }
    
    func updateTextFields(){
        if problemStatement.text.isEmpty || problemStatement.text == "" {
            problemStatement.text = "Enter the Problem Statement"
            problemStatement.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else if problemStatement.text != "Enter the Problem Statement"{
            problemStatement.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if fiveWhy1.text.isEmpty || fiveWhy1.text == "" {
            fiveWhy1.text = "First Why"
            fiveWhy1.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else if fiveWhy1.text != "First Why"{
            fiveWhy1.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if fiveWhy2.text.isEmpty || fiveWhy2.text == "" {
            fiveWhy2.text = "Second Why"
            fiveWhy2.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else if fiveWhy2.text != "Second Why"{
            fiveWhy2.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if fiveWhy3.text.isEmpty || fiveWhy3.text == "" {
            fiveWhy3.text = "Third Why"
            fiveWhy3.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else if fiveWhy2.text != "Third Why"{
            fiveWhy3.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if fiveWhy4.text.isEmpty || fiveWhy4.text == "" {
            fiveWhy4.text = "Fourth Why"
            fiveWhy4.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else if fiveWhy4.text != "Fourth Why"{
            fiveWhy4.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if fiveWhy5.text.isEmpty || fiveWhy5.text == "" {
            fiveWhy5.text = "Fifth Why"
            fiveWhy5.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else if fiveWhy5.text != "Fifth Why"{
            fiveWhy5.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        
        if problemStatement.text != "Enter the Problem Statement"{
            fiveWhy1.isHidden = false
            labels[1].isHidden = false
        }
        else{
            print("empty")
            fiveWhy1.isHidden = true
            fiveWhy2.isHidden = true
            fiveWhy3.isHidden = true
            fiveWhy4.isHidden = true
            fiveWhy5.isHidden = true
            for i in 1...5{
                labels[i].isHidden = true
            }
            return
        }
        if fiveWhy1.text != "First Why"{
            fiveWhy2.isHidden = false
            labels[2].isHidden = false
        }
        else{
            fiveWhy2.isHidden = true
            fiveWhy3.isHidden = true
            fiveWhy4.isHidden = true
            fiveWhy5.isHidden = true
            for i in 2...5{
                labels[i].isHidden = true
            }
            return
        }
        if fiveWhy2.text != "Second Why"{
            fiveWhy3.isHidden = false
            labels[3].isHidden = false
        }
        else{
            fiveWhy3.isHidden = true
            fiveWhy4.isHidden = true
            fiveWhy5.isHidden = true
            for i in 3...5{
                labels[i].isHidden = true
            }
            return
        }
        if fiveWhy3.text != "Third Why"{
            fiveWhy4.isHidden = false
            labels[4].isHidden = false
        }
        else{
            fiveWhy4.isHidden = true
            fiveWhy5.isHidden = true
            for i in 4...5{
                labels[i].isHidden = true
            }
            return
        }
        if fiveWhy4.text != "Fourth Why"{
            fiveWhy5.isHidden = false
            labels[5].isHidden = false
        }
        else{
            fiveWhy5.isHidden = true
            labels[5].isHidden = true
            return
        }
        if fiveWhy5.text != "Fifth Why"{
            fiveWhy5.isHidden = false
        }
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
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom + 50
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

    func checkForChanges()
    {
        let homeData = [problemStatement.text,fiveWhy1.text,fiveWhy2.text,fiveWhy3.text,fiveWhy4.text,fiveWhy5.text]
        let analysisData = HomeViewController.analysisData
        let allData = [homeData,analysisData]
        let jsonEncoder = JSONEncoder()
        self.jsonData = try? jsonEncoder.encode(allData)
        print("Checking old data")
        print(getURL(for: .ProjectInShared))
        print(getURL(for: .ApplicationInShared))
        let fileName = LandingPageViewController.projectName + ".excelsior"
        print(fileName)
        let file = FileHandling(name: fileName)
        
        if file.findFile(in: .ProjectInShared)
        {
            try? self.oldjSONData = Data(contentsOf: getURL(for: .ProjectInShared).appendingPathComponent(LandingPageViewController.projectName + ".excelsior"), options: .uncachedRead)
            print("Old Data restored")
        }
    }
    
    func load_action()
    {
        let fileName = LandingPageViewController.projectName+".excelsior"
        let file = FileHandling(name: fileName)
        if file.findFile(in: .ProjectInShared) {
            try? self.jsonData = Data(contentsOf: getURL(for: .ProjectInShared).appendingPathComponent(fileName), options: .uncachedRead)
            print("Data encoded")
            let jsonDecoder = JSONDecoder()
            let decodedData = try? jsonDecoder.decode([[String]].self, from: self.jsonData!)
            if decodedData != nil {
                let allData = decodedData
                restoreState(allData: allData!)
            }
        }
    }
    
    func restoreState(allData : [[String]]){
        let homeData = allData[0]
        HomeViewController.analysisData = allData[1]
        
        problemStatement.text = homeData[0]
        fiveWhy1.text = homeData[1]
        fiveWhy2.text = homeData[2]
        fiveWhy3.text = homeData[3]
        fiveWhy4.text = homeData[4]
        fiveWhy5.text = homeData[5]
        updateTextFields()
    }
    
    //    Generates unique ID for the shapes
    func getUniqueID() -> Int{
        HomeViewController.uniqueProcessID += 1
        return HomeViewController.uniqueProcessID
    }
    

    
    @objc func didClickExit(){
        
        checkForChanges()
        
        if self.jsonData != nil, self.oldjSONData != nil, String(data: self.jsonData!, encoding: .utf8) == String(data: self.oldjSONData!, encoding: .utf8)
        {
            dismiss(animated: true)
        }
        else if self.oldjSONData == nil{
            dismiss(animated: true)
        }
        else
        {
            let alert = UIAlertController(title: "Exiting without saving changes!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                ContainerViewController.menuDelegate?.saveViewState()
                self.dismiss(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
                self.dismiss(animated: true)
            }))

            self.present(alert, animated: true)
        }
    }

    
    @objc func didClickMenu()
    {
        HomeViewController.delegate?.handleMenuToggle(forMenuOption: nil)
    }
 
    // End of Class HomeViewController
}


// Extenstions


extension UITextView {
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone){
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done:UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace,done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}

extension UIScrollView {
    func resizeScrollViewContentSize() {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        self.contentSize = contentRect.size
    }
}

extension UIImage {
    func isEqual(to image: UIImage) -> Bool {
        guard let data1: Data = self.pngData(),
            let data2: Data = image.pngData() else {
                return false
        }
        return data1.elementsEqual(data2)
    }
}

extension FloatingPoint {
    func rounded(to value: Self, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self{
        return (self / value).rounded(roundingRule) * value
        
    }
}

extension CGPoint {
    func rounded(to value: CGFloat, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint{
        return CGPoint(x: CGFloat((self.x / value).rounded(.toNearestOrAwayFromZero) * value), y: CGFloat((self.y / value).rounded(.toNearestOrAwayFromZero) * value))
    }
}

extension CGRect {
    func rounded(to value: CGFloat, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect{
        return CGRect(x: self.origin.x, y: self.origin.y, width: CGFloat((self.width / value).rounded(.toNearestOrAwayFromZero) * value), height: CGFloat((self.height / value).rounded(.toNearestOrAwayFromZero) * value))
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x:0, y: 0, width: 150, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = "  "+message+"  "
        toastLabel.sizeToFit()
        toastLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height-75)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension HomeViewController: savePDFDelegate
{
    func savePDFtoStorage() {
        if HomeViewController.pdfData != nil {
            self.view.saveViewPdf(data: HomeViewController.pdfData!, name: LandingPageViewController.projectName)
        }
    }
}


extension HomeViewController: menuControllerDelegate, UIPopoverPresentationControllerDelegate
{
 
    
    func saveViewState() {
        
        let homeData = [problemStatement.text,fiveWhy1.text,fiveWhy2.text,fiveWhy3.text,fiveWhy4.text,fiveWhy5.text]
        let analysisData = HomeViewController.analysisData
        let allData = [homeData,analysisData]
        let jsonEncoder = JSONEncoder()
        self.jsonData = try? jsonEncoder.encode(allData)
        let fileName = LandingPageViewController.projectName+".excelsior"
        if writeFile(containing: String(data: jsonData!, encoding: .utf8)!, to: getURL(for: .ProjectInShared), withName: fileName) {
            self.showToast(message: "Saved Successfully.")
        }
        print(getURL(for: .ProjectInShared))
    }
    
    func saveViewStateAsNew() {

        let homeData = [problemStatement.text,fiveWhy1.text,fiveWhy2.text,fiveWhy3.text,fiveWhy4.text,fiveWhy5.text]
        let analysisData = HomeViewController.analysisData
        let allData = [homeData,analysisData]
        let jsonEncoder = JSONEncoder()
        self.jsonData = try? jsonEncoder.encode(allData)
        
        let alert = UIAlertController(title: "Enter the name of the Project", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "The name should be unique"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if ((alert.textFields?.first?.text) != nil)
            {
                LandingPageViewController.projectName = alert.textFields!.first!.text!
                let directory = FileHandling(name: LandingPageViewController.projectName)
                if directory.createNewProjectDirectory(), directory.createSharedProjectDirectory()
                {
                    print("Directory successfully created!")
                    let fileName = LandingPageViewController.projectName+".excelsior"
                    if self.writeFile(containing: String(data: self.jsonData!, encoding: .utf8)!, to: self.getURL(for: .ProjectInShared), withName: fileName)
                    {
                        self.showToast(message: "Saved Successfully")
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
    
    func takeScreenShot()
    {
        self.view.exportAsImage(auxView: HomeViewController.analysisVC.view, attachBelow: false)
        self.showToast(message: "Saved Screenshot Successfully")
    }
    
    func exportAsPDF()
    {
        let popoverVC = self.view.exportAsPdfFromView(name: LandingPageViewController.projectName, auxView: HomeViewController.analysisVC.view, attachBelow: false) as? PdfPreviewViewController
        if (popoverVC != nil){
            HomeViewController.pdfData = NSMutableData(data: popoverVC!.pdfData)
            popoverVC?.delegate = self
            popoverVC!.modalPresentationStyle = .popover
            popoverVC!.preferredContentSize = CGSize(width: self.view.bounds.width*(2/3), height: self.view.bounds.height*(2/3))
            if let popoverController = popoverVC!.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/6)
                popoverController.permittedArrowDirections = .any
                popoverController.delegate = self
                popoverVC!.delegate = self
            }
            present(popoverVC!, animated: true, completion: nil)
        }
    }
    
    func startAnalysis()
    {
        
        returnTextView(gesture: UIGestureRecognizer())
        if fiveWhy5.isHidden != true, fiveWhy5.text != "Fifth Why" {
//            let vc = AnalysisViewController()
            self.navigationController?.pushViewController(HomeViewController.analysisVC, animated: true)
        }
        else{
            self.showToast(message: "Please complete the Five Whys first")
        }
    }
    

}
