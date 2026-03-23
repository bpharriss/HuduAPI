function New-HuduProcedureFromTemplate {
    <#
    .SYNOPSIS
    Create a new process from a global template.

    .DESCRIPTION
    Calls POST /api/v1/procedures/{id}/create_from_template.

    The source procedure must be a global template.

    Behavior:
    - If CompanyId is supplied, creates a company-specific process.
    - If CompanyId is omitted, creates another global template copy.

    This cmdlet creates a process/template copy only. It does not create a run.

    .PARAMETER ProcedureId
    ID of the global template to copy from.

    .PARAMETER CompanyId
    Optional company ID for the new process.
    If omitted, a new global template copy is created.

    .PARAMETER Name
    Optional new name for the copied process.

    .PARAMETER Description
    Optional new description for the copied process.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('Id')]
        [int]$ProcedureId,

        [int]$CompanyId,

        [string]$Name,

        [string]$Description
    )

    $procedureContext = Get-HuduProcedureContext -ProcedureId $ProcedureId
    if (-not $procedureContext) {
        throw "Could not determine procedure context for procedure ID $ProcedureId."
    }

    if ($procedureContext.IsRun) {
        Write-Warning "Procedure ID $ProcedureId is a run. Only global templates can be copied with create_from_template."
        return $null
    }

    if (-not $procedureContext.IsGlobal) {
        Write-Warning "Procedure ID $ProcedureId is not a global template. Only global templates can be copied with create_from_template."
        return $null

    $params = @{}
    if ($PSBoundParameters.ContainsKey('CompanyId'))   { $params.company_id = $CompanyId }
    if ($PSBoundParameters.ContainsKey('Name'))        { $params.name = $Name }
    if ($PSBoundParameters.ContainsKey('Description')) { $params.description = $Description }

    try {
        $res = Invoke-HuduRequest -Method POST -Resource "/api/v1/procedures/$ProcedureId/create_from_template" -Params $params
        return ($res.procedure ?? $res)
    }
    catch {
        Write-Warning "Failed to create procedure from template ID $ProcedureId- $($_.Exception.Message)"
        return $null
    }
}
}