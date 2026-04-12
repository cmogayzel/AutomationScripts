Invoke-Command -ComputerName "ChuckMiniServer" -ScriptBlock { 
    Get-NetAdapter | Where-Object { $_.Status -eq 'Up'} | Select-Object Name, InterfaceDescription, MediaType, 
    PhysicalMediaType
}