<#
.Synopsis
   Returns a hashtable containing the configuration for sending slack messages to web hook integrations.

.EXAMPLE
   Send-SlackNotification -Url "https://yourname.slack.com/path/to/hookintegrations" -Notification $Notification
#>
function Send-SlackNotification
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]
        $Url,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline = $true,
                   Position=1)]
        [System.Collections.Hashtable]
        $Notification
    )

    Begin
    {
    }
    Process
    {
        try
        {
            Invoke-RestMethod -Method POST -Uri $Url -Body ($Notification | ConvertTo-Json -Depth 4)
        }

        catch
        {
            Write-Warning $_
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Creates a rich notification to be posted in a slack channel.
.DESCRIPTION
   Long description
.EXAMPLE
   New-SlackRichNotification -Fallback "Your app sucks it should process attachments" -Title "Service Error" -Value "Service down for server contoso1" -Severity danger -channel "Operations" -UserName "Slack Powershell Bot"
#>
function New-SlackRichNotification
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        # Title of the notification
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]
        $Fallback,

        # Title of the notification
        [Parameter(Mandatory=$true,
                   Position=1)]
        [String]
        $Title,

        # Value or message of the notification you would like to send
        [Parameter(Mandatory=$true,
                   Position=2)]
        [String]
        $Value,

        # Value or message of the notification you would like to send
        [Parameter(Mandatory=$true,
                   Position=3)]
        [ValidateSet("good", "warning", "danger")]
        [String]
        $Severity,

        # Channel to send message to. Can be a public channel, private group or IM channel. Can be an encoded ID, or a name.
        [Parameter(Mandatory=$true,
                   Position=4)]
        [String]
        $Channel,

        # Name of the user posting the message (bot name).
        [Parameter(Mandatory=$true,
                   Position=5)]
        [String]
        $UserName,

        # Url of the icon or image you would like.
        [Parameter(Mandatory=$false,
                   Position=6)]
        [String]
        $IconUrl
    )

    Begin
    {
    }
    Process
    {
        $SlackNotification = @{
            channel = $Channel
            username = $UserName
            icon_url = $IconUrl
            attachments = @(
                @{
                    fallback = $Fallback
                    color = $Severity
                    fields = @(
                        @{
                            title = $Title
                            value = $Value
                        }
                    )
                }    
            )
        }

        Write-Output $SlackNotification
    }
    End
    {
    }
}
