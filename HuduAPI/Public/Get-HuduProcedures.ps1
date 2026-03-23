function Get-HuduProcedures {
    <#
    .SYNOPSIS
    Get Hudu processes and/or runs.

    .DESCRIPTION
    Retrieves a list of procedures from Hudu. In the new API, this includes:
    - Processes/templates (run = false)
    - Runs/instances (run = true)

    .PARAMETER Id
    Retrieve a single procedure by ID.

    .PARAMETER Type
    Filter by type: process, run, or all.

    .PARAMETER ProcessScope
    Filter process templates by scope: global or company.

    .PARAMETER ParentProcessId
    Filter runs created from a specific process.

    .PARAMETER Name
    Filter by exact name.

    .PARAMETER CompanyId
    Filter by company ID.

    .PARAMETER Slug
    Filter by slug.

    .PARAMETER CreatedAt
    Exact date or date range string.

    .PARAMETER UpdatedAt
    Exact date or date range string.

    .PARAMETER Archived
    Filter by archived status.

    .PARAMETER PageSize
    Optional page size.
    #>
    [CmdletBinding()]
    param(
        [int]$Id,

        [ValidateSet('process','run','all')]
        [string]$Type = 'all',

        [ValidateSet('global','company')]
        [string]$ProcessScope,

        [Alias('parent_procedure_id')]
        [int]$ParentProcessId,

        [string]$Name,
        [int]$CompanyId,
        [string]$Slug,
        [string]$CreatedAt,
        [string]$UpdatedAt,

        [Nullable[bool]]$Archived,

        [int]$PageSize
    )

    if ($Id) {
        try {
            $res = Invoke-HuduRequest -Method GET -Resource "/api/v1/procedures/$Id"
            return ($res.procedure ?? $res)
        }
        catch {
            Write-Warning "Failed to retrieve procedure ID $Id- $($_.Exception.Message)"
            return $null
        }
    }

    $params = @{}

    if ($PSBoundParameters.ContainsKey('Type'))            { $params.type = $Type }
    if ($PSBoundParameters.ContainsKey('ProcessScope'))    { $params.process_scope = $ProcessScope }
    if ($PSBoundParameters.ContainsKey('ParentProcessId')) { $params.parent_process_id = $ParentProcessId }
    if ($PSBoundParameters.ContainsKey('Name'))            { $params.name = $Name }
    if ($PSBoundParameters.ContainsKey('CompanyId'))       { $params.company_id = $CompanyId }
    if ($PSBoundParameters.ContainsKey('Slug'))            { $params.slug = $Slug }
    if ($PSBoundParameters.ContainsKey('CreatedAt'))       { $params.created_at = $CreatedAt }
    if ($PSBoundParameters.ContainsKey('UpdatedAt'))       { $params.updated_at = $UpdatedAt }
    if ($PSBoundParameters.ContainsKey('Archived'))        { $params.archived = if ($Archived) { 'true' } else { 'false' } }
    if ($PSBoundParameters.ContainsKey('PageSize'))        { $params.page_size = $PageSize }

    Invoke-HuduRequestPaginated -HuduRequest @{
        Method   = 'GET'
        Resource = '/api/v1/procedures'
        Params   = $params
    } -Property procedures
}