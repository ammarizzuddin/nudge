//
//  CompanionView.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import EventKit
import SwiftUI

struct CompanionView: View {

    let event: EKEvent?

    @State private var isFloating = false

    var body: some View {
        VStack(spacing: 8) {
            Text("✈️")
                .font(.system(size: 72))
                .offset(y: isFloating ? -6 : 6)

            if let event {
                VStack(spacing: 3) {
                    Text(event.title ?? "Upcoming Event")
                        .font(.headline)
                        .lineLimit(1)

                    Text(event.startDate, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(radius: 8)
            }
        }
        .padding(20)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isFloating = true
            }
        }
    }
}
