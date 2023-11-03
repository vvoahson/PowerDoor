function Find-ByteSequence {
    param(
        [byte[]]$bytes,
        [byte[]]$sequence
    )

    for ($i = 0; $i -le $bytes.Length - $sequence.Length; $i++) {
        for ($j = 0; $j -lt $sequence.Length; $j++) {
            if ($bytes[$i + $j] -ne $sequence[$j]) {
                break
            }
            if ($j -eq $sequence.Length - 1) {
                return $i
            }
        }
    }

    return -1
}
takeown   /f c:\windows\system32\termsrv.dll
function Replace-Bytes {
    param(
        [byte[]]$source,
        [byte[]]$search,
        [byte[]]$replace
    )

    $offset = Find-ByteSequence -bytes $source -sequence $search

    if ($offset -ne -1) {
        for ($i = 0; $i -lt $replace.Length; $i++) {
            $source[$offset + $i] = $replace[$i]
        }
        return $true
    } else {
        return $false
    }
}

# Define file path
$filePath = "C:\Windows\System32\termsrv.dll"

# Ensure you're running this as an administrator and have taken ownership and full control of the file copy
# Read the entire file into a byte array
$data = [System.IO.File]::ReadAllBytes($filePath)

# Define the search and replace sequences
$searchBytes = [byte[]](0x39, 0x81, 0x3C, 0x06, 0x00, 0x00, 0x0F, 0x84)
$replaceBytes = [byte[]](0xB8, 0x00, 0x01, 0x00, 0x00, 0x89, 0x81, 0x38, 0x06, 0x00, 0x00, 0x90)

# Search for the bytes and replace them
$result = Replace-Bytes -source $data -search $searchBytes -replace $replaceBytes

if ($result) {
    # Write the modified byte array back to the file
    [System.IO.File]::WriteAllBytes($filePath, $data)
    Write-Host "Replacement successful."
} else {
    Write-Host "Sequence not found."
}
