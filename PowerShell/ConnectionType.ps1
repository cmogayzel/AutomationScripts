Invoke-Command -ComputerName "Chuck" -ScriptBlock { 
    Get-NetAdapter | Where-Object { $_.Status -eq 'Up'} | Select-Object Name, InterfaceDescription, MediaType, 
    PhysicalMediaType
}