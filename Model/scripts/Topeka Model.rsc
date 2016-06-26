// Model Tool Box 
Dbox "Topeka Model" center, center, 45.8,30 toolbox nokeyboard
title: "Model Toolbox" 

Frame 0.5,0,45,6.1 
Frame 1.5,.30,43,5.5 
Button 3,1.25 icon: "S:\\DVC\\Topeka Model\\Resource Code\\Topekalogo.bmp" 

// Scenarios
Frame 0.5,6.5,45,6 Prompt: "Scenario"

Button "Input" 3.2,8
do
  ProjectPath="S:\\DVC\\Topeka Model"
  opts.initialdirectory="S:\\DVC\\Topeka Model"
  ProjectPath=ChooseDirectory("Choose Input File",opts)
  Nnames = GetDirectoryInfo(ProjectPath+"\\*.dbd","File")
  dim Networks[Nnames.length]

  for i = 1 to Nnames.length do
     Networks[i] = Nnames[i][1]
  end
endItem

Text 9,8,35,1 Framed Variable:ProjectPath

Button "Output" 1.8,10.5
  do
   opts.initialdirectory=ProjectPath+"\\Output"
OutputPath = ChooseDirectory("Select Output Directory",opts)
enditem

Text 9,10.5,35,1 Framed Variable:OutputPath


// Update Network Button

Frame 2.5,13,41,10.5 Prompt: "Run Model"

Button "b1" 9, 14.5 icons:"bmp\\plannetwork.bmp", "bmp\\plannetwork.bmp", "bmp\\plannetwork.bmp"

Button "Build Network" after, same, 15, 1.2 
      do
      RunMacro("Lookup", DataPath, OutputPath, NetworkFile, ReturnCode)
enditem

// Trip Generation Button

Button "b2" 9, after icons:"bmp\\plantripgen.bmp", "bmp\\plantripgen.bmp", "bmp\\plantripgen.bmp"
     
Button "Trip Generation" after,same, 15, 1.2
      do
      RunMacro ("Trip Gen")
enditem 

// Trip Distribution Button

Button "b3" 9, after icons: "bmp\\plantripdist.bmp", "bmp\\plantripdist.bmp", "bmp\\plantripdist.bmp"

Button "Trip Distribution" after,same, 15, 1.2

do
      RunMacro ("Trip Distribution")
Enditem

// Trip Assignment Button

Button "b4" 9, after icons: "bmp\\planassign.bmp", "bmp\\planassign.bmp", "bmp\\planassign.bmp"

Button "Trip Assignment" after,same, 15, 1.2 
do
      RunMacro ("Trip Assignment")
Enditem

// Run All Steps Button

Button "Run All Steps" 9,22,27

do
   RunMacro ("Run All Steps")
Enditem

// Create Map Button

Frame 2.5,24,41,3.5 Prompt: "Utilities"


Button 9.0,25.5  icons: "bmp\\map.bmp", "bmp\\map.bmp", "bmp\\map.bmp"

Button "LOS/Flow" after,same, 8.7,1.2

do
   RunMacro ("LOS/Flow")
Enditem

// Create Report Button

Button 23.2,25.5 icons: "bmp\\mod.bmp", "bmp\\mod.bmp", "bmp\\mod.bmp"

Button "Reports" after,same, 8.7,1.2

//Close Button

Button 14,28.5  icons: "bmp\\no.bmp", "bmp\\no.bmp", "bmp\\no.bmp"

Button "Close" after,same, 12.5,.8
do
Return()
Enditem     

EndDbox


Macro "Lookup" 
    RunMacro("TCB Init")

// STEP 1: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "Highway/Streets"}
     Opts.Global.Fields = {"Lookup"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "(FT * 10) + AT"    
     
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

// STEP 2: Fill Dataview
     tb = OpenTable("tab", "ACCESS", {"S:\\DVC\\Topeka Model\\Lookup\\Lookup.accdb", "Lookup", "Lookup"})
     ExportView(tb+"|", "DBASE", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", , )
     
     tb = OpenTable("tab", "DBASE", {"S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf"})
     {node_layer, line_layer} = RunMacro("TCB Add DB Layers", "S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd")

     jv = JoinViews("jv", line_layer + ".LookUp", tb + ".LookUp",)
     v = GetDataVector(jv + "|", tb + ".FC",)
     SetDataVector(jv + "|", line_layer+".FC", v,)
     CloseView(jv)
     CloseView(tb)

     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

// STEP 3: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", {"Lookup"}, {"Lookup"}}, "Highways/Streets+LookUp"}
     Opts.Global.Fields = {"[Highways/Streets].FF_SPEED"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.FF_SPEED"
     
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    

// STEP 4: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", {"Lookup"}, {"Lookup"}}, "Highways/Streets+LookUp"}
     Opts.Global.Fields = {"[Highways/Streets].PK_SPEED"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.PK_SPEED"
    
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    

// STEP 5: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", {"Lookup"}, {"Lookup"}}, "Highways/Streets+LookUp"}
     Opts.Global.Fields = {"[Highways/Streets].AB_CAP"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.AB_CAP * AB_Lanes"     
    
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    

// STEP 6: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", {"Lookup"}, {"Lookup"}}, "Highways/Streets+LookUp"}
     Opts.Global.Fields = {"[Highways/Streets].BA_CAP"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.BA_CAP * BA_Lanes"     
   
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    
    
// STEP 7: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", {"Lookup"}, {"Lookup"}}, "Highways/Streets+LookUp"}
     Opts.Global.Fields = {"[Highways/Streets].Alpha"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.Alpha"     
  
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)    
    

// STEP 8: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets", "S:\\DVC\\Topeka Model\\Lookup\\LookUp.dbf", {"Lookup"}, {"Lookup"}}, "Highways/Streets+LookUp"}
     Opts.Global.Fields = {"[Highways/Streets].Beta"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.Beta"    
    
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

     CloseView("tab")

// STEP 9: Calculate FF and PK Travel Times 
     Opts = null
     Opts.Input.[Dataview Set] = {"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets"}
     Opts.Global.Fields = {"[Highways/Streets].FF_TT"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "(Length*60)/FF_SPEED"

     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

     Opts = null
     Opts.Input.[Dataview Set] = {"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.dbd|Highways/Streets"}
     Opts.Global.Fields = {"[Highways/Streets].PK_TT"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "(Length*60)/PK_SPEED"

     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

// STEP 10: Build Highway Network      

     Opts = null
     Opts.Input.[Link Set] = {"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.DBD|Highways/Streets", "Highways/Streets"}
     Opts.Global.[Network Options].[Node ID] = "Endpoints.ID"
     Opts.Global.[Network Options].[Link ID] = "[Highways/Streets].ID"
     Opts.Global.[Network Options].[Turn Penalties] = "Yes"
     Opts.Global.[Network Options].[Keep Duplicate Links] = "FALSE"
     Opts.Global.[Network Options].[Ignore Link Direction] = "FALSE"
     Opts.Global.[Network Options].[Time Unit] = "Minutes"
     Opts.Global.[Link Options] = {{"Length", {"[Highways/Streets].Length", "[Highways/Streets].Length", , , "False"}}, {"[AB_Lanes / BA_Lanes]", {"[Highways/Streets].AB_Lanes", "[Highways/Streets].BA_Lanes", , , "False"}}, {"FT", {"[Highways/Streets].FT", "[Highways/Streets].FT", , , "False"}}, {"AT", {"[Highways/Streets].AT", "[Highways/Streets].AT", , , "False"}}, {"Lookup", {"[Highways/Streets].Lookup", "[Highways/Streets].Lookup", , , "False"}}, {"FF_SPEED", {"[Highways/Streets].FF_SPEED", "[Highways/Streets].FF_SPEED", , , "False"}}, {"PK_SPEED", {"[Highways/Streets].PK_SPEED", "[Highways/Streets].PK_SPEED", , , "False"}}, {"[AB_CAP / BA_CAP]", {"[Highways/Streets].AB_CAP", "[Highways/Streets].BA_CAP", , , "False"}}, {"Alpha", {"[Highways/Streets].Alpha", "[Highways/Streets].Alpha", , , "False"}}, {"Beta", {"[Highways/Streets].Beta", "[Highways/Streets].Beta", , , "False"}}, {"[Base Count]", {"[Highways/Streets].[Base Count]", "[Highways/Streets].[Base Count]", , , "False"}}, {"Screenline", {"[Highways/Streets].Screenline", "[Highways/Streets].Screenline", , , "False"}}, {"FF_TT", {"[Highways/Streets].FF_TT", "[Highways/Streets].FF_TT", , , "True"}}, {"PK_TT", {"[Highways/Streets].PK_TT", "[Highways/Streets].PK_TT", , , "True"}}}
     Opts.Global.[Node Options].ZONE = {"Endpoints.ZONE", , }
     Opts.Global.[Length Unit] = "Miles"
     Opts.Global.[Time Unit] = "Minutes"
     Opts.Output.[Network File] = "S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.DBD|network.net"
 
           
     ret_value = RunMacro("TCB Run Operation", "Build Highway Network", Opts, &Ret)

     
// STEP 11: Highway Network Setting
     Opts = null
     Opts.Input.Database = "S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.DBD"
     Opts.Input.Network = "S:\\DVC\\Topeka Model\\Topeka Network\\network.net"
     Opts.Input.[Centroids Set] = {"S:\\DVC\\Topeka Model\\Topeka Network\\Topeka Network.DBD|Endpoints", "Endpoints", "Selection", "Select * where ZONE<>null"}
     Opts.Input.[Spc Turn Pen Table] = {"S:\\DVC\\Topeka Model\\Topeka Network\\TURNPEN.dbf"}
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}

     ret_value = RunMacro("TCB Run Operation", "Highway Network Setting", Opts, &Ret)

// Turn The Centroids On
    SetlayerVisibility("Highways/Streets"+"|"+"Endpoints", "True")
    SetLayer("Endpoints")
    SetDisplayStatus("Endpoints"+"|", "Invisible")
    SetDisplayStatus("Endpoints"+"|Selection", "Active")
    SetIcon("Endpoints"+"|Selection", "Font Character", "Caliper Cartographic|8", 36)
    SetIconColor("Endpoints"+"|Selection", colorRGB(0,30000,0))

        
// STEP 12: Create FT Map
     line_sty = RunMacro ("G30 setup line styles")
     colors = RunMacro ("G30 setup colors")

     SetMap(FT)
     SetLayer("Highways/Streets")
     solid = line_sty [2]
     dash = line_sty[6]

     map_styles = {solid, solid, solid, solid, solid, solid, solid, solid, dash}

     map_colors =  {colors[2],                     //Other 
                    colors[17],                   //Interstate(Blue)
			  colors[30],                   //Expressway (Brown)
                    colors[5],                     //Major Arterial (Red)
		  	  colors[25],                    //Minor Arterial  (Green)
		  	  colors[18],                    //Collector (Purple)
		  	  colors[1],                     //Local (Black)
		  	  colors[2],                     //Ramp (Grey)
		  	  colors[2]}                     //Connectors (Grey)                  


     map_widths = {0, 4, 3, 2, 1.5, 1, 1, 1, 0}  //Interstate to Connectors

     val_th = CreateTheme("Facility Type", "Highways/Streets.FT", "Categories",9,)

     SetThemeLineStyles(val_th, map_styles)
     SetThemeLineColors(val_th, map_colors)
     SetThemeLineWidths(val_th, map_widths)
     SetThemeClassLabels(val_th, {"Other", "Interstate", "Expressway", "Major Arterial", "Minor Arterial", "Collector", "Local", "Ramp", "Connectors"})
     Showtheme(, "Facility Type")    

//Map Legend
     RunMacro("G30 create legend")   
   
     stg = GetLegendSettings(FT)
     stg[2]={1, 0, 0, 0, 1, 4}
     stg[3]={1,1,1}
     stg[4][1] = "arial|Bold|18"  //Title font
     stg[4][2] = "arial|Bold|12"  //Footnote font
     stg[4][3] = "arial|Bold|14"  //Subtitle font
     stg[4][4] = "arial|Bold|12"  //Item font
     stg[5][1] = "Topeka Model" 
      
     SetLegendSettings(FT ,stg)

     SetLabels("Endpoints|", "Label", {{"Font", "Arial|Bold|10"},{"Alignment", "N"}})


     SaveMap(, "S:\\DVC\\Topeka Model\\Topeka Network\\Base Model Facility Type.map")  
     
     
quit:
   
     ret_value = RunMacro("TCB Run Operation", "Create FC Map", Opts, &Ret)

endMacro

//Trip Generation

Macro "Trip Gen" 
    RunMacro("TCB Init")

endMacro

