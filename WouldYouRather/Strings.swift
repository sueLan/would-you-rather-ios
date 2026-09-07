import Foundation

enum Strings {
    static func text(_ key: Key, _ language: AppLanguage) -> String {
        language == .en ? key.en : key.zhHans
    }

    enum Key {
        case decks, history, settings, title, subtitle, cards(Int), wouldYouRather, or
        case biblicalContext, exploreStory, swipeHint, openInBible, previous, next, deckComplete, deckCompleteBody
        case shuffleAgain, anotherDeck, yourChoice, noHistory, noHistoryBody, clearAll
        case clearConfirm, cancel, delete, language, about, privacy, privacyBody
        case appDescription, linkFailed, retry, copyLink, copied, choiceSaved
        case unableToSave, done, ok, version

        var en: String {
            switch self {
            case .decks: "Decks"
            case .history: "History"
            case .settings: "Settings"
            case .title: "Would You Rather"
            case .subtitle: "Questions for faith-filled conversation"
            case .cards(let count): "\(count) cards"
            case .wouldYouRather: "WOULD YOU RATHER"
            case .or: "OR"
            case .biblicalContext: "Biblical Context"
            case .exploreStory: "Explore the story"
            case .swipeHint: "Swipe to explore the deck"
            case .openInBible: "Open in Bible"
            case .previous: "Previous"
            case .next: "Next"
            case .deckComplete: "Deck complete"
            case .deckCompleteBody: "You made space for fifty meaningful choices."
            case .shuffleAgain: "Shuffle Again"
            case .anotherDeck: "Choose Another Deck"
            case .yourChoice: "Your choice"
            case .noHistory: "No choices yet"
            case .noHistoryBody: "Choose A or B on a card and it will appear here."
            case .clearAll: "Clear All"
            case .clearConfirm: "Delete every saved choice? This cannot be undone."
            case .cancel: "Cancel"
            case .delete: "Delete"
            case .language: "Language"
            case .about: "About"
            case .privacy: "Privacy"
            case .privacyBody: "Your choices stay on this device. The app only connects to the internet when you open a Bible reference."
            case .appDescription: "600 Scripture-centered questions across twelve themes for faith and life."
            case .linkFailed: "The Bible link could not be opened."
            case .retry: "Retry"
            case .copyLink: "Copy Link"
            case .copied: "Link copied"
            case .choiceSaved: "Choice saved"
            case .unableToSave: "Unable to save"
            case .done: "Done"
            case .ok: "OK"
            case .version: "Version"
            }
        }

        var zhHans: String {
            switch self {
            case .decks: "卡组"
            case .history: "历史"
            case .settings: "设置"
            case .title: "你愿意选择"
            case .subtitle: "开启有信仰深度的对话"
            case .cards(let count): "\(count) 张卡片"
            case .wouldYouRather: "你愿意选择"
            case .or: "还是"
            case .biblicalContext: "圣经背景"
            case .exploreStory: "了解故事背景"
            case .swipeHint: "左右滑动浏览卡组"
            case .openInBible: "在圣经中打开"
            case .previous: "上一张"
            case .next: "下一张"
            case .deckComplete: "本组已完成"
            case .deckCompleteBody: "你已经认真思考了五十个有意义的选择。"
            case .shuffleAgain: "重新洗牌"
            case .anotherDeck: "选择其他卡组"
            case .yourChoice: "你的选择"
            case .noHistory: "还没有选择"
            case .noHistoryBody: "在卡片上选择 A 或 B，记录就会显示在这里。"
            case .clearAll: "全部清除"
            case .clearConfirm: "要删除所有已保存的选择吗？此操作无法撤销。"
            case .cancel: "取消"
            case .delete: "删除"
            case .language: "语言"
            case .about: "关于"
            case .privacy: "隐私"
            case .privacyBody: "你的选择只保存在此设备上。只有当你打开圣经经文时，应用才会连接网络。"
            case .appDescription: "十二个信仰与生活主题，共 600 个以圣经为中心的问题。"
            case .linkFailed: "无法打开圣经链接。"
            case .retry: "重试"
            case .copyLink: "复制链接"
            case .copied: "链接已复制"
            case .choiceSaved: "选择已保存"
            case .unableToSave: "无法保存"
            case .done: "完成"
            case .ok: "好"
            case .version: "版本"
            }
        }
    }
}
