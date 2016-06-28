
Macro "Assignment Network Setting"(Args)

     //  Highway Network Setting
     Opts = null
     Opts.Input.Database = Args.[Highway DB]
     Opts.Input.Network = Args.[Hwy NET]
     Opts.Input.[Spc Turn Pen Table] = {Args.[Turn Pen]}
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}
     Opts.Flag.[Centroids in Network] = 1
     
     ret_value = RunMacro("TCB Run Operation", 1, "Highway Network Setting", Opts)
     return(ret_value)
     
EndMacro

Macro "Assignment" (Args)

    // TCAD 7 Assignment Method
    Opts = null
    Opts.Input.Network = Args.[Hwy Net]
    Opts.Input.Database = Args.[Highway DB]
    Opts.Global.[Link to Link Penalty Method] = "Internal"
    ok = RunMacro("TCB Run Operation", "Network Settings", Opts)
      
//  Assignment
    Opts = null
    Opts.Input.Database = Args.[Highway DB]
    Opts.Input.Network = Args.[Hwy Net]
    Opts.Input.[OD Matrix Currency] = {Args.[OD MAT], "Total", , }
    Opts.Field.[VDF Fld Names] = {"[Travel Time]", "[[AB Capacity] / [BA Capacity]]", "Alpha", "Beta", "None"}
    Opts.Global.[Load Method] = "CUE"
    Opts.Global.[Loading Multiplier] = 1
    Opts.Global.[N Conjugate] = 2
    Opts.Global.Convergence = Args.[conv]
    Opts.Global.Iterations = 500
    Opts.Global.[VDF DLL] = "bpr.vdf"
    Opts.Global.[VDF Defaults] = {, , 0.15, 4, 0}
    Opts.Output.[Flow Table] = Args.[Asgn link]
    Opts.Output.[Iteration Log] = Args.[ASGN ITER]
    ok = RunMacro("TCB Run Procedure", "Assignment", Opts)
    return(ok)

EndMacro

Macro "Add assignment fields to hwy" (Args)      
// Add assignment fields to hwy network
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])
   
     newfields = {"[Assignment Volume]", "[Congested Travel Time]"}
     asgfields = {"TOT_Flow", "AB_Time"} 
     addFields ={{ newfields[1], "Real", 10, 3},
                 { newfields[2], "Real", 10, 3}}
     RunMacro("TCB Add View Fields",{line_layer,addFields}) 
     CloseView(line_layer)
     CloseView(node_layer)
          

     for f = 1 to newfields.length do
        Opts = null
        Opts.Input.[Dataview Set] = {{Args.[Highway DB]+"|"+ line_layer, Args.[Asgn link], "ID", "ID1"}, line_layer+"ASN_LinkFlow"}
        Opts.Global.Fields = {newfields[f]}
        Opts.Global.Method = "Formula"
        Opts.Global.Parameter = asgfields[f] 
 
        ret_value = RunMacro("TCB Run Operation", 1, "Fill Dataview", Opts)

     end
     
     return(ret_value)
EndMacro
