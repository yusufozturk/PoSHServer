# You can also use html files as templates
# Let's import one of them
# But we only get content of html files, you can't execute Powershell in them.
@"
$(Write-Host Hello World Example4!)
$(Get-Content "$HomeDirectory\index.htm")
"@