//
//  TestViewController.swift
//  CardTest

import UIKit

protocol ToggleProtocol {
    func toggle()
}

class TestViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    var currentIndex: Int = 0 {
        didSet {
            guard let label = self.label else { return }
            label.text = "\(currentIndex)"
        }
    }
    var delegate: ToggleProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "\(currentIndex)"
    }
    
    @IBAction func toggleCards(_ sender: Any) {
        delegate?.toggle()
    }
    
}
