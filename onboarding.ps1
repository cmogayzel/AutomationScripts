Import-Module ActiveDirectory

# CSV file path
$csvPath = "C:\Scripts\NewUsers.csv"

#Import users from the CSV file
$Users = Import-Csv -Path $csvPath

foreach ($User in $Users) {
    try {
        $FirstName = $User.FirstName.Trim()
        $LastName = $User.LastName.Trim()
        $UserName = $User.UserName.Trim()
        $Location = $User.Location.Trim()
        $Department = $USer.Department.Trim()
        $Password = ConvertTo-SecureString $User.Password -AsPlainText -=foreach

        $Name = "$FirstName $LastName"
        $DisplayName = "$FirstName $LastName"
        $UPN = "$Username@chuck.local"

        #Location OU and Fixed OU called Department
        $OUPath = "Ou=$Location,OU=$Department,DC=Chuck,DC=com"

        #Check if OU exists
        $OUExists = Get-ADOrganationalUnit -LDAPFilter "(distinguishedName=$OUPath)" -ErrorAction SilentlyCointinue

        if (-not $OUExists) {
            Write-Warning "OU not found for $Name : $OUPath"
            continue
        }

        # Check if username already exists
        $ExistingUser = Get-ADUser - Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyCointinue

        if ($ExistingUser) {
            Write-Warning "User already exists: $Username"
            continue
        }

        #Create new user
          New-ADUser `
            -Name $Name `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $Username `
            -UserPrincipalName $UPN `
            -DisplayName $DisplayName `
            -Department $Department `
            -Path $OUPath `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user $Name in $OUPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create user $($User.UserName) : $($_.Exception.Message)" 
    }
}

