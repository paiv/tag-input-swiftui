import SwiftUI


public struct HFlow<Content>: View where Content:View {
    
    private let alignment: VerticalAlignment
    private let itemSpacing: CGFloat?
    private let rowSpacing: CGFloat?
    private let contentBuilder: () -> Content

    public init(
        alignment: VerticalAlignment = .center,
        itemSpacing: CGFloat? = nil,
        rowSpacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.itemSpacing = itemSpacing
        self.rowSpacing = rowSpacing
        self.contentBuilder = content
    }
    
    public var body: some View {
        FlowLayout(
            alignment: alignment,
            itemSpacing: itemSpacing,
            rowSpacing: rowSpacing
        ) {
            contentBuilder()
        }
    }
}


#Preview {
    let tokens = (0..<37).map { _ in String.randomWord(count: Int.random(in: 2...11)) }

    HFlow(alignment: .firstTextBaseline) {
        ForEach(tokens, id: \.self) { token in
            let f = CGFloat.random(in: 12..<32)
            Text(token)
                .font(.system(size: f))
        }
    }
    .background(.thickMaterial)
}


#Preview("Priority") {
    let tokens = ["Aaaaaa", "Bbbbbb", "Cccccc", "Dddddd", "Eeeeee", "Ffffff", "Jjjjjj", "Hhhhhh", "Kkkkkk", "Llllll", "Mmmmmm", "Nnnnnn", "Oooooo"]

    HFlow(alignment: .firstTextBaseline) {
        ForEach(tokens, id: \.self) { token in
            let f = CGFloat.random(in: 12..<32)
            Text(token)
                .font(.system(size: f))
        }
    }
    .background(.thickMaterial)
    .overlay(alignment: .topLeading) {
        Text("Left")
            .font(.title2)
            .padding(4)
            .background(.tertiary)
    }
    .overlay(alignment: .topTrailing) {
        Text("Right")
            .font(.title2)
            .padding(4)
            .background(.tertiary)
    }
}
