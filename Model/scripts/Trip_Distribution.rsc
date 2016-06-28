Macro "Gravity Model" (Args)


    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])
   
// STEP 1: Gravity
     Opts = null
     Opts.Input.[PA View Set] = {{Args.[Highway DB] +"|"+ node_layer, Args.[QRM], "ID", "ID1"}, node_layer+"QRM_ALL", "Selection", "Select * where zone>0"}
     Opts.Input.[FF Matrix Currencies] = {{Args.[Hwy Skim], "[Travel Time]", , }, {Args.[Hwy Skim], "[Travel Time]", , }, {Args.[Hwy Skim], "[Travel Time]", , }}
     Opts.Input.[Imp Matrix Currencies] = {{Args.[Hwy Skim], "[Travel Time] (Skim)", , }, {Args.[Hwy Skim], "[Travel Time] (Skim)", , }, {Args.[Hwy Skim], "[Travel Time] (Skim)", , }}
     Opts.Input.[KF Matrix Currencies] = {{Args.[Hwy Skim], "[Travel Time]", , }, {Args.[Hwy Skim], "[Travel Time]", , }, {Args.[K Factors], "K-Factors", , }}
     Opts.Field.[Prod Fields] = {"["+node_layer+"QRM_ALL].QRM_ALL.HBW_P", "["+node_layer+"QRM_ALL].QRM_ALL.HBNW_P", "["+node_layer+"QRM_ALL].QRM_ALL.NHB_P"}
     Opts.Field.[Attr Fields] = {"["+node_layer+"QRM_ALL].QRM_ALL.HBW_A", "["+node_layer+"QRM_ALL].QRM_ALL.HBNW_A", "["+node_layer+"QRM_ALL].QRM_ALL.NHB_A"}
     Opts.Global.[Purpose Names] = {"HBW", "HBNW", "NHB"}
     Opts.Global.Iterations = {10, 10, 10}
     Opts.Global.Convergence = {0.01, 0.01, 0.01}
     Opts.Global.[Constraint Type] = {"Double", "Double", "Double"}
     Opts.Global.[Fric Factor Type] = {"Exponential", "Exponential", "Exponential"}
     Opts.Global.[A List] = {1, 1, 1}
     Opts.Global.[B List] = {0.3, 0.3, 0.3}
     Opts.Global.[C List] = {-0.10, 0.04, 0.02}
     Opts.Flag.[Use K Factors] = {0, 0, 1}
     Opts.Output.[Output Matrix].Label = "Output Matrix"
     Opts.Output.[Output Matrix].Compression = 1
     Opts.Output.[Output Matrix].[File Name] = Args.[PA MAT]


     ret_value = RunMacro("TCB Run Procedure", 1, "Gravity", Opts)

     return(ret_value)
     
EndMacro