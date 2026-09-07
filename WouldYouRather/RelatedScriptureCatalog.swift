import Foundation

enum RelatedScriptureCatalog {
    static func references(for deck: DeckID) -> [BibleReference] {
        switch deck {
        case .love:
            return [
                reference("1 Corinthians 13:4–7", "哥林多前书 13:4–7", "1CO.13.4-7"),
                reference("John 15:9–13", "约翰福音 15:9–13", "JHN.15.9-13"),
                reference("1 John 4:7–12", "约翰一书 4:7–12", "1JN.4.7-12")
            ]
        case .faith:
            return [
                reference("Hebrews 11:1–6", "希伯来书 11:1–6", "HEB.11.1-6"),
                reference("Proverbs 3:5–6", "箴言 3:5–6", "PRO.3.5-6"),
                reference("Mark 9:23–24", "马可福音 9:23–24", "MRK.9.23-24")
            ]
        case .connection:
            return [
                reference("Acts 2:42–47", "使徒行传 2:42–47", "ACT.2.42-47"),
                reference("Ecclesiastes 4:9–12", "传道书 4:9–12", "ECC.4.9-12"),
                reference("Hebrews 10:24–25", "希伯来书 10:24–25", "HEB.10.24-25")
            ]
        case .reflection:
            return [
                reference("Psalm 139:23–24", "诗篇 139:23–24", "PSA.139.23-24"),
                reference("Romans 12:1–2", "罗马书 12:1–2", "ROM.12.1-2"),
                reference("Philippians 4:8–9", "腓立比书 4:8–9", "PHP.4.8-9")
            ]
        case .wisdom:
            return [
                reference("Proverbs 2:1–6", "箴言 2:1–6", "PRO.2.1-6"),
                reference("James 1:5", "雅各书 1:5", "JAS.1.5"),
                reference("Colossians 4:5–6", "歌罗西书 4:5–6", "COL.4.5-6")
            ]
        case .prayer:
            return [
                reference("Matthew 6:6–13", "马太福音 6:6–13", "MAT.6.6-13"),
                reference("Philippians 4:6–7", "腓立比书 4:6–7", "PHP.4.6-7"),
                reference("1 Thessalonians 5:16–18", "帖撒罗尼迦前书 5:16–18", "1TH.5.16-18")
            ]
        case .purpose:
            return [
                reference("Ephesians 2:10", "以弗所书 2:10", "EPH.2.10"),
                reference("Colossians 3:23–24", "歌罗西书 3:23–24", "COL.3.23-24"),
                reference("Romans 12:4–8", "罗马书 12:4–8", "ROM.12.4-8")
            ]
        case .courage:
            return [
                reference("Joshua 1:9", "约书亚记 1:9", "JOS.1.9"),
                reference("2 Timothy 1:7", "提摩太后书 1:7", "2TI.1.7"),
                reference("Psalm 27:1", "诗篇 27:1", "PSA.27.1")
            ]
        case .gratitude:
            return [
                reference("Psalm 100", "诗篇 100", "PSA.100.1-5"),
                reference("1 Thessalonians 5:16–18", "帖撒罗尼迦前书 5:16–18", "1TH.5.16-18"),
                reference("Colossians 3:15–17", "歌罗西书 3:15–17", "COL.3.15-17")
            ]
        case .forgiveness:
            return [
                reference("Ephesians 4:31–32", "以弗所书 4:31–32", "EPH.4.31-32"),
                reference("Colossians 3:12–13", "歌罗西书 3:12–13", "COL.3.12-13"),
                reference("Matthew 18:21–35", "马太福音 18:21–35", "MAT.18.21-35")
            ]
        case .service:
            return [
                reference("Mark 10:42–45", "马可福音 10:42–45", "MRK.10.42-45"),
                reference("1 Peter 4:10–11", "彼得前书 4:10–11", "1PE.4.10-11"),
                reference("Galatians 5:13", "加拉太书 5:13", "GAL.5.13")
            ]
        case .hope:
            return [
                reference("Romans 5:1–5", "罗马书 5:1–5", "ROM.5.1-5"),
                reference("Romans 15:13", "罗马书 15:13", "ROM.15.13"),
                reference("Revelation 21:1–5", "启示录 21:1–5", "REV.21.1-5")
            ]
        }
    }

    private static func reference(_ en: String, _ zhHans: String, _ path: String) -> BibleReference {
        BibleReference(
            display: .init(en: en, zhHans: zhHans),
            englishURL: URL(string: "https://www.bible.com/bible/111/\(path).NIV")!,
            chineseURL: URL(string: "https://www.bible.com/bible/48/\(path).CUNPSS-%E7%A5%9E")!
        )
    }
}

extension QuestionCard {
    var scriptureReferences: [BibleReference] {
        ([reference] + RelatedScriptureCatalog.references(for: deckID)).reduce(into: []) { result, item in
            guard !result.contains(where: { $0.englishURL == item.englishURL }) else { return }
            result.append(item)
        }
    }
}
