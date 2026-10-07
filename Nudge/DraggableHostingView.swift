//
//  DraggableHostingView.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import AppKit
import SwiftUI

final class DraggableHostingView<Content: View>: NSHostingView<Content> {

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
