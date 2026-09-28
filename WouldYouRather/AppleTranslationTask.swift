import SwiftUI
import Translation

struct AppleTranslationRequest: Identifiable, Hashable, Sendable {
    let id: String
    let sourceText: String
}

@available(iOS 18.0, *)
struct AppleTranslationTask: View {
    let targetLanguage: AppLanguage
    let requests: [AppleTranslationRequest]
    let trigger: Int
    let onCompletion: @MainActor ([String: String]) -> Void
    let onFailure: @MainActor (Error) -> Void

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .translationTask(
                source: AppLanguage.en.localeLanguage,
                target: targetLanguage.localeLanguage
            ) { session in
                guard !requests.isEmpty else { return }
                do {
                    let translations = try await Self.translate(
                        requests,
                        using: TranslationSessionTransfer(session)
                    )
                    onCompletion(translations)
                } catch {
                    onFailure(error)
                }
            }
            .id(requestSignature)
    }

    private var requestSignature: Int {
        var hasher = Hasher()
        hasher.combine(targetLanguage)
        hasher.combine(requests)
        hasher.combine(trigger)
        return hasher.finalize()
    }

    nonisolated private static func translate(
        _ requests: [AppleTranslationRequest],
        using session: TranslationSessionTransfer
    ) async throws -> [String: String] {
        let batch = requests.map {
            TranslationSession.Request(
                sourceText: $0.sourceText,
                clientIdentifier: $0.id
            )
        }
        let responses = try await session.value.translations(from: batch)
        return Dictionary(uniqueKeysWithValues: responses.compactMap { response in
            response.clientIdentifier.map { ($0, response.targetText) }
        })
    }
}

/// TranslationSession is designed to perform asynchronous translation, but
/// the iOS 18 SDK doesn't annotate the session as Sendable for Swift 6 callers.
/// This narrow wrapper transfers it exactly once into the translation helper.
@available(iOS 18.0, *)
private struct TranslationSessionTransfer: @unchecked Sendable {
    let value: TranslationSession

    init(_ value: TranslationSession) {
        self.value = value
    }
}
