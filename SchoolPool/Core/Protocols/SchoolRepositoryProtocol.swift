import Foundation

protocol SchoolRepositoryProtocol {
    func search(query: String, limit: Int) async throws -> [School]
    func fetch(id: String) async throws -> School?
    func findByEmailDomain(_ domain: String) async throws -> School?
}
