<#
.Synopsis
   Send Messages to a Slack channel
.DESCRIPTION
   Long description
.EXAMPLE
   Send-SlackMessage -Token xxxx-xxxxx-xxxxx -Channel "Operations" -Text "Slack Test Message!" -Uri <Webhook URL> -UserName "Powershell Slack Bot"
#>
function Send-SlackMessage
{
    [CmdletBinding()]
    Param
    (
        # Text of the message to send
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Text,

        # Authentication Token
        [Parameter(Mandatory=$false,
                   Position=1)]
        [String]
        $Token,

        # Channel to send message to. Can be a public channel, private group or IM channel. Can be an encoded ID, or a name.
        [Parameter(Mandatory=$true,
                   Position=2)]
        [String]
        $Channel,

        # Uri to pass into the Invoke-RestMethod cmdlet. Will be your <customerName>.slack.com
        [Parameter(Mandatory=$true,
                   Position=3)]
        [String]
        $WebhookUrl,

        # Name of bot.
        [String]
        $UserName = "Powershell Slack Bot",

        # URL to an image to use as the icon for this message.
        [String]
        $IconUrl,

        # Emoji to use as the icon for this message. Overrides parameter IconUrl
        [String]
        $IconEmoji
    )

    Begin
    {
    }
    Process
    {
        if ($IconURL)
        {
            $Body = @{
                token = $Token;
                channel = $channel;
                text = $Text;
                username = $UserName;
                icon_url = $IconUrl;
            }
        }

        elseif ($IconEmoji)
        {
            $Body = @{
                token = $Token;
                channel = $channel;
                text = $Text;
                username = $UserName;
                icon_emoji = $IconEmoji;
            }
        }

        else
        {
            $Body = @{
                token = $Token;
                channel = $channel;
                text = $Text;
                username = $UserName;
            }
        }

        try
        {
            $Response = Invoke-RestMethod -Method Post -Uri $WebhookUrl -Body (ConvertTo-Json $Body)

            if ($Response.ok -eq $false)
            {
                Write-Error $Response.error
            }
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
