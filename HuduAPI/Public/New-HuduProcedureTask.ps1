function New-HuduProcedureTask {
    <#
    .SYNOPSIS
    Create a new procedure task

    .DESCRIPTION
    Creates a new task associated with a procedure.
    On Hudu versions prior to 2.41.0, this uses the legacy task behavior.
    On Hudu 2.41.0 and later, run-aware behavior is applied.

    .PARAMETER Name
    Name of the task

    .PARAMETER ProcedureId
    ID of the procedure or run to attach the task to

    .PARAMETER Description
    Optional task description

    .PARAMETER Priority
    Optional priority level

    .PARAMETER UserId
    Optional single user assignment

    .PARAMETER AssignedUsers
    Optional array of user IDs to assign

    .PARAMETER DueDate
    Optional due date (YYYY-MM-DD)

    .PARAMETER Position
    Optional ordering position
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [int]$ProcedureId,
        [string]$Description,
        [ValidateSet("unsure", "low", "normal", "high", "urgent")]
        [string]$Priority,
        [int]$UserId,
        [int[]]$AssignedUsers,
        [string]$DueDate,
        [int]$Position,
        [switch]$RunTask # only used for 2.41.0+, otherwise ignored.
    )

    if (-not $script:HuduVersion) {
        [version]$script:HuduVersion = (Get-HuduAppInfo).version
    }

    if ($script:HuduVersion -lt [version]'2.41.0') {
        return New-HuduProcedureTaskLegacy @PSBoundParameters
    }

    return New-HuduProcedureTaskV241 @PSBoundParameters
}