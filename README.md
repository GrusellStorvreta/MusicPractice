# MusicPractice

En iOS-app för att logga övningspass: låt/stycke, datum, längd och anteckningar.

## Tech

- SwiftUI, iOS 18+
- SwiftData för lokal lagring
- Projektet genereras med [XcodeGen](https://github.com/yonaskolb/XcodeGen) från `project.yml`

## Kom igång

```sh
brew install xcodegen   # om det inte redan finns
xcodegen generate
open MusicPractice.xcodeproj
```

`MusicPractice.xcodeproj` är genererad och **inte** incheckad (den ligger i `.gitignore`),
eftersom Xcode skriver om den lokalt varje gång du öppnar projektet (t.ex. ditt
signerings-Team-ID). Kör `xcodegen generate` efter varje `git pull` som rör `project.yml`
eller lägger till/tar bort filer, samt en gång innan första `open`.
