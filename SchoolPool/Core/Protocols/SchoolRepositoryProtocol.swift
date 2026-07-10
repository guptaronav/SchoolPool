import Foundation

protocol SchoolRepositoryProtocol {
    func search(query: String, limit: Int) async throws -> [School]
    func fetch(id: String) async throws -> School?
}
