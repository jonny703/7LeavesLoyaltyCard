//
//  TeamMembersTableViewController.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 2/4/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class TeamMembersTableViewController: UITableViewController {

    var teams: [Team] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Empty DataSet
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.teams = ViewController.sharedInstance.teams
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.teams.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eachFriend", for: indexPath) as! EachTeamMemberTableViewCell

        cell.friend = teams[indexPath.row]

        return cell
    }
}

extension TeamMembersTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You haven’t referred a friend yet. Once a friend successfully redeems their code, they will appear here."
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let textFont = UIFont.systemFont(ofSize: 16)
        let attributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
    }
}
