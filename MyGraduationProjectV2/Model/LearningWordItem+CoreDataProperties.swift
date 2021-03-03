//
//  LearningWordItem+CoreDataProperties.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/8.
//
//

import Foundation
import CoreData


extension LearningWordItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LearningWordItem> {
        return NSFetchRequest<LearningWordItem>(entityName: "LearningWordItem")
    }

    @NSManaged public var nextReviewDay: Int16
    @NSManaged public var reviewTimes: Int16
    @NSManaged public var todayReviewCount: Int16
    @NSManaged public var wordContent: String?
    @NSManaged public var wordID: Int32
    @NSManaged public var wordStatus: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var sourceWord: WordItem?

}

extension LearningWordItem : Identifiable {

}
