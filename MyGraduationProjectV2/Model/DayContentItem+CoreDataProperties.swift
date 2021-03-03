//
//  DayContentItem+CoreDataProperties.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/10.
//
//

import Foundation
import CoreData


extension DayContentItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayContentItem> {
        return NSFetchRequest<DayContentItem>(entityName: "DayContentItem")
    }

    @NSManaged public var dateString: String?
    @NSManaged public var monthString: String?
    @NSManaged public var isLearnDone: Bool

}

extension DayContentItem : Identifiable {

}
