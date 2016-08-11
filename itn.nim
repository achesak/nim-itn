# Nim module for parsing ITN (TomTom intinerary) files.

# Written by Adam Chesak.
# Released under the MIT open source license.


## nim-itn is a Nim module for parsing ITN (TomTom intinerary) files.
##
## For the purposes of examples, assume a file exists called ``data.itn`` containing
## the following text:
##
##    490843|5237653|Amsterdam Central Station|4|
##    496283|5226712|Abcoude Park and Ride|0|
##    507226|5208633|Stadsbaan Utrecht|2|
##    509797|5199465|Company in Vianen|2|
##
## (Example data taken from Wikipedia at https://en.wikipedia.org/wiki/Itinerary_file.)
##
##  .. code-block:: nimrod
##    
##    # Parse the data from the file.
##    var itn : seq[ITN] = parseITN(readFile("data.itn"))
##    # The previous line could also be simplified to:
##    # var itn : seq[ITN] = readITN("data.itn")
##    
##    # Loop through the parsed data, output the description, longitude, and latitude of each row.
##    for row in itn:
##        echo(row.description & " - " & intToStr(row.longitude) & "," & intToStr(row.latitude))
##    # Output:
##    # Amsterdam Central Station - 490843,5237653
##    # Abcoude Park and Ride - 496283,5226712
##    # Stadsbaan Utrecht - 507226,5208633
##    # Company in Vianen - 509797,5199465
##
## nim-itn does some error checking to make sure files are valid. It will require the first row to 
## be set as a departure point (type = 4), and not allow any other row to be set as such. It will also
## not allow unrecognised types.


import strutils


type
    ITNRow* = object
        longitude* : int
        latitude* : int
        description* : string
        itnType* : ITNType
    
    ITNType* = enum
        Waypoint, DisabledWaypoint, Stopover, DisabledStopover, Departure
    
    ITNError* = object of Exception


proc parseITN*(data : string): seq[ITNRow] = 
    ## Parses an ITN file from the given ``data``.
    
    var lines : seq[string] = data.splitLines()
    var itn : seq[ITNRow] = @[]
    
    var firstRow : bool = true
    for line in lines:
        
        if line.strip() == "":
            continue
        
        var fields : seq[string] = line.split("|")
        var itnrow : ITNRow = ITNRow(longitude: parseInt(fields[0]), latitude: parseInt(fields[1]), description: fields[2])
        
        if firstRow and fields[3] != "4":
            raise newException(ITNError, "parseITN(): first row is not set as departure point (type 4; type = " & fields[3] & ")")
        
        if fields[3] == "0":
            itnrow.itnType = ITNType.Waypoint
        elif fields[3] == "1":
            itnrow.itnType = ITNType.DisabledWaypoint
        elif fields[3] == "2":
            itnrow.itnType = ITNType.Stopover
        elif fields[3] == "3":
            itnrow.itnType = ITNType.DisabledStopover
        elif fields[3] == "4":
            if not firstRow:
                raise newException(ITNError, "parseITN(): a row other than the first is set as departure point (type 4)")
            else:
                itnrow.itnType = ITNType.Departure
        else:
            raise newException(ITNError, "parseITN(): unrecognised type; expected 0,1,2,3,4; got " & fields[3])
        
        firstRow = false
        itn.add(itnrow)
    
    return itn


proc readITN*(filename : string): seq[ITNRow] = 
    ## Parses an ITN file from the given ``filename``.
    
    return parseITN(readFile(filename))
