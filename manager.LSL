key notecardQueryId; //Identifier for the dataserver event

string notecardName = "bannlist"; //Name of a notecard in the object's inventory. Needs to be Full Perm for key checking for changed contents to work
 
integer notecardLine; //Initialize the counter value at 0

key notecardKey; //Store the notecard's key, so we don't read it again by accident.
 
list notecardData; //List to store data read from the notecard.

ReadNotecard()
{
    if (llGetInventoryKey(notecardName) == NULL_KEY)
    { //Check if the notecard exists in inventory, and is has been saved since it's creation (newly created notecards that are yet to be saved are assigned NULL_KEY).
        llSay(0,"Notecard '" + notecardName + "' is missing, unwritten, or not full permission."); //Notify user.
        return; //Don't do anything else.
    }
    else if (llGetInventoryKey(notecardName) == notecardKey) return;
    //This notecard has already been read - call to read was made in error, so don't do anything. (Notecards are assigned a new key each time they are saved.)

    llSay(0,"Began reading notecard: " + notecardName); //Notify user that read has started.
    notecardData = []; //Clear the memory of the previous notecard.
    notecardKey = llGetInventoryKey(notecardName); //Remember the key of this iteration of the notecard, so we don't read it again by accident.
    notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
}
 
default
{
    state_entry()
    {
        ReadNotecard(); //Pass off to the read function.
    }
    
    changed(integer change)
    {
        if(change & CHANGED_INVENTORY)
        { //The object's inventory just changed - the notecard could have been modified!
            ReadNotecard();
        }
    }
 
    dataserver(key query_id, string data)
    {
        if (query_id == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
               llSay(0,"Done reading notecard, read " + (string) notecardLine + " notecard lines. Start now with bann!(just a test)");
              //  llAddToLandBanList(,0.0); //Notify user.
                llSay(0,"=== Banned UUIDs: " + notecardName + " ===\n" + llDumpList2String(notecardData,"\n"));
                //Dump the contents of the notecard (for testing purposes).
            }
            else
            {
                key uuid = (key)data;
                if(uuid) {
                    llAddToLandBanList(uuid, 0.0);
                } else {
                    llSay(PUBLIC_CHANNEL, "invalid notecard line");
                }
                notecardData += data; //Add the line being read to a new entry on the list.
                ++notecardLine; //Increment line number (read next line).
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }
}
