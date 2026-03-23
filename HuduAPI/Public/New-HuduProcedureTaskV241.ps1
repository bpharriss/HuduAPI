function New-HuduProcedureTaskV241 {
    <#
    .SYNOPSIS
    Create a new procedure task.

    .DESCRIPTION
    Creates a task for either a process template or a run.
    Some fields only make sense on runs (priority, users, due dates).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$ProcedureId,

        [string]$Description,

        [int]$Position,

        [ValidateSet("unsure", "low", "normal", "high", "urgent")]
        [string]$Priority,

        [Nullable[int]]$UserId,

        [int[]]$AssignedUsers,

        [datetime]$DueDate,

        [switch]$RunTask
    )

    $isRun = Test-HuduProcedureIsRun -ProcedureId $ProcedureId
    $runParamsPresent = $false
    foreach ($field in 'Priority','UserId','AssignedUsers','DueDate') {
        if ($PSBoundParameters.ContainsKey($field)) {
            $runParamsPresent = $true
            break
        }
    }

    if ($RunTask -and -not $isRun -and $runParamsPresent) {
        Write-Verbose "Procedure ID $ProcedureId is not a run. Kicking off a run first."
        $run = Start-HuduProcedure -ProcedureId $ProcedureId
        if (-not $run -or -not $run.id) {
            throw "Failed to kick off a run for procedure ID $ProcedureId."
        }
        $ProcedureId = [int]$run.id
        $isRun = $true
    }

    $task = @{
        name         = $Name
        procedure_id = $ProcedureId
    }

    if ($PSBoundParameters.ContainsKey('Description')) { $task.description = $Description }
    if ($PSBoundParameters.ContainsKey('Position'))    { $task.position = $Position }

    if ($isRun) {
        if ($PSBoundParameters.ContainsKey('Priority'))      { $task.priority = $Priority }
        if ($PSBoundParameters.ContainsKey('UserId'))        { $task.user_id = $UserId }
        if ($PSBoundParameters.ContainsKey('AssignedUsers')) { $task.assigned_users = $AssignedUsers }
        if ($PSBoundParameters.ContainsKey('DueDate')) {
            $task.due_date = $DueDate.ToString('yyyy-MM-dd')
        }
    } else {
        foreach ($field in 'Priority','UserId','AssignedUsers','DueDate') {
            if ($PSBoundParameters.ContainsKey($field)) {
                Write-Warning "$field can only be set on tasks for runs. It was ignored for template/process task creation. To Automatically Switch to a run task, use the -RunTask switch."
            }
        }
    }

    $payload = @{ procedure_task = $task } | ConvertTo-Json -Depth 10

    try {
        $res = Invoke-HuduRequest -Method POST -Resource "/api/v1/procedure_tasks" -Body $payload
        return ($res.procedure_task ?? $res)
    }
    catch {
        Write-Warning "Failed to create procedure task '$Name': $($_.Exception.Message)"
        return $null
    }
}