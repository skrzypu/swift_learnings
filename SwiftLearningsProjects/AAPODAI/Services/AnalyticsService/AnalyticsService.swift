//
//  AnalyticsService.swift
//  AAPODAI
//

import Foundation
import ComposableArchitecture

final class AnalyticsService {
    private let googleAppsScriptURL: URL
    private let secretToken: String

    // Initialize with the Google Apps Script URL
    init(googleAppsScriptURL: URL, secretToken: String) {
        self.googleAppsScriptURL = googleAppsScriptURL
        self.secretToken = secretToken
    }
    
    private func logAPOD(item: APODItem, opened: Bool) async {
        // Ensure tags are available
        guard let tags = item.tags else {
            print("No tags available for the item.")
            return
        }

        // Prepare the data to send
        let data: [String: Any] = [
            "token": secretToken, // Include the token for authentication
            "copyright": item.copyright ?? "Unknown",
            "tags": tags.joined(separator: ","),
            "mediaType": item.media_type.rawValue,
            "opened": opened ? 1 : 0
        ]

        // Convert the data to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("Failed to serialize JSON.")
            return
        }

        var request = URLRequest(url: googleAppsScriptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)

            // Check the response status code
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("Data logged successfully!")
                } else {
                    // Attempt to parse error message
                    if let errorResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                       let errorMessage = errorResponse["error"] as? String {
                        print("Failed to log data: \(errorMessage)")
                    } else {
                        print("Failed to log data, status code: \(httpResponse.statusCode)")
                    }
                }
            }
        } catch {
            print("Error logging APOD item: \(error)")
        }
    }

    // Method to log APOD item analytics
    func logAPODItemOpened(item: APODItem) async {
        await logAPOD(item: item, opened: true)
    }

    func logAPODItemShowed(item: APODItem) async {
        await logAPOD(item: item, opened: false)
    }
}

private enum AnalyticsServiceDependency: DependencyKey {
    static let liveValue: AnalyticsService = {
        let url = Configuration.configurationImplementation.configurationAnalytics.googleAppsScriptURL
        return AnalyticsService(googleAppsScriptURL: URL(string: url)!,
                                secretToken: Configuration.configurationImplementation.configurationAnalytics.secretToken) //DO NOT PUT IN GIT, MOVE FIRST TO SEPARATE FILE
    }()
}

extension DependencyValues {
  var analyticsService: AnalyticsService {
    get { self[AnalyticsServiceDependency.self] }
    set { self[AnalyticsServiceDependency.self] = newValue }
  }
}
