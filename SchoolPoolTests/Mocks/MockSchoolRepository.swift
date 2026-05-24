import Foundation
@testable import SchoolPool

final class MockSchoolRepository: SchoolRepositoryProtocol {
    var schools: [School] = []
    var searchError: Error?
    var fetchError: Error?

    private(set) var searchCallCount = 0

    func search(query: String, limit: Int) async throws -> [School] {
        searchCallCount += 1
        if let searchError { throw searchError }
        let q = query.lowercased()
        return Array(schools.filter { $0.name.lowercased().contains(q) }.prefix(limit))
    }

    func fetch(id: String) async throws -> School? {
        if let fetchError { throw fetchError }
        return schools.first { $0.id == id }
    }

    func findByEmailDomain(_ domain: String) async throws -> School? {
        schools.first { $0.matches(emailDomain: domain) }
    }
}
