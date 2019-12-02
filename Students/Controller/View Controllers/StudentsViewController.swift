//
//  MainViewController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import UIKit

class StudentsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sortSelector: UISegmentedControl!
    @IBOutlet weak var filterSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let studentController = StudentController()
    private var filteredAndSortedStudents = [Student]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        studentController.loadFromPersistentStore { [weak self] students, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading students: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let students = students else { return }
                self.filteredAndSortedStudents = students
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func sort(_ sender: UISegmentedControl) {
        updateDataSource()
    }
    
    @IBAction func filter(_ sender: UISegmentedControl) {
        updateDataSource()
    }
    
    // MARK: - Private
    private func updateDataSource() {
        let sort = SortOptions(rawValue: sortSelector.selectedSegmentIndex) ?? .firstName
        let filter = TrackType(rawValue: filterSelector.selectedSegmentIndex) ?? .none
        
        studentController.filter(with: filter, sortedBy: sort) { [weak self] students in
            guard let self = self else { return }
            self.filteredAndSortedStudents = students
        }
    }
}

// --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - TableView Data Source Extension
extension StudentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAndSortedStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = filteredAndSortedStudents[indexPath.row]
        cell.textLabel?.text = student.name
        cell.detailTextLabel?.text = student.course
        return cell
    }
}
