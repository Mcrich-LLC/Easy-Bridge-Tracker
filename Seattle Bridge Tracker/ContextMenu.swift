//
//  ContextMenu.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 9/7/22.
//

import Foundation
import SwiftUI

struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var navigate: () -> Void
    init(content: Content, preview: Preview, menu: UIMenu, navigate: @escaping () -> Void) {
        self.content = content
        self.preview = preview
        self.menu = menu
        self.navigate = navigate
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(_ parent: ContextMenuHelper) {
            self.parent = parent
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil) {
                let previewController = UIHostingController(rootView: self.parent.preview)
                return previewController
            } actionProvider: { _ in
                return self.parent.menu
            }
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            parent.navigate()
        }
    }
}

extension View {
    func contextMenu<Preview: View>(navigate: @escaping () -> Void = {}, @ViewBuilder preview: @escaping () -> Preview, menu: @escaping () -> UIMenu) -> some View {
        return CustomContextMenu(navigate: navigate, content: {self}, preview: preview, menu: menu)
    }
}

struct CustomContextMenu<Content: View, Preview: View>: View {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var navigate: () -> Void
    init(navigate: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content, @ViewBuilder preview: @escaping () -> Preview, menu: @escaping () -> UIMenu) {
        self.content = content()
        self.preview = preview()
        self.menu = menu()
        self.navigate = navigate
    }
    var body: some View {
        ZStack {
            content
                .overlay(ContextMenuHelper(content: content, preview: preview, menu: menu, navigate: navigate))
        }
    }
}
