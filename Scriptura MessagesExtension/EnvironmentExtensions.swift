//
//  EnvironmentExtensions.swift
//  Scriptura MessagesExtension
//
//  Created by Xcode Developer on 2/13/24.
//

import Foundation
import SwiftUI
import Messages

struct MSConversationKey: EnvironmentKey {
    static let defaultValue: MSConversation? = nil
}

extension EnvironmentValues {
    var msConversation: MSConversation? {
        get { self[MSConversationKey.self] }
        set { self[MSConversationKey.self] = newValue }
    }
}
