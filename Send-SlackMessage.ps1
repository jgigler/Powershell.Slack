<#
.Synopsis
   Returns a hashtable containing the configuration for sending slack messages to web hook integrations.
.DESCRIPTION
   Takes a Hashtable and converts it to JSON before it sends it to the designated webhook URL.
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
        $json = $Notification | ConvertTo-Json -Depth 4
        $json = [regex]::replace($json,'\\u[a-fA-F0-9]{4}',{[char]::ConvertFromUtf32(($args[0].Value -replace '\\u','0x'))})
        $json = $json -replace "\\\\", "\"
        
        try
        {
            Invoke-RestMethod -Method POST -Uri $Url -Body $json
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
   Used to create Atachment message payloads for Slack. Attachemnts are a way of crafting richly-formatted messages in Slack. They can be as simple as a single plain text message, to as complex as a multi-line message with pictures, links and tables. 

.PARAMETER Fallback
A plain-text summary of the attachment. This text will be used in clients that don't show formatted text (eg. IRC, mobile notifications) and should not contain any markup.

.PARAMETER Severity
This value is used to color the border along the left side of the message attachment. This parameter cannot be used in conjunction with the "Color" parameter. Only good,bad and warning are accepted by this parameter.

.PARAMETER Colour
This value is used to color the border along the left side of the message attachment. Use Hex Web Colors to define the color. This parameter cannot be used in conjuction with the Severity Parameter.

.PARAMETER Pretext
This is optional text that appears above the message attachment block.

.PARAMETER AuthorName
Small text used to display the author's name.

.PARAMETER AuthorLink
A valid URL that will hyperlink the AuthorName text mentioned above. Will only work if AuthorName is present.

.PARAMETER AuthorIcon
A valid URL that displays a small 16x16px image to the left of the AuthorName text. Will only work if AuthorName is present.

.PARAMETER Title
The title is displayed as larger, bold text near the top of the message attachment.

.PARAMETER TitleLink
If the title link is specified then it turns the Title into a hyperlink that the user can click. 

.PARAMETER Text
This is the main text in a message attachment, and can contain standard message markup. Not to be confused with Pretext which would appear above this.

.PARAMETER ImageURL
A valid URL to an image file that will be displayed inside a message attachment.

.PARAMETER ThumbURL
A valid URL to an image file that will be displayed as a thumbnail on the right side of a message attachment.

.PARAMETER Fields
Fields are defined as an array, and hashtables contained within it will be displayed in a table inside the message attachment.
Each hashtable inside the array must contain a "title" parameter and a "value" parameter. Optionally it may also contain "Short" which is a boolean parameter.

.PARAMETER Channel
Channel to send message to. Can be a public channel, private group or IM channel. Can be an encoded ID, or a name.

.PARAMETER Username
Can be used to change the name of the bot. If not specified, the custom Webhook name is used.

.PARAMETER IconUrl
URL to an image to use as the icon for this message

.EXAMPLE
   New-SlackRichNotification -Fallback "Your app sucks it should process attachments" -Title "Service Error" -Value "Service down for server contoso1" -Severity danger -channel "Operations" -UserName "Slack Powershell Bot"
   
   This command would generate the following output in Powershell:
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


.EXAMPLE
$MyFields = @(
    @{
        title = 'Assigned To'
        value = 'John Doe'
        short = 'true'
    }
    @{
        title = 'Priority'
        value = 'Super Critical!'
        short = 'true'
    }
)

$notification = New-SlackRichNotification -Fallback "A plaintext message" -Title "Description" -Text "Some text that will appear above the Fields" -Fields $MyFields
Send-SlackNotification -Url "https://yourname.slack.com/path/to/hookintegrations" -Notification $notification

----------------------------------------------------------------------
In this example, $MyFields is defined as an Array. Inside that array are two separate hashtables with the two parameters that are required for a field. 
Since the "short" boolean parameter has been speified these two fields will be displayed next to each other in Slack. 


.LINK
https://github.com/jgigler/Powershell.Slack

.LINK
https://api.slack.com/docs/attachments

.LINK
https://api.slack.com/methods/chat.postMessage
#>
function New-SlackRichNotification
{
    [CmdletBinding(SupportsShouldProcess=$false,
                    DefaultParameterSetName=’SeverityOrColour’
                    )]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        #<Attachment>
        [Parameter(Mandatory=$true,
                    Position=0
                    )]
        [String]
        $Fallback,
        
        [Parameter(Mandatory=$false,
                    ParameterSetName='SeverityOrColour')]
        [ValidateSet("good",
                     "warning", 
                     "danger"
                     )]
        [String]
        $Severity,
        
        [Parameter(Mandatory=$false,
                    ParameterSetName='ColourOrSeverity'
                    )]
        [Alias("Colour")]
        [string]
        $Color,

        [Parameter(Mandatory=$false)]
        [String]
        $AuthorName,

        [Parameter(Mandatory=$false)]
        [String]
        $Pretext,

        [Parameter(Mandatory=$false)]
        [String]
        $AuthorLink,

        [Parameter(Mandatory=$false)]
        [String]
        $AuthorIcon,

        [Parameter(Mandatory=$false)] 
        [String]
        $Title,

        [Parameter(Mandatory=$false)]
        [String]
        $TitleLink,
        
        [Parameter(Mandatory=$false,
                    Position=1
                    )]
        [String]
        $Text,

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
        #consolidate the colour and severity parameters for the API.
        If($Severity -match 'good|warning|danger')
        {
            $Color = $Severity
        }
        
        $SlackNotification = @{
            username = $UserName
            icon_url = $IconUrl
            channel = $Channel
            attachments = @(
                @{                    
                    fallback = $Fallback
                    color = $Color
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