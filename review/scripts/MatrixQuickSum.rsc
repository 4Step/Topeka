Macro "Batch Macro"
    RunMacro("TCB Init")
// STEP 1: Matrix QuickSum
     Opts = null
     Opts.Input.[Input Currency] = {"C:\\projects\\git_versions\\Topeka\\review\\Base\\PA2OD.mtx", "HBW (0-24)", "Rows", "Cols"}

     ret_value = RunMacro("TCB Run Operation", "Matrix QuickSum", Opts, &Ret)

     if !ret_value then goto quit


    quit:
         Return( RunMacro("TCB Closing", ret_value, True ) )
endMacro

