/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, see https://www.jetbrains.com/help/space/automation.html
*/

job("Print balance") {
    container(displayName = "ledger-cli", image = "dcycle/ledger:1") {
        shellScript {
            content = "ledger -f "${'$'}(date +%Y).dat" bal"
        }
    }
}
job("Upload artifact") {
    container(displayName = "ledger-journal", image = "dcycle/ledger:1") {
        shellScript {
            content = "echo ${'$'}USER ${'$'}HOME; ledger -f 2023.dat xml > ${'$'}JB_SPACE_FILE_SHARE_PATH/journal.xml"
        }
    }
    container(displayName = "xsltproc", image = "s3v1/xsltproc") {
        shellScript {
            content = "xsltproc -o ${'$'}JB_SPACE_FILE_SHARE_PATH/journal.html ledger-journal.xslt ${'$'}JB_SPACE_FILE_SHARE_PATH/journal.xml"
        }
    }
    // Docker image must contain the curl tool
    container("alpine/curl") {
        shellScript {
            content = """
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/journal.html" "https://files.pkg.jetbrains.space/doev/p/finanzen/files/journals/2023.html"
            """
        }
    }
}