//
//  ActivitiesViewController.swift
//  Where
//
//  Created by Vinicius Silva on 09/11/21.
//

import UIKit

class ActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var activities: [Activity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.activities = DatabaseManager.shared.getAllActivities()
        self.tableView.reloadData()
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.cellID) as! ActivityTableViewCell
        
        let activity = self.activities[indexPath.section]
        
        cell.configWith(activity: activity)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.activities.count
    }
}
