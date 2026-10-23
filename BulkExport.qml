import QtQuick 2.15
import QtQuick.Controls 2.15
import MuseScore 3.0
import FileIO 3.0

MuseScore {
    id: plugin
    property string scoreBaseName: ""
    property int lastBatchExitCode: -1
    width: 480
    height: 260
    title: "Score und Stimmauszüge exportieren"

    menuPath: "Plugins.Bulk export"
    description: "Exportiert Score und Stimmauszüge als PDF und MP3."
    version: "1.0"
    pluginType: "dialog"

    // Use the open in-memory score through MuseScore's plugin API.
    onRun: {
        if (!curScore) {
            info.text = "Kein geöffneter Score."
            return
        }
        let name = "";
        try { name = curScore.scoreName } catch (e) { }
        if (!name) try { name = curScore.fileName } catch (e) { }
        if (!name) name = "Score"
        scoreBaseName = name
        exportDir.text = ""

        let source = "";
        try { source = curScore.path } catch (e) { }
        if (!source) try { source = curScore.metaTag("filePath") } catch (e) { }
        if (source) {
            exportDir.text = pathDirectory(source) + "/Export"
            return
        }

        info.text = "Suche den Score in der Liste zuletzt geöffneter Dateien …"
        if (Qt.platform.os === "windows") {
            const script = "$p=Join-Path $env:LOCALAPPDATA 'MuseScore/MuseScore4/recent_files.json'; if(Test-Path $p){[Console]::Write((Get-Content -Raw $p))}"
            recentProcess.startWithArgs("powershell", ["-NoProfile", "-NonInteractive", "-Command", script])
        } else if (Qt.platform.os === "osx") {
            const script = 'p="$HOME/Library/Application Support/MuseScore/MuseScore4/recent_files.json"; [ -f "$p" ] && cat "$p"'
            recentProcess.startWithArgs("sh", ["-c", script])
        } else {
            const script = 'p="${XDG_DATA_HOME:-$HOME/.local/share}/MuseScore/MuseScore4/recent_files.json"; [ -f "$p" ] && cat "$p"'
            recentProcess.startWithArgs("sh", ["-c", script])
        }
    }

    QProcess { id: process }
    QProcess { id: batchProcess }
    QProcess { id: recentProcess }
    FileIO { id: jobFile }
    FileIO { id: scoreTempFile }

    function collectRecentPaths(value, result) {
        if (typeof value === "string") {
            if (value.indexOf("/") >= 0 || value.indexOf("\\") >= 0)
                result.push(value)
        } else if (Array.isArray(value)) {
            for (let i = 0; i < value.length; ++i)
                collectRecentPaths(value[i], result)
        } else if (value && typeof value === "object") {
            for (let key in value)
                collectRecentPaths(value[key], result)
        }
    }

    function localFilePath(value) {
        let path = value
        if (path.indexOf("file://") === 0) {
            path = path.substring(7)
            if (Qt.platform.os === "windows" && path.charAt(0) === "/")
                path = path.substring(1)
            try { path = decodeURIComponent(path) } catch (e) { }
        }
        return path
    }

    function pathBaseName(path) {
        let name = path.substring(Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\")) + 1)
        const dot = name.lastIndexOf(".")
        return dot > 0 ? name.substring(0, dot) : name
    }

    function pathDirectory(path) {
        return path.substring(0, Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\")))
    }

    function safeFileName(name) {
        const cleaned = String(name).replace(/[<>:"/\\|?*\x00-\x1F]/g, "_").replace(/[. ]+$/g, "")
        return cleaned.length ? cleaned : "Stimmauszug"
    }

    function ensureExportDirectories(base, audio) {
        try {
            if (Qt.platform.os === "windows") {
                const psBase = base.replace(/'/g, "''")
                const psAudio = audio.replace(/'/g, "''")
                const script = "$ErrorActionPreference='Stop'; New-Item -ItemType Directory -Force -Path '" + psBase + "','" + psAudio + "' | Out-Null"
                process.startWithArgs("powershell.exe", ["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command", script])
            } else {
                process.startWithArgs("sh", ["-c", 'mkdir -p "$1" "$2"', "bulk-export", base, audio])
            }
            return process.waitForFinished(15000)
        } catch (e) {
            console.log("Could not create export directories: " + e)
            return false
        }
    }

    function currentMuseScoreExecutable() {
        try {
            if (Qt.application && Qt.application.arguments && Qt.application.arguments.length > 0)
                return String(Qt.application.arguments[0])
        } catch (e) { }
        return ""
    }

    function exportPartsFromCurrentSnapshot(base, audio) {
        const executable = currentMuseScoreExecutable()
        if (!executable)
            return false

        const tempDir = jobFile.tempPath()
        const stamp = Date.now()
        scoreTempFile.source = tempDir + "/musescore-bulk-export-score-" + stamp + ".mscz"
        jobFile.source = tempDir + "/musescore-bulk-export-parts-" + stamp + ".json"

        if (!writeScore(curScore, scoreTempFile.source, "mscz")) {
            console.log("Could not create temporary score snapshot for excerpt export.")
            scoreTempFile.remove()
            return false
        }

        const outputs = [
            [base + "/", ".pdf"],
            [audio + "/", ".mp3"]
        ]
        const job = [{"in": scoreTempFile.source, "out": outputs}]
        if (!jobFile.write(JSON.stringify(job))) {
            console.log("Could not write temporary part export job: " + jobFile.source)
            scoreTempFile.remove()
            return false
        }

        lastBatchExitCode = -1
        try {
            batchProcess.startWithArgs(executable, ["-j", jobFile.source])
            const finished = batchProcess.waitForFinished(600000)
            jobFile.remove()
            scoreTempFile.remove()
            return finished && lastBatchExitCode === 0
        } catch (e) {
            console.log("Part export process failed: " + e)
            jobFile.remove()
            scoreTempFile.remove()
            return false
        }
    }

    function exportCurrentScore() {
        const base = exportDir.text.replace(/[\\/]$/, "")
        const audio = base + "/_Audio"
        if (!ensureExportDirectories(base, audio)) {
            info.text = "Der Exportordner konnte nicht angelegt werden. Bitte den Pfad prüfen."
            runButton.enabled = true
            return
        }

        let succeeded = 0
        let failed = 0
        const scorePdf = base + "/_" + safeFileName(scoreBaseName) + ".pdf"
        const scoreMp3 = audio + "/_" + safeFileName(scoreBaseName) + ".mp3"
        try { if (writeScore(curScore, scorePdf, "pdf")) ++succeeded; else ++failed } catch (e) { ++failed; console.log("Score PDF export failed: " + e) }
        try { if (writeScore(curScore, scoreMp3, "mp3")) ++succeeded; else ++failed } catch (e) { ++failed; console.log("Score MP3 export failed: " + e) }

        let excerpts = []
        try { excerpts = curScore.excerpts } catch (e) { }
        console.error("#############", excerpts)
        console.error("#############")
        console.error("#############")
        console.error("#############")
        console.error("#############", JSON.stringify(excerpts))
        if (excerpts && excerpts.length > 0) {
            if (exportPartsFromCurrentSnapshot(base, audio))
                succeeded += excerpts.length * 2
            else
                failed += excerpts.length * 2
        }

        info.text = failed === 0
            ? "Export abgeschlossen (" + succeeded + " Dateien).\n" + base
            : "Export teilweise fehlgeschlagen: " + succeeded + " erfolgreich, " + failed + " fehlgeschlagen.\n" + base
        runButton.enabled = true
    }

    Connections {
        target: recentProcess
        function onFinished(exitCode, exitStatus) {
            const raw = String(recentProcess.readAllStandardOutput())
            let parsed = null
            try { parsed = JSON.parse(raw) } catch (e) { }

            const candidates = []
            if (parsed !== null)
                collectRecentPaths(parsed, candidates)

            let latestPath = ""
            let matchedPath = ""
            for (let i = 0; i < candidates.length; ++i) {
                const candidate = localFilePath(candidates[i])
                if (!latestPath && candidate.length)
                    latestPath = candidate
                if (pathBaseName(candidate) === scoreBaseName) {
                    matchedPath = candidate
                    break
                }
            }

            if (matchedPath) {
                exportDir.text = pathDirectory(matchedPath) + "/Export"
                info.text = "Exportordner anhand der zuletzt geöffneten Datei vorbelegt."
            } else {
                if (latestPath)
                    exportDir.text = pathDirectory(latestPath) + "/Export"
                info.text = "Kein Eintrag mit dem Score-Namen \"" + scoreBaseName + "\" in der Liste zuletzt geöffneter Dateien gefunden."
            }
        }
    }

    Connections {
        target: batchProcess
        function onFinished(exitCode, exitStatus) {
            plugin.lastBatchExitCode = exitCode
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Label { text: "Exportordner" }
        TextField { id: exportDir; width: parent.width; placeholderText: "Ordner auswählen oder Pfad eingeben" }
        Label { id: info; text: ""; wrapMode: Text.WordWrap; width: parent.width }
        Button {
            id: runButton
            text: "PDF und MP3 exportieren"
            enabled: scoreBaseName.length > 0 && exportDir.text.length > 0
            onClicked: {
                runButton.enabled = false
                info.text = "Export läuft …"
                exportTimer.start()
            }
        }
    }

    Timer {
        id: exportTimer
        interval: 50
        repeat: false
        onTriggered: exportCurrentScore()
    }
}
