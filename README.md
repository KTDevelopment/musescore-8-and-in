# MuseScore-Plugin 8AndIn

**8AndIn** ist ein Plugin für MuseScore Studio 4. Es ergänzt den Anfang einer Partitur um zwei 4/4-Takte und setzt das bisherige Anfangstempo an den neuen Partituranfang.

## Funktionen

- **Einzählen einfügen:** Fügt zwei Takte vor dem bisherigen ersten Takt ein. Die neuen Takte erhalten 4/4. Die ursprüngliche Taktart wird ab dem bisherigen ersten Takt fortgesetzt und das bisherige Anfangstempo vorne eingesetzt.
- **Einzählen entfernen:** Soll die beiden vorderen Takte samt neuem Tempotext und 4/4-Taktart entfernen.

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
