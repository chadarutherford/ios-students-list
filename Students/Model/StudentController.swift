//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum SortOptions: Int {
    case firstName
    case lastName
}

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

class StudentController {
    
    private var students = [Student]()
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Persistence
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Helper Methods
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        let bgQueue = DispatchQueue(label: "studentQueue", attributes: .concurrent)
        bgQueue.async { [weak self] in
            guard let self = self else { return }
            let fm = FileManager.default
            let decoder = JSONDecoder()
            guard let fileURL = self.persistentFileURL, fm.fileExists(atPath: fileURL.path) else { return }
            do {
                let data = try Data(contentsOf: fileURL)
                let students = try decoder.decode([Student].self, from: data)
                self.students = students
                completion(self.students, nil)
            } catch let loadError {
                print("Error loading student data: \(loadError.localizedDescription)")
                completion(nil, loadError)
            }
        }
    }
    
    func filter(with trackType: TrackType, sortedBy sorter: SortOptions, completion: @escaping ([Student]) -> Void) {
        var updatedStudents: [Student]
        switch trackType {
        case .iOS:
            updatedStudents = students.filter { $0.course == "iOS" }
        case .Web:
            updatedStudents = students.filter { $0.course == "Web" }
        case .UX:
            updatedStudents = students.filter { $0.course == "UX" }
        default:
            updatedStudents = students
        }
        
        if sorter == .firstName {
            updatedStudents = updatedStudents.sorted { $0.firstName < $1.firstName }
        } else {
            updatedStudents = updatedStudents.sorted { $0.lastName < $1.lastName }
        }
        
        completion(updatedStudents)
    }
}
