Import-Module PoShKeePass

$outfile = 'C:\temp\keepass.csv'

$keepass = Get-KeePassEntry -AsPlainText
$passwords = @()
$passwords += "nickname,website,username,password,additional info"

foreach($pw in $keepass) {
    $title          = $pw.Title    -replace '"', '""'
    $URL            = $pw.URL      -replace '"', '""'
    $username       = $pw.UserName -replace '"', '""'
    $password       = $pw.Password -replace '"', '""'
    $additionalInfo = $pw.Notes    -replace '"', '""'

    $passwords += '"{0}","{1}","{2}","{3}","{4}"' -f $title, $URL, $username, $password, $additionalInfo
}


 $passwords | Out-File $outfile