About
=====

nim-itn is a Nim module for parsing ITN (TomTom intinerary) files.

For the purposes of examples, assume a file exists called ``data.itn`` containing
the following text:

    490843|5237653|Amsterdam Central Station|4|
    496283|5226712|Abcoude Park and Ride|0|
    507226|5208633|Stadsbaan Utrecht|2|
    509797|5199465|Company in Vianen|2|

(Example data taken from Wikipedia at https://en.wikipedia.org/wiki/Itinerary_file.)

    # Parse the data from the file.
    var itn : seq[ITN] = parseITN(readFile("data.itn"))
    # The previous line could also be simplified to:
    # var itn : seq[ITN] = readITN("data.itn")
    
    # Loop through the parsed data, output the description, longitude, and latitude of each row.
    for row in itn:
        echo(row.description & " - " & intToStr(row.longitude) & "," & intToStr(row.latitude))
    # Output:
    # Amsterdam Central Station - 490843,5237653
    # Abcoude Park and Ride - 496283,5226712
    # Stadsbaan Utrecht - 507226,5208633
    # Company in Vianen - 509797,5199465

nim-itn does some error checking to make sure files are valid. It will require the first row to 
be set as a departure point (type = 4), and not allow any other row to be set as such. It will also
not allow unrecognised types.



License
=======

nim-itn is released under the MIT open source license.
