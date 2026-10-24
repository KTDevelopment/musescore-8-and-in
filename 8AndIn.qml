import QtQuick 2.15
import MuseScore 3.0
import Muse.UiComponents

MuseScore {
    id: root
    width: 460
    height: 260
    title: "8AndIn"

    menuPath: "Plugins.8AndIn"
    description: "Fügt zwei 4/4-Takte und das bisherige Anfangstempo ein."
    version: "1.0"
    pluginType: "dialog"

    function insertCountIn() {
        if (!curScore) {
            quit();
            return;
        }

        // Cursor tempo is expressed in quarter notes per second.
        const cursor = curScore.newCursor();
        cursor.rewind(Cursor.SCORE_START);
        const initialTempoBpm = Math.round(cursor.tempo * 60);
        const originalTimeSig = cursor.measure.timesigNominal;
        const originalNumerator = originalTimeSig.numerator;
        const originalDenominator = originalTimeSig.denominator;

        curScore.startCmd();
        try {
            // The insert command needs a selected element. The selection may
            // change after insertion, so select the first element each time.
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

            // Restore the original meter in the original first measure, now
            // measure 3, then set the two new measures to 4/4.
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

        quit();
    }

    function removeCountIn() {
        if (!curScore) {
            quit();
            return;
        }

        // The third measure is the original first measure. Select the time
        // from the score start up to (but not including) that measure.
        const firstMeasure = curScore.firstMeasure;
        const secondMeasure = firstMeasure ? firstMeasure.nextMeasure : null;
        const thirdMeasure = secondMeasure ? secondMeasure.nextMeasure : null;
        if (!thirdMeasure || !thirdMeasure.firstSegment) {
            console.warn("Could not locate the first two measures to remove.");
            quit();
            return;
        }

        const startTick = firstMeasure.firstSegment.tick;
        const endTick = thirdMeasure.firstSegment.tick;
        if (!curScore.selection.selectRange(startTick, endTick, 0, curScore.nstaves)) {
            console.warn("Could not select the first two measures.");
            quit();
            return;
        }

        // The action has no handler while the plugin dialog owns the UI
        // context. Close the dialog first, then dispatch in the score context.
        deleteRangeTimer.start();
        quit();
    }

    Timer {
        id: deleteRangeTimer
        interval: 250
        repeat: false
        onTriggered: cmd("time-delete")
    }

    onRun: {
        // Keep the dialog open; the score changes only after the button click.
    }

    Column {
        anchors.centerIn: parent
        spacing: 14

        Rectangle {
            width: 420
            height: 86
            radius: 8
            color: "#fff0cf"
            border.color: "#d49a2a"
            border.width: 2

            Text {
                anchors.fill: parent
                anchors.margins: 12
                text: "Bitte speichere deine Partitur vor dem Einfügen (⌘S). Das Plugin kann ungespeicherte Änderungen nicht erkennen."
                color: "#49350b"
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }
        }

        FlatButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Einzählen einfügen"
            accentButton: true
            onClicked: root.insertCountIn()
        }

        FlatButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Einzählen entfernen"
            onClicked: root.removeCountIn()
        }
    }
}
