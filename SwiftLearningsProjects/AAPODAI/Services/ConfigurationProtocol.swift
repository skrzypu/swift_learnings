//
//  ConfigurationProtocol.swift
//  AAPODAI
//

import Foundation

//
// ConfigurationImplementation should be implemented in separate file which won't be pushed to git.
// struct ConfigurationImplementation: ConfigurationProtocol { ... }
//
enum Configuration {
    static var configurationImplementation: ConfigurationProtocol = {
       ConfigurationImplementation()
    }()
}

protocol ConfigurationAnalyticsProtocol {
    var googleAppsScriptURL: String { get }
    var secretToken: String { get }
}

protocol ConfigurationProtocol {
    var configurationAnalytics: ConfigurationAnalyticsProtocol { get }
}
