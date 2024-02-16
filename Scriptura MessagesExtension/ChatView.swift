//
//  ChatView.swift
//  Scriptura MessagesExtension
//
//  Created by Xcode Developer on 2/8/24.
//



import SwiftUI
import UIKit
import Messages

struct ChatView: View {
    @Environment(\.msConversation) var conversation: MSConversation?
    
    @ObservedObject var chatData: ChatData
    @State private var lastMessageId: String?
    
    var body: some View {
        ScrollViewReader { scrollView in
            List(chatData.messages) { message in
                let message_id = message.id
                
                Section {
                    HStack(alignment: .bottom, spacing: 0.0, content: {
                        Text(message.prompt)
                            .font(.body).fontWeight(.ultraLight)
                        
                    })
                    .listRowBackground(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 25.0, bottomLeading: 0.0, bottomTrailing: 0.0, topTrailing: 25.0))
                            .strokeBorder(Color.init(uiColor: .gray).opacity(0.25), lineWidth: 1.0)
                        //                            .shadow(color: Color.gray, radius: 3.0)
                    )
                    
                    HStack(alignment: .top, spacing: 0.0, content: {
                        Text(message.response)
                            .font(.body).fontWeight(.light)
                    })
                    .listRowBackground(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 0.0, bottomLeading: 25.0, bottomTrailing: 25.0, topTrailing: 0.0))
                            .fill(Color.init(uiColor: .gray).opacity(0.25))
                        //                            .shadow(color: Color.gray, radius: 3.0)
                    )
                    .onTapGesture {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = message.response
                        
                        
                        let message_ios = MSMessage()
                        
                        message_ios.summaryText = message.response
                        
                        let conversation = self.conversation!
                        
                        let layout = MSMessageTemplateLayout()
                        layout.caption = message.response
                        message_ios.layout = layout
                        
                        conversation.insert(message_ios) { error in
                            if let error = error {
                                print("Error occurred: \(error)")
                            }
                        }
                    }
                }
                .listSectionSpacing(25.0)
                .id(message_id)
                //                .task {
                //                    if message_id == chatData.messages.last?.id {
                //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //                            scrollView.scrollTo(message_id, anchor: .bottom)
                //                        }
                //                    }
                //                }
                //                .task {
                //                    if message_id == chatData.messages.last?.id {
                //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //                            scrollView.scrollTo(message_id, anchor: .bottom)
                //                        }
                //                    }
                //                }
            }
            .listStyle(.plain)
            .listRowSpacing(0)
            .scrollContentBackground(.hidden)
            .onAppear {
                lastMessageId = chatData.messages.last?.id
            }
            .onChange(of: chatData.messages, {
                lastMessageId = chatData.messages.last?.id
            })
//            .onChange(of: chatData.messages) { _ in
//                lastMessageId = chatData.messages.last?.id
//                
//                
//            }
            .onOrientationChange {
                if let lastMessageId = lastMessageId {
                    scrollView.scrollTo(lastMessageId, anchor: .bottom)
                }
            }
            
        }
    }
}

private func sendAsMSMessage(conversation: MSConversation, text: String) {
    let message = MSMessage()
    message.summaryText = text
    
    conversation.insert(message) { error in
        if let error = error {
            print(error.localizedDescription)
        }
    }
}

struct OrientationChangeDetector: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action()
            }
    }
}

extension View {
    func onOrientationChange(perform action: @escaping () -> Void) -> some View {
        self.modifier(OrientationChangeDetector(action: action))
    }
}


/*
 .padding()
 .background(Color.init(uiColor: UIColor(white: 1.0, alpha: 0.3)))
 .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous))
 */
