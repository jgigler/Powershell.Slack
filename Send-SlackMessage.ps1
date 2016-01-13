<#
.Synopsis
   Returns a hashtable containing the configuration for sending slack messages to web hook integrations.
.DESCRIPTION
   Sends a JSON payload to the designated webhook URL
.EXAMPLE
   Send-SlackNotification -Url "https://yourname.slack.com/path/to/hookintegrations" -Notification $Notification

   Would post the message that was crafted in New-SlackRichNotification to the WebHook
.EXAMPLE
   New-SlackRichNotification -Fallback "Fallback summary" -Title "Message Title" -Value "Details of something that good happened!" -Severity good -UserName "My Bot Name" | Send-SlackNotification -Url "https://yourname.slack.com/path/to/hookintegrations" 

   This would create the message and send it to slack in the one line. 
.PARAMETER  Url
The Webhook URL goes here. 
.PARAMETER  Notification
The output of New-SlackRichNotification goes here.
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
   Creates a rich notification (Attachment) to be posted in a slack channel.
.DESCRIPTION
   Outputs a Hashtable that can be converted to JSON and sent to a Webhook in Slack. 

.PARAMETER Fallback
A plain-text summary of the attachment(value parameter). This text will be used in clients that don't show formatted text (eg. IRC, mobile notifications) and should not contain any markup.

.PARAMETER Title
The title is displayed as larger, bold text near the top of a message attachment

.PARAMETER Value
The message that you want to send. It may contain standard message markup and must be escaped as normal. May be multi-line.

.PARAMETER Severity
This value is used to color the border along the left side of the message attachment

.PARAMETER Channel
Channel to send message to. Can be a public channel, private group or IM channel. Can be an encoded ID, or a name. Not required if a webhook is used.

.PARAMETER Username
Can be used to change the name of the bot. If not specified, the custom Webhook name is used.

.PARAMETER IconUrl
URL to an image to use as the icon for this message

.NOTES
This function does not utilise the full capability of Slack attachments and some modification may be required if you wish to extend it. 

.EXAMPLE
   New-SlackRichNotification -Fallback "Your app sucks it should process attachments" -Title "Service Error" -Value "Service down for server contoso1" -Severity danger -channel "Operations" -UserName "Slack Powershell Bot"
   
   This command would generate the following output:
-------------------------------------------------------------------------------

Name                           Value                                                                                                                                                                                  
----                           -----                                                                                                                                                                                  
username                       Slack Powershell Bot                                                                                                                                                                   
channel                        Operations                                                                                                                                                                             
icon_url                                                                                                                                                                                                              
attachments                    {System.Collections.Hashtable}

.EXAMPLE
(New-SlackRichNotification -Fallback "Your app sucks it should process attachments" -Title "Service Error" -Value "Service down for server contoso1" -Severity danger -channel "random" -UserName "Slack Powershell Bot").attachments

This command allows us to see inside the attachments Hashtable. It's output looks like the following:
-------------------------------------------------------------------------------

Name                           Value                                                                                                                                                                                  
----                           -----                                                                                                                                                                                  
color                          danger                                                                                                                                                                                 
fallback                       Your app sucks it should process attachments                                                                                                                                           
fields                         {System.Collections.Hashtable}

.LINK
https://api.slack.com/docs/attachments

.LINK
https://api.slack.com/methods/chat.postMessage



#>
function New-SlackRichNotification
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]
        $Fallback,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [String]
        $Title,

        [Parameter(Mandatory=$true,
                   Position=2)]
        [String]
        $Value,

        [Parameter(Mandatory=$true,
                   Position=3)]
        [ValidateSet("good", "warning", "danger")]
        [String]
        $Severity,
        
        [Parameter(Mandatory=$false,
                   Position=4)]
        [String]
        $Channel,

        [Parameter(Mandatory=$false,
                   Position=5)]
        [String]
        $UserName,

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
