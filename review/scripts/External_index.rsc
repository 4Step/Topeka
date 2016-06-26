Macro "Batch Macro"
    RunMacro("TCB Init")
// STEP 1: Add Matrix Index
     Opts = null
     Opts.Input.[Current Matrix] = "C:\\projects\\git_versions\\Topeka\\review\\Base\\PA2OD.mtx"
     Opts.Input.[Index Type] = "Both"
     Opts.Input.[View Set] = {"C:\\projects\\git_versions\\Topeka\\review\\Base\\Topeka Network.DBD|Endpoints", "Endpoints", "Ext Stn", "Select * where [Node Type] = 'External Station'"}
     Opts.Input.[Old ID Field] = {"C:\\projects\\git_versions\\Topeka\\review\\Base\\Topeka Network.DBD|Endpoints", "ID"}
     Opts.Input.[New ID Field] = {"C:\\projects\\git_versions\\Topeka\\review\\Base\\Topeka Network.DBD|Endpoints", "ID"}
     Opts.Output.[New Index] = "New"

     ret_value = RunMacro("TCB Run Operation", "Add Matrix Index", Opts, &Ret)

     if !ret_value then goto quit


    quit:
         Return( RunMacro("TCB Closing", ret_value, True ) )
endMacro

