//
//  HomePageSceneViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/23/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit

class HomePageSceneViewController: UIViewController {
    
    fileprivate var homePageViewController: HomePageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let homePageList = childViewControllers.first as? HomePageViewController else  {
            fatalError("Check storyboard for missing HomePageViewController")
        }
        
        homePageViewController = homePageList
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
