//
//  PdfPreviewViewController.swift
//  Five Why
//
//  Created by Vishal Hosakere on 17/04/19.
//  Copyright © 2019 Vishal Hosakere. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

class PdfPreviewViewController: UIViewController {

    var pdfData : Data!
    var delegate: HomeViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    convenience init(data: NSMutableData){
        self.init()
        self.pdfData = data as Data
        let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width*(2/3), height: self.view.bounds.height*(2/3) - 80))
        let document = PDFDocument(data: data as Data)
        pdfView.document = document
        pdfView.autoScales = true
        self.view.addSubview(pdfView)
        
        let save = UIButton(frame: CGRect(x: self.view.bounds.width*(2/6) - 30, y: self.view.bounds.height*(2/3) - 80, width: 60, height: 50))
        save.setTitle("Save", for: .normal)
        save.backgroundColor = .black
        //save.center = CGPoint(x: self.view.bounds.width*(2/6), y: self.view.bounds.height*(2/3) - 80)
        save.addTarget(self, action: #selector(clickedSave), for: .touchUpInside)
        self.view.addSubview(save)

    }

    
    @objc func clickedSave(_ sender : UIButton){
        delegate?.savePDFtoStorage()
        dismiss(animated: true, completion: nil)
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
