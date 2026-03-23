function Start-HuduProcedureRun {
    <#
    .SYNOPSIS
    Create a run from an existing company process.

    .DESCRIPTION
    Calls POST /procedures/{id}/kickoff.
    Global templates must first be copied to a company process before kickoff.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ProcedureId,

        [int]$AssetId,

        [string]$Name
    )

    $params = @{}
    if ($PSBoundParameters.ContainsKey('AssetId')) { $params.asset_id = $AssetId }
    if ($PSBoundParameters.ContainsKey('Name'))    { $params.name = $Name }

    try {
        $res = Invoke-HuduRequest -Method POST -Resource "/api/v1/procedures/$ProcedureId/kickoff" -Params $params
        return $res
    }
    catch {
        Write-Warning "Failed to kickoff procedure ID $ProcedureId: $($_.Exception.Message)"
        return $null
    }
}