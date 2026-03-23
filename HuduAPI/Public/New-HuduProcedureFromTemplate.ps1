function New-HuduProcedureFromTemplate {
    <#
    .SYNOPSIS
    Create a new process from a global template.

    .DESCRIPTION
    Calls POST /procedures/{id}/create_from_template.
    If CompanyId is supplied, creates a company-specific process.
    If not, creates another global template copy.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ProcedureId,

        [Nullable[int]]$CompanyId,

        [string]$Name,

        [string]$Description
    )

    $params = @{}
    if ($PSBoundParameters.ContainsKey('CompanyId'))   { $params.company_id = $CompanyId }
    if ($PSBoundParameters.ContainsKey('Name'))        { $params.name = $Name }
    if ($PSBoundParameters.ContainsKey('Description')) { $params.description = $Description }

    try {
        $res = Invoke-HuduRequest -Method POST -Resource "/api/v1/procedures/$ProcedureId/create_from_template" -Params $params
        return ($res.procedure ?? $res)
    }
    catch {
        Write-Warning "Failed to create procedure from template ID $ProcedureId: $($_.Exception.Message)"
        return $null
    }
}