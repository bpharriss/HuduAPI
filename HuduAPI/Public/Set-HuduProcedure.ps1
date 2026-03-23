function Set-HuduProcedure {
    <#
    .SYNOPSIS
    Update an existing Hudu process or run.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Id,

        [string]$Name,
        [string]$Description,
        [Nullable[int]]$CompanyId,
        [Nullable[bool]]$Archived
    )

    $procedure = @{}

    if ($PSBoundParameters.ContainsKey('Name'))        { $procedure.name = $Name }
    if ($PSBoundParameters.ContainsKey('Description')) { $procedure.description = $Description }
    if ($PSBoundParameters.ContainsKey('CompanyId'))   { $procedure.company_id = $CompanyId }
    if ($PSBoundParameters.ContainsKey('Archived'))    { $procedure.archived = $Archived }

    if ($procedure.Count -eq 0) {
        throw "No fields were supplied to update."
    }

    $payload = $procedure | ConvertTo-Json -Depth 10

    try {
        $res = Invoke-HuduRequest -Method PUT -Resource "/api/v1/procedures/$Id" -Body $payload
        return ($res.procedure ?? $res)
    }
    catch {
        Write-Warning "Failed to update procedure ID $Id: $($_.Exception.Message)"
        return $null
    }
}