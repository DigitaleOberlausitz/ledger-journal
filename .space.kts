/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, see https://www.jetbrains.com/help/space/automation.html
*/

job("Print balance") {
    container(displayName = "ledger-cli", image = "dcycle/ledger:1") {
        shellScript {
            content = """
                ledger -f "${'$'}(date +%Y).dat" bal
            """
        }
    }
}
job("Upload journal") {
    container(displayName = "ledger-journal", image = "dcycle/ledger:1") {
        shellScript {
            content = """
                ledger -y %F -f "2018.dat" xml > "${'$'}JB_SPACE_FILE_SHARE_PATH/2018.xml"
                ledger -y %F -f "2019.dat" xml > "${'$'}JB_SPACE_FILE_SHARE_PATH/2019.xml"
                ledger -y %F -f "2020.dat" xml > "${'$'}JB_SPACE_FILE_SHARE_PATH/2020.xml"
                ledger -y %F -f "2021.dat" xml > "${'$'}JB_SPACE_FILE_SHARE_PATH/2021.xml"
                ledger -y %F -f "2022.dat" xml > "${'$'}JB_SPACE_FILE_SHARE_PATH/2022.xml"
                ledger -y %F -f "${'$'}(date +%Y).dat" xml > "${'$'}JB_SPACE_FILE_SHARE_PATH/${'$'}(date +%Y).xml"
            """
        }
    }
    container(displayName = "xsltproc", image = "s3v1/xsltproc") {
        shellScript {
            content = """
                xsltproc -o "${'$'}JB_SPACE_FILE_SHARE_PATH/2018.html" ledger-journal.xslt "${'$'}JB_SPACE_FILE_SHARE_PATH/2018.xml"
                xsltproc -o "${'$'}JB_SPACE_FILE_SHARE_PATH/2019.html" ledger-journal.xslt "${'$'}JB_SPACE_FILE_SHARE_PATH/2019.xml"
                xsltproc -o "${'$'}JB_SPACE_FILE_SHARE_PATH/2020.html" ledger-journal.xslt "${'$'}JB_SPACE_FILE_SHARE_PATH/2020.xml"
                xsltproc -o "${'$'}JB_SPACE_FILE_SHARE_PATH/2021.html" ledger-journal.xslt "${'$'}JB_SPACE_FILE_SHARE_PATH/2021.xml"
                xsltproc -o "${'$'}JB_SPACE_FILE_SHARE_PATH/2022.html" ledger-journal.xslt "${'$'}JB_SPACE_FILE_SHARE_PATH/2022.xml"
                xsltproc -o "${'$'}JB_SPACE_FILE_SHARE_PATH/${'$'}(date +%Y).html" ledger-journal.xslt "${'$'}JB_SPACE_FILE_SHARE_PATH/${'$'}(date +%Y).xml"
            """
        }
    }
    container("alpine/curl") {
        shellScript {
            content = """
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/2018.html" "https://files.pkg.jetbrains.space/doev/p/finanzen/journals/"
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/2019.html" "https://files.pkg.jetbrains.space/doev/p/finanzen/journals/"
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/2020.html" "https://files.pkg.jetbrains.space/doev/p/finanzen/journals/"
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/2021.html" "https://files.pkg.jetbrains.space/doev/p/finanzen/journals/"
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/2022.html" "https://files.pkg.jetbrains.space/doev/p/finanzen/journals/"
                curl -i -H "Authorization: Bearer ${'$'}JB_SPACE_CLIENT_TOKEN" -F file=@"${'$'}JB_SPACE_FILE_SHARE_PATH/${'$'}(date +%Y).html" "https://files.pkg.jetbrains.space/doev/p/finanzen/journals/"
            """
        }
    }
}