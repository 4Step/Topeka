Macro "PA2OD" (Args)

     Opts = null
     Opts.Input.[PA Matrix Currency] = {Args.[PA MAT], "HBW", ,}
     Opts.Field.[Matrix Cores] = {1, 2, 3}
     Opts.Field.[Adjust Fields] = {, , }
     Opts.Field.[Peak Hour Field] = {, , }
     Opts.Global.[Method Type] = "PA to OD"
     Opts.Global.[Average Occupancies] = {1.1, 1.8, 1.7}
     Opts.Global.[Adjust Occupancies] = {"No", "No", "No"}
     Opts.Global.[Peak Hour Factor] = {0, 0, 0}
     Opts.Flag.[Separate Matrices] = "No"
     Opts.Flag.[Convert to Vehicles] = {"Yes", "Yes", "Yes"}
     Opts.Flag.[Include PHF] = {"No", "No", "No"}
     Opts.Flag.[Adjust Peak Hour] = {"No", "No", "No"}
     Opts.Output.[Output Matrix].Label = "PA to OD"
     Opts.Output.[Output Matrix].Compression = 1
     Opts.Output.[Output Matrix].[File Name] = Args.[OD MAT]
     ret_value = RunMacro("TCB Run Procedure", 1, "PA2OD", Opts)
     return(ret_value)
EndMacro


Macro "Daily Internal OD" (Args)      
// STEP 1 : Quick sum matrix
     Opts = null
     Opts.Input.[Input Currency] = {Args.[OD MAT], "HBW (0-24)", ,}
     ret_value = RunMacro("TCB Run Operation", "Matrix QuickSum", Opts)
     return(ret_value)
EndMacro

Macro "OD External Index" (Args)
    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])

     // Add EE Index
     Opts = null
     Opts.Input.[Current Matrix] = Args.[OD MAT]
     Opts.Input.[Index Type] = "Both"
     Opts.Input.[View Set] = {Args.[Highway DB]+ "|" + node_layer, node_layer, "External Stations", "Select * where [Node Type] = 'External Station'"}
     Opts.Input.[Old ID Field] = {Args.[Highway DB]+ "|" + node_layer, "ID"}
     Opts.Input.[New ID Field] = {Args.[Highway DB]+ "|" + node_layer, "ID"}
     Opts.Output.[New Index] = "External"
     ret_value = RunMacro("TCB Run Operation", "Add Matrix Index", Opts)
     return(ret_value)
EndMacro


Macro "Add EE Trips to OD" (Args)

     m = OpenMatrix(Args.[OD MAT],)
     AddMatrixCore(m, "Total")
     mc_Total = CreateMatrixCurrency(m,"Total", ,  ,)
     mc_QuickSum = CreateMatrixCurrency(m,"QuickSum", , ,)
     mc_Total := mc_QuickSum
        
     mc_Total = CreateMatrixCurrency(m,"Total", "External", "External" ,)
     mc_QuickSum = CreateMatrixCurrency(m,"QuickSum","External", "External" ,)
      
     m_EE = OpenMatrix(Args.[EE Trips],)
     mc_ee= CreateMatrixCurrency(m_EE,"Matrix 1", , ,)
     
     mc_Total := mc_QuickSum + mc_ee
     
     mc_ee = Null
     mc_QuickSum = Null
     mc_Total = Null
     m = Null
     m_EE = Null
     return(1)
EndMacro
 