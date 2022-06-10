//
//  ActivitiesViewController.swift
//  Where
//
//  Created by Vinicius Silva on 09/11/21.
//

import UIKit

class ActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var viewModelDelegate: ActivitiesViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModelDelegate = ActivitiesViewModel()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func presentDetail(For activity: Activity) {
        	
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.cellID) as! ActivityTableViewCell
        
        let activity = self.viewModelDelegate.activities[indexPath.section]
        
        cell.configWith(activity: activity)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = self.viewModelDelegate.activities[indexPath.section]
        self.presentDetail(For: activity)
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
        return self.viewModelDelegate.activities.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activity = self.viewModelDelegate.activities[indexPath.section]
            let deleted = self.viewModelDelegate.deleteActicity(activity: activity)
            if deleted {
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
        }
    }
}
