import Foundation

enum ContentCatalog {
    static let allTopicsTitle = LocalizedValue(en: "All Topics", zhHans: "全部主题")
    static let allTopicsSummary = LocalizedValue(
        en: "Explore shuffled questions from every topic.",
        zhHans: "随机探索所有主题的问题。"
    )

    static let payload = CatalogPayload(decks: decks, cards: cards)

    static let decks: [DeckDefinition] = [
        DeckDefinition(
            id: .love,
            title: .init(en: "Love", zhHans: "爱"),
            summary: .init(en: "Practice patient, courageous love.", zhHans: "操练忍耐而勇敢的爱。")
        ),
        DeckDefinition(
            id: .faith,
            title: .init(en: "Faith", zhHans: "信心"),
            summary: .init(en: "Trust God through uncertainty.", zhHans: "在不确定中信靠上帝。")
        ),
        DeckDefinition(
            id: .connection,
            title: .init(en: "Connection", zhHans: "连结"),
            summary: .init(en: "Build honest, life-giving community.", zhHans: "建立真诚、彼此造就的群体。")
        ),
        DeckDefinition(
            id: .reflection,
            title: .init(en: "Reflection", zhHans: "省察"),
            summary: .init(en: "Slow down and notice what shapes you.", zhHans: "放慢脚步，察看什么在塑造你。")
        ),
        DeckDefinition(
            id: .wisdom,
            title: .init(en: "Wisdom", zhHans: "智慧"),
            summary: .init(en: "Discern faithful choices in complex moments.", zhHans: "在复杂时刻分辨忠信的选择。")
        ),
        DeckDefinition(
            id: .prayer,
            title: .init(en: "Prayer", zhHans: "祷告"),
            summary: .init(en: "Grow an honest, attentive life with God.", zhHans: "建立向上帝诚实、专注的生命。")
        ),
        DeckDefinition(
            id: .purpose,
            title: .init(en: "Purpose", zhHans: "使命"),
            summary: .init(en: "Discover faithful work in every season.", zhHans: "在每个季节发现忠心的使命。")
        ),
        DeckDefinition(
            id: .courage,
            title: .init(en: "Courage", zhHans: "勇气"),
            summary: .init(en: "Meet fear with truth, love, and faith.", zhHans: "以真理、爱和信心面对惧怕。")
        ),
        DeckDefinition(
            id: .gratitude,
            title: .init(en: "Gratitude", zhHans: "感恩"),
            summary: .init(en: "Notice grace in ordinary life.", zhHans: "在平凡生活中察看恩典。")
        ),
        DeckDefinition(
            id: .forgiveness,
            title: .init(en: "Forgiveness", zhHans: "饶恕"),
            summary: .init(en: "Pursue mercy, truth, and restored freedom.", zhHans: "追求怜悯、真理与重新得力。")
        ),
        DeckDefinition(
            id: .service,
            title: .init(en: "Service", zhHans: "服事"),
            summary: .init(en: "Offer your gifts for the good of others.", zhHans: "为他人的益处献上你的恩赐。")
        ),
        DeckDefinition(
            id: .hope,
            title: .init(en: "Hope", zhHans: "盼望"),
            summary: .init(en: "Hold to God's promises through every season.", zhHans: "在每个季节持守上帝的应许。")
        )
    ]

    static let cards: [QuestionCard] = CatalogExpansion.cards
}
