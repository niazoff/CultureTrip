//
//  MainViewController.swift
//  CultureTrip
//
//  Created by Natanel Niazoff on 10/28/20.
//

import UIKit
import SwiftUI

class MainViewController: UIViewController {
  @IBAction func viewArticles(_ sender: UIButton) {
    navigationController?.pushViewController(UIHostingController(rootView: ArticlesView(model: .init())), animated: true)
  }
}
