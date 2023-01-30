/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, see https://www.jetbrains.com/help/space/automation.html
*/

job("Print balance") {
    container(displayName = "ledger-cli", image = "dcycle/ledger:1") {
        args("-f", "2023.dat", "bal")
    }
    container(displayName = "ledger-journal", image = "dcycle/ledger:1") {
        shellScript {
            content = "pwd; ls -al; ledger -f 2023.dat xml > ${'$'}JB_SPACE_FILE_SHARE_PATH/journal.xml"
        }
    }
    container(displayName = "xsltproc", image = "s3v1/xsltproc") {
        shellScript {
            content = "xsltproc -o ${'$'}JB_SPACE_FILE_SHARE_PATH/journal.html ledger-journal.xslt ${'$'}JB_SPACE_FILE_SHARE_PATH/journal.xml"
        }
    }
    container(displayName = "cat", image = "alpine") {
        shellScript {
            content = "ls -al; ls -al ${'$'}JB_SPACE_FILE_SHARE_PATH/"
        }
    }
    container("openjdk:11") {
        kotlinScript { api ->
            api.space().projects.automation.deployments.start(
                project = api.projectIdentifier(),
                targetIdentifier = TargetIdentifier.Key("journal"),
                version = "1.0.0",
                // automatically update deployment status based on a status of a job
                syncWithAutomationJob = true
            )
        }
    }
}
