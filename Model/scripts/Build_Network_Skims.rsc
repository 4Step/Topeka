Macro "Build Highway Network" (Args)

    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])
   

     // Build Highway Network
     Opts = null
     Opts.Input.[Link Set] = {Args.[Highway DB] + "|" + line_layer, line_layer}
     Opts.Global.[Network Options].[Node ID] = node_layer + ".ID"
     Opts.Global.[Network Options].[Link ID] = line_layer + ".ID"
     Opts.Global.[Network Options].[Turn Penalties] = "Yes"
     Opts.Global.[Network Options].[Keep Duplicate Links] = "FALSE"
     Opts.Global.[Network Options].[Ignore Link Direction] = "FALSE"
     Opts.Global.[Link Options] = {{"Length", line_layer+".Length", line_layer+".Length"},
          {"ID", line_layer+".ID", line_layer+".ID"},
          {"Length", line_layer+".Length", line_layer+".Length"},
          {"Dir", line_layer+".Dir", line_layer+".Dir"},
          {"[[AB Capacity] / [BA Capacity]]", line_layer+".[AB_CAP]", line_layer+".[BA_CAP]"},
          {"[Facility Type]", line_layer+".[FT]", line_layer+".[FT]"},
          {"[FF SPEED]", line_layer+".[FF_SPEED]", line_layer+".[FF_SPEED]"},
          {"[Congested SPEED]", line_layer+".[PK_SPEED]", line_layer+".[PK_SPEED]"},
          {"Alpha", line_layer+".Alpha", line_layer+".Alpha"},
          {"Beta", line_layer+".Beta", line_layer+".Beta"},
          {"[Travel Time]", line_layer+".[FF_TT]", line_layer+".[FF_TT]"},
          {"[Congested Travel Time]", line_layer+".[PK_TT]", line_layer+".[PK_TT]"}}
     Opts.Global.[Node Options] = {{"ID", "Endpoints.ID"}, 
          {"Longitude", node_layer+".Longitude"}, 
          {"Latitude", node_layer+".Latitude"}, 
          {"District", node_layer+".District"}, 
          {"ZONE", node_layer+".ZONE"}}
         
     Opts.Output.[Network File] = Args.[Hwy Net]


     ret_value = RunMacro("TCB Run Operation", 1, "Build Highway Network", Opts)

     return(ret_value)
EndMacro


Macro "Highway Network Setting" (Args)
    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])

     // Highway Network Setting
     Opts = null
     Opts.Input.Database = Args.[Highway DB]
     Opts.Input.Network = Args.[Hwy Net]
     Opts.Input.[Centroids Set] = {Args.[Highway DB]+"|" + node_layer, node_layer, "Selection", "Select * where ZONE>0"}
     Opts.Input.[Spc Turn Pen Table] = {Args.[Turn Pen]}
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}

     ret_value = RunMacro("TCB Run Operation", 2, "Highway Network Setting", Opts)
     return(ret_value)
EndMacro


Macro "Build Skims" (Args)      
     shared loop, run_type
     
    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])
     
     if run_type = 3 and loop_n > 1 then 
        minimize_field = "[Congested Travel Time]" else
           minimize_field = "[Travel Time]"
        
        
     // TCSPMAT
     Opts = null
     Opts.Input.Network = Args.[Hwy Net]
     Opts.Input.[Origin Set] = {Args.[Highway DB]+ "|" +node_layer, node_layer, "Selection", "Select * where ZONE>0"}
     Opts.Input.[Destination Set] = {Args.[Highway DB] + "|" +node_layer, node_layer, "Selection"}
     Opts.Input.[Via Set] = {Args.[Highway DB] + "|" +node_layer, node_layer}
     Opts.Field.Minimize = minimize_field // "[Travel Time]"
     Opts.Field.Nodes = node_layer + ".ID"
     Opts.Field.[Skim Fields] = {{"[Travel Time]", "All"}}
     Opts.Output.[Output Matrix].Label = "Shortest Path"
     Opts.Output.[Output Matrix].Compression = 1
     Opts.Output.[Output Matrix].[File Name] = Args.[HWY SKIM]

     ret_value = RunMacro("TCB Run Procedure", 1, "TCSPMAT", Opts)
     return(ret_value)
EndMacro


Macro "Intrazonal Times" (Args)
     // Compute intrazonal travel times
     Opts = null
     Opts.Input.[Matrix Currency] = {Args.[HWY SKIM], "[Travel Time] (Skim)", , }
     ret_value = RunMacro("TCB Run Procedure", 1, "Intrazonal", Opts)

     return(ret_value)
EndMacro


Macro "External Index" (Args)
    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])

     // Add EE Index
     Opts = null
     Opts.Input.[Current Matrix] = Args.[HWY SKIM]
     Opts.Input.[Index Type] = "Both"
     Opts.Input.[View Set] = {Args.[Highway DB]+ "|" + node_layer, node_layer, "External Stations", "Select * where [Node Type] = 'External Station'"}
     Opts.Input.[Old ID Field] = {Args.[Highway DB]+ "|" + node_layer, "ID"}
     Opts.Input.[New ID Field] = {Args.[Highway DB]+ "|" + node_layer, "ID"}
     Opts.Output.[New Index] = "External"
     ret_value = RunMacro("TCB Run Operation", "Add Matrix Index", Opts)
     return(ret_value)
      
EndMacro


Macro "Zero Out EE Skim Time" (Args)
     // Zero Out EE Travel Time
     Opts = null
     Opts.Input.[Matrix Currency] = {Args.[HWY SKIM], "[Travel Time]", "External", "External"}
     Opts.Global.Method = 1
     Opts.Global.Value = 0
     Opts.Global.[Cell Range] = 2
     Opts.Global.[Matrix Range] = 1
     Opts.Global.[Matrix List] = {"[Travel Time]", "[Travel Time] (Skim)"}
     ret_value = RunMacro("TCB Run Operation", "Fill Matrices", Opts)
     return(ret_value)
      
EndMacro
