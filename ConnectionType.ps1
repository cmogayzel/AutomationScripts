Invoke-Command -ComputerName "hostname" -ScriptBlock { 
    Get-NetAdapter | Where-Object { $_.Status -eq 'Up'} | Select-Object Name, InterfaceDescription, MediaType, 
    PhysicalMediaType
}