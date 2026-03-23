function Get-HuduProcedureContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ProcedureId
    )

    $procedure = Get-HuduProcedures -Id $ProcedureId
    if (-not $procedure) {
        return $null
    }

    $isRun = $procedure.run -eq $true

    $processType = [string]$procedure.process_type
    $companyIdPresent = -not [string]::IsNullOrWhiteSpace([string]$procedure.company_id)

    $isGlobal = (
        $processType -ieq 'global' -or
        (-not $companyIdPresent -and -not $isRun)
    )

    $isCompanyProcess = (
        -not $isRun -and (
            $processType -ieq 'company' -or
            $companyIdPresent
        )
    )

    $canKickoff = $isCompanyProcess

    [pscustomobject]@{
        Procedure      = $procedure
        IsRun          = $isRun
        IsGlobal       = $isGlobal
        IsCompany      = $isCompanyProcess
        ProcessType    = $processType
        CompanyId      = if ($companyIdPresent) { [int]$procedure.company_id } else { $null }
        CanKickoff     = $canKickoff
    }
}