# Installationsanleitung

## Entwicklungsumgebung einrichten

### 1. Godot Engine installieren

Download von: https://godotengine.org/download

Unterstützte Versionen: 4.2, 4.3, 4.4

### 2. Projekt klonen und öffnen

```bash
git clone <repository-url>
cd medieval-tower-defense
```

Godot Engine starten und das Projekt über `project.godot` importieren.

### 3. Im Editor testen

- F5: Spiel starten
- F6: Aktuelle Szene starten

## Android-Build erstellen

### Voraussetzungen

- Android SDK installiert
- Java JDK 17 installiert
- Godot Export-Templates heruntergeladen

### SDK-Konfiguration

1. Editor > Editor Settings > Export > Android
2. Android SDK Path eintragen
3. Debug Keystore konfigurieren (wird automatisch erzeugt)

### Export-Schritte

1. Projekt > Exportieren
2. "Android" Preset auswählen (vorkonfiguriert in `export_presets.cfg`)
3. Für Debug: "Export Project" als .apk
4. Für Release: Eigenen Keystore konfigurieren

### Release-Keystore erstellen

```bash
keytool -genkey -v -keystore release.keystore \
  -alias medievaltd -keyalg RSA -keysize 2048 \
  -validity 10000
```

### Auf Gerät installieren

```bash
adb install medieval-tower-defense.apk
```

## Projektstruktur

```
medieval_tower_defense/
├── scripts/              # Spiellogik
│   ├── Enemy.gd         # Feind-KI und Pfadverfolgung
│   ├── GameManager.gd   # Spielzustand und Wellenverwaltung
│   ├── LevelGenerator.gd # Prozedurale Level-Erstellung
│   ├── MainGame.gd      # Hauptszene-Controller
│   ├── MainMenu.gd      # Menüsystem
│   ├── Tower.gd         # Turmsysteme und Kampf
│   └── UIManager.gd     # Benutzeroberfläche
├── scenes/              # Godot-Szenendateien
│   ├── MainGame.tscn    # Spielszene
│   └── MainMenu.tscn    # Menüszene
├── assets/              # Ressourcen
│   ├── sprites/         # Grafiken (Platzhalter)
│   └── audio/           # Audio (noch leer)
├── project.godot        # Godot-Projektkonfiguration
├── export_presets.cfg   # Export-Einstellungen
└── icon.png             # App-Icon
```

## Fehlerbehebung

### Häufige Probleme

**Projekt lässt sich nicht öffnen:**
- Godot-Version prüfen (mind. 4.2)
- Alle Dateien vorhanden?

**Android-Export schlägt fehl:**
- Android SDK Pfad prüfen
- JDK 17 installiert?
- Export-Templates heruntergeladen?

**Performance-Probleme:**
- Mobile Renderer aktiviert (Standard)
- Gerätekompatibilität prüfen (arm64-v8a)
