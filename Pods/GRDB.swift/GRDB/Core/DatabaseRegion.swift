/// DatabaseRegion defines a region in the database. DatabaseRegion is dedicated
/// to help transaction observers recognize impactful database changes in their
/// `observes(eventsOfKind:)` and `databaseDidChange(with:)` methods.
///
/// A database region is the union of any number of "table regions", which can
/// cover a full table, or the combination of columns and rows:
///
///     |Table1 |   |Table2 |   |Table3 |   |Table4 |   |Table5 |
///     |-------|   |-------|   |-------|   |-------|   |-------|
///     |x|x|x|x|   |x| | | |   |x|x|x|x|   |x|x| |x|   | | | | |
///     |x|x|x|x|   |x| | | |   | | | | |   | | | | |   | |x| | |
///     |x|x|x|x|   |x| | | |   | | | | |   |x|x| |x|   | | | | |
///     |x|x|x|x|   |x| | | |   | | | | |   | | | | |   | | | | |
///
/// To create a database region, you use one of those methods:
///
/// - `DatabaseRegion.fullDatabase`: the region that covers all database tables.
///
/// - `DatabaseRegion()`: the empty region.
///
/// - `DatabaseRegion(table:)`: the region that covers one database table.
///
/// - `SelectStatement.databaseRegion`:
///
///         let statement = try db.makeSelectStatement(sql: "SELECT name, score FROM player")
///         let region = statement.databaseRegion
///
/// - `FetchRequest.databaseRegion(_:)`
///
///         let request = Player.filter(key: 1)
///         let region = try request.databaseRegion(db)
public struct DatabaseRegion: CustomStringConvertible, Equatable {
    private let tableRegions: [String: TableRegion]?
    
    private init(tableRegions: [String: TableRegion]?) {
        self.tableRegions = tableRegions
    }
    
    /// Returns whether the region is empty.
    public var isEmpty: Bool {
        guard let tableRegions = tableRegions else {
            // full database
            return false
        }
        return tableRegions.isEmpty
    }
    
    /// The region that covers the full database: all columns and all rows
    /// from all tables.
    public static let fullDatabase = DatabaseRegion(tableRegions: nil)
    
    /// Creates an empty database region.
    public init() {
        self.init(tableRegions: [:])
    }
    
    /// Creates a region that spans all rows and columns of a database table.
    ///
    /// - parameter table: A table name.
    public init(table: String) {
        self.init(tableRegions: [table: TableRegion(columns: nil, rowIds: nil)])
    }
    
    /// Full columns in a table: (some columns in a table) × (all rows)
    init(table: String, columns: Set<String>) {
        self.init(tableRegions: [table: TableRegion(columns: columns, rowIds: nil)])
    }
    
    /// Full rows in a table: (all columns in a table) × (some rows)
    init(table: String, rowIds: Set<Int64>) {
        self.init(tableRegions: [table: TableRegion(columns: nil, rowIds: rowIds)])
    }
    
    /// Returns the intersection of this region and the given one.
    ///
    /// This method is not public because there is no known public use case for
    /// this intersection. It is currently only used as support for
    /// the isModified(byEventsOfKind:) method.
    func intersection(_ other: DatabaseRegion) -> DatabaseRegion {
        guard let tableRegions = tableRegions else { return other }
        guard let otherTableRegions = other.tableRegions else { return self }
        
        var tableRegionsIntersection: [String: TableRegion] = [:]
        for (table, tableRegion) in tableRegions {
            guard let otherTableRegion = otherTableRegions
                .first(where: { (otherTable, _) in otherTable == table })?
                .value else { continue }
            let tableRegionIntersection = tableRegion.intersection(otherTableRegion)
            guard !tableRegionIntersection.isEmpty else { continue }
            tableRegionsIntersection[table] = tableRegionIntersection
        }
        
        return DatabaseRegion(tableRegions: tableRegionsIntersection)
    }
    
    /// Only keeps those rowIds in the given table
    func tableIntersection(_ table: String, rowIds: Set<Int64>) -> DatabaseRegion {
        guard var tableRegions = tableRegions else {
            return DatabaseRegion(table: table, rowIds: rowIds)
        }
        
        guard let tableRegion = tableRegions[table] else {
            return self
        }
        
        let intersection = tableRegion.intersection(TableRegion(columns: nil, rowIds: rowIds))
        if intersection.isEmpty {
            tableRegions.removeValue(forKey: table)
        } else {
            tableRegions[table] = intersection
        }
        return DatabaseRegion(tableRegions: tableRegions)
    }
    
    /// Returns the union of this region and the given one.
    public func union(_ other: DatabaseRegion) -> DatabaseRegion {
        guard let tableRegions = tableRegions else { return .fullDatabase }
        guard let otherTableRegions = other.tableRegions else { return .fullDatabase }
        
        var tableRegionsUnion: [String: TableRegion] = [:]
        let tableNames = Set(tableRegions.keys).union(Set(otherTableRegions.keys))
        for table in tableNames {
            let tableRegion = tableRegions[table]
            let otherTableRegion = otherTableRegions[table]
            let tableRegionUnion: TableRegion
            switch (tableRegion, otherTableRegion) {
            case (nil, nil):
                preconditionFailure()
            case let (nil, tableRegion?), let (tableRegion?, nil):
                tableRegionUnion = tableRegion
            case let (tableRegion?, otherTableRegion?):
                tableRegionUnion = tableRegion.union(otherTableRegion)
            }
            tableRegionsUnion[table] = tableRegionUnion
        }
        
        return DatabaseRegion(tableRegions: tableRegionsUnion)
    }
    
    /// Inserts the given region into this region
    public mutating func formUnion(_ other: DatabaseRegion) {
        self = union(other)
    }
    
    /// Returns a region suitable for database observation by removing views.
    ///
    /// We can do it because modifications only happen in actual tables. And we
    /// want to do it because we have a fast path for regions that span a
    /// single table.
    func ignoringViews(_ db: Database) throws -> DatabaseRegion {
        guard let tableRegions = tableRegions else { return .fullDatabase }
        let viewNames = try db.schema().names(ofType: .view)
        guard viewNames.isEmpty == false else { return self }
        let filteredRegions = tableRegions.filter { viewNames.contains($0.key) == false }
        return DatabaseRegion(tableRegions: filteredRegions)
    }
    
    /// Returns a region which doesn't contain any SQLite internal table.
    func ignoringInternalSQLiteTables() -> DatabaseRegion {
        guard let tableRegions = tableRegions else { return .fullDatabase }
        let filteredRegions = tableRegions.filter { !$0.key.starts(with: "sqlite_") }
        return DatabaseRegion(tableRegions: filteredRegions)
    }
}

extension DatabaseRegion {
    
    // MARK: - Database Events
    
    /// Returns whether the content in the region would be impacted if the
    /// database were modified by an event of this kind.
    public func isModified(byEventsOfKind eventKind: DatabaseEventKind) -> Bool {
        return intersection(eventKind.modifiedRegion).isEmpty == false
    }
    
    /// Returns whether the content in the region is impacted by this event.
    ///
    /// - precondition: event has been filtered by the same region
    ///   in the TransactionObserver.observes(eventsOfKind:) method, by calling
    ///   region.isModified(byEventsOfKind:)
    public func isModified(by event: DatabaseEvent) -> Bool {
        guard let tableRegions = tableRegions else {
            // Full database: all changes are impactful
            return true
        }
        
        guard let tableRegion = tableRegions[event.tableName] else {
            // FTS4 (and maybe other virtual tables) perform unadvertised
            // changes. For example, an "INSERT INTO document ..." statement
            // advertises an insertion in the `document` table, but the
            // actual change events happen in the `document_content` shadow
            // table. When such a non-advertised event happens, assume that
            // the region is modified.
            // See https://github.com/groue/GRDB.swift/issues/620
            return true
        }
        return tableRegion.contains(rowID: event.rowID)
    }
}

// Equatable
extension DatabaseRegion {
    /// :nodoc:
    public static func == (lhs: DatabaseRegion, rhs: DatabaseRegion) -> Bool {
        switch (lhs.tableRegions, rhs.tableRegions) {
        case (nil, nil):
            return true
        case let (ltableRegions?, rtableRegions?):
            let ltableNames = Set(ltableRegions.keys)
            let rtableNames = Set(rtableRegions.keys)
            guard ltableNames == rtableNames else {
                return false
            }
            for tableName in ltableNames where ltableRegions[tableName]! != rtableRegions[tableName]! {
                return false
            }
            return true
        default:
            return false
        }
    }
}

// CustomStringConvertible
extension DatabaseRegion {
    /// :nodoc:
    public var description: String {
        guard let tableRegions = tableRegions else {
            return "full database"
        }
        if tableRegions.isEmpty {
            return "empty"
        }
        return tableRegions
            .sorted(by: { (l, r) in l.key < r.key })
            .map { (table, tableRegion) in
                var desc = table
                if let columns = tableRegion.columns {
                    desc += "(" + columns.sorted().joined(separator: ",") + ")"
                } else {
                    desc += "(*)"
                }
                if let rowIds = tableRegion.rowIds {
                    desc += "[" + rowIds.sorted().map { "\($0)" }.joined(separator: ",") + "]"
                }
                return desc
            }
            .joined(separator: ",")
    }
}

private struct TableRegion: Equatable {
    var columns: Set<String>? // nil means "all columns"
    var rowIds: Set<Int64>? // nil means "all rowids"
    
    var isEmpty: Bool {
        if let columns = columns, columns.isEmpty { return true }
        if let rowIds = rowIds, rowIds.isEmpty { return true }
        return false
    }
    
    func intersection(_ other: TableRegion) -> TableRegion {
        let columnsIntersection: Set<String>?
        switch (self.columns, other.columns) {
        case let (nil, columns), let (columns, nil):
            columnsIntersection = columns
        case let (columns?, other?):
            columnsIntersection = columns.intersection(other)
        }
        
        let rowIdsIntersection: Set<Int64>?
        switch (self.rowIds, other.rowIds) {
        case let (nil, rowIds), let (rowIds, nil):
            rowIdsIntersection = rowIds
        case let (rowIds?, other?):
            rowIdsIntersection = rowIds.intersection(other)
        }
        
        return TableRegion(columns: columnsIntersection, rowIds: rowIdsIntersection)
    }
    
    func union(_ other: TableRegion) -> TableRegion {
        let columnsUnion: Set<String>?
        switch (self.columns, other.columns) {
        case (nil, _), (_, nil):
            columnsUnion = nil
        case let (columns?, other?):
            columnsUnion = columns.union(other)
        }
        
        let rowIdsUnion: Set<Int64>?
        switch (self.rowIds, other.rowIds) {
        case (nil, _), (_, nil):
            rowIdsUnion = nil
        case let (rowIds?, other?):
            rowIdsUnion = rowIds.union(other)
        }
        
        return TableRegion(columns: columnsUnion, rowIds: rowIdsUnion)
    }
    
    func contains(rowID: Int64) -> Bool {
        guard let rowIds = rowIds else {
            return true
        }
        return rowIds.contains(rowID)
    }
}

// MARK: - DatabaseRegionConvertible

public protocol DatabaseRegionConvertible {
    /// Returns a database region.
    ///
    /// - parameter db: A database connection.
    func databaseRegion(_ db: Database) throws -> DatabaseRegion
}

extension DatabaseRegion: DatabaseRegionConvertible {
    /// :nodoc:
    public func databaseRegion(_ db: Database) throws -> DatabaseRegion {
        return self
    }
}

/// A type-erased DatabaseRegionConvertible
public struct AnyDatabaseRegionConvertible: DatabaseRegionConvertible {
    let _region: (Database) throws -> DatabaseRegion
    
    public init(_ region: @escaping (Database) throws -> DatabaseRegion) {
        _region = region
    }
    
    public init(_ region: DatabaseRegionConvertible) {
        _region = { try region.databaseRegion($0) }
    }
    
    /// :nodoc:
    public func databaseRegion(_ db: Database) throws -> DatabaseRegion {
        return try _region(db)
    }
}

// MARK: - Utils

extension DatabaseRegion {
    static func union(_ regions: DatabaseRegion...) -> DatabaseRegion {
        return regions.reduce(into: DatabaseRegion()) { union, region in
            union.formUnion(region)
        }
    }
    
    static func union(_ regions: [DatabaseRegionConvertible]) -> (Database) throws -> DatabaseRegion {
        return { db in
            try regions.reduce(into: DatabaseRegion()) { union, region in
                try union.formUnion(region.databaseRegion(db))
            }
        }
    }
}
