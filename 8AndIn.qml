import QtQuick 2.15
import MuseScore 3.0

MuseScore {
    id: root
    menuPath: "Plugins.2 Takte und Tempo am Anfang"
    description: "Fügt zwei Takte am Anfang ein und setzt dort das bisherige Anfangstempo."
    version: "1.0"
    pluginType: "dialog"

    onRun: {
        if (!curScore) {
            return;
        }

        // Save the tempo before inserting measures; cursor.tempo is in
        // quarter notes per second in the MuseScore plugin API.
        const cursor = curScore.newCursor();
        cursor.rewind(Cursor.SCORE_START);
        const initialTempoBpm = Math.round(cursor.tempo * 60);

        curScore.startCmd();
        try {
            // The command needs a selected element. Inserting a measure can
            // change or clear the selection, so select the first element again
            // before each insertion.
            for (let i = 0; i < 2; ++i) {
                cursor.rewind(Cursor.SCORE_START);
                const firstElement = cursor.element;
                if (!firstElement || !curScore.selection.select(firstElement)) {
                    console.warn("Could not select the first score element; stopped after " + i + " inserted measures.");
                    break;
                }
                cmd("insert-measure");
            }

            cursor.rewind(Cursor.SCORE_START);
            const timeSig = newElement(Element.TIMESIG);
            timeSig.timesig = fraction(4, 4);
            cursor.add(timeSig);

            const tempoText = newElement(Element.TEMPO_TEXT);
            tempoText.text = "♩ = " + initialTempoBpm;
            tempoText.tempo = initialTempoBpm / 60.0;
            cursor.add(tempoText);
        } finally {
            curScore.endCmd();
        }

        // A dialog plugin closes by returning from onRun; Qt.quit() can
        // terminate MuseScore 4 itself.
    }
}
