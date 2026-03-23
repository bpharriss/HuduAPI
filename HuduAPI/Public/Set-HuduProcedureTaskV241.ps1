function Set-HuduProcedureTaskV241 {
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
        [switch]$RunTask
    )

    $existingTask = Get-HuduProcedureTasks -Id $Id
    if (-not $existingTask) {
        throw "Could not retrieve procedure task ID $Id."
    }

    $targetProcedureId = if ($PSBoundParameters.ContainsKey('ProcedureId')) {
        $ProcedureId
    } else {
        $existingTask.procedure_id
    }

    $isRun = $false
    if ($targetProcedureId) {
        $isRun = Test-HuduProcedureIsRun -ProcedureId $targetProcedureId
    }

    $runParamsPresent = @('Priority','UserId','AssignedUsers','DueDate').Where{
        $PSBoundParameters.ContainsKey($_)
    }.Count -gt 0

    if ($RunTask -and -not $isRun) {
        if ($AutoKickoff) {
            $run = Start-HuduProcedure -ProcedureId $targetProcedureId
            if (-not $run -or -not $run.id) {
                throw "Failed to kick off a run for procedure ID $targetProcedureId."
            }
            $targetProcedureId = [int]$run.id
            $isRun = $true
        }
        else {
            throw "Task ID $Id is not associated with a run. Pass a run ProcedureId or use -AutoKickoff."
        }
    }

    $task = @{}
    if ($PSBoundParameters.ContainsKey('Name'))        { $task.name = $Name }
    if ($PSBoundParameters.ContainsKey('Description')) { $task.description = $Description }
    if ($PSBoundParameters.ContainsKey('Completed'))   { $task.completed = $Completed }
    if ($PSBoundParameters.ContainsKey('ProcedureId')) { $task.procedure_id = $targetProcedureId }
    if ($PSBoundParameters.ContainsKey('Position'))    { $task.position = $Position }

    if ($isRun) {
        if ($PSBoundParameters.ContainsKey('Priority'))      { $task.priority = $Priority }
        if ($PSBoundParameters.ContainsKey('UserId'))        { $task.user_id = $UserId }
        if ($PSBoundParameters.ContainsKey('AssignedUsers')) { $task.assigned_users = $AssignedUsers }
        if ($PSBoundParameters.ContainsKey('DueDate'))       { $task.due_date = $DueDate }
    }
    else {
        foreach ($field in 'Priority','UserId','AssignedUsers','DueDate') {
            if ($PSBoundParameters.ContainsKey($field)) {
                Write-Warning "$field can only be set on run tasks. Ignoring it for template task update."
            }
        }
    }

    $payload = @{ procedure_task = $task } | ConvertTo-Json -Depth 10

    try {
        $res = Invoke-HuduRequest -Method PUT -Resource "/api/v1/procedure_tasks/$Id" -Body $payload
        return ($res.procedure_task ?? $res)
    }
    catch {
        Write-Warning "Failed to update procedure task ID $Id : $($_.Exception.Message)"
        return $null
    }
}