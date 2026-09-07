import Foundation

/// Builds the expanded offline catalog from deck-specific subjects and five
/// complementary decision lenses. The original hand-authored cards are kept
/// at their stable IDs; expansion cards fill each deck to exactly 50 entries.
enum CatalogExpansion {
    private struct Profile: Sendable {
        let foundation: LocalizedValue
        let topics: [LocalizedValue]
    }

    private struct Lens: Sendable {
        let context: LocalizedValue
        let reference: LocalizedValue
        let path: String
    }

    static func cards(for deck: DeckID, preserving base: [QuestionCard] = []) -> [QuestionCard] {
        precondition(base.count <= 50, "A deck cannot preserve more than 50 cards")
        let profile = profile(for: deck)
        precondition(profile.topics.count == 10, "Every expansion profile needs 10 topics")
        guard base.count < 50 else { return base }

        let generated = ((base.count + 1)...50).map { number in
            makeCard(number: number, deck: deck, profile: profile)
        }
        return base + generated
    }

    private static func makeCard(number: Int, deck: DeckID, profile: Profile) -> QuestionCard {
        let combination = number - 1
        let lensIndex = combination / 10
        let topic = profile.topics[combination % 10]
        let lens = lenses[lensIndex]
        let choices = choices(for: topic, lens: lensIndex)

        return QuestionCard(
            id: "\(deck.rawValue)-\(String(format: "%02d", number))",
            deckID: deck,
            optionA: choices.a,
            optionB: choices.b,
            context: .init(
                en: "\(profile.foundation.en) \(lens.context.en)",
                zhHans: "\(profile.foundation.zhHans)\(lens.context.zhHans)"
            ),
            reference: .init(
                display: lens.reference,
                englishURL: URL(string: "https://www.bible.com/bible/111/\(lens.path).NIV")!,
                chineseURL: URL(string: "https://www.bible.com/bible/48/\(lens.path).CUNPSS-%E7%A5%9E")!
            )
        )
    }

    private static func choices(
        for topic: LocalizedValue,
        lens: Int
    ) -> (a: LocalizedValue, b: LocalizedValue) {
        switch lens {
        case 0:
            (
                .init(
                    en: "Take a visible first step toward \(topic.en)",
                    zhHans: "为\(topic.zhHans)迈出一个看得见的第一步"
                ),
                .init(
                    en: "Begin by praying quietly about \(topic.en)",
                    zhHans: "先为\(topic.zhHans)安静祷告"
                )
            )
        case 1:
            (
                .init(
                    en: "Act now to pursue \(topic.en)",
                    zhHans: "现在就采取行动，追求\(topic.zhHans)"
                ),
                .init(
                    en: "Wait and seek wise counsel about \(topic.en)",
                    zhHans: "先等候，并为\(topic.zhHans)寻求智慧建议"
                )
            )
        case 2:
            (
                .init(
                    en: "Invite someone to join you in \(topic.en)",
                    zhHans: "邀请他人与你一同操练\(topic.zhHans)"
                ),
                .init(
                    en: "Practice \(topic.en) privately before involving others",
                    zhHans: "先独自操练\(topic.zhHans)，再邀请他人"
                )
            )
        case 3:
            (
                .init(
                    en: "Choose a costly response for \(topic.en)",
                    zhHans: "为\(topic.zhHans)选择一个需要付代价的回应"
                ),
                .init(
                    en: "Build a sustainable rhythm for \(topic.en)",
                    zhHans: "为\(topic.zhHans)建立可持续的节奏"
                )
            )
        default:
            (
                .init(
                    en: "Speak openly about \(topic.en)",
                    zhHans: "公开谈论\(topic.zhHans)"
                ),
                .init(
                    en: "Let consistent action demonstrate \(topic.en)",
                    zhHans: "让持续的行动显明\(topic.zhHans)"
                )
            )
        }
    }

    private static let lenses: [Lens] = [
        Lens(
            context: .init(
                en: "Scripture joins inward conviction with outward obedience. Which first step would be faithful here?",
                zhHans: "圣经把内在信念与外在顺服连在一起。此刻哪一个第一步更忠心？"
            ),
            reference: .init(en: "James 2:14–18", zhHans: "雅各书 2:14–18"),
            path: "JAS.2.14-18"
        ),
        Lens(
            context: .init(
                en: "Biblical wisdom makes room for timely action and patient counsel. Consider what this moment truly requires.",
                zhHans: "圣经中的智慧既重视及时行动，也重视耐心求教。请思想此刻真正需要什么。"
            ),
            reference: .init(en: "Proverbs 15:22", zhHans: "箴言 15:22"),
            path: "PRO.15.22"
        ),
        Lens(
            context: .init(
                en: "Formation happens both in trustworthy community and in the hidden life. Which setting would help this practice take root?",
                zhHans: "生命塑造既发生在可信赖的群体中，也发生在隐秘处。哪一种环境更能帮助这项操练扎根？"
            ),
            reference: .init(en: "Hebrews 10:24–25", zhHans: "希伯来书 10:24–25"),
            path: "HEB.10.24-25"
        ),
        Lens(
            context: .init(
                en: "Jesus calls people to count the cost without confusing faithfulness with burnout. Seek a response that is both courageous and enduring.",
                zhHans: "耶稣呼召人计算代价，却不把忠心等同于耗尽自己。要寻找既勇敢又能持久的回应。"
            ),
            reference: .init(en: "Luke 14:28–33", zhHans: "路加福音 14:28–33"),
            path: "LUK.14.28-33"
        ),
        Lens(
            context: .init(
                en: "Words and deeds both bear witness. Discern which one would communicate integrity and love most clearly now.",
                zhHans: "言语和行动都能作见证。请分辨此刻哪一种更能清楚表达正直与爱。"
            ),
            reference: .init(en: "1 John 3:16–18", zhHans: "约翰一书 3:16–18"),
            path: "1JN.3.16-18"
        )
    ]

    private static func profile(for deck: DeckID) -> Profile {
        switch deck {
        case .love:
            Profile(
                foundation: .init(
                    en: "God's love becomes visible through patient, truthful, self-giving care.",
                    zhHans: "上帝的爱借着忍耐、真实和舍己的关怀显明出来。"
                ),
                topics: topics(
                    ("care for a lonely neighbor", "对孤单邻舍的关怀"),
                    ("patience in a difficult family relationship", "在困难家庭关系中的忍耐"),
                    ("hospitality toward a newcomer", "对新来者的接待"),
                    ("kindness toward a critic", "对批评者的善意"),
                    ("sacrificial support for a friend", "对朋友舍己的支持"),
                    ("truthful compassion for a coworker", "对同事真实的怜悯"),
                    ("loyalty during an uncertain season", "在不确定季节中的忠诚"),
                    ("protection for someone vulnerable", "对软弱者的保护"),
                    ("generosity toward a stranger", "对陌生人的慷慨"),
                    ("reconciliation in a broken relationship", "破裂关系中的和好")
                )
            )
        case .faith:
            Profile(
                foundation: .init(
                    en: "Faith trusts God's character while taking the next obedient step.",
                    zhHans: "信心是在迈出下一个顺服步伐时，仍信靠上帝的属性。"
                ),
                topics: topics(
                    ("trust during unanswered prayer", "祷告尚未蒙应允时的信靠"),
                    ("obedience without complete clarity", "尚未完全明白时的顺服"),
                    ("peace amid financial uncertainty", "经济不确定中的平安"),
                    ("faithfulness in a hidden season", "隐藏季节中的忠心"),
                    ("confidence after disappointment", "失望之后的信靠"),
                    ("dependence on God in an important decision", "重要决定中对上帝的倚靠"),
                    ("worship during suffering", "苦难中的敬拜"),
                    ("trust when plans change", "计划改变时的信靠"),
                    ("courage to live your conviction", "活出信念的勇气"),
                    ("patience while waiting on God", "等候上帝时的忍耐")
                )
            )
        case .connection:
            Profile(
                foundation: .init(
                    en: "Christ-shaped community grows through honesty, welcome, and mutual care.",
                    zhHans: "以基督为样式的群体，借着诚实、接纳和彼此关怀而成长。"
                ),
                topics: topics(
                    ("honesty in a close friendship", "亲密友谊中的诚实"),
                    ("welcome for someone outside your circle", "对圈子以外之人的接纳"),
                    ("unity through a real disagreement", "真实分歧中的合一"),
                    ("asking for help before exhaustion", "在耗尽以前主动求助"),
                    ("mentoring a younger believer", "陪伴年轻信徒成长"),
                    ("reconciliation after conflict", "冲突之后的和好"),
                    ("fellowship around a shared meal", "共享饭桌上的团契"),
                    ("encouragement for someone discouraged", "对灰心之人的鼓励"),
                    ("accountability in a recurring struggle", "反复挣扎中的彼此督责"),
                    ("cooperation across generations", "跨世代的同工")
                )
            )
        case .reflection:
            Profile(
                foundation: .init(
                    en: "Prayerful reflection notices what is shaping the heart and turns insight into obedience.",
                    zhHans: "祷告中的省察留意什么正在塑造内心，并让领悟成为顺服。"
                ),
                topics: topics(
                    ("examining your hidden motives", "察验隐藏的动机"),
                    ("noticing God's presence today", "察看上帝今日的同在"),
                    ("reviewing the fruit of your habits", "检视习惯所结的果子"),
                    ("processing regret with grace", "在恩典中面对遗憾"),
                    ("naming reasons for gratitude", "说出感恩的理由"),
                    ("listening to God in silence", "在安静中聆听上帝"),
                    ("discerning a recent decision", "分辨最近的决定"),
                    ("remembering God's faithfulness", "记念上帝的信实"),
                    ("releasing unhealthy comparison", "放下不健康的比较"),
                    ("choosing your next faithful step", "选择下一个忠心的步伐")
                )
            )
        case .wisdom:
            Profile(
                foundation: .init(
                    en: "Godly wisdom listens carefully, tests motives, and seeks a faithful path.",
                    zhHans: "属上帝的智慧会细心聆听、察验动机，并寻找忠信的道路。"
                ),
                topics: topics(
                    ("discernment in a career decision", "职业决定中的分辨"),
                    ("grace in an online disagreement", "网络争论中的恩慈"),
                    ("stewardship in a financial choice", "财务选择中的好管家心态"),
                    ("a healthy relational boundary", "健康的关系界限"),
                    ("clarity in a complex family decision", "复杂家庭决定中的清晰"),
                    ("direction amid conflicting advice", "不同建议中的方向"),
                    ("wisdom in ordering your time", "安排时间的智慧"),
                    ("integrity when hearing gossip", "听见闲话时的正直"),
                    ("humility in a leadership opportunity", "带领机会中的谦卑"),
                    ("patience with incomplete information", "信息不完整时的耐心")
                )
            )
        case .prayer:
            Profile(
                foundation: .init(
                    en: "Prayer brings honest desire, attentive silence, and trusting surrender before God.",
                    zhHans: "祷告把真实的渴望、专注的安静和信靠的交托带到上帝面前。"
                ),
                topics: topics(
                    ("a faithful morning prayer rhythm", "忠心的晨祷节奏"),
                    ("prayer during an anxious night", "焦虑夜晚中的祷告"),
                    ("intercession for someone difficult", "为难以相处之人的代祷"),
                    ("praying with the words of Scripture", "用圣经话语祷告"),
                    ("silent listening before God", "在上帝面前安静聆听"),
                    ("honesty in group prayer", "集体祷告中的诚实"),
                    ("perseverance in an unanswered request", "未蒙应允祈求中的坚持"),
                    ("gratitude within your prayers", "祷告中的感恩"),
                    ("confession without hiding", "毫不隐藏的认罪"),
                    ("a bold request offered with surrender", "带着交托的大胆祈求")
                )
            )
        case .purpose:
            Profile(
                foundation: .init(
                    en: "Purpose is formed through faithful presence, gifted service, and openness to God's direction.",
                    zhHans: "使命借着忠心同在、恩赐服事和向上帝带领敞开而形成。"
                ),
                topics: topics(
                    ("using your strongest gift faithfully", "忠心运用最强的恩赐"),
                    ("meaning in your current work", "当前工作中的意义"),
                    ("purpose during a waiting season", "等候季节中的使命"),
                    ("responding to an unmet community need", "回应群体中未被满足的需要"),
                    ("an opportunity beyond your comfort zone", "舒适区以外的机会"),
                    ("stewardship of a long-term dream", "对长期梦想的管理"),
                    ("faithfulness in an ordinary responsibility", "平凡责任中的忠心"),
                    ("discernment about changing vocation", "转换职业呼召的分辨"),
                    ("the legacy your life is forming", "生命正在留下的传承"),
                    ("the next purposeful step", "下一个有使命感的步伐")
                )
            )
        case .courage:
            Profile(
                foundation: .init(
                    en: "Biblical courage faces fear with truth, love, and confidence in God's presence.",
                    zhHans: "圣经中的勇气以真理、爱和对上帝同在的信靠面对惧怕。"
                ),
                topics: topics(
                    ("speaking a difficult truth gently", "温柔说出困难的真相"),
                    ("standing beside someone excluded", "站在被排斥者身旁"),
                    ("beginning again after failure", "失败之后重新开始"),
                    ("asking forgiveness for real harm", "为真实伤害请求饶恕"),
                    ("refusing a convenient compromise", "拒绝方便的妥协"),
                    ("entering an unfamiliar community", "进入陌生的群体"),
                    ("faith during medical uncertainty", "医疗不确定中的信心"),
                    ("leading a necessary change", "带领必要的改变"),
                    ("admitting that you need help", "承认自己需要帮助"),
                    ("persevering through opposition", "在反对中坚持到底")
                )
            )
        case .gratitude:
            Profile(
                foundation: .init(
                    en: "Gratitude receives ordinary gifts as grace without denying pain or difficulty.",
                    zhHans: "感恩把平凡的礼物当作恩典领受，却不否认痛苦和困难。"
                ),
                topics: topics(
                    ("thankfulness for an ordinary meal", "为平凡一餐感恩"),
                    ("appreciation for an unnoticed helper", "感谢未被看见的帮助者"),
                    ("gratitude for a difficult lesson", "为艰难功课感恩"),
                    ("wonder at God's creation", "对上帝创造的惊叹"),
                    ("thankfulness within an imperfect family", "在不完美家庭中的感恩"),
                    ("gratitude for meaningful work", "为有意义的工作感恩"),
                    ("remembering an answered prayer", "记念蒙应允的祷告"),
                    ("noticing a small provision", "留意微小的供应"),
                    ("appreciation for your community", "对所属群体的感激"),
                    ("receiving rest as a gift", "把安息当作礼物领受")
                )
            )
        case .forgiveness:
            Profile(
                foundation: .init(
                    en: "Christian forgiveness seeks freedom from revenge while honoring truth, safety, justice, and wise boundaries.",
                    zhHans: "基督徒的饶恕使人脱离报复，同时尊重真相、安全、公义和智慧的界限。"
                ),
                topics: topics(
                    ("releasing a long-held resentment", "放下长期怀恨"),
                    ("seeking reconciliation after hurt", "受伤之后寻求和好"),
                    ("offering a specific apology", "作出具体的道歉"),
                    ("maintaining a wise boundary", "持守智慧的界限"),
                    ("receiving grace after your failure", "失败之后领受恩典"),
                    ("praying for someone who harmed you", "为伤害过你的人祷告"),
                    ("making restitution where possible", "在可能之处作出补偿"),
                    ("remembering how God forgave you", "记念上帝如何饶恕你"),
                    ("helping others move toward peace", "帮助他人走向和平"),
                    ("rebuilding trust with patience", "耐心重建信任")
                )
            )
        case .service:
            Profile(
                foundation: .init(
                    en: "Service follows Jesus by offering practical care without chasing recognition.",
                    zhHans: "服事是跟随耶稣，以实际关怀帮助人，却不追求被人看见。"
                ),
                topics: topics(
                    ("meeting a hidden practical need", "满足一个隐藏的实际需要"),
                    ("offering your professional skill", "献上你的专业技能"),
                    ("taking an unnoticed church task", "承担不被注意的教会工作"),
                    ("serving your neighborhood", "服事所在的社区"),
                    ("supporting an exhausted caregiver", "支持疲惫的照顾者"),
                    ("amplifying a marginalized voice", "让被边缘化者的声音被听见"),
                    ("mentoring someone with less experience", "陪伴经验较少的人成长"),
                    ("giving your time generously", "慷慨付出时间"),
                    ("responding during a community crisis", "在群体危机中作出回应"),
                    ("remaining faithful in unseen work", "在无人看见的工作中保持忠心")
                )
            )
        case .hope:
            Profile(
                foundation: .init(
                    en: "Christian hope faces reality honestly while trusting God's promised renewal.",
                    zhHans: "基督徒的盼望诚实面对现实，同时信靠上帝所应许的更新。"
                ),
                topics: topics(
                    ("hope through a long delay", "漫长延迟中的盼望"),
                    ("hope while grieving a loss", "哀伤失去时的盼望"),
                    ("hope while confronting injustice", "面对不公时的盼望"),
                    ("hope in a season of loneliness", "孤单季节中的盼望"),
                    ("hope during serious illness", "重病期间的盼望"),
                    ("hope after a failed plan", "计划失败后的盼望"),
                    ("hope for a divided community", "为分裂群体所怀的盼望"),
                    ("hope in the presence of doubt", "疑惑之中的盼望"),
                    ("hope for an uncertain future", "面对不确定未来的盼望"),
                    ("hope for restoration and new life", "对恢复与新生命的盼望")
                )
            )
        }
    }

    private static func topics(_ values: (String, String)...) -> [LocalizedValue] {
        values.map { LocalizedValue(en: $0.0, zhHans: $0.1) }
    }
}
