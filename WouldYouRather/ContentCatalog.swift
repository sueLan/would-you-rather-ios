import Foundation

enum ContentCatalog {
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

    static let cards: [QuestionCard] =
        CatalogExpansion.cards(for: .love, preserving: loveCards)
        + CatalogExpansion.cards(for: .faith, preserving: faithCards)
        + CatalogExpansion.cards(for: .connection, preserving: connectionCards)
        + CatalogExpansion.cards(for: .reflection, preserving: reflectionCards)
        + CatalogExpansion.cards(for: .wisdom)
        + CatalogExpansion.cards(for: .prayer)
        + CatalogExpansion.cards(for: .purpose)
        + CatalogExpansion.cards(for: .courage)
        + CatalogExpansion.cards(for: .gratitude)
        + CatalogExpansion.cards(for: .forgiveness)
        + CatalogExpansion.cards(for: .service)
        + CatalogExpansion.cards(for: .hope)

    private static func card(
        _ id: String, _ deck: DeckID,
        _ a: String, _ azh: String,
        _ b: String, _ bzh: String,
        _ context: String, _ contextZh: String,
        _ reference: String, _ referenceZh: String,
        _ path: String
    ) -> QuestionCard {
        QuestionCard(
            id: id,
            deckID: deck,
            optionA: .init(en: a, zhHans: azh),
            optionB: .init(en: b, zhHans: bzh),
            context: .init(en: context, zhHans: contextZh),
            reference: .init(
                display: .init(en: reference, zhHans: referenceZh),
                englishURL: URL(string: "https://www.bible.com/bible/111/\(path).NIV")!,
                chineseURL: URL(string: "https://www.bible.com/bible/48/\(path).CUNPSS-%E7%A5%9E")!
            )
        )
    }

    private static let loveCards: [QuestionCard] = [
        card("love-01", .love,
             "Stop to help a stranger when you are already late", "即使已经迟到，仍停下来帮助陌生人",
             "Keep your commitment and arrange help for them", "先履行承诺，同时为对方安排帮助",
             "Jesus makes the wounded stranger—not convenience—the test of neighborly love.", "耶稣以受伤的陌生人，而不是我们的方便，来检验爱邻舍的心。",
             "Luke 10:25–37", "路加福音 10:25–37", "LUK.10.25-37"),
        card("love-02", .love,
             "Speak a difficult truth gently", "温柔地说出一个难以接受的真相",
             "Wait quietly until the other person is ready", "安静等候，直到对方预备好",
             "Biblical love joins patience and kindness with a refusal to delight in falsehood.", "圣经中的爱既有忍耐和恩慈，也不以不义为乐。",
             "1 Corinthians 13:4–7", "哥林多前书 13:4–7", "1CO.13.4-7"),
        card("love-03", .love,
             "Serve someone without telling anyone", "默默服事一个人，不告诉任何人",
             "Publicly invite others to serve with you", "公开邀请他人与你一同服事",
             "Jesus presents humble service as the recognizable pattern of his love.", "耶稣把谦卑服事显明为祂爱的记号。",
             "John 13:12–17", "约翰福音 13:12–17", "JHN.13.12-17"),
        card("love-04", .love,
             "Pray regularly for someone who hurt you", "常常为伤害过你的人祷告",
             "Take one practical step toward reconciliation", "采取一个实际行动，迈向和好",
             "Jesus calls his followers beyond retaliation toward active love and prayer.", "耶稣呼召跟随祂的人超越报复，以行动和祷告去爱。",
             "Matthew 5:43–48", "马太福音 5:43–48", "MAT.5.43-48"),
        card("love-05", .love,
             "Stay beside a friend through an uncertain season", "在朋友不确定的人生阶段陪伴到底",
             "Give them space to begin again somewhere new", "给对方空间，在新的地方重新开始",
             "Ruth's costly loyalty shows love expressed through presence and shared risk.", "路得付代价的忠诚，让我们看见爱借着陪伴和共同承担风险表达出来。",
             "Ruth 1:16–18", "路得记 1:16–18", "RUT.1.16-18"),
        card("love-06", .love,
             "Show love first when you feel uncertain", "即使心里不确定，仍先表达爱",
             "Ask for reassurance before opening your heart", "先寻求肯定，再敞开心",
             "John grounds our ability to love in God's initiative rather than our confidence.", "约翰把我们爱的能力建立在上帝主动的爱上，而不是自己的把握上。",
             "1 John 4:7–12", "约翰一书 4:7–12", "1JN.4.7-12"),
        card("love-07", .love,
             "Forgive quickly while rebuilding trust slowly", "迅速饶恕，同时慢慢重建信任",
             "Wait to forgive until the relationship feels safe", "等到关系让你感到安全时再饶恕",
             "Paul describes forgiveness as a response to Christ's grace, alongside compassion and patience.", "保罗把饶恕描绘为对基督恩典的回应，并与怜悯和忍耐相连。",
             "Colossians 3:12–14", "歌罗西书 3:12–14", "COL.3.12-14"),
        card("love-08", .love,
             "Be present in a friend's grief without advice", "陪伴悲伤的朋友，不急着给建议",
             "Offer one practical idea that may lighten their load", "提出一个实际办法，减轻对方的重担",
             "Wisdom recognizes faithful friendship as steady in both joy and adversity.", "智慧让我们看见，忠诚的友谊在喜乐和患难中都坚定不移。",
             "Proverbs 17:17", "箴言 17:17", "PRO.17.17"),
        card("love-09", .love,
             "Carry part of someone's burden yourself", "亲自分担他人的一部分重担",
             "Help them build strength to carry it", "帮助对方建立承担重担的力量",
             "Paul holds mutual burden-bearing together with responsible personal growth.", "保罗既教导彼此担当重担，也看重个人负责任地成长。",
             "Galatians 6:2–5", "加拉太书 6:2–5", "GAL.6.2-5"),
        card("love-10", .love,
             "Give up a comfort to make room for a friend", "放下一项自己的舒适，为朋友腾出空间",
             "Protect your limits so you can love consistently", "守住界限，好让自己能持续地去爱",
             "Jesus connects deep love with willing, purposeful self-giving.", "耶稣把深厚的爱与甘心、有目的的舍己相连。",
             "John 15:9–13", "约翰福音 15:9–13", "JHN.15.9-13"),
        card("love-11", .love,
             "Celebrate someone whose success surpasses yours", "为成就超过你的人真心庆祝",
             "Step back until your envy has settled", "先退一步，等嫉妒的情绪平静下来",
             "Sincere love learns to honor others and share both joy and sorrow.", "真诚的爱学习尊重他人，并与人同喜同悲。",
             "Romans 12:9–16", "罗马书 12:9–16", "ROM.12.9-16"),
        card("love-12", .love,
             "Welcome someone who does not fit your usual circle", "接纳一个不属于你惯常圈子的人",
             "Deepen the relationships already entrusted to you", "加深那些已经托付给你的关系",
             "James warns that partiality contradicts the call to love our neighbor.", "雅各提醒我们，偏待人违背了爱邻舍的呼召。",
             "James 2:1–9", "雅各书 2:1–9", "JAS.2.1-9")
    ]

    private static let faithCards: [QuestionCard] = [
        card("faith-01", .faith,
             "Take the first faithful step without seeing the whole path", "看不见整条道路时，仍迈出忠心的第一步",
             "Wait for greater clarity before committing", "等候更清楚的指引后再作决定",
             "Hebrews remembers faith as trusting God's promise before outcomes are visible.", "希伯来书把信心描述为在结果尚未看见时，仍信靠上帝的应许。",
             "Hebrews 11:1–8", "希伯来书 11:1–8", "HEB.11.1-8"),
        card("faith-02", .faith,
             "Step out of the boat when Jesus calls", "耶稣呼召时就走出船外",
             "Stay aboard and ask for one more sign", "留在船上，再求一个印证",
             "Peter's story holds courageous response and honest dependence together.", "彼得的故事把勇敢回应与诚实倚靠放在一起。",
             "Matthew 14:22–33", "马太福音 14:22–33", "MAT.14.22-33"),
        card("faith-03", .faith,
             "Trust God's direction over your preferred plan", "在自己喜欢的计划之上信靠上帝的带领",
             "Keep planning carefully while asking God to redirect you", "继续谨慎计划，同时求上帝纠正方向",
             "Wisdom invites whole-hearted trust while acknowledging God in every path.", "智慧邀请我们全心信靠，并在每条道路上承认上帝。",
             "Proverbs 3:5–6", "箴言 3:5–6", "PRO.3.5-6"),
        card("faith-04", .faith,
             "Ask God boldly for wisdom", "放胆向上帝求智慧",
             "Begin with the wisdom already available to you", "先运用已经领受的智慧",
             "James encourages confident prayer to the God who gives generously.", "雅各鼓励人凭信心祷告，因为上帝厚赐智慧。",
             "James 1:5–8", "雅各书 1:5–8", "JAS.1.5-8"),
        card("faith-05", .faith,
             "Pray, “I believe; help my unbelief”", "祷告说：“我信，但我信不足，求主帮助”",
             "Wait to pray until your faith feels stronger", "等信心更强时再祷告",
             "Jesus receives a father's honest mixture of faith, fear, and need.", "耶稣接纳一位父亲把信心、惧怕和需要诚实地带到祂面前。",
             "Mark 9:20–27", "马可福音 9:20–27", "MRK.9.20-27"),
        card("faith-06", .faith,
             "Trust that God is at work in a painful season", "在痛苦的季节中仍相信上帝正在工作",
             "Focus only on the next good action you can take", "只专注于眼前能够采取的善行",
             "Paul speaks hope without calling suffering good or denying its weight.", "保罗传递盼望，却没有把苦难说成美好，也没有否认它的重量。",
             "Romans 8:26–28", "罗马书 8:26–28", "ROM.8.26-28"),
        card("faith-07", .faith,
             "Stand publicly for your conviction despite the cost", "即使付代价，也公开坚守信念",
             "Practice your conviction quietly without confrontation", "安静地实践信念，避免正面冲突",
             "Daniel's friends entrust both rescue and loss to God without controlling the result.", "但以理的朋友把得救或受损都交托给上帝，不试图控制结果。",
             "Daniel 3:16–28", "但以理书 3:16–28", "DAN.3.16-28"),
        card("faith-08", .faith,
             "Walk through the dark valley with trusted companions", "与可信赖的同伴一起走过幽谷",
             "Seek solitude to listen for the Shepherd's voice", "独处安静，聆听牧者的声音",
             "The psalmist finds courage not in an easy path but in God's presence.", "诗人的勇气不是来自平坦道路，而是来自上帝的同在。",
             "Psalm 23", "诗篇 23", "PSA.23.1-6"),
        card("faith-09", .faith,
             "Give generously before every future need is covered", "在未来需要尚未全有保障时仍慷慨给予",
             "Build a careful reserve so you can give sustainably", "谨慎储备，好让自己能持续给予",
             "Jesus redirects anxious attention toward the Father's care and today's faithfulness.", "耶稣把焦虑的目光转向天父的看顾和今日的忠心。",
             "Matthew 6:25–34", "马太福音 6:25–34", "MAT.6.25-34"),
        card("faith-10", .faith,
             "Choose by faith when visible evidence is limited", "眼前证据有限时，凭信心作选择",
             "Gather more evidence as an act of faithful stewardship", "继续收集证据，作为忠心管理的一部分",
             "Walking by faith changes what ultimately guides us, not whether we think carefully.", "凭信心而行改变的是最终引导我们的依据，而不是停止认真思考。",
             "2 Corinthians 5:6–10", "哥林多后书 5:6–10", "2CO.5.6-10"),
        card("faith-11", .faith,
             "Lay aside one habit that slows your spiritual growth", "放下一个拦阻属灵成长的习惯",
             "Add one life-giving practice before removing anything", "先加入一个带来生命的操练，再考虑舍弃",
             "Hebrews pictures faithfulness as an enduring race focused on Jesus.", "希伯来书把忠心描绘为一场定睛耶稣、忍耐奔跑的赛程。",
             "Hebrews 12:1–3", "希伯来书 12:1–3", "HEB.12.1-3"),
        card("faith-12", .faith,
             "Move forward courageously with what God has given you", "带着上帝已经赐下的，勇敢向前",
             "Pause to strengthen the people who will go with you", "先停下来，坚固将与你同行的人",
             "Joshua's courage is rooted in God's presence and attentive obedience.", "约书亚的勇气扎根于上帝的同在和专心顺服。",
             "Joshua 1:6–9", "约书亚记 1:6–9", "JOS.1.6-9")
    ]

    private static let connectionCards: [QuestionCard] = [
        card("connection-01", .connection,
             "Share a meal with people you barely know", "与不太熟悉的人一同吃饭",
             "Invite a few close friends into deeper conversation", "邀请几位密友进入更深的交谈",
             "The early church's shared life joined open tables with committed fellowship.", "初期教会的共同生活，把开放的饭桌与委身的团契连在一起。",
             "Acts 2:42–47", "使徒行传 2:42–47", "ACT.2.42-47"),
        card("connection-02", .connection,
             "Ask for help before you are overwhelmed", "在不堪重负以前主动求助",
             "Try one more time on your own before reaching out", "先再独自尝试一次，然后再求助",
             "Ecclesiastes praises companionship that lifts, warms, and strengthens.", "传道书赞美能够扶持、温暖并加添力量的同伴关系。",
             "Ecclesiastes 4:9–12", "传道书 4:9–12", "ECC.4.9-12"),
        card("connection-03", .connection,
             "Encourage someone face to face", "当面鼓励一个人",
             "Write words they can return to later", "写下让对方日后可以重读的话",
             "Christian community deliberately stirs people toward love, hope, and good action.", "基督徒群体有意识地激励人活出爱、盼望和善行。",
             "Hebrews 10:23–25", "希伯来书 10:23–25", "HEB.10.23-25"),
        card("connection-04", .connection,
             "Gently challenge a friend who is drifting", "温柔地提醒一个正在偏离的朋友",
             "Stay close and let your example speak first", "继续陪伴，先让自己的榜样说话",
             "Restoration is entrusted to people shaped by gentleness and self-awareness.", "挽回的责任托付给那些有温柔和自省之心的人。",
             "Galatians 6:1–2", "加拉太书 6:1–2", "GAL.6.1-2"),
        card("connection-05", .connection,
             "Use your strongest gift where the community needs it", "在群体最需要之处运用你的恩赐",
             "Serve in an unnoticed role that no one else wants", "承担一个无人愿意、也不引人注目的服事",
             "Paul describes different gifts as belonging to one interdependent body.", "保罗把不同恩赐描绘为同属一个彼此依存的身体。",
             "Romans 12:3–8", "罗马书 12:3–8", "ROM.12.3-8"),
        card("connection-06", .connection,
             "Offer specific encouragement to someone discouraged", "给灰心的人一个具体的鼓励",
             "Quietly take over one task that is exhausting them", "默默接过一项令对方疲惫的任务",
             "Paul calls a community to adapt its care to the discouraged, weak, and impatient.", "保罗呼召群体按着灰心、软弱和需要忍耐之人的处境去关怀。",
             "1 Thessalonians 5:11–14", "帖撒罗尼迦前书 5:11–14", "1TH.5.11-14"),
        card("connection-07", .connection,
             "Confess a struggle to a trusted friend", "向可信赖的朋友承认自己的挣扎",
             "First name it privately before God", "先在上帝面前私下承认它",
             "James connects honest confession, prayer, and healing within trustworthy community.", "雅各把诚实认罪、彼此祷告和医治连在可信赖的群体中。",
             "James 5:13–16", "雅各书 5:13–16", "JAS.5.13-16"),
        card("connection-08", .connection,
             "Address a conflict before the day ends", "在一天结束前面对冲突",
             "Take time to become calm before speaking", "先花时间平静下来再开口",
             "Paul pairs timely reconciliation with truthful, gracious speech.", "保罗把及时和好与诚实、恩慈的言语放在一起。",
             "Ephesians 4:25–32", "以弗所书 4:25–32", "EPH.4.25-32"),
        card("connection-09", .connection,
             "Protect unity by emphasizing shared faith", "强调共同的信仰，守护合一",
             "Name a real disagreement so unity can become honest", "说出真实分歧，使合一建立在诚实上",
             "Jesus prays for a unity grounded in truth, love, and shared life with God.", "耶稣所祈求的合一扎根于真理、爱以及与上帝共享的生命。",
             "John 17:20–23", "约翰福音 17:20–23", "JHN.17.20-23"),
        card("connection-10", .connection,
             "Give up being recognized so another person can flourish", "放下被看见的机会，让另一个人得以成长",
             "Accept leadership so the group has clear direction", "承担带领责任，使群体有清楚方向",
             "Christ-shaped community resists selfish ambition while taking responsible action.", "以基督为样式的群体拒绝自私争竞，同时勇于承担责任。",
             "Philippians 2:1–5", "腓立比书 2:1–5", "PHP.2.1-5"),
        card("connection-11", .connection,
             "Invite honest feedback from a close friend", "邀请亲近的朋友给你诚实反馈",
             "Ask them first what support they need from you", "先询问对方需要你怎样支持",
             "Proverbs values the faithful friction through which friends sharpen one another.", "箴言看重朋友之间忠诚的磨合，使彼此更加成熟。",
             "Proverbs 27:5–6, 17", "箴言 27:5–6、17", "PRO.27.5-6,17"),
        card("connection-12", .connection,
             "Welcome people into your home even when it is imperfect", "即使家里不完美，仍欢迎人进来",
             "Meet elsewhere so you can give them your full attention", "约在别处见面，好让你能全心陪伴",
             "Peter connects hospitality and service with love that does not complain.", "彼得把接待和服事与不发怨言的爱连在一起。",
             "1 Peter 4:8–11", "彼得前书 4:8–11", "1PE.4.8-11")
    ]

    private static let reflectionCards: [QuestionCard] = [
        card("reflection-01", .reflection,
             "Ask God to reveal one hidden motive", "求上帝显明一个隐藏的动机",
             "Thank God for one area of visible growth", "为一个明显成长的领域感谢上帝",
             "The psalm welcomes God's searching presence as a guide toward life.", "诗人欢迎上帝鉴察的同在，引导自己走向生命之路。",
             "Psalm 139:23–24", "诗篇 139:23–24", "PSA.139.23-24"),
        card("reflection-02", .reflection,
             "Begin the day remembering God's mercy", "以记念上帝的怜悯开始新的一天",
             "End the day naming where you needed mercy", "在一天结束时，省察自己何处需要怜悯",
             "Lament makes room for pain while deliberately recalling God's faithful compassion.", "哀歌为痛苦留下空间，同时有意识地记念上帝信实的怜悯。",
             "Lamentations 3:19–26", "耶利米哀歌 3:19–26", "LAM.3.19-26"),
        card("reflection-03", .reflection,
             "Write down what is true and worthy of praise", "写下真实、值得称赞的事",
             "Speak your anxieties honestly in prayer", "在祷告中诚实说出焦虑",
             "Paul holds honest prayer and disciplined attention together on the path to peace.", "保罗把诚实祷告和有操练的专注结合在通往平安的路上。",
             "Philippians 4:6–9", "腓立比书 4:6–9", "PHP.4.6-9"),
        card("reflection-04", .reflection,
             "Examine the fruit of a recent decision", "察看最近一个决定所结出的果子",
             "Examine the motive from which you made it", "察看作出这个决定时的动机",
             "Jesus teaches discernment that looks beyond appearances to enduring fruit.", "耶稣教导人分辨，不只看外表，而要看长久的果子。",
             "Matthew 7:15–20", "马太福音 7:15–20", "MAT.7.15-20"),
        card("reflection-05", .reflection,
             "Act today on one truth you already know", "今天就实践一个已经明白的真理",
             "Study it more deeply before changing your routine", "先更深入研读，再改变日常生活",
             "James warns against reflection that never becomes embodied obedience.", "雅各警告人，不要让省察停留在思想里，却不成为实际的顺服。",
             "James 1:22–25", "雅各书 1:22–25", "JAS.1.22-25"),
        card("reflection-06", .reflection,
             "Sit in silence for ten minutes", "安静独坐十分钟",
             "Take a slow walk while praying", "一边缓慢行走，一边祷告",
             "The psalm calls hurried hearts to stillness before the God who is present.", "诗篇呼召匆忙的心，在同在的上帝面前安静。",
             "Psalm 46:1–11", "诗篇 46:1–11", "PSA.46.1-11"),
        card("reflection-07", .reflection,
             "Name where you identify with the younger son", "说出自己在哪些方面像小儿子",
             "Name where you identify with the older son", "说出自己在哪些方面像大儿子",
             "Jesus' parable invites both obvious wanderers and resentful insiders to receive the Father's grace.", "耶稣的比喻邀请明显迷失的人和心怀怨恨的圈内人，一同领受父的恩典。",
             "Luke 15:11–32", "路加福音 15:11–32", "LUK.15.11-32"),
        card("reflection-08", .reflection,
             "Remove one voice that is shaping you poorly", "远离一个正在错误塑造你的声音",
             "Add one practice that renews your thinking", "加入一个更新思想的操练",
             "Paul describes transformation as both resistance to a pattern and renewal of the mind.", "保罗把生命转变描述为拒绝旧模式，同时让心意更新。",
             "Romans 12:1–2", "罗马书 12:1–2", "ROM.12.1-2"),
        card("reflection-09", .reflection,
             "Accept that this season cannot be rushed", "接受这个人生季节无法催促",
             "Make one change that may begin a new season", "作出一个可能开启新季节的改变",
             "Ecclesiastes honors life's different seasons without making us passive within them.", "传道书尊重生命的不同季节，却不是叫我们消极不动。",
             "Ecclesiastes 3:1–8", "传道书 3:1–8", "ECC.3.1-8"),
        card("reflection-10", .reflection,
             "Count your days so you can choose wisely", "数算自己的日子，好作智慧选择",
             "Focus fully on today rather than measuring time", "全心活在今天，而不计算时间",
             "Moses' prayer joins awareness of life's brevity with a request for wisdom and meaningful work.", "摩西的祷告把对人生短暂的认识，与求智慧和有意义的工作连在一起。",
             "Psalm 90:12–17", "诗篇 90:12–17", "PSA.90.12-17"),
        card("reflection-11", .reflection,
             "Choose one quiet act of justice", "选择一个安静的公义行动",
             "Choose one relationship in which to practice mercy", "选择一段关系去操练怜悯",
             "Micah summarizes faithful life through justice, mercy, and humble companionship with God.", "弥迦以行公义、好怜悯、谦卑与上帝同行来概括忠信的生命。",
             "Micah 6:6–8", "弥迦书 6:6–8", "MIC.6.6-8"),
        card("reflection-12", .reflection,
             "Let gratitude reshape a current complaint", "让感恩重新塑造你当前的抱怨",
             "Name the complaint honestly before seeking gratitude", "先诚实说出抱怨，再寻找可感恩之处",
             "Paul connects Christ's peace, truthful community, and gratitude rather than using thanks to hide pain.", "保罗把基督的平安、真实的群体和感恩连在一起，而不是用感谢掩盖痛苦。",
             "Colossians 3:15–17", "歌罗西书 3:15–17", "COL.3.15-17")
    ]
}
