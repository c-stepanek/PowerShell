function New-PowerShellSignatureGenerator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Message
    )

    # Convert the string to a character array 
    $messageChars = $Message.ToCharArray()

    foreach ($char in $messageChars) {
        <#
            Convert the char to UInt32 (this will be the ASCII decimal value)
            Format the UInt32 value as a hexadecimal string
            Add the value to $hexString
        #>
        $hexString += [String]::Format("{0:X}", [Convert]::ToUInt32($char))
    }
    
    <#
        RegEx Filter for Split
        ?<= - Positive Lookbehind. Matches a group before the main expression.
        \G  - Asserts position at the end of the previous match or the start of the string for the first match.
        .   - Matches any character (except for line terminators).
        {2} - Matches the previous token exactly 2 times.
    #>

    # The value after the comma (,) is the maximum number of substrings returned by the split operation.
    # This will be total length of the hex string divided by 2.
    # The foreach (%) takes the hex string and casts it to [int] then casts the [int] to [char]

    Write-Output "-join('$hexString' -split'(?<=\G.{2})',$($hexString.Length/2)|%{[char][int]`"0x`$_`"})"
}