//
//  ModalViewController.swift
//  CardTest

import UIKit

class ModalViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    
    var modalView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let modalView = modalView {
            containerView.embed(modalView)
        }
    }
}
