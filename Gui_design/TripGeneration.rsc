Macro "Trip Generation QRM All" (Args)
    RunMacro("TCB Init")
   // Get year
   year = Args.Year  
   if year > 2000  then 
    digit2_year = String(year - 2000) else 
    digit2_year = String(year)

     //  QRM All
     Opts = null
     Opts.Input.[Zone View] = {Args.[SE Data],"SE_Data" }
     Opts.Input.[Zone Set] = {Args.[SE Data],"SE_Data" }
     Opts.Input.[Production Table] = {Args.[Prod Rates]}
     Opts.Input.[Attraction Table] = {Args.[Attr Rates]}
     Opts.Field.[Total HH] = "SE_Data.HH"+digit2_year
     Opts.Field.Dwelling = "SE_Data.HH"+digit2_year
     Opts.Field.[Retail Employment] = "SE_Data.RETAIL"+digit2_year
     Opts.Field.[Non-Ret Employment] = "SE_Data.NON_RETAIL"+digit2_year
     Opts.Field.Income = "SE_Data.INCOME"+digit2_year
     Opts.Field.[Ext Productions] = {"SE_Data.HBW_P", "SE_Data.HBNW_P", "None", "SE_Data.NHB_P"}
     Opts.Field.[Ext Attractions] = {"SE_Data.HBW_A", "SE_Data.HBNW_A", "None", "SE_Data.NHB_A"}
     Opts.Field.[Zone Type] = "SE_Data.SPECIAL"
     Opts.Field.[Zone Code] = 0
     Opts.Global.[Model Option] = "Prod & Attr"
     Opts.Global.[Classify By] = 2
     Opts.Global.Population = 100
     Opts.Global.[Production Option] = "Rates HH"
     Opts.Global.[Income Option] = "Income Based"
     Opts.Global.[Balance Method] = "Hold Productions"
     Opts.Global.[Number of Purposes] = 4
     Opts.Global.[Ext Names] = {"HBW", "HBNW", "HBO", "NHB"}
     Opts.Output.[Output Table] = Args.[QRM]
     //ret_value = RunMacro("TCB Run Procedure", 1, "QRM All", Opts)
     ok = RunMacro("TCB Run Procedure", "QRM All", Opts)
     Return(ok)
EndMacro


Macro "NHB Adjust"(Args)

     Opts = null
     Opts.Input.[Dataview Set] = {Args.[QRM], "QRM_ALL"}
     Opts.Global.Fields = {"NHB_P"}
     Opts.Global.Method = "Formula"
     Opts.Global.Parameter = "NHB_A"
     ret_value = RunMacro("TCB Run Operation", 1, "Fill Dataview", Opts)
     return(ret_value)
     
EndMacro