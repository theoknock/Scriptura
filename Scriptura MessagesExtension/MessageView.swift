//
//  MessageView.swift
//  Scriptura MessagesExtension
//
//  Created by Xcode Developer on 2/8/24.
//


import SwiftUI

struct MessageView: View {
    @ObservedObject var chatData: ChatData
    @State private var prompt: String = String()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0.0) {
            TextField(("Message ChatGTP..."), text: $prompt, axis: .vertical)
                .focused($isTextFieldFocused)
                .font(.body).dynamicTypeSize(.xLarge)
                .fontWeight(isTextFieldFocused ? .light : .ultraLight)
                .lineLimit(1, reservesSpace: false)
                .lineSpacing(1.0)
                .safeAreaPadding(.leading)
                .frame(idealWidth: UIScreen.main.bounds.width * 0.875, idealHeight: UIScreen.main.bounds.height * 0.125)
                .padding(.leading)
//                .onf
//                .background {
////                    UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 25.0, bottomLeading: 0.0, bottomTrailing: 0.0, topTrailing: 25.0))
////                        .strokeBorder(Color.init(uiColor: .gray).opacity(0.25), lineWidth: 1.0) :
//                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
//                        .fill(Color.init(uiColor: .gray).opacity(0.25))
//                }
            Spacer()
            Button(action: {
                Task {
                    let prompt_tidy = prompt.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                    prompt = prompt_tidy
                    chatData.addMessage(message: prompt_tidy)
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    prompt = String()
                }
            }, label: {
                Label("", systemImage: "arrow.up.circle")
                    .symbolRenderingMode(.hierarchical)
                    .font(.largeTitle)
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
            })
//            .safeAreaPadding(.trailing)
        }
        .foregroundColor(.white)
        
        //            ZStack(alignment: .trailing) {
        //                TextField(("Message ChatGTP..."), text: $prompt, axis: .vertical)
        //
        //
        //    //            // yep, this just works out of the box
        //    //            Text("```code```\nTo **learn more**, *please* feel free to visit [SwiftUIRecipes](https://swiftuirecipes.com) for details, or check the `source code` at [Github page](https://github.com/globulus).")
        //            }
        
        
        //        ZStack(alignment: (.trailing), content: {
        //            HStack {
        //                TextField(("Message ChatGTP..."), text: $prompt, axis: .vertical)
        //            }
        //            .padding(.trailing)
        //            Spacer()
        //            HStack {
        //                Button(action: {
        //                    Task {
        //                        let prompt_tidy = prompt.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //                        prompt = prompt_tidy
        //                        chatData.addMessage(message: prompt_tidy)
        //                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //                        prompt = String()
        //                    }
        //                }, label: {
        //                    Label("", systemImage: "arrow.up.circle")
        //                        .symbolRenderingMode(.hierarchical)
        //                        .font(.largeTitle)
        //                        .imageScale(.large)
        //                        .labelStyle(.iconOnly)
        //                        .clipShape(Circle())
        //                })
        //                .padding(.leading)
        //            }
        ////            .ignoresSafeArea()
        ////            .background(Color.init(uiColor: UIColor(white: 1.0, alpha: 0.2)))
        ////            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25), style: .continuous))
        //        })
        ////        .ignoresSafeArea()
        //        .background(Color.init(uiColor: UIColor(white: 1.0, alpha: 0.2)))
        //        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25), style: .continuous))
        //
        //        // -------
        //
        ////        HStack {
        ////            Spacer()
        ////            RoundedRectangle(cornerRadius: 4.0, style: .continuous)
        ////                .stroke(Color.accentColor, lineWidth: 4.0)
        ////                .frame(idealWidth: UIScreen.main.bounds.width * 0.875, idealHeight: 40)
        ////                .fixedSize(horizontal: false, vertical: true)
        ////            Spacer()
        ////            RoundedRectangle(cornerRadius: 4.0, style: .continuous)
        ////                .stroke(Color.accentColor, lineWidth: 4.0)
        ////                .frame(idealWidth: UIScreen.main.bounds.width * 0.125, idealHeight: 40)
        ////                .fixedSize(horizontal: true, vertical: true)
        ////            Spacer ()
        ////        }
        ////        .frame(idealWidth: UIScreen.main.bounds.width, idealHeight: 40)
        ////        .fixedSize(horizontal: true, vertical: false)
        //
        //    }
        
        //    var body: some View {
        //        ZStack {
        //            color.BaseColor
        //                .edgesIgnoringSafeArea(.all)
        //
        //                    TextField(("Message ChatGTP..."), text: $prompt, axis: .vertical)
        //                        .padding()
        //                        .focused($isTextFieldFocused)
        //                        .textInputAutocapitalization(.never)
        //                        .disableAutocorrection(true)
        //
        //
        //                    Button(action: {
        //                        Task {
        //                            let prompt_tidy = prompt.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //                            prompt = prompt_tidy
        //                            chatData.addMessage(message: prompt_tidy)
        //                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //                            prompt = String()
        //                        }
        //                    }, label: {
        //                        Label("", systemImage: "arrow.up.circle")
        //                            .foregroundColor(Color.init(uiColor: UIColor(white: 1.0, alpha: 0.3125))) // isTextFieldFocused ? Color.white : Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)))
        //                            .symbolRenderingMode(.hierarchical)
        //                            .font(.largeTitle)
        //                            .imageScale(.large)
        //                            .labelStyle(.iconOnly)
        ////                            .clipShape(Circle())
        //                    })
        //                    .background(
        //                        Circle()
        //                            .fill(Color(#colorLiteral(red: 0.2714048326, green: 0.3794743717, blue: 0.5048485994, alpha: 1)))
        //                            .modifier(NeumorphismModifier())
        //                    )
        //                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        //
        //                }
        //                .ignoresSafeArea()
        //
        ////                .background(
        ////                    RoundedRectangle(cornerSize: CGSize(width: 25, height: 25), style: .continuous)
        ////                        .fill(Color(#colorLiteral(red: 0.2714048326, green: 0.3794743717, blue: 0.5048485994, alpha: 1)))
        ////                        .modifier(NeumorphismModifier())
        ////                )
        //                //                .background(
        //                //                    RoundedRectangle(cornerSize: CGSize(width: 25, height: 25), style: .continuous)
        //                //                        .fill(Color(#colorLiteral(red: 0.2714048326, green: 0.3794743717, blue: 0.5048485994, alpha: 1)))
        //                //                        .modifier(NeumorphismModifier())
        //                //                )
        //                //                .clipShape(/*RoundedRectangle(cornerSize: CGSize(width: 25, height: 25), style: .continuous)*/)
        //            }
        //
        ////            .background(
        //                //                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25), style: .continuous)
        //                //                    .fill(Color(#colorLiteral(red: 0.2714048326, green: 0.3794743717, blue: 0.5048485994, alpha: 1)))
        //                //                    .modifier(NeumorphismModifier())
        ////            )
        //        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
            .preferredColorScheme(.dark)
    }
}
