/**
* JetBrains Space Automation
* This Kotlin-script file lets you automate build activities
* For more info, see https://www.jetbrains.com/help/space/automation.html
*/

job("Print balance") {
    container(displayName = "ledger-cli", image = "dcycle/ledger") {
        args("-f", "/mnt/space/work/ledger-journal/2021.dat", "bal")
    }
}
