import SwiftUI


public struct FlowLayout: Layout {
    
    private let alignment: VerticalAlignment
    private let itemSpacing: CGFloat?
    private let rowSpacing: CGFloat?
    
    public init(alignment: VerticalAlignment = .center, itemSpacing: CGFloat? = nil, rowSpacing: CGFloat? = nil) {
        self.alignment = alignment
        self.itemSpacing = itemSpacing
        self.rowSpacing = rowSpacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let layout = renderLayout(proposal: proposal, subviews: subviews)
        var content = CGSize.zero
        for row in layout {
            content.width = max(content.width, row.size.width)
            content.height += row.size.height + row.spacing
        }
        return content
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = renderLayout(proposal: proposal, subviews: subviews)
        var offset = bounds.origin
        for row in layout {
            offset.y += row.spacing
            for child in row.content {
                offset.x += child.spacing
                place(child, at: offset, in: row.size)
                offset.x += child.size.width
            }
            offset.x = bounds.origin.x
            offset.y += row.size.height
        }
    }
}


private extension FlowLayout {
    
    func place(_ child: RowRendering.Element, at offset: CGPoint, in row: CGSize) {
        let proposal = ProposedViewSize(child.size)
        let offset = align(child, in: row, at: offset, alignment: alignment, proposal: proposal)
        child.content.place(at: offset, anchor: .topLeading, proposal: proposal)
    }
    
    func align(_ child: RowRendering.Element, in row: CGSize, at offset: CGPoint, alignment: VerticalAlignment, proposal: ProposedViewSize) -> CGPoint {
        if child.size.height > 0 {
            var offset = offset
            let dims = child.content.dimensions(in: proposal)
            offset.y += dims[alignment] * (row.height / child.size.height - 1)
            return offset
        }
        return offset
    }
    
    struct LayoutFrame<Content> {
        var content: Content
        var size: CGSize
        var spacing: CGFloat = 0
    }
    
    typealias RowRendering = [LayoutFrame<LayoutSubview>]
    typealias Rendering = [LayoutFrame<RowRendering>]
    
    func renderLayout(proposal: ProposedViewSize, subviews: Subviews) -> Rendering {
        let contentWidth = proposal.replacingUnspecifiedDimensions().width
        var layout: Rendering = []
        var spacings: [ViewSpacing] = []
        for (index, child) in subviews.enumerated() {
            if let lastRow = layout.indices.last {
                let spacing = itemSpacing ?? subviews[index.advanced(by: -1)].spacing.distance(to: child.spacing, along: .horizontal)
                let itemSize = child.sizeThatFits(
                    child.priority < 0 ?
                    proposal
                        .excluding(width: layout[lastRow].size.width)
                        .excluding(width: spacing)
                    : proposal
                )
                if layout[lastRow].size.width + spacing + itemSize.width <= contentWidth {
                    layout[lastRow].append(child, size: itemSize, spacing: spacing)
                    spacings[lastRow].formUnion(child.spacing)
                    continue
                }
            }
            let itemSize = child.sizeThatFits(proposal)
            layout.append(.init(child, size: itemSize))
            spacings.append(child.spacing)
        }
        for index in spacings.indices.dropFirst() {
            layout[index].spacing = rowSpacing ?? spacings[index.advanced(by: -1)].distance(to: spacings[index], along: .vertical)
        }
        return layout
    }
}


private extension ProposedViewSize {
    
    func excluding(width: CGFloat) -> ProposedViewSize {
        ProposedViewSize(
            width: self.width.map { max(0, $0 - width) },
            height: self.height
        )
    }
}


private extension FlowLayout.LayoutFrame where Content == [FlowLayout.LayoutFrame<LayoutSubview>] {

    init(_ newElement: LayoutSubview, size: CGSize) {
        self.init(content: [.init(content: newElement, size: size)], size: size)
    }
    
    mutating func append(_ newElement: LayoutSubview, size: CGSize, spacing: CGFloat) {
        content.append(.init(content: newElement, size: size, spacing: spacing))
        self.size.width += spacing + size.width
        self.size.height = max(self.size.height, size.height)
    }
}


#Preview("Para") {
    let tokens: [String] = (0..<16).map { _ in String.randomWord(count: Int.random(in: 2...12)) }
    
    return VStack(spacing: 20) {
        Text(tokens.joined(separator: " "))
            .background(.blue.opacity(0.5))
        FlowLayout(alignment: .firstTextBaseline) {
            ForEach(tokens, id: \.self) { token in
                Text(token)
                    .lineLimit(1)
                    .background(.pink.opacity(0.5))
            }
        }
        .background(.red.opacity(0.25))
    }
    .font(.title2)
}


#Preview("Tags") {
    struct Token: Identifiable {
        let id: String
        let scale: CGFloat
    }
    let tokens: [Token] = (0..<17).map { _ in
        Token(
            id: "#" + String.randomWord(count: Int.random(in: 2...11)),
            scale: CGFloat.random(in: 8..<40)
        )
    }
    
    struct TokenView: View {
        let token: Token
        
        var body: some View {
            Text(token.id)
                .lineLimit(1)
                .font(.system(size: token.scale))
                .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                .background(
                    RoundedRectangle(cornerSize: CGSize(width: token.scale/4, height: token.scale/4))
                        .fill(.tint.opacity(0.5))
                )
        }
    }
    
    struct Panel: View {
        let tokens: [Token]
        var alignment: VerticalAlignment? = nil
        
        var body: some View {
            FlowLayout(alignment: alignment ?? .center) {
                ForEach(tokens) { token in
                    TokenView(token: token)
                }
            }
            .background(.tint.opacity(0.25))
        }
    }
    
    return ScrollView(.vertical) {
        VStack(spacing: 20) {
            Panel(tokens: tokens)
                .tint(.blue)
            Panel(tokens: tokens, alignment: .firstTextBaseline)
                .tint(.red)
            Panel(tokens: tokens, alignment: .bottom)
                .tint(.green)
        }
    }
}


#Preview("Edit") {
    struct PreviewView: View {
        @State var text = ""
        
        var body: some View {
            VStack(spacing: 20) {
                FlowLayout {
                    Text("Token1")
                    TextField("Text", text: $text)
                        .frame(minWidth: 100)
                        .layoutPriority(-1)
                        .background(.tint.opacity(0.25))
                }
                .background(.tint.opacity(0.25))
                .tint(.blue)
                
                HStack {
                    Text("Token1")
                    TextField("Text", text: $text)
                        .background(.tint.opacity(0.25))
                }
                .background(.tint.opacity(0.25))
                .tint(.red)
            }
        }
    }
    return PreviewView()
}
