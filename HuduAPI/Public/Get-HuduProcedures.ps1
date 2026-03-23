function Get-HuduProcedures {
    <#
    .SYNOPSIS
    Get Hudu processes and runs.

    .DESCRIPTION
    Retrieves processes (templates) and runs (active instances).

    On newer Hudu versions, the API distinguishes between:
    - process: a template
    - run: an active instance created from a process

    Deprecated parameters are still accepted for compatibility, but a warning
    is emitted and they are translated to the newer API parameters when possible.
    #>
    [CmdletBinding()]
    param (
        [int]$Id,
        [int]$CompanyId,
        [string]$Name,
        [string]$Slug,

        [ValidateSet('process','run','all')]
        [string]$Type,

        [ValidateSet('global','company')]
        [string]$ProcessScope,

        [int]$ParentProcessId,

        [string]$CreatedAt,
        [string]$UpdatedAt,

        [bool]$Archived,

        [int]$PageSize,

        # deprecated
        [string]$GlobalTemplate,
        [int]$CompanyTemplate,
        [int]$ParentProcedureId
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

    if ($PSBoundParameters.ContainsKey('Name'))            { $params.name = $Name }
    if ($PSBoundParameters.ContainsKey('Slug'))            { $params.slug = $Slug }
    if ($PSBoundParameters.ContainsKey('CompanyId'))       { $params.company_id = $CompanyId }
    if ($PSBoundParameters.ContainsKey('Type'))            { $params.type = $Type }
    if ($PSBoundParameters.ContainsKey('ProcessScope'))    { $params.process_scope = $ProcessScope }
    if ($PSBoundParameters.ContainsKey('ParentProcessId')) { $params.parent_process_id = $ParentProcessId }
    if ($PSBoundParameters.ContainsKey('CreatedAt'))       { $params.created_at = $CreatedAt }
    if ($PSBoundParameters.ContainsKey('UpdatedAt'))       { $params.updated_at = $UpdatedAt }
    if ($PSBoundParameters.ContainsKey('Archived'))        { $params.archived = "$Archived".ToString().ToLower() }
    if ($PSBoundParameters.ContainsKey('PageSize'))        { $params.page_size = $PageSize }

    if ($PSBoundParameters.ContainsKey('GlobalTemplate')) {
        if ($PSBoundParameters.ContainsKey('ProcessScope')) {
            Write-Warning "GlobalTemplate is deprecated and was ignored because ProcessScope was also provided."
        }
        else {
            Write-Warning "GlobalTemplate is deprecated. Use -ProcessScope 'global' or 'company' instead."
            $params.type = 'process'
            switch ($GlobalTemplate.ToString().ToLowerInvariant()) {
                'true'  { $params.process_scope = 'global' }
                '1'     { $params.process_scope = 'global' }
                'false' { $params.process_scope = 'company' }
                '0'     { $params.process_scope = 'company' }
                default { Write-Warning "Unrecognized value for GlobalTemplate: '$GlobalTemplate'." }
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('CompanyTemplate')) {
        if ($PSBoundParameters.ContainsKey('ProcessScope') -or $PSBoundParameters.ContainsKey('CompanyId')) {
            Write-Warning "CompanyTemplate is deprecated and was ignored because ProcessScope and/or CompanyId were also provided."
        }
        else {
            Write-Warning "CompanyTemplate is deprecated. Use -ProcessScope 'company' with -CompanyId instead."
            $params.type = 'process'
            $params.process_scope = 'company'
            $params.company_id = $CompanyTemplate
        }
    }

    if ($PSBoundParameters.ContainsKey('ParentProcedureId')) {
        if ($PSBoundParameters.ContainsKey('ParentProcessId')) {
            Write-Warning "ParentProcedureId is deprecated and was ignored because ParentProcessId was also provided."
        }
        else {
            Write-Warning "ParentProcedureId is deprecated. Use -ParentProcessId instead."
            $params.type = 'run'
            $params.parent_process_id = $ParentProcedureId
        }
    }

    Invoke-HuduRequestPaginated -HuduRequest @{
        Method   = 'GET'
        Resource = '/api/v1/procedures'
        Params   = $params
    } -Property procedures
}