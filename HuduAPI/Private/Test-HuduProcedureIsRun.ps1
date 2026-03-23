function Test-HuduProcedureIsRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ProcedureId
    )

    $procedure = Get-HuduProcedure -Id $ProcedureId
    if (-not $procedure) {
        throw "Procedure ID $ProcedureId was not found."
    }

    return (($procedure.run ?? $false) -eq $true)
}