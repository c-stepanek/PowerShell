# Start base classes
class Entity {
    # A comment provided by the user or the application.
    [string] $Comment
}

class Creator : Entity {
    # The name of the application that created the log.
    [string] $Name

    # The version number of the application that created the log.
    [string] $Version

    # Override ToString() method.
    [string] ToString() {
        return "$($this.Name):$($this.Version)"
    }
}

class Parameters : Entity {
    # The name of a parameter.
    [string] $Name

    # The value of a parameter.
    [string] $Value

    # Override ToString() method.
    [string] ToString() {
        return "$($this.Name):$($this.Version)"
    }
}

class Message : Entity {
    # Constructor
    Message() {
        $this.Cookies = [System.Collections.Generic.List[Cookie]]::new()
        $this.Headers = [System.Collections.Generic.List[Header]]::new()
    }

    # The HTTP Version.
    [string] $HttpVersion

    # A list of cookie objects.
    [System.Collections.Generic.List[Cookie]] $Cookies

    # A list of header objects.
    [System.Collections.Generic.List[Header]] $Headers

    # Total number of bytes from the start of the HTTP request message
    # until (and including) the double CRLF before the body.
    [int] $HeadersSize

    # Size of the body (payload) in bytes.
    [Nullable[int]] $BodySize
}
# End base classes

class Browser : Creator {
    # Override ToString() method.
    [string] ToString() {
        return "$($this.Name):$($this.Version)"
    }
}

class Cache : Entity {
    # The state of a cache entry before the request.
    [CacheState] $BeforeRequest

    # The state of a cache entry after the request.
    [CacheState] $AfterRequest

    # Override ToString() method.
    [string] ToString() {
        $strBeforeRequest = "BeforeRequest:$($this.BeforeRequest)"
        $strAfterRequest = "AfterRequest:$($this.AfterRequest)"

        return "$strBeforeRequest, $strAfterRequest"
    }
}

class CacheState : Entity {
    # The expiration time of the cache entry.
    [DateTime] $Expires

    # The last time the cache entry was opened.
    [DateTime] $LastAccess

    # ETag
    [string] $ETag

    # The number of times the cache entry has been opened.
    [int] $HitCount

    # Override ToString() method.
    [string] ToString() {
        $strExpires = "Expires:$($this.Expires)"
        $strLastAccessTime = "LastAccessTime:$($this.LastAccess)"
        $strETag = "ETag:$($this.ETag)"
        $strHitCount = "HitCount:$($this.HitCount)"

        return "$strExpires, $strLastAccessTime, $strETag, $strHitCount"
    }
}

class Content : Entity {
    # Length of the returned content in bytes.
    [int] $Size
    
    # The number of bytes saved.
    [Nullable[int]] $Compression

    # The MIME type of the response text.
    [string] $MimeType

    # Response body sent from the server or loaded from the browser cache.
    # This field is populated with textual content only. The text field is
    # either HTTP decoded text or a encoded (e.g. "base64") representation
    # of the response body.
    [string] $Text

    # Encoding used for response text field e.g "base64".
    [string] $Encoding

    # Override ToString() method.
    [string] ToString() {
        $strSize = "Size:$($this.Size)"
        $strCompression = "Compression:$($this.Compression)"
        $strMimeType = "MimeType:$($this.MimeType)"
        $strText = "Text:ExpandForFullDetails"
        $strEncoding = "Encoding:$($this.Encoding)"

        return "$strSize, $strCompression, $strMimeType, $strText, $strEncoding"
    }
}

class Convert {
    # Root method to deserialize the JSON content to a HAR object.
    [Har] static Deserialize([string] $json) {
        $javaScriptSerializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $javaScriptSerializer.MaxJsonLength = [int]::MaxValue
        return $javaScriptSerializer.Deserialize($json, [har])
    }

    # This method reads the JSON content from file and deserializes to a HAR object.
    [Har] static DeserializeFromFile([string] $filePath) {
        $json = Get-Content -Path $filePath -Raw
        return [Convert]::Deserialize($json);
    }

    # This method reads the content bytes and deserializes to a HAR object.
    [Har] static DeserializeFromBytes([byte[]] $fileBytes) {
        $json = [System.Text.Encoding]::UTF8.GetString($fileBytes)
        return [Convert]::Deserialize($json);
    }
}

class Cookie : Parameters {
    # The path pertaining to the cookie.
    [string] $Path

    # The host of the cookie.
    [string] $Domain

    # The cookie expiration time.
    [Nullable[DateTime]] $Expires

    # Set to true if the cookie is HTTP only, false otherwise.
    [bool] $HttpOnly

    # True if the cookie was transmitted over ssl, false otherwise.
    [bool] $Secure

    # Override ToString() method.
    [string] ToString() {
        return "$($this.Name):$($this.Value)"
    }

}

class Entry : Entity {
    # A reference to the parent page.
    [string] $PageRef

    # Date and time stamp of the request start.
    [DateTime] $StartedDateTime
  
    # Total elapsed time of the request in milliseconds.
    [Nullable[double]] $Time

    # Detailed info about the request.
    [Request] $Request

    # Detailed info about the response.
    [Response] $Response

    # Info about cache usage.
    [Cache] $Cache

    # Detailed timing info about request/response round trip.
    [Timings] $Timings
    
    # The IP address of the server that was connected (result of DNS resolution).
    [string] $ServerIPAddress

    # Unique ID of the parent TCP/IP connection, can be the client port number.
    # Note that a port number doesn't have to be unique identifier in cases
    # where the port is shared for more connections.
    [string] $Connection

    # Override ToString() method.
    [string] ToString() {
        $strPageRef = "PageRef:$($this.PageRef)"
        $strStartedDateTime = "StartedDateTime:$($this.StartedDateTime)"
        $strTime = "Time:$($this.Time)"
        $strRequest = "Request:$($this.Request)"
        $strResponse = "Response$($this.Response)"
        $strCache = "Cache:$($this.Cache)"
        $strTimings = "Timings:$($this.Timings)"
        $strServerIPAddress = "ServerIPAddress:$($this.ServerIPAddress)"

        return "$strPageRef, $strStartedDateTime, $strTime, $strRequest, $strResponse, $strCache, $strTimings, $strServerIPAddress"
    }
}

class Har {
    # The root object.
    [Log] $Log
}

class Header : Parameters {
    # Override ToString() method.
    [string] ToString() {
        return "$($this.Name):$($this.Value)"
    }
}

class Log : Entity {
    # Constructor
    Log () {
        $this.Pages = [System.Collections.Generic.List[Page]]::new()
        $this.Entries = [System.Collections.Generic.List[Entry]]::new()
    }

    # Version number of the HAR format.
    [string] $Version

    # An object of type creator that contains the name and version
    # information of the log creator application.
    [Creator] $Creator

    # An object of type browser that contains the name and version 
    # information of the user agent.
    [Browser] $Browser

    # An array of objects of type page, each representing one exported (tracked) page.
    [System.Collections.Generic.List[Page]] $Pages

    # An array of objects of type entry, each representing one exported (tracked) HTTP request.
    [System.Collections.Generic.List[Entry]] $Entries

    # Override ToString() method.
    [string] ToString() {
        $strVersion = "Version:$($this.Version)"
        $strCreator = "Creator:$($this.Creator)"
        $strBrowser = "Browser:$($this.Browser)"
        $strPages = "Pages:$($this.Pages)"
        $strEntries = "Entries:$($this.Entries)"
        
        return "$strVersion, $strCreator, $strBrowser, $strPages, $strEntries"
    }
}

class Page : Entity {
    # Date and time stamp for the beginning of the page load.
    [DateTime] $StartedDateTime
    
    # Unique identifier of a page. Entries use it to refer the parent page.
    [string] $Id
    
    # The page title.
    [string] $Title
    
    # Detailed timing info about page load.
    [PageTimings] $PageTimings

    # Override ToString() method.
    [string] ToString() {
        $strStartedDateTime = "StartedDateTime:$($this.StartedDateTime)"
        $strId = "Id:$($this.Id)"
        $strTitle = "Title:$($this.Title)"
        $strPageTimings = "PageTimings:$($this.PageTimings)"

        return "$strStartedDateTime, $strId, $strTitle, $strPageTimings"
    }
}

class PageTimings : Entity {
    # Content of the page loaded. Number of milliseconds since page load started.
    [Nullable[double]] $OnContentLoad
   
    # Page is loaded (onLoad event fired). Number of milliseconds since page load started.
    [Nullable[double]] $OnLoad

    # Override ToString() method.
    [string] ToString() {
        $strOnContentLoad = "OnContentLoad:$($this.OnContentLoad)"
        $strOnLoad = "OnLoad:$($this.OnLoad)"

        return "$strOnContentLoad, $strOnLoad"
    }
}

class PostData : Entity {
    # The mime type.
    [string] $MimeType

    # A list of posted parameters.
    [System.Collections.Generic.List[PostDataParameters]] $Params

    # The posted data in plain text.
    [string] $Text

    # Override ToString() method.
    [string] ToString() {
        $strMimeType = "MimeType:$($this.MimeType)"
        $strParams = "Params:$($this.Params)"
        $strText = "Text:$($this.Text)"

        return "$strMimeType, $strParams, $strText"
    }
}

class PostDataParameters : Parameters {
    # The name of a posted file.
    [string] $FileName

    # The content type of a posted file.
    [string] $ContentType

    [string] ToString() {
        $strFileName = "FileName:$($this.FileName)"
        $strContentType = "ContentType:$($this.ContentType)"

        return "$strFileName, $strContentType"
    }
}

class QueryStringParameter : Parameters {
    # Override ToString() method.
    [string] ToString() {
        return "$($this.Name):$($this.Value)"
    }
}

class Request : Message {
    # Request method (GET, POST, ...).
    [string] $Method

    # Absolute URL of the request (fragments are not included).
    [Uri] $Url

    # A list of query parameter objects.
    [System.Collections.Generic.List[QueryStringParameter]] $QueryString

    # The posted data info.
    [PostData] $PostData

    # Override ToString() method.
    [string] ToString() {
        $strMethod = "Method:$($this.Method)"
        $strUrl = "Url:$($this.Url)"
        $strQueryString = "QueryString:$($this.QueryString)"
        $strPostData = "PostData:$($this.PostData)"
        $strHttpVersion = "HttpVersion:$($this.HttpVersion)"
        $strHeaders = "Headers:$($this.Headers)"
        $strHeadersSize = "HeadersSize:$($this.HeadersSize)"
        $strBodySize = "BodySize:$($this.BodySize)"

        return "$strMethod, $strUrl, $strQueryString, $strPostData, $strHttpVersion, $strHeaders, $strHeadersSize, $strBodySize"
    }
}

class Response : Message {
    # The response status.
    [int] $Status

    # The response status description.
    [string] $StatusText

    # Details about the response body.
    [Content] $Content

    # Redirection target URL from the location response header.
    [Uri] $RedirectUrl

    # Override ToString() method.
    [string] ToString() {
        $strStatus = "Status:$($this.Status)"
        $strStatusText = "StatusText:$($this.StatusText)"
        $strRedirectUrl = "RedirectUrl:$($this.RedirectUrl)"
        $strHttpVersion = "HttpVersion:$($this.HttpVersion)"
        $strHeaders = "Headers:$($this.Headers)"
        $strHeadersSize = "HeadersSize:$($this.HeadersSize)"
        $strBodySize = "BodySize:$($this.BodySize)"

        return "$strStatus, $strStatusText, $strRedirectUrl, $strHttpVersion, $strHeaders, $strHeadersSize, $strBodySize"
    }
}

class Timings : Entity {
    # Time spent in a queue waiting for a network connection.
    [Nullable[double]] $Blocked

    # DNS resolution time. The time required to resolve a host name.
    [Nullable[double]] $Dns

    # The time required to create a TCP connection.
    [Nullable[double]] $Connect

    # The time required to send a HTTP request to the server.
    [double] $Send

    # The time required waiting for a response from the server.
    [double] $Wait

    # Time required to read the entire response from the server (or cache).
    [double] $Receive

    # Time required for SSL/TLS negotiation.
    [Nullable[double]] $Ssl

    # Override ToString() method.
    [string] ToString() {
        $strBlocked = "Blocked:$($this.Blocked)"
        $strDns = "Dns:$($this.Dns)"
        $strConnect = "Connect:$($this.Connect)"
        $strSend = "Send:$($this.Send)"
        $strWait = "Wait:$($this.Wait)"
        $strReceive = "Receive:$($this.Receive)"
        $strSsl = "SSL:$($this.Ssl)"

        return "$strBlocked, $strDns, $strConnect, $strSend, $strWait, $strReceive, $strSsl"
    }
}

function ConvertFrom-Har {
    [OutputType([Har], [Entry])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "FilePath")]
        [ValidateScript( {
                if (-not ($_ -match '^(?:[\w]\:|\\)(\\[a-z_\-\s0-9\.]+)+\.(har|HAR)$')) {
                    throw "$_ either does not have a valid HAR file extension `n" + 
                    "or you did not specify a full filepath. Example: C:\temp\domain.com.har or \\server\share\domain.com.har" 
                }
                elseif (-not (Test-Path $_ -PathType leaf)) {
                    throw "File not found: $_"
                }
                else {
                    $true
                }
            })]
        [string]$FilePath,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "FileBytes")]
        [byte[]]$FileBytes,
        [switch]$ShowClientErrors,
        [switch]$ShowServerErrors,
        [switch]$ShowRedirects
    )

    begin {
        Add-Type -AssemblyName 'System.Web.Extensions'
    
    }
    process {

        switch ($PSCmdlet.ParameterSetName) {
            FilePath { 
                try {
                    $har = [Convert]::DeserializeFromFile($FilePath)
                }
                catch {
                    throw "Unable to deserialize the Http Archive file. Please make sure you have a valid .har file."
                }
                break
            }
            FileBytes {
                try {
                    $har = [Convert]::DeserializeFromBytes($FileBytes)
                }
                catch {
                    throw "Unable to deserialize the byte array. Please make sure you have a valid .har data."
                }
                break
            }
        }

        if ($null -ne $har) {
            $entries = $har.Log.Entries

            if ($ShowClientErrors -and $ShowServerErrors) {
                $entries | Where-object { $_.Response.Status -ge 400 }
            }
            elseif ($ShowClientErrors) {
                $entries | Where-Object { $_.Response.Status -ge 400 -and $_.Response.Status -lt 500 }
            }
            elseif ($ShowServerErrors) {
                $entries | Where-Object { $_.Response.Status -ge 500 }
            }
            elseif ($ShowRedirects) {
                $entries | Where-Object { $_.Response.Status -ge 300 -and $_.Response.Status -lt 400 }
            }
            else {
                Write-Output $har
            }
        }
    }

    end { }

<#
.SYNOPSIS

Coverts the content of a HTTP Archive (.har) file to an object.

.DESCRIPTION

Deserializes the JSON content of a HTTP Archive (.har) file to a .Net object.

HAR SPEC: "https://w3c.github.io/web-performance/specs/HAR/Overview.html"

.PARAMETER FilePath
Specifies the file path.

.PARAMETER FileBytes
Specifies the file in bytes.

.PARAMETER ShowClientErrors
A switch to filter entries with a response status of 4xx.

.PARAMETER ShowServerErrors
A switch to filter entries with a response status of 5xx.

.PARAMETER ShowRedirects
A switch to filter entries with a response status of 3xx.

.INPUTS

None. You cannot pipe objects to ConvertFrom-Har

.OUTPUTS

Har
Entry

ConvertFrom-Har can return a har object or entry object if any of the filtering switches are used.

.EXAMPLE

PS> ConvertFrom-Har -FilePath c:\temp\www.bing.com.har

Returns a Har object.

.EXAMPLE

PS> ConvertFrom-Har -FileBytes (Get-Content -Path c:\temp\www.bing.com.har -Encoding Byte -Raw)

Returns a Har object.

.EXAMPLE

PS> ConvertFrom-Har -FilePath c:\temp\www.bing.com.har -ShowClientErrors

Returns Entry objects with a response status of 4xx.

.EXAMPLE

PS> ConvertFrom-Har -FilePath c:\temp\www.bing.com.har -ShowServerErrors

Returns Entry objects with a response status of 5xx.

.EXAMPLE

PS> ConvertFrom-Har -FilePath c:\temp\www.bing.com.har -ShowClientErrors -ShowServerErrors

Returns Entry objects with a response status of both 4xx and 5xx.

.EXAMPLE

PS> ConvertFrom-Har -FilePath c:\temp\www.bing.com.har -ShowRedirects

Returns Entry objects with a response status of 3xx.
#>

}

Export-ModuleMember -Function 'ConvertFrom-Har'