import SwiftUI
import CoreText

enum AppFonts {
    static let family = "Host Grotesk"

    /// A appeler une fois au lancement : enregistre les .ttf embarques (Resources/Fonts) aupres de CoreText.
    static func register() {
        let names = ["HostGrotesk-Regular", "HostGrotesk-SemiBold", "HostGrotesk-Bold"]
        for name in names {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension Font {
    // Chaque poids reference son fichier .ttf exact par nom PostScript : `.fontWeight()`
    // sur une police custom statique est peu fiable avec CoreText (echoue silencieusement
    // ou log "Unable to update Font Descriptor's weight"), et le SemiBold est meme
    // enregistre sous une famille legacy separee ("Host Grotesk SemiBold").
    static func hostGrotesk(_ size: CGFloat) -> Font {
        .custom("HostGrotesk-Regular", size: size)
    }

    static func hostGroteskSemiBold(_ size: CGFloat) -> Font {
        .custom("HostGrotesk-SemiBold", size: size)
    }

    static func hostGroteskBold(_ size: CGFloat) -> Font {
        .custom("HostGrotesk-Bold", size: size)
    }
}
