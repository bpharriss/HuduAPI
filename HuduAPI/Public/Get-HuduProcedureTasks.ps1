function Get-HuduProcedureTasks {
    <#
    .SYNOPSIS
    Retrieve procedure tasks.
    #>
    [CmdletBinding()]
    param(
        [int]$Id,
        [int]$ProcedureId,
        [string]$Name,
        [int]$CompanyId
    )

    if ($Id) {
        try {
            $res = Invoke-HuduRequest -Method GET -Resource "/api/v1/procedure_tasks/$Id"
            return ($res.procedure_task ?? $res)
        }
        catch {
            Write-Warning "Failed to retrieve procedure task ID $Id: $($_.Exception.Message)"
            return $null
        }
    }

    $params = @{}
    if ($PSBoundParameters.ContainsKey('ProcedureId')) { $params.procedure_id = $ProcedureId }
    if ($PSBoundParameters.ContainsKey('Name'))        { $params.name = $Name }
    if ($PSBoundParameters.ContainsKey('CompanyId'))   { $params.company_id = $CompanyId }

    Invoke-HuduRequestPaginated -HuduRequest @{
        Method   = 'GET'
        Resource = '/api/v1/procedure_tasks'
        Params   = $params
    } -Property procedure_tasks
}