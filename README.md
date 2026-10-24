# MuseScore-Plugin 8AndIn

**8AndIn** ist ein Plugin für MuseScore Studio 4. Es ergänzt den Anfang einer Partitur um zwei Takte in einer einstellbaren Taktart und setzt das bisherige Anfangstempo an den neuen Partituranfang.

## Funktionen

- **Taktart auswählen:** Zähler von 1 bis 16 und Nenner 2, 4, 8, 16 oder 32. Vorgabe ist 4/4.
- **Einzählen einfügen:** Fügt zwei Takte mit der gewählten Taktart vor dem bisherigen ersten Takt ein. Die ursprüngliche Taktart wird ab dem bisherigen ersten Takt fortgesetzt und das bisherige Anfangstempo vorne eingesetzt.
- **Einzählen entfernen:** Soll die beiden vorderen Takte samt neuem Tempotext und Taktart entfernen.

> **Vor dem Einfügen speichern:** Speichere die Partitur mit **⌘S**. Das Plugin kann nicht erkennen, ob Änderungen ungespeichert sind.

## Installation

1. Lade `8AndIn-<VERSION>.zip` aus dem gewünschten GitHub-Release herunter und entpacke es.
2. Verschiebe oder kopiere den entpackten Ordner in den MuseScore-Plugin-Ordner:
   - macOS: `~/Documents/MuseScore4/Plugins`
   - Windows: `%HOMEPATH%\Documents\MuseScore4\Plugins`
   - Linux: `~/Documents/MuseScore4/Plugins`
3. Starte MuseScore Studio neu, damit das Plugin geladen wird.
4. Öffne **Home → Plugins** oder **Plugins → Plugin-Manager**.
5. Aktiviere **8AndIn**.
6. Öffne eine Partitur und starte das Plugin über **Plugins → 8AndIn**.

## GitHub-Releases

Der Workflow `.github/workflows/release.yml` erstellt bei jedem Push auf den Branch `relase` automatisch ein GitHub-Release. 
Der Release-Tag und -Titel verwenden exakt die Version aus `VERSION` (zum Beispiel `1.0.0`), ohne Commit-Hash. 
Erhöhe `VERSION` vor jedem Push, der ein neues Release erzeugen soll; eine bereits veröffentlichte Version führt zu einem fehlgeschlagenen Workflow. 
Bearbeite vor dem Push `RELEASE_NOTES.md` und bei Bedarf `INSTALLATION.md`; der Workflow fügt beide Dateien zur Release-Beschreibung zusammen. 
Als einziges Release-Asset wird `8AndIn-<VERSION>.zip` angehängt. 
Es enthält Plugin, Dokumentation, Release-Notes, Versionsdatei und Lizenz.
