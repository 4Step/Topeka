Macro "Batch Macro"
    RunMacro("TCB Init")
// STEP 1: Fill Matrices
     Opts = null
     Opts.Input.[Matrix Currency] = {"C:\\projects\\git_versions\\Topeka\\review\\Base\\SPMAT.mtx", "[Travel Time]", "External", "External"}
     Opts.Global.Method = 1
     Opts.Global.Value = 0
     Opts.Global.[Cell Range] = 2
     Opts.Global.[Matrix Range] = 1
     Opts.Global.[Matrix List] = {"[Travel Time]", "[Travel Time] (Skim)"}

     ret_value = RunMacro("TCB Run Operation", "Fill Matrices", Opts, &Ret)

     if !ret_value then goto quit


    quit:
         Return( RunMacro("TCB Closing", ret_value, True ) )
endMacro

