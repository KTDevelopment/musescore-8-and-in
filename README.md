# MuseScore-Plugin 8AndIn

**8AndIn** ist ein Plugin für MuseScore Studio 4. Es ergänzt den Anfang einer Partitur um zwei Takte in einer einstellbaren Taktart und setzt das bisherige Anfangstempo an den neuen Partituranfang.

## Funktionen

- **Taktart auswählen:** Zähler von 1 bis 16 und Nenner 2, 4, 8, 16 oder 32. Vorgabe ist 4/4.
- **Einzählen einfügen:** Fügt zwei Takte mit der gewählten Taktart vor dem bisherigen ersten Takt ein. Die ursprüngliche Taktart wird ab dem bisherigen ersten Takt fortgesetzt und das bisherige Anfangstempo vorne eingesetzt.
- **Einzählen entfernen:** Soll die beiden vorderen Takte samt neuem Tempotext und Taktart entfernen.

> **Vor dem Einfügen speichern:** Speichere die Partitur mit **⌘S**. Das Plugin kann nicht erkennen, ob Änderungen ungespeichert sind.

## Installation

1. Kopiere `8AndIn.qml` in den MuseScore-Plugin-Ordner. Der Standardordner ist:
   - macOS: `~/Documents/MuseScore4/Plugins`
   - Windows: `~/Documents/MuseScore4/Plugins`
   - Linux: `~/Documents/MuseScore4/Plugins`
2. Starte MuseScore Studio neu, damit das Plugin geladen wird.
3. Öffne **Home → Plugins** oder **Plugins → Plugin-Manager**.
4. Aktiviere **8AndIn**.
5. Öffne eine Partitur und starte das Plugin über **Plugins → 8AndIn**.

## GitHub-Releases

Der Workflow `.github/workflows/release.yml` erstellt bei jedem Push auf den Branch `relase` automatisch ein GitHub-Release. Der Release-Tag und -Titel verwenden exakt die Version aus `VERSION` (zum Beispiel `1.0.0`), ohne Commit-Hash. Erhöhe `VERSION` vor jedem Push, der ein neues Release erzeugen soll; eine bereits veröffentlichte Version führt zu einem fehlgeschlagenen Workflow. Das Release enthält `8AndIn.qml`, diese README und die Versionsdatei.
