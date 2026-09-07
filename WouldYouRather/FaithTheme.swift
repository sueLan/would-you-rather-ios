import SwiftUI

struct FaithBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [.faithBackgroundTop, .faithIvory, .faithIvoryDeep],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [.white.opacity(0.92), .clear],
                    center: UnitPoint(x: 0.5, y: 0.05),
                    startRadius: 4,
                    endRadius: proxy.size.width * 0.7
                )

                MountainRangeShape(heights: [0.68, 0.48, 0.60, 0.34, 0.63, 0.43, 0.61, 0.30, 0.59, 0.44, 0.66])
                    .fill(Color.faithBrownSoft.opacity(0.10))
                    .frame(height: proxy.size.height * 0.52)
                    .blur(radius: 3)
                    .offset(y: proxy.size.height * 0.17)

                MountainRangeShape(heights: [0.42, 0.22, 0.52, 0.32, 0.62, 0.34, 0.53, 0.19, 0.48])
                    .fill(Color.faithOlive.opacity(0.11))
                    .frame(height: proxy.size.height * 0.44)
                    .offset(y: proxy.size.height * 0.39)

                LinearGradient(
                    colors: [.clear, .white.opacity(0.26), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 110)
                .blur(radius: 18)
                .offset(y: proxy.size.height * 0.16)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct BrandLockupView: View {
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 11) {
            VStack(spacing: 0) {
                Image(systemName: "cross.fill")
                    .font(.system(size: 20, weight: .regular))
                Image(systemName: "book")
                    .font(.system(size: 23, weight: .light))
                    .offset(y: -2)
            }
            .foregroundStyle(Color.faithGold)
            .frame(width: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(language == .en ? "WOULD YOU RATHER" : "信仰抉择问答卡")
                    .font(.system(.headline, design: .serif, weight: .regular))
                    .tracking(language == .en ? 1.4 : 1.0)
                    .foregroundStyle(Color.faithEspresso)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(language == .en ? "Faith · Reflection · Connection" : "信仰 · 反思 · 连接")
                    .font(.system(.caption2, design: .serif))
                    .tracking(0.7)
                    .foregroundStyle(Color.faithGold)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct OrnamentalCorners: View {
    var inset: CGFloat = 10
    var length: CGFloat = 23

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let left = inset
                let right = proxy.size.width - inset
                let top = inset
                let bottom = proxy.size.height - inset

                path.move(to: CGPoint(x: left, y: top + length))
                path.addLine(to: CGPoint(x: left, y: top))
                path.addLine(to: CGPoint(x: left + length, y: top))

                path.move(to: CGPoint(x: right - length, y: top))
                path.addLine(to: CGPoint(x: right, y: top))
                path.addLine(to: CGPoint(x: right, y: top + length))

                path.move(to: CGPoint(x: left, y: bottom - length))
                path.addLine(to: CGPoint(x: left, y: bottom))
                path.addLine(to: CGPoint(x: left + length, y: bottom))

                path.move(to: CGPoint(x: right - length, y: bottom))
                path.addLine(to: CGPoint(x: right, y: bottom))
                path.addLine(to: CGPoint(x: right, y: bottom - length))
            }
            .stroke(Color.faithGoldLight, lineWidth: 1)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct PillFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > width {
                widestRow = max(widestRow, rowWidth)
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }

        widestRow = max(widestRow, rowWidth)
        totalHeight += rowHeight
        return CGSize(width: proposal.width ?? widestRow, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

private struct MountainRangeShape: Shape {
    let heights: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        for (index, height) in heights.enumerated() {
            let progress = CGFloat(index) / CGFloat(max(heights.count - 1, 1))
            path.addLine(to: CGPoint(x: rect.width * progress, y: rect.height * height))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

extension View {
    func parchmentPanel(cornerRadius: CGFloat = 18) -> some View {
        background(
            LinearGradient(
                colors: [.white.opacity(0.54), Color.faithPaper.opacity(0.97)],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.faithGold.opacity(0.48), lineWidth: 1)
        }
        .shadow(color: Color.faithEspresso.opacity(0.12), radius: 18, y: 10)
    }
}
