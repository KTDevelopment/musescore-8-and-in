import QtQuick 2.15
import MuseScore 3.0
import Muse.Ui
import Muse.UiComponents

MuseScore {
    id: root
    width: 460
    height: 370
    title: "8AndIn"

    menuPath: "Plugins.8AndIn"
    description: "Fügt zwei Takte in der gewählten Taktart und das bisherige Anfangstempo ein."
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
        const countInNumerator = parseInt(numeratorInput.currentValue, 10);
        const countInDenominator = parseInt(denominatorInput.currentValue, 10);

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
            // measure 3, then set the two new measures to the chosen meter.
            cursor.rewind(Cursor.SCORE_START);
            cursor.nextMeasure();
            cursor.nextMeasure();
            const restoredTimeSig = newElement(Element.TIMESIG);
            restoredTimeSig.timesig = fraction(originalNumerator, originalDenominator);
            cursor.add(restoredTimeSig);

            cursor.rewind(Cursor.SCORE_START);
            const timeSig = newElement(Element.TIMESIG);
            timeSig.timesig = fraction(countInNumerator, countInDenominator);
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
        spacing: 22

        Text {
            width: 420
            text: "Fügt zwei Takte in der gewählten Taktart ein und setzt das bisherige Tempo an den Partituranfang."
            color: "#ffffff"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Item {
            width: 1
            height: 6
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                text: "Taktart:"
                font.pixelSize: 18
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledDropdown {
                id: numeratorInput
                model: [
                    { "text": "1", "value": 1 }, { "text": "2", "value": 2 },
                    { "text": "3", "value": 3 }, { "text": "4", "value": 4 },
                    { "text": "5", "value": 5 }, { "text": "6", "value": 6 },
                    { "text": "7", "value": 7 }, { "text": "8", "value": 8 },
                    { "text": "9", "value": 9 }, { "text": "10", "value": 10 },
                    { "text": "11", "value": 11 }, { "text": "12", "value": 12 },
                    { "text": "13", "value": 13 }, { "text": "14", "value": 14 },
                    { "text": "15", "value": 15 }, { "text": "16", "value": 16 }
                ]
                currentIndex: 3
                width: 76
                onActivated: function(index, _) {
                    currentIndex = index
                }
            }

            Text {
                text: "/"
                font.pixelSize: 22
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledDropdown {
                id: denominatorInput
                model: [
                    { "text": "2", "value": 2 }, { "text": "4", "value": 4 },
                    { "text": "8", "value": 8 }, { "text": "16", "value": 16 },
                    { "text": "32", "value": 32 }
                ]
                currentIndex: 1
                width: 76
                onActivated: function(index, _) {
                    currentIndex = index
                }
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

        Item {
            width: 1
            height: 8
        }

        Rectangle {
            width: 420
            height: 58
            radius: 6
            color: "#3a3f45"
            border.color: "#62676d"
            border.width: 1

            Text {
                anchors.fill: parent
                anchors.margins: 8
                text: "Bitte speichere deine Partitur vor dem Einfügen (⌘S)."
                color: "#d7d9dc"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}
