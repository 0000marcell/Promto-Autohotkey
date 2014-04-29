/*
IncreSimple Search 
By: Dantheuber
6/7/2013
 
Q.  There are scripts that do this already. Why?
A.  While they are all fine and good, they are all rather complex and unnecessary for simple search tools people may be building. 
    I needed this for a recent project and felt this would proove usefull to many others.
        TL;DR: Posterity
 
Q.  What's it do exactly?
A.  Uses an external .csv to provide a large list of delimited values. Which it reads upon intial load.
    As text is entered into top Edit field, after a short delay to allow for quick typing of a search, 
    a Parsing loop builds a new list on a seperate variable of items that contain the searchstring. Finally, Updating the 
    ListBox with the new list. 
 
    I use an odd delimiter( ++ ), in my .csv to order to allow for further regex reordering down the line
     - Sometimes multiple sets of delimeters are required to make something work with lots of content, 
       and you cant always get both delimeters into the .csv and maintain the content you need to present.
 
    In my personal project, I needed to do multiple things with different values but show both to the user on the same line.
    this functionality I thought should be included for others to use. This example googles the word selected when double clicked
    and puts the number in your clipboard if only selected and followed by a click of the 'Copy Number' buton.
     
Enjoy!
*/
 
Loop, Read, example.csv
{
    RegExMatch(A_LoopReadLine,"(?<Number>\d{1,4})\+{2}(?<Word>.*)",_)
    List    .=  _Number . " - " . _Word . "|"
}
List_a      :=  "|" . List
Gui, Add, Edit, x5 y5 h20 w300 -wrap vSearchString gIncrimentalSearch, 
Gui, Add, Listbox, x5 y30 h300 w300 Sort vChoice gSelectedItem, %List%
Gui, Add, Button, x5 y340 h20 w300 gCopyClick, Copy Number
Gui, Show, Center, IncreSimpleSearch
Return
 
IncrimentalSearch:
    Sleep 1100
    List_b := "|"
    GuiControl, -Redraw, Choice
    Gui, Submit, NoHide
    If SearchString = 
        GuiControl, , Choice, %List_a%
    Else
    {
        Loop, Parse, List, |
        {
            IfInString, A_LoopField, %SearchString%
                List_b  .= A_LoopField . "|"
        }
        GuiControl, , Choice, %List_b%
    }
    GuiControl, +Redraw, Choice
Return
 
SelectedItem:
    If A_GuiEvent != DoubleClick
        Return
    Gui, Submit, NoHide
    RegExMatch(Choice,"\d{1,4} \- (.*)",query)
    Run https://www.google.com/search?q=%query1%
return
 
CopyClick:
    Gui, Submit, NoHide
    If Choice =
        Return
    Else
    {
        RegExMatch(Choice,"(\d{1,4}) \- .*",Clip)
        ClipBoard   :=  Clip1
        TrayTip, IncreSimpleSearch, Copied: %Clip1%,1,1
    }
Return