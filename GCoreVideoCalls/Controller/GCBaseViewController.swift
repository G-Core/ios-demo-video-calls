//
//  GCBaseViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 07.04.2022.
//

import UIKit

class GCBaseViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blueMagentaVeryDark
        
        navigationController?.isNavigationBarHidden = true
        let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
        statusBar?.backgroundColor = .blueMagentaVeryDark
    }
}

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        visibleViewController?.supportedInterfaceOrientations ?? .all
    }
}
