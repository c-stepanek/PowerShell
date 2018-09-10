# PowerShell
Repository for PowerShell scripts.

# New-AzureVM.ps1
Name doesn't matter as long as it's unique.

Location can be found with Get-AzureRMLocation

VMSize can be determined with Get-AzureRMVMSize -Location <location>
  
  We default to Standard_D1 since it's super cheap
  
  The largest VM we'd suggest you go with is Standard_D4s_v3 because of it's unique cost/benefit
  
  For more pricing details: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/windows/
