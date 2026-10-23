# MuseScore Bulk Export

Ein MuseScore-Studio-4-Plugin zum Exportieren eines geöffneten Scores und seiner bereits angelegten Stimmauszüge als PDF und MP3.

## Ausgabe

Im gewählten Exportordner wird folgende Struktur erstellt. Standardmäßig wird `Export` neben der zuletzt geöffneten passenden Score-Datei vorgeschlagen; der Ordner kann im Plugin geändert werden:

```text
Export/
  _<Dateiname des Scores>.pdf
  <Name des Stimmauszugs>.pdf
  _Audio/
    _<Dateiname des Scores>.mp3
    <Name des Stimmauszugs>.mp3
```

Die Part-Dateien verwenden den von MuseScore im Stimmauszug hinterlegten Namen. Der Score wird direkt über MuseScores Plugin-API exportiert. Für die Stimmauszüge erstellt das Plugin kurzzeitig eine Score-Kopie des aktuell geöffneten Inhalts und lässt MuseScore daraus die Part-Dateien rendern, da `writeScore()` nur den ausgewählten Score schreiben kann. Die Liste zuletzt geöffneter Dateien dient nur dazu, den Exportordner vorzubelegen, falls die Plugin-API keinen Score-Pfad liefert.

## Installation

1. `BulkExport.qml` in den MuseScore-Plugin-Ordner kopieren.
2. MuseScore Studio neu starten.
3. Im Plugin-Manager **Bulk export** aktivieren und anschließend über **Plugins → Bulk export** starten.

Typische Plugin-Ordner sind `~/Documents/MuseScore4/Plugins` unter macOS und Windows oder `~/.local/share/MuseScore/MuseScore4/Plugins` unter Linux.

## Hinweise

- Wenn kein passender Eintrag in der Liste zuletzt geöffneter Dateien gefunden wird, kann der Exportordner manuell eingetragen werden.
- MP3-Rendering kann abhängig von Score-Länge und Soundprofil einige Zeit beanspruchen.
- Vorhandene Dateien mit denselben Namen werden beim Export überschrieben.
