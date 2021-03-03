//
//  ToDoItem+CoreDataProperties.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/20.
//
//

import Foundation
import CoreData


extension ToDoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItem> {
        return NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
    }

    @NSManaged public var todoID: UUID?
    @NSManaged public var todoContent: String?
    @NSManaged public var done: Bool
    @NSManaged public var createDate: Date?
    @NSManaged public var createDateString: String?

}
