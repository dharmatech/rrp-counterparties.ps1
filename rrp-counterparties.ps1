
Param([switch]$csv)

$date = '2022-01-01'

$result = Invoke-RestMethod ('https://markets.newyorkfed.org/api/rp/reverserepo/propositions/search.json?startDate={0}' -f $date)

$items = $result.repo.operations | Sort-Object operationDate | Where-Object note -NotMatch 'Small Value Exercise'

$table = $items | ForEach-Object {
    [pscustomobject]@{
        date = $_.operationDate
        totalAmtAccepted = $_.totalAmtAccepted
        bank = ($_.propositions | Where-Object counterpartyType -EQ 'bank').amtAccepted
        gse  = ($_.propositions | Where-Object counterpartyType -EQ 'gse').amtAccepted
        mmf  = ($_.propositions | Where-Object counterpartyType -EQ 'mmf').amtAccepted
        pd   = ($_.propositions | Where-Object counterpartyType -EQ 'pd').amtAccepted
    }
}

$table | Format-Table

if ($csv)
{
    $table | Export-Csv ('rrp-counterparties-{0}.csv' -f (Get-Date -Format 'yyyy-MM-dd')) -NoTypeInformation
}

# $json = @{
#     chart = @{
#         type = 'line'
#         data = @{
#             labels = $table.ForEach({ $_.date })
#             datasets = @(
#                 @{ label = 'total'; data = $table.ForEach({ $_.totalAmtAccepted / 1000 / 1000 / 1000 }) }
#                 @{ label = 'Bank';  data = $table.ForEach({ $_.bank             / 1000 / 1000 / 1000 }) }
#                 @{ label = 'GSE';   data = $table.ForEach({ $_.gse              / 1000 / 1000 / 1000 }) }
#                 @{ label = 'MMF';   data = $table.ForEach({ $_.mmf              / 1000 / 1000 / 1000 }) }
#                 @{ label = 'PD';    data = $table.ForEach({ $_.pd               / 1000 / 1000 / 1000 }) }
#             )
#         }
#         options = @{
#             scales = @{ }
#         }
#     }
# } | ConvertTo-Json -Depth 100
# 
# $result = Invoke-RestMethod -Method Post -Uri 'https://quickchart.io/chart/create' -Body $json -ContentType 'application/json'
# 
# # Start-Process $result.url
# 
# $id = ([System.Uri] $result.url).Segments[-1]
# 
# Start-Process ('https://quickchart.io/chart-maker/view/{0}' -f $id)



$json = @{
    chart = @{
        type = 'line'
        data = @{
            labels = $table.ForEach({ $_.date })
            datasets = @(
                @{ label = 'total'; data = $table.ForEach({ $_.totalAmtAccepted    / 1000 / 1000 / 1000 }) }
                @{ label = 'Bank';  data = $table.ForEach({ if ($_.bank -ne $null) { $_.bank / 1000 / 1000 / 1000 } }) }
                @{ label = 'GSE';   data = $table.ForEach({ if ($_.gse  -ne $null) { $_.gse  / 1000 / 1000 / 1000 } }) }
                @{ label = 'MMF';   data = $table.ForEach({ if ($_.mmf  -ne $null) { $_.mmf  / 1000 / 1000 / 1000 } }) }
                @{ label = 'PD';    data = $table.ForEach({ if ($_.pd   -ne $null) { $_.pd   / 1000 / 1000 / 1000 } }) }
            )
        }
        options = @{
            title = @{ display = $true; text = 'RRP Counterparties (billions USD)' }
            scales = @{ }
        }
    }
} | ConvertTo-Json -Depth 100

$result = Invoke-RestMethod -Method Post -Uri 'https://quickchart.io/chart/create' -Body $json -ContentType 'application/json'

# Start-Process $result.url

$id = ([System.Uri] $result.url).Segments[-1]

Start-Process ('https://quickchart.io/chart-maker/view/{0}' -f $id)
