//
//  AboutThisWeekViewController.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 10/16/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import UIKit
import SideMenu
import CTSlidingUpPanel
import SwiftUI

class AboutThisWeekViewController: UIViewController {

    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var descriptionOutlet: UITextView!
    
    private var dataSource: artworkDataSource!
    var work: ArtworkDataType!
      @ObservedObject private var viewModel = ArtworkViewModel()

      private var arr = [ArtworkDataType]()
      private var url = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = AppDelegate.instance.dataSource
        
       self.viewModel.fetchData{arr in
        self.arr = arr
        self.work = self.arr[currentArtNum]
            DispatchQueue.main.async {
                self.titleOutlet.text = self.work.weekTitle
                self.descriptionOutlet.text = self.work.weekDescription

            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
    }
    @IBAction func menuButtonClickws(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weekToMenu"{
            let dest = segue.destination as? TemporaryMenuViewController;}
    }
    //
//    @IBAction func menuButtonClicked(_ sender: Any) {
//        present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil);
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
