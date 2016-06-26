Macro "Batch Macro"
    RunMacro("TCB Init")
// STEP 1: PA2OD
     Opts = null
     Opts.Input.[PA Matrix Currency] = {"C:\\projects\\git_versions\\Topeka\\review\\Base\\cgrav.mtx", "HBW", "Row ID's", "Col ID's"}
     Opts.Input.[Lookup Set] = {"C:\\Program Files (x86)\\TransCAD2015\\tab\\hourly.bin", "HOURLY"}
     Opts.Field.[Matrix Cores] = {1, 2, 3}
     Opts.Field.[Adjust Fields] = {, , }
     Opts.Field.[Peak Hour Field] = {, , }
     Opts.Field.[Hourly AB Field] = {"HOUR", "HOUR", "HOUR"}
     Opts.Field.[Hourly BA Field] = {"HOUR", "HOUR", "HOUR"}
     Opts.Global.[Method Type] = "PA to OD"
     Opts.Global.[Start Hour] = 0
     Opts.Global.[End Hour] = 23
     Opts.Global.[Cache Size] = 500000
     Opts.Global.[Average Occupancies] = {1.1, 1.7, 1.8}
     Opts.Global.[Adjust Occupancies] = {"No", "No", "No"}
     Opts.Global.[Peak Hour Factor] = {1, 1, 1}
     Opts.Flag.[Separate Matrices] = "Yes"
     Opts.Flag.[Convert to Vehicles] = {"Yes", "Yes", "Yes"}
     Opts.Flag.[Include PHF] = {"No", "No", "No"}
     Opts.Flag.[Adjust Peak Hour] = {"No", "No", "No"}
     Opts.Output.[Output Matrix].Label = "PA to OD"
     Opts.Output.[Output Matrix].[File Name] = "C:\\projects\\git_versions\\Topeka\\review\\base\\PA2OD.mtx"

     ret_value = RunMacro("TCB Run Procedure", "PA2OD", Opts, &Ret)

     if !ret_value then goto quit


    quit:
         Return( RunMacro("TCB Closing", ret_value, True ) )
endMacro

