//
//  TitleTextEditor.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/28/23.
//

import SwiftUI

struct TitleTextEditor: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var isEditing: Bool
    let clearButtonMode: UITextField.ViewMode?
    let onCommit: () -> Void
    
    init(text: Binding<String>, isEditing: Binding<Bool>, clearButtonMode: UITextField.ViewMode? = nil, onCommit: @escaping () -> Void) {
        self._text = text
        self._isEditing = isEditing
        self.clearButtonMode = clearButtonMode
        self.onCommit = onCommit
    }
    
    func makeUIView(context: UIViewRepresentableContext<TitleTextEditor>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        if isEditing {
            textField.becomeFirstResponder()
        }
        if !isEditing {
            textField.resignFirstResponder()
        }
        textField.text = self.text
        
        if let clearButtonMode {
            textField.clearButtonMode = clearButtonMode
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TitleTextEditor>) {
        if isEditing {
            uiView.becomeFirstResponder()
        }
        if !isEditing {
            uiView.resignFirstResponder()
        }
        
        if let clearButtonMode {
            uiView.clearButtonMode = clearButtonMode
        }
    }
    
    func makeCoordinator() -> TitleTextEditorCoordinator {
        TitleTextEditorCoordinator(titleTextEditor: self)
    }
    
    class TitleTextEditorCoordinator: NSObject, UITextFieldDelegate {
        
        let titleTextEditor: TitleTextEditor
        
        init(titleTextEditor: TitleTextEditor) {
            self.titleTextEditor = titleTextEditor
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.titleTextEditor.isEditing = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.titleTextEditor.text = textField.text ?? self.titleTextEditor.text
                self.titleTextEditor.isEditing = false
                self.titleTextEditor.onCommit()
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async {
                self.titleTextEditor.text = textField.text ?? self.titleTextEditor.text
                self.titleTextEditor.isEditing = false
                self.titleTextEditor.onCommit()
            }
            textField.resignFirstResponder()
            return true
        }
    }
}
