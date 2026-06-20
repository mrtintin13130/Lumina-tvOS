//
//  LuminaButtons.swift
//  lumina
//
//  Created by Martin Thomas on 20/06/2026.
//

import SwiftUI

enum LuminaActionButtonRole {
    case primary
    case secondary
    case destructive
}

enum LuminaActionButtonSize {
    case compact
    case regular
    case wide

    var minWidth: CGFloat {
        switch self {
        case .compact:
            return 180
        case .regular:
            return 230
        case .wide:
            return 300
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .compact:
            return 58
        case .regular, .wide:
            return 68
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .compact:
            return 22
        case .regular, .wide:
            return 28
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .compact:
            return 27
        case .regular, .wide:
            return 29
        }
    }
}

enum LuminaActionButtonPresentation {
    case full
    case expandable(isExpanded: Bool)

    var showsTitle: Bool {
        switch self {
        case .full:
            return true
        case .expandable(let isExpanded):
            return isExpanded
        }
    }

    var usesMinimumWidth: Bool {
        if case .full = self {
            return true
        }
        return false
    }
}

struct LuminaActionButtonStyle: ButtonStyle {
    let role: LuminaActionButtonRole
    let size: LuminaActionButtonSize
    let isFocused: Bool
    let presentation: LuminaActionButtonPresentation

    @Environment(\.isEnabled) private var isEnabled

    init(
        role: LuminaActionButtonRole = .secondary,
        size: LuminaActionButtonSize = .regular,
        isFocused: Bool = false,
        presentation: LuminaActionButtonPresentation = .full
    ) {
        self.role = role
        self.size = size
        self.isFocused = isFocused
        self.presentation = presentation
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.84)
            .labelStyle(LuminaActionLabelStyle(showsTitle: presentation.showsTitle))
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, presentation.showsTitle ? size.horizontalPadding : 0)
            .frame(width: buttonWidth, height: size.minHeight)
            .frame(minWidth: presentation.usesMinimumWidth ? size.minWidth : nil)
            .clipped()
            .background(backgroundStyle(isPressed: configuration.isPressed), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(borderStyle, lineWidth: isFocused ? 2 : 1)
            }
            .scaleEffect(scale(isPressed: configuration.isPressed))
            .shadow(color: focusShadow, radius: isFocused ? 20 : 0, x: 0, y: 0)
            .opacity(isEnabled ? 1 : 0.46)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.16), value: isFocused)
            .animation(.easeInOut(duration: 0.18), value: presentation.showsTitle)
    }

    private var buttonWidth: CGFloat? {
        presentation.showsTitle ? nil : size.minHeight
    }

    private var foregroundStyle: Color {
        guard isEnabled else { return .white.opacity(0.68) }

        switch role {
        case .primary:
            return .black
        case .secondary, .destructive:
            return .white
        }
    }

    private func backgroundStyle(isPressed: Bool) -> Color {
        guard isEnabled else { return .white.opacity(0.09) }

        switch role {
        case .primary:
            return .white.opacity(isPressed ? 0.78 : 0.94)
        case .secondary:
            return .white.opacity(isFocused ? 0.18 : 0.10)
        case .destructive:
            return Color(red: 0.88, green: 0.22, blue: 0.24)
                .opacity(isPressed ? 0.72 : isFocused ? 0.9 : 0.76)
        }
    }

    private var borderStyle: Color {
        guard isEnabled else { return .white.opacity(0.10) }

        switch role {
        case .primary:
            return isFocused ? .white.opacity(0.55) : .clear
        case .secondary:
            return .white.opacity(isFocused ? 0.42 : 0.16)
        case .destructive:
            return .white.opacity(isFocused ? 0.46 : 0.18)
        }
    }

    private var focusShadow: Color {
        switch role {
        case .primary:
            return .white.opacity(0.34)
        case .secondary:
            return .white.opacity(0.24)
        case .destructive:
            return Color(red: 1, green: 0.24, blue: 0.26).opacity(0.3)
        }
    }

    private func scale(isPressed: Bool) -> CGFloat {
        if isPressed {
            return 0.97
        }
        return isFocused ? 1.06 : 1
    }
}

struct LuminaActionRow<Content: View>: View {
    private let alignment: VerticalAlignment
    private let spacing: CGFloat
    private let content: Content

    init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct LuminaActionLabelStyle: LabelStyle {
    let showsTitle: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: showsTitle ? 10 : 0) {
            configuration.icon
                .imageScale(.medium)

            if showsTitle {
                configuration.title
                    .transition(.opacity)
            }
        }
    }
}
