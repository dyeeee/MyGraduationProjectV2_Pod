//
//  LCRelation.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/24/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud relation type.

 This type can be used to make one-to-many relationship between objects.
 */
public final class LCRelation: NSObject, LCValue, LCValueExtension, Sequence {
    public typealias Element = LCObject
    
    public let application: LCApplication

    /// The key where relationship based on.
    var key: String?

    /// The parent of all children in relation.
    weak var parent: LCObject?

    /// The class name of children.
    var objectClassName: String?

    /// An array of children added locally.
    var value: [Element] = []

    /// Effective object class name.
    var effectiveObjectClassName: String? {
        return objectClassName ?? value.first?.actualClassName
    }
    
    override init() {
        self.application = LCApplication.default
        super.init()
    }
    
    init(application: LCApplication) {
        self.application = application
        super.init()
    }

    init(application: LCApplication, key: String, parent: LCObject) {
        self.application = application
        super.init()
        
        self.key    = key
        self.parent = parent
    }

    init?(application: LCApplication, dictionary: [String: Any]) {
        self.application = application
        super.init()
        
        guard let type = dictionary["__type"] as? String else {
            return nil
        }
        guard let dataType = HTTPClient.DataType(rawValue: type) else {
            return nil
        }
        guard case dataType = HTTPClient.DataType.relation else {
            return nil
        }

        objectClassName = dictionary["className"] as? String
    }

    public required init?(coder aDecoder: NSCoder) {
        if let applicationID = aDecoder.decodeObject(forKey: "applicationID") as? String,
            let registeredApplication = LCApplication.registry[applicationID] {
            self.application = registeredApplication
        } else {
            self.application = LCApplication.default
        }
        super.init()
        value = (aDecoder.decodeObject(forKey: "value") as? [Element]) ?? []
        objectClassName = aDecoder.decodeObject(forKey: "objectClassName") as? String
    }

    public func encode(with aCoder: NSCoder) {
        let applicationID: String = self.application.id
        aCoder.encode(applicationID, forKey: "applicationID")
        aCoder.encode(value, forKey: "value")

        if let objectClassName = objectClassName {
            aCoder.encode(objectClassName, forKey: "objectClassName")
        }
    }

    public func copy(with zone: NSZone?) -> Any {
        return self
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCRelation {
            return object === self || (parent != nil && key != nil && object.parent == parent && object.key == key)
        } else {
            return false
        }
    }

    public func makeIterator() -> IndexingIterator<[Element]> {
        return value.makeIterator()
    }

    public var jsonValue: Any {
        return typedJSONValue
    }

    private var typedJSONValue: [String: String] {
        var result = [
            "__type": "Relation"
        ]

        if let className = effectiveObjectClassName {
            result["className"] = className
        }

        return result
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return LCDictionary(typedJSONValue).formattedJSONString(indentLevel: indentLevel, numberOfSpacesForOneIndentLevel: numberOfSpacesForOneIndentLevel)
    }

    public var jsonString: String {
        return formattedJSONString(indentLevel: 0)
    }

    public var rawValue: Any {
        return self
    }

    var lconValue: Any? {
        return value.compactMap { (element) in element.lconValue }
    }
    
    static func instance(application: LCApplication) -> LCValue {
        return self.init(application: application)
    }

    func forEachChild(_ body: (_ child: LCValue) throws -> Void) rethrows {
        try value.forEach { element in try body(element) }
    }

    func add(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be added.")
    }

    func concatenate(_ other: LCValue, unique: Bool) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be concatenated.")
    }

    func differ(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be differed.")
    }

    func validateClassName(_ objects: [Element]) throws {
        guard !objects.isEmpty else { return }

        let className = effectiveObjectClassName ?? objects.first!.actualClassName

        for object in objects {
            guard object.actualClassName == className else {
                throw LCError(code: .invalidType, reason: "Invalid class name.", userInfo: nil)
            }
        }
    }

    /**
     Append elements.

     - parameter elements: The elements to be appended.
     */
    func appendElements(_ elements: [Element]) throws {
        try validateClassName(elements)

        value = value + elements
    }

    /**
     Remove elements.

     - parameter elements: The elements to be removed.
     */
    func removeElements(_ elements: [Element]) {
        value = value - elements
    }

    /**
     Insert a child into relation.

     - parameter child: The child that you want to insert.
     */
    public func insert(_ child: LCObject) throws {
        guard let key = key else {
            throw LCError(code: .inconsistency, reason: "Failed to insert object to relation without key.")
        }
        guard let parent = parent else {
            throw LCError(code: .inconsistency, reason: "Failed to insert object to an unbound relation.")
        }
        try parent.insertRelation(key, object: child)
    }

    /**
     Remove a child from relation.

     - parameter child: The child that you want to remove.
     */
    public func remove(_ child: LCObject) throws {
        guard let key = key else {
            throw LCError(code: .inconsistency, reason: "Failed to remove object from relation without key.")
        }
        guard let parent = parent else {
            throw LCError(code: .inconsistency, reason: "Failed to remove object from an unbound relation.")
        }
        try parent.removeRelation(key, object: child)
    }

    /**
     Get query of current relation.
     */
    public var query: LCQuery {
        var query: LCQuery!

        let key = self.key!
        let parent = self.parent!

        /* If class name already known, use it.
           Otherwise, use class name redirection. */
        if let objectClassName = objectClassName {
            query = LCQuery(application: self.application, className: objectClassName)
        } else {
            query = LCQuery(application: self.application, className: parent.actualClassName)
            query.extraParameters = [
                "redirectClassNameForKey": key
            ]
        }

        query.whereKey(key, .relatedTo(parent))

        return query
    }
}
