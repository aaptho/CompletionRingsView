//  ForEachWithIndex.swift
//
//  Copied from https://stackoverflow.com/a/61149111/10601393
//

import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public struct ForEachWithIndex<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    public var data: Data
    public var content: (_ element: Data.Element, _ index: Int) -> Content
    var id: KeyPath<Data.Element, ID>

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        content: @escaping (_ element: Data.Element, _ index: Int) -> Content
    ) {
        self.data = data
        self.id = id
        self.content = content
    }

    public var body: some View {
        ForEach(
            zip(self.data.indices, self.data).map { index, element in
                IndexInfo(
                    index: index,
                    id: self.id,
                    element: element
                )
            },
            id: \.elementID
        ) { indexInfo in
            self.content(indexInfo.element, indexInfo.index as! Int)
        }
    }
}

@available(macOS 10.15, iOS 13.0, *)
extension ForEachWithIndex where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {
    public init(_ data: Data, @ViewBuilder content: @escaping (_ element: Data.Element, _ index: Int) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}

@available(macOS 10.15, iOS 13.0, *)
extension ForEachWithIndex: DynamicViewContent where Content: View {
}

private struct IndexInfo<Index, Element, ID: Hashable>: Hashable {
    let index: Index
    let id: KeyPath<Element, ID>
    let element: Element

    var elementID: ID {
        self.element[keyPath: self.id]
    }

    static func == (_ lhs: IndexInfo, _ rhs: IndexInfo) -> Bool {
        lhs.elementID == rhs.elementID
    }

    func hash(into hasher: inout Hasher) {
        self.elementID.hash(into: &hasher)
    }
}
