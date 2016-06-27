// Output Directory Setup
Macro "Setup Output Folder"(Args)
    shared loop, taz_no, scen_data_dir, archive_type
    
    // Prepare output folder           
    RunMacro("Create Output Folder", Args)
     
    Return(1)
EndMacro

// Prepare output folder
Macro "Create Output Folder" (Args)
   shared scen_data_dir, archive_type
   
   // Check if output folder exists
   in_dir = scen_data_dir+"Input"
   out_dir = scen_data_dir+"Output"
   doesExist = GetDirectoryInfo(out_dir, "Folder") 
   
   // if (doesExist <> NULL & Args.ArchivePreviousOutput = 1) then do
   if (doesExist <> NULL & archive_type = 2) then do    
      // Rename existing output dir by dir date/time
      dateTime = doesExist[1][7]+"_"+ doesExist[1][8]  
      dateTime = Substitute(dateTime, ",", "", ) 
      dateTime = Substitute(dateTime, ":", "_", )
      dateTime = Substitute(dateTime, " ", "_", )
      old_out_dir = "Output_"+dateTime  
      old_in_dir = scen_data_dir+"Input_"+dateTime
      RunProgram('cmd /c ren '+  out_dir +" " +old_out_dir, {{"Minimize", "True"}})
      // RunProgram("xcopy /I /E " + in_dir +"\\*.* " + old_in_dir  +"\\*.*", {{"Minimize", "True"}})
            
      ftpr= OpenFile(scen_data_dir+"copyIO.bat","w")
      WriteLine(ftpr, "xcopy /I /E " + in_dir +" " + old_in_dir)
      CloseFile(ftpr)
      RunProgram(scen_data_dir+"copyIO.bat",{{"Minimize", "True"}})
      DeleteFile(scen_data_dir+"copyIO.bat")
   end    

   // if (doesExist <> NULL & Args.ArchivePreviousOutput = 0) then do
   if (doesExist <> NULL & archive_type = 1) then do    
      // Remove output directory
      RunProgram('cmd /c RMDIR '+  out_dir +" /s /Q ", {{"Minimize", "True"}}) 
   end 

   // Create a new output directory and copy input files
   CreateDirectory(out_dir)
   // Create output sub-folders
   subDirList = {"skims",
                 "tripgen",
                 "asgn",
                 "hwy",
                 "taz"}
                 
   for s = 1 to subDirList.length do
     CreateDirectory(out_dir+"\\"+subDirList[s])
   end
        
   // Copy Hwy database files 
   inHwyFile  = Args.[Input Highway DB]
   outHwyFile = Args.[Highway DB]
   CopyDatabase(inHwyFile,outHwyFile)
   
   // Copy Taz database files
   inTazFile  = Args.[Input TAZ DB]
   outTazFile = Args.[TAZ DB]
   CopyDatabase(inTazFile,outTazFile)
   
   // Get year
   year = Args.Year  
   if year > 2000  then 
    digit2_year = String(year - 2000) else 
    digit2_year = String(year) 
    
   fields_to_extract = {"ZONE", "DISTRICT","NODE TYPE", "SPECIAL", "HBW_P", "HBNW_P", "NHB_P", "HBW_A", "HBNW_A", "NHB_A"} 
   fields_to_extract_by_year =  {"HH", "RETAIL", "NON_RETAIL", "INCOME", "TOT_EMPLOY"}
   
   for f = 1 to fields_to_extract_by_year.length do
      fields_to_extract_by_year[f] = fields_to_extract_by_year[f] + digit2_year 
   end
   fields_to_extract = fields_to_extract + fields_to_extract_by_year
   
   // Copy SE data file
   inSEFile  = Args.[Input SE Data]
   outSEFile = Args.[SE Data] 
   sedata_vw = OpenTable("sedata","FFB",{inSEFile},) 
   ExportView(sedata_vw+"|","FFB",outSEFile,fields_to_extract,)
   CloseView(sedata_vw)
   
EndMacro


Macro "AreaType and Facility Type"(Args)
Shared scen_data_dir

// STEP 0: Get node and line layer names
   {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])

// STEP 1: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {Args.[Highway DB] + "|" + line_layer, line_layer}
     Opts.Global.Fields = {"Lookup"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "(FT * 10) + AT"    
     
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

// STEP 2: Fill Dataview
     // tb = OpenTable("tab", "ACCESS", {Args.[ACCESS Lookup Capacity], "Lookup", "Lookup"})
     // ExportView(tb+"|", "DBASE", Args.[Lookup Capacity], , )
     
     tb = OpenTable("tab", "DBASE", {Args.[Capacity Lookup]})
     jv = JoinViews("jv", line_layer + ".LookUp", tb + ".LookUp",)
     v = GetDataVector(jv + "|", tb + ".FC",)
     SetDataVector(jv + "|", line_layer+".FC", v,)
     CloseView(jv)
     CloseView(tb)
    // ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

// STEP 3: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{Args.[Highway DB] + "|" + line_layer, Args.[Capacity Lookup], {"Lookup"}, {"Lookup"}}, line_layer+"LookUp"}
     Opts.Global.Fields = {line_layer+".FF_SPEED"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.FF_SPEED"
     
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    

// STEP 4: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{Args.[Highway DB] + "|" + line_layer, Args.[Capacity Lookup], {"Lookup"}, {"Lookup"}}, line_layer+"LookUp"}
     Opts.Global.Fields = {line_layer +".PK_SPEED"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.PK_SPEED"
    
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    

// STEP 5: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{Args.[Highway DB] + "|" + line_layer, Args.[Capacity Lookup], {"Lookup"}, {"Lookup"}}, line_layer+"LookUp"}
     Opts.Global.Fields = {line_layer +".AB_CAP"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.AB_CAP * AB_Lanes"     
    
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    

// STEP 6: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{Args.[Highway DB] + "|" + line_layer, Args.[Capacity Lookup], {"Lookup"}, {"Lookup"}}, line_layer+"LookUp"}
     Opts.Global.Fields = {line_layer +".BA_CAP"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.BA_CAP * BA_Lanes"     
   
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    
    
// STEP 7: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{Args.[Highway DB] + "|" + line_layer, Args.[Capacity Lookup], {"Lookup"}, {"Lookup"}}, line_layer+"LookUp"}
     Opts.Global.Fields = {line_layer +".Alpha"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.Alpha"     
  
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)    
    

// STEP 8: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{Args.[Highway DB] + "|" + line_layer, Args.[Capacity Lookup], {"Lookup"}, {"Lookup"}}, line_layer+"LookUp"}
     Opts.Global.Fields = {line_layer +".Beta"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "LookUp.Beta"    
    
     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)


// STEP 9: Calculate FF and PK Travel Times 
     Opts = null
     Opts.Input.[Dataview Set] = {Args.[Highway DB] + "|" + line_layer}
     Opts.Global.Fields = {line_layer +".FF_TT"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "(Length*60)/FF_SPEED"

     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

     Opts = null
     Opts.Input.[Dataview Set] = {Args.[Highway DB] + "|" + line_layer}
     Opts.Global.Fields = {line_layer +".PK_TT"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "(Length*60)/PK_SPEED"

     ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)

EndMacro