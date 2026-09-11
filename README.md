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

`MusicPractice.xcodeproj` är genererad och incheckad, men om du ändrar `project.yml`
(t.ex. lägger till mål eller ändrar inställningar), kör `xcodegen generate` igen.
