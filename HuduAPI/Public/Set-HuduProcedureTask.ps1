function Set-HuduProcedureTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [int]$Id,
        [string]$Name,
        [string]$Description,
        [bool]$Completed,
        [int]$ProcedureId,
        [int]$Position,
        [int]$UserId,
        [string]$DueDate,
        [ValidateSet("unsure", "low", "normal", "high", "urgent")]
        [string]$Priority,
        [int[]]$AssignedUsers,

        # 2.41.0+ only
        [switch]$RunTask
    )

    if (-not $script:HuduVersion) {
        [version]$script:HuduVersion = (Get-HuduAppInfo).version
    }

    if ($script:HuduVersion -lt [version]'2.41.0') {
        if ($PSBoundParameters.ContainsKey('RunTask') -or $PSBoundParameters.ContainsKey('AutoKickoff')) {
            Write-Verbose "RunTask/AutoKickoff are not used on Hudu versions earlier than 2.41.0."
        }

        $legacyParams = @{}
        foreach ($kv in $PSBoundParameters.GetEnumerator()) {
            $legacyParams[$kv.Key] = $kv.Value
        }

        [void]$legacyParams.Remove('RunTask')

        return Set-HuduProcedureTaskLegacy @legacyParams
    }

    return Set-HuduProcedureTaskV241 @PSBoundParameters
}