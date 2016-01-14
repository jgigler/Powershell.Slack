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
The title is displayed as larger, bold text near the top of the message attachment.

.PARAMETER TitleLink
If the title link is specified then it turns the Title into a hyperlink that the user can click. 

.PARAMETER Severity
This value is used to color the border along the left side of the message attachment

.PARAMETER Channel
Channel to send message to. Can be a public channel, private group or IM channel. Can be an encoded ID, or a name.

.PARAMETER Username
Can be used to change the name of the bot. If not specified, the custom Webhook name is used.

.PARAMETER IconUrl
URL to an image to use as the icon for this message


.PARAMETER Text
This is the main text in a message attachment, and can contain standard message markup. Not to be confused with Pretext which would appear above this.

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
        #<Attachment>
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]
        $Fallback,
        
        [Parameter(Mandatory=$false,
                    Position=1)]
        [ValidateSet("good",
                     "warning", 
                     "danger"
                     )]
        [String]
        $Severity,

        [Parameter(Mandatory=$false,
                    ParameterSetName='Author Set'
                    )]
        [String]
        $AuthorName,

        [Parameter(Mandatory=$false,
                    ParameterSetName='Author Set'
                    )]
        [String]
        $AuthorLink,

        [Parameter(Mandatory=$false,
                    ParameterSetName='Author Set'
                    )]
        [String]
        $AuthorIcon,

        [Parameter(Mandatory=$false, #this could be mandatory. This needs testing. 
                   ParameterSetName='Title Set'
                   )]
        [String]
        $Title,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Title Set'
                   )]
        [String]
        $TitleLink,
        
        [Parameter(Mandatory=$false)]
        [String]
        $Text, #may be mandatory.

        [Parameter(Mandatory=$false)]
        [String]
        $ImageURL,

        [Parameter(Mandatory=$false)]
        [String]
        $ThumbURL,
        
        [Parameter(Mandatory=$false)]
        [Array]
        $Fields,
        #</Attachment>
        #<postMessage Arguments>
        [Parameter(Mandatory=$false)]
        [String]
        $Channel,

        [Parameter(Mandatory=$false)]
        [String]
        $UserName,

        [Parameter(Mandatory=$false)]
        [String]
        $IconUrl
        #</postMessage Arguments>
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
                    pretext = $Pretext
                    author_name = $AuthorName
                    author_link = $AuthorLink
                    author_icon = $AuthorIcon
                    title = $Title
                    title_link = $TitleLink
                    text = $Text
                    fields = $Fields #Fields are defined by the user as an Array of HashTables.
                    image_url = $ImageURL
                    thumb_url = $ThumbURL
                }    
            )
        }

        Write-Output $SlackNotification
    }
    End
    {
    }
}


<#
Change Notes:
    - Removing positional paramater definition of optional parameters.

#>