function Set-HuduProcedureTaskLegacy {
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
        [int[]]$AssignedUsers
    )

    $task = @{}
    if ($PSBoundParameters.ContainsKey('Name'))          { $task.name = $Name }
    if ($PSBoundParameters.ContainsKey('Description'))   { $task.description = $Description }
    if ($PSBoundParameters.ContainsKey('Completed'))     { $task.completed = $Completed }
    if ($PSBoundParameters.ContainsKey('ProcedureId'))   { $task.procedure_id = $ProcedureId }
    if ($PSBoundParameters.ContainsKey('Position'))      { $task.position = $Position }
    if ($PSBoundParameters.ContainsKey('UserId'))        { $task.user_id = $UserId }
    if ($PSBoundParameters.ContainsKey('DueDate'))       { $task.due_date = $DueDate }
    if ($PSBoundParameters.ContainsKey('Priority'))      { $task.priority = $Priority }
    if ($PSBoundParameters.ContainsKey('AssignedUsers')) { $task.assigned_users = $AssignedUsers }

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