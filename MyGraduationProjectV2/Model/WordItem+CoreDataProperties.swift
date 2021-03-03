//
//  WordItem+CoreDataProperties.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/8.
//
//

import Foundation
import CoreData


extension WordItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordItem> {
        return NSFetchRequest<WordItem>(entityName: "WordItem")
    }

    @NSManaged public var bncLevel: Int16
    @NSManaged public var collinsLevel: Int16
    @NSManaged public var definition: String?
    @NSManaged public var exampleSentences: String?
    @NSManaged public var frqLevel: Int16
    @NSManaged public var latestSearchDate: Date?
    @NSManaged public var oxfordLevel: Int16
    @NSManaged public var phonetic_EN: String?
    @NSManaged public var phonetic_US: String?
    @NSManaged public var searchCount: Int16
    @NSManaged public var starLevel: Int16
    @NSManaged public var translation: String?
    @NSManaged public var wordContent: String?
    @NSManaged public var wordExchanges: String?
    @NSManaged public var wordID: Int32
    @NSManaged public var wordNote: String?
    @NSManaged public var wordTags: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var learningStatus: LearningWordItem?

}

extension WordItem : Identifiable {

}
