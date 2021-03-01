//
//  BatchRequest.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/22/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

class BatchRequest {
    let object: LCObject
    let method: HTTPClient.Method?
    let operationTable: OperationTable?
    let parameters: [String: Any]?

    init(
        object: LCObject,
        method: HTTPClient.Method? = nil,
        operationTable: OperationTable? = nil,
        parameters: [String: Any]? = nil)
    {
        self.object = object
        self.method = method
        self.operationTable = operationTable
        self.parameters = parameters
    }

    var isNewborn: Bool {
        return !object.hasObjectId
    }

    var actualMethod: HTTPClient.Method {
        return method ?? (isNewborn ? .post : .put)
    }

    func getBody(internalId: String) -> [String: Any] {
        var body: [String: Any] = ["__internalId": internalId]
        var children: [(String, LCObject)] = []
        self.operationTable?.forEach { (key, operation) in
            if case .set = operation.name,
                let child = operation.value as? LCObject,
                !child.hasObjectId {
                children.append((key, child))
            } else {
                body[key] = operation.lconValue
            }
        }
        if !children.isEmpty {
            body["__children"] = children.map { (key, child) -> [String: String] in
                ["className": child.actualClassName,
                 "cid": child.internalId,
                 "key": key]
            }
        }
        return body
    }

    func jsonValue() throws -> Any {
        let method = actualMethod
        let path = try object.application.httpClient.getBatchRequestPath(object: object, method: method)
        let internalId = object.objectId?.value ?? object.internalId

        if let request = try object.preferredBatchRequest(method: method, path: path, internalId: internalId) {
            return request
        }

        var request: [String: Any] = [
            "path": path,
            "method": method.rawValue
        ]
        if let params: [String: Any] = self.parameters {
            request["params"] = params
        }

        switch method {
        case .get:
            break
        case .post, .put:
            request["body"] = getBody(internalId: internalId)

            if isNewborn {
                request["new"] = true
            }
        case .delete:
            break
        }

        return request
    }
}

class BatchRequestBuilder {
    /**
     Get a list of requests of an object.

     - parameter object: The object from which you want to get.

     - returns: A list of request.
     */
    static func buildRequests(_ object: LCObject, parameters: [String: Any]?) throws -> [BatchRequest] {
        return try operationTableList(object).map { element in
            BatchRequest(object: object, operationTable: element, parameters: parameters)
        }
    }

    /**
     Get initial operation table list of an object.

     - parameter object: The object from which to get.

     - returns: The operation table list.
     */
    private static func initialOperationTableList(_ object: LCObject) throws -> OperationTableList {
        var operationTable: OperationTable = [:]

        /* Collect all non-null properties. */
        try object.forEach { (key, value) in
            switch value {
            case let relation as LCRelation:
                /* If the property type is relation,
                   We should use "AddRelation" instead of "Set" as operation type.
                   Otherwise, the relations will added as an array. */
                operationTable[key] = try Operation(name: .addRelation, key: key, value: LCArray(relation.value))
            default:
                operationTable[key] = try Operation(name: .set, key: key, value: value)
            }
        }

        return [operationTable]
    }

    /**
     Get operation table list of object.

     - parameter object: The object from which you want to get.

     - returns: A list of operation tables.
     */
    private static func operationTableList(_ object: LCObject) throws -> OperationTableList {
        if object.hasObjectId, let operationHub = object.operationHub {
            return operationHub.operationTableList()
        } else {
            return try initialOperationTableList(object)
        }
    }
}
