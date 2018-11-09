//
//  ViewControllerAddChild.swift
//  CardTest

import UIKit
import WebKit

class ViewControllerAddChild: UIViewController {

    @IBOutlet var containerView: UIView!
    
    var pages = [1,1,1]
    var currentIndex = 1
    
    var colorViewController: TestViewController!
    var cardNavigationController = CardNavigationController()
    
    // CardViewControllerTest
    override func viewDidLoad() {
        super.viewDidLoad()

        if let testViewController = storyboard?.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController {
            colorViewController = testViewController
            colorViewController.delegate = self
            colorViewController.currentIndex = currentIndex
            colorViewController.view.backgroundColor = UIColor.random
        }
        
        cardNavigationController.navigationView = colorViewController.view
        cardNavigationController.dataSource = self
        cardNavigationController.delegate = self
        embedChildViewController(cardNavigationController)
        containerView.embed(cardNavigationController.view)
    }
    
    func embedChildViewController(_ child: UIViewController) {
        child.beginAppearanceTransition(true, animated: false)
        addChild(child)
        child.didMove(toParent: self)
        child.endAppearanceTransition()
    }
    
    @IBAction func goModal(_ sender: Any) {
        let navigationView = cardNavigationController.removeNavigationView(snapshot: true)
        performSegue(withIdentifier: "goModal", sender: navigationView)
    }
    
    // Needed for IB linking to exit
    @IBAction func unwindToViewController(_ segue: UIStoryboardSegue) {
        cardNavigationController.navigationView = colorViewController.view
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goModal" {
            guard let modalVC = segue.destination as? ModalViewController else {
                fatalError("goModal segue doensn't contain a ModalViewController as its destination!")
            }
            guard let navigationView = sender as? UIView else {
                fatalError("goModal segue sender isn't a UIView as expected!")
            }
            
            modalVC.modalView = navigationView
        }
    }
}

extension ViewControllerAddChild: CardNavigationDelegate {
    func cardViewControllerDidNavigateForward(_ cardViewController: CardNavigationController) {
        currentIndex += 1
        colorViewController.currentIndex = currentIndex
        colorViewController.view.backgroundColor = UIColor.random
    }
    
    func cardViewControllerDidNavigateBack(_ cardViewController: CardNavigationController) {
        currentIndex -= 1
        colorViewController.currentIndex = currentIndex
        colorViewController.view.backgroundColor = UIColor.random
    }
}

extension ViewControllerAddChild: CardNavigationDatasource {
    func cardViewControllerCanNavigateForward(_ cardViewController: CardNavigationController) -> Bool {
        return currentIndex < pages.count - 1
    }
    
    func cardViewControllerCanNavigateBackwards(_ cardViewController: CardNavigationController) -> Bool {
        return currentIndex > 0
    }
}

extension ViewControllerAddChild: ToggleProtocol {
    func toggle() {
        cardNavigationController.allowNavigation = !cardNavigationController.allowNavigation
    }
    
}
