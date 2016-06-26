Macro "Batch Macro"
    RunMacro("TCB Init")
ProjectPath="C:\\projects\\git_versions\\Topeka\\review\\Base"
year = 10
//---------------------------------------------------TRIP GENERATION-----------------------------------------------------------
// STEP 1: QRM All
     Opts = null
     Opts.Input.[Zone View] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints"}
     Opts.Input.[Zone Set] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints", "Selection", "Select * where ZONE>0"}
     Opts.Input.[Production Table] = {ProjectPath+"\\prod_tgp.dbf"}
     Opts.Input.[Attraction Table] = {ProjectPath+"\\attr_tgp.dbf"}
     Opts.Field.[Total HH] = "Endpoints.HH"+String(year)
     Opts.Field.Dwelling = "Endpoints.HH"+String(year)
     Opts.Field.[Retail Employment] = "Endpoints.RETAIL"+String(year)
     Opts.Field.[Non-Ret Employment] = "Endpoints.NON_RETAIL"+String(year)
     Opts.Field.Income = "Endpoints.INCOME"+String(year)
     Opts.Field.[Ext Productions] = {"Endpoints.HBW_P", "Endpoints.HBNW_P", "None", "Endpoints.NHB_P"}
     Opts.Field.[Ext Attractions] = {"Endpoints.HBW_A", "Endpoints.HBNW_A", "None", "Endpoints.NHB_A"}
     Opts.Field.[Zone Type] = "Endpoints.SPECIAL"
     Opts.Field.[Zone Code] = 0
     Opts.Global.[Model Option] = "Prod & Attr"
     Opts.Global.[Classify By] = 2
     Opts.Global.Population = 100
     Opts.Global.[Production Option] = "Rates HH"
     Opts.Global.[Income Option] = "Income Based"
     Opts.Global.[Balance Method] = "Hold Productions"
     Opts.Global.[Number of Purposes] = 4
     Opts.Global.[Ext Names] = {"HBW", "HBNW", "HBO", "NHB"}
     Opts.Output.[Output Table] = ProjectPath+"\\QRM_ALL.bin"


     ret_value = RunMacro("TCB Run Procedure", 1, "QRM All", Opts)

     if !ret_value then goto quit

// STEP 1: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {ProjectPath+"\\QRM_ALL.bin", "QRM_ALL"}
     Opts.Global.Fields = {"NHB_P"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "NHB_A"


     ret_value = RunMacro("TCB Run Operation", 1, "Fill Dataview", Opts)

     if !ret_value then goto quit
//---------------------------------------------------BUILD NETWORK-----------------------------------------------------------

// STEP 1: Build Highway Network
     Opts = null
     Opts.Input.[Link Set] = {ProjectPath+"\\Topeka Network.DBD|Highways/Streets", "Highways/Streets"}
     Opts.Global.[Network Options].[Node ID] = "Endpoints.ID"
     Opts.Global.[Network Options].[Link ID] = "[Highways/Streets].ID"
     Opts.Global.[Network Options].[Turn Penalties] = "Yes"
     Opts.Global.[Network Options].[Keep Duplicate Links] = "FALSE"
     Opts.Global.[Network Options].[Ignore Link Direction] = "FALSE"
     Opts.Global.[Link Options] = {{"Length", "[Highways/Streets].Length", "[Highways/Streets].Length"},
          {"ID", "[Highways/Streets].ID", "[Highways/Streets].ID"},
          {"Length", "[Highways/Streets].Length", "[Highways/Streets].Length"},
          {"Dir", "[Highways/Streets].Dir", "[Highways/Streets].Dir"},
          {"[2010 Count]", "[Highways/Streets].[2010 Count]", "[Highways/Streets].[2010 Count]"},
          {"[2004 Count]", "[Highways/Streets].[2004 Count]", "[Highways/Streets].[2004 Count]"},
          // {"[Daily Capacity]", "[Highways/Streets].[Daily Capacity]", "[Highways/Streets].[Daily Capacity]"},
          {"[[AB Capacity] / [BA Capacity]]", "[Highways/Streets].[AB_CAP]", "[Highways/Streets].[BA_CAP]"},
          {"[Facility Type]", "[Highways/Streets].[FT]", "[Highways/Streets].[FT]"},
          {"[FF SPEED]", "[Highways/Streets].[FF_SPEED]", "[Highways/Streets].[FF_SPEED]"},
          {"[Congested SPEED]", "[Highways/Streets].[PK_SPEED]", "[Highways/Streets].[PK_SPEED]"},
          {"Alpha", "[Highways/Streets].Alpha", "[Highways/Streets].Alpha"},
          {"Beta", "[Highways/Streets].Beta", "[Highways/Streets].Beta"},
          {"Screenline", "[Highways/Streets].Screenline", "[Highways/Streets].Screenline"},
          {"[2004 Assignment]", "[Highways/Streets].[2004 Assignment]", "[Highways/Streets].[2004 Assignment]"},
          {"[Travel Time]", "[Highways/Streets].[FF_TT]", "[Highways/Streets].[FF_TT]"},
          {"[Congested Travel Time]", "[Highways/Streets].[PK_TT]", "[Highways/Streets].[PK_TT]"}}
     Opts.Global.[Node Options] = {{"ID", "Endpoints.ID"}, 
          {"Longitude", "Endpoints.Longitude"}, 
          {"Latitude", "Endpoints.Latitude"}, 
          {"District", "Endpoints.District"}, 
          {"ZONE", "Endpoints.ZONE"}, 
          {"TOT_EMLOY", "Endpoints.TOT_EMPLOY"+String(year)}, 
          {"RET", "Endpoints.RETAIL"+String(year)}, 
          {"NON_RET", "Endpoints.NON_RETAIL"+String(year)}, 
          {"HH", "Endpoints.HH"+String(year)}, 
         // {"HH_POP", "Endpoints.HH_POP"+String(year)}, 
          {"INCOME", "Endpoints.INCOME"+String(year)}, 
          {"SPECIAL", "Endpoints.SPECIAL"}, 
          {"HBW_P", "Endpoints.HBW_P"}, 
          {"HBNW_P", "Endpoints.HBNW_P"}, 
          {"NHB_P", "Endpoints.NHB_P"}, 
          {"HBW_A", "Endpoints.HBW_A"}, 
          {"HBNW_A", "Endpoints.HBNW_A"}, 
          {"NHB_A", "Endpoints.NHB_A"}, 
          {"S_HBW_P", "Endpoints.S_HBW_P"}, 
          {"S_HBNW_P", "Endpoints.S_HBNW_P"}, 
          {"S_NHB_P", "Endpoints.S_NHB_P"}, 
          {"S_HBW_A", "Endpoints.S_HBW_A"}, 
          {"S_HBNW_A", "Endpoints.S_HBNW_A"}, 
          {"S_NHB_A", "Endpoints.S_NHB_A"} /*, 
          {"[Through Adjustment]", "Endpoints.[Through Adjustment]"}, 
          {"[Left Adjustment]", "Endpoints.[Left Adjustment]"}, 
          {"[Immediate Right Adjustment]", "Endpoints.[Immediate Right Adjustment]"}, 
          {"[Other Movements Adjustment]", "Endpoints.[Other Movements Adjustment]"}, 
          {"[Cycle Length]", "Endpoints.[Cycle Length]"}, 
          {"[Minimum Unsignalized Capacity]", "Endpoints.[Minimum Unsignalized Capacity]"}, 
          {"[U-Turns Allowed (0=no, 1=yes)]", "Endpoints.[U-Turns Allowed (0=no, 1=yes)]"}, 
          {"[Intrazonal Travel Time]", "Endpoints.[Intrazonal Travel Time]"}, 
          {"[INTRAZONAL TRIPS ==>:1]", "Endpoints.[INTRAZONAL TRIPS ==>:1]"}, 
          {"[Average Autos/Household]", "Endpoints.[Average Autos/Household]"}, 
          {"[Intrazonal Travel Time:1]", "Endpoints.[Intrazonal Travel Time:1]"}, 
          {"[INTRAZONAL TRIPS ==>]", "Endpoints.[INTRAZONAL TRIPS ==>]"}, 
          {"[TOTAL INCOME]", "Endpoints.[TOTAL INCOME]"} */ }
     Opts.Output.[Network File] = ProjectPath+"\\Highway_Network.net"


     ret_value = RunMacro("TCB Run Operation", 1, "Build Highway Network", Opts)

     if !ret_value then goto quit

// STEP 2: Highway Network Setting
     Opts = null
     Opts.Input.Database = ProjectPath+"\\Topeka Network.DBD"
     Opts.Input.Network = ProjectPath+"\\Highway_Network.net"
     Opts.Input.[Centroids Set] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints", "Selection", "Select * where ZONE>0"}
     Opts.Input.[Spc Turn Pen Table] = {ProjectPath+"\\TURNPEN.DBF"}
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}


     ret_value = RunMacro("TCB Run Operation", 2, "Highway Network Setting", Opts)

     if !ret_value then goto quit

//---------------------------------------------------TRIP DISTRIBUTION-----------------------------------------------------------

// STEP 1: TCSPMAT
     Opts = null
     Opts.Input.Network = ProjectPath+"\\Highway_Network.NET"
     Opts.Input.[Origin Set] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints", "Selection", "Select * where ZONE>0"}
     Opts.Input.[Destination Set] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints", "Selection"}
     Opts.Input.[Via Set] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints"}
     Opts.Field.Minimize = "[Travel Time]"
     Opts.Field.Nodes = "Endpoints.ID"
     Opts.Field.[Skim Fields] = {{"[Travel Time]", "All"}}
     Opts.Output.[Output Matrix].Label = "Shortest Path"
     Opts.Output.[Output Matrix].Compression = 1
     Opts.Output.[Output Matrix].[File Name] = ProjectPath+"\\SPMAT.mtx"


     ret_value = RunMacro("TCB Run Procedure", 1, "TCSPMAT", Opts)

     if !ret_value then goto quit

// STEP 2: Intrazonal
     Opts = null
     Opts.Input.[Matrix Currency] = {ProjectPath+"\\SPMAT.mtx", "[Travel Time] (Skim)", , }
     ret_value = RunMacro("TCB Run Procedure", 1, "Intrazonal", Opts)

     if !ret_value then goto quit


// STEP 3A: Add Matrix Index
     Opts = null
     Opts.Input.[Current Matrix] = ProjectPath+"\\SPMAT.mtx"
     Opts.Input.[Index Type] = "Both"
     Opts.Input.[View Set] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "Endpoints", "External Stations", "Select * where [Node Type] = 'External Station'"}
     Opts.Input.[Old ID Field] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "ID"}
     Opts.Input.[New ID Field] = {ProjectPath+"\\Topeka Network.DBD|Endpoints", "ID"}
     Opts.Output.[New Index] = "External"
     ret_value = RunMacro("TCB Run Operation", "Add Matrix Index", Opts)
     if !ret_value then goto quit

// STEP 3B: Zero Out E-E
/*     Opts = null
     Opts.Input.[Matrix Currency] = {ProjectPath+"\\SPMAT.mtx", "[Travel Time] (Skim)", , }
     Opts.Input.[Formula Currencies] = {{ProjectPath+"\\SPMAT-Ext.mtx", "[1]", "Origin", "Destination"}}
     Opts.Global.Method = 11
     Opts.Global.[Cell Range] = 2
     Opts.Global.[Expression Text] = "[Shortest].[[1]]* [[Travel Time] (Skim)]"
     Opts.Global.[Formula Labels] = {"Shortest"}
     Opts.Global.[Force Missing] = "Yes"
     ret_value = RunMacro("TCB Run Operation", 1, "Fill Matrices", Opts)
     if !ret_value then goto quit
*/
     Opts = null
     Opts.Input.[Matrix Currency] = {ProjectPath+"\\SPMAT.mtx", "[Travel Time]", "External", "External"}
     Opts.Global.Method = 1
     Opts.Global.Value = 0
     Opts.Global.[Cell Range] = 2
     Opts.Global.[Matrix Range] = 1
     Opts.Global.[Matrix List] = {"[Travel Time]", "[Travel Time] (Skim)"}
     ret_value = RunMacro("TCB Run Operation", "Fill Matrices", Opts)
     if !ret_value then goto quit



// STEP 1: Gravity
     Opts = null
     Opts.Input.[PA View Set] = {{ProjectPath+"\\Topeka Network.dbd|Endpoints", ProjectPath+"\\QRM_ALL.bin", "ID", "ID1"}, "Endpoints+QRM_ALL", "Selection", "Select * where zone>0"}
     Opts.Input.[FF Matrix Currencies] = {{ProjectPath+"\\SPMAT.mtx", "[Travel Time]", , }, {ProjectPath+"\\SPMAT.mtx", "[Travel Time]", , }, {ProjectPath+"\\SPMAT.mtx", "[Travel Time]", , }}
     Opts.Input.[Imp Matrix Currencies] = {{ProjectPath+"\\SPMAT.mtx", "[Travel Time] (Skim)", , }, {ProjectPath+"\\SPMAT.mtx", "[Travel Time] (Skim)", , }, {ProjectPath+"\\SPMAT.mtx", "[Travel Time] (Skim)", , }}
     Opts.Input.[KF Matrix Currencies] = {{ProjectPath+"\\SPMAT.mtx", "[Travel Time]", , }, {ProjectPath+"\\SPMAT.mtx", "[Travel Time]", , }, {ProjectPath+"\\K_Factors.mtx", "K-Factors", , }}
     Opts.Field.[Prod Fields] = {"[Endpoints+QRM_ALL].QRM_ALL.HBW_P", "[Endpoints+QRM_ALL].QRM_ALL.HBNW_P", "[Endpoints+QRM_ALL].QRM_ALL.NHB_P"}
     Opts.Field.[Attr Fields] = {"[Endpoints+QRM_ALL].QRM_ALL.HBW_A", "[Endpoints+QRM_ALL].QRM_ALL.HBNW_A", "[Endpoints+QRM_ALL].QRM_ALL.NHB_A"}
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
     Opts.Output.[Output Matrix].[File Name] = ProjectPath+"\\cgrav.mtx"


     ret_value = RunMacro("TCB Run Procedure", 1, "Gravity", Opts)

     if !ret_value then goto quit

//---------------------------------------------------PA TO OD-----------------------------------------------------------

// STEP 1: PA2OD
     Opts = null
     Opts.Input.[PA Matrix Currency] = {ProjectPath+"\\cgrav.mtx", "HBW", "Row ID's", "Col ID's"}
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
     Opts.Output.[Output Matrix].[File Name] = ProjectPath+"\\PA2OD.mtx"


     ret_value = RunMacro("TCB Run Procedure", 1, "PA2OD", Opts)

     if !ret_value then goto quit

// STEP 2: Add E-E Trips to OD
     Opts = null
     Opts.Input.[Matrix Currency] = {ProjectPath+"\\PA2OD_Sum.mtx", "QuickSum", "Rows", "Columns"}
     Opts.Input.[Formula Currencies] = {{ProjectPath+"\\PA2OD.mtx", "HBW (0-24)", "Rows", "Cols"}}
     Opts.Global.Method = 11
     Opts.Global.[Cell Range] = 2
     Opts.Global.[Expression Text] = "[PA to OD].[HBW (0-24)]+ [PA to OD].[HBNW (0-24)]+ [PA to OD].[NHB (0-24)]"
     Opts.Global.[Formula Labels] = {"PA to OD"}
     Opts.Global.[Force Missing] = "Yes"


     ret_value = RunMacro("TCB Run Operation", 1, "Fill Matrices", Opts)

     if !ret_value then goto quit

// STEP 3: Fill Matrices
     Opts = null
     Opts.Input.[Matrix Currency] = {ProjectPath+"\\PA2OD_Sum.mtx", "Total", "Rows", "Columns"}
     Opts.Global.Method = 11
     Opts.Global.[Cell Range] = 2
     Opts.Global.[Expression Text] = "[Matrix 1]+ [QuickSum]"
     Opts.Global.[Force Missing] = "Yes"


     ret_value = RunMacro("TCB Run Operation", 2, "Fill Matrices", Opts)

     if !ret_value then goto quit


//---------------------------------------------------ASSIGNMENT-----------------------------------------------------------

// STEP 1: Highway Network Setting
     Opts = null
     Opts.Input.Database = ProjectPath+"\\Topeka Network.DBD"
     Opts.Input.Network = ProjectPath+"\\Highway_Network.net"
     Opts.Input.[Spc Turn Pen Table] = {ProjectPath+"\\35MODELTURNPENALTIES.BIN"}
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}
     Opts.Flag.[Centroids in Network] = 1


     ret_value = RunMacro("TCB Run Operation", 1, "Highway Network Setting", Opts)

     if !ret_value then goto quit

// STEP 2: Assignment
     Opts = null
     Opts.Input.Database = ProjectPath+"\\Topeka Network.DBD"
     Opts.Input.Network = ProjectPath+"\\Highway_Network.net"
     Opts.Input.[OD Matrix Currency] = {ProjectPath+"\\PA2OD_Sum.mtx", "Total", "Rows", "Columns"}
     Opts.Field.[FF Time] = "[Travel Time]"
     Opts.Field.Capacity = "[[AB Capacity] / [BA Capacity]]"
     Opts.Field.Alpha = "Alpha"
     Opts.Field.Beta = "Beta"
     Opts.Field.Preload = "None"
     Opts.Global.[Load Method] = 6
     Opts.Output.[Flow Table] = ProjectPath+"\\ASN_LinkFlow.bin"


     ret_value = RunMacro("TCB Run Procedure", 2, "Assignment", Opts)

     if !ret_value then goto quit

// STEP 3: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{ProjectPath+"\\Topeka Network.dbd|Highways/Streets", ProjectPath+"\\ASN_LinkFlow.bin", "ID", "ID1"}, "Highways/Streets+ASN_LinkFlow"}
     Opts.Global.Fields = {"[2034 Assignment]"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "TOT_Flow"


     ret_value = RunMacro("TCB Run Operation", 1, "Fill Dataview", Opts)

     if !ret_value then goto quit

// STEP 4: Fill Dataview
     Opts = null
     Opts.Input.[Dataview Set] = {{ProjectPath+"\\Topeka Network.dbd|Highways/Streets", ProjectPath+"\\ASN_LinkFlow.bin", "ID", "ID1"}, "Highways/Streets+ASN_LinkFlow"}
     Opts.Global.Fields = {"[Congested Travel Time]"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "AB_Time"


     ret_value = RunMacro("TCB Run Operation", 2, "Fill Dataview", Opts)

     if !ret_value then goto quit



    quit:
         Return( RunMacro("TCB Closing", ret_value, True ) )
endMacro
