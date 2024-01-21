//
//  KeyOperationLog.swift
//
//
//  Created by Vamsi Madduluri on 20/01/24.
//
import Vapor
import Fluent

final class KeyOperationLog: Model {
    
    static let schema = "key_operation_logs"
    static let database: DatabaseID = .main
    @ID(key: .id) var id: UUID?
    @Parent(key: "key_id") var key: CryptoKey
    @Field(key: "operation") var operation: KeyOperation
    @Field(key: "timestamp") var timestamp: Date
    
    init() {}
    
    init(keyID: UUID, operation: KeyOperation, timestamp: Date) {
        self.$key.id = keyID
        self.operation = operation
        self.timestamp = timestamp
    }
}

public enum KeyOperation: String, Codable {
    case create
    case rotate
    case deprecate
}
