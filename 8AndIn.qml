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
            quit();
            return;
        }

        // Save the tempo before inserting measures; cursor.tempo is in
        // quarter notes per second in the MuseScore plugin API.
        const cursor = curScore.newCursor();
        cursor.rewind(Cursor.SCORE_START);
        const initialTempoBpm = Math.round(cursor.tempo * 60);
        const originalTimeSig = cursor.measure.timesigNominal;
        const originalNumerator = originalTimeSig.numerator;
        const originalDenominator = originalTimeSig.denominator;

        curScore.startCmd();
        try {
            // The command needs a selected element. Inserting a measure can
            // change or clear the selection, so select the first element again
            // before each insertion.
            for (let i = 0; i < 2; ++i) {
                cursor.rewind(Cursor.SCORE_START);
                const firstElement = cursor.element;
                let selectableElement = firstElement;
                if (firstElement && firstElement.type === Element.CHORD && firstElement.notes.length > 0) {
                    selectableElement = firstElement.notes[0];
                }
                if (!selectableElement || !curScore.selection.select(selectableElement)) {
                    console.warn("Could not select the first score element; stopped after " + i + " inserted measures.");
                    break;
                }
                cmd("insert-measure");
            }

            // The original first measure is now measure 3. Restore its meter
            // there before setting the two newly inserted measures to 4/4.
            cursor.rewind(Cursor.SCORE_START);
            cursor.nextMeasure();
            cursor.nextMeasure();
            const restoredTimeSig = newElement(Element.TIMESIG);
            restoredTimeSig.timesig = fraction(originalNumerator, originalDenominator);
            cursor.add(restoredTimeSig);

            cursor.rewind(Cursor.SCORE_START);
            const timeSig = newElement(Element.TIMESIG);
            timeSig.timesig = fraction(4, 4);
            cursor.add(timeSig);

            cursor.rewind(Cursor.SCORE_START);
            const tempoText = newElement(Element.TEMPO_TEXT);
            tempoText.text = "♩ = " + initialTempoBpm;
            tempoText.tempo = initialTempoBpm / 60.0;
            cursor.add(tempoText);
        } finally {
            curScore.endCmd();
        }

        // Close this plugin after the undoable score command has finished.
        // In MuseScore 4, quit() closes the plugin; Qt.quit() may close MuseScore.
        quit();
    }
}
