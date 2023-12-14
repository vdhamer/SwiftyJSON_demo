//
//  DetailViewController.swift
//  Project38
//
//  Created by Peter van den Hamer on 03/12/2023.
//

import UIKit

class DetailViewController: UIViewController {

    var detailItem: Commit?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let detail = self.detailItem {
            detailLabel.text = detail.message
//             navigationItem.rightBarButtomItem = UIBarButtonItem(
//                                                     title: "Commit 1/\(detail.author.commits.count)",
//                                                     style: .plain,
//                                                     target: self,
//                                                     action: #selector(showAuthorCommits)
//             )
        }
    }

    @IBOutlet weak var detailLabel: UILabel!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
