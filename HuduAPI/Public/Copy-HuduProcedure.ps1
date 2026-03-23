function Copy-HuduProcedure {
    <#
    .SYNOPSIS
    Duplicate an existing process.

    .DESCRIPTION
    Calls POST /api/v1/procedures/{id}/duplicate to create a new company process
    by duplicating an existing process.

    .PARAMETER ProcedureId
    ID of the process to duplicate.

    .PARAMETER CompanyId
    Company ID for the new duplicated process.

    .PARAMETER Name
    Optional new name for the duplicated process.

    .PARAMETER Description
    Optional new description for the duplicated process.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('Id')]
        [int]$ProcedureId,

        [Parameter(Mandatory)]
        [int]$CompanyId,

        [string]$Name,

        [string]$Description
    )

    $params = @{
        company_id = $CompanyId
    }

    if ($PSBoundParameters.ContainsKey('Name'))        { $params.name = $Name }
    if ($PSBoundParameters.ContainsKey('Description')) { $params.description = $Description }

    try {
        $res = Invoke-HuduRequest -Method POST -Resource "/api/v1/procedures/$ProcedureId/duplicate" -Params $params
        return ($res.procedure ?? $res)
    }
    catch {
        Write-Warning "Failed to duplicate procedure ID $ProcedureId $($_.Exception.Message)"
        return $null
    }
}