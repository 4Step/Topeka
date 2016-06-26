Macro "Batch Macro"
    RunMacro("TCB Init")
    input_path = "c:\\projects\\git_versions\\topeka\\review\\base\\"
    output_path = "c:\\projects\\git_versions\\topeka\\review\\base\\"
// STEP 1: Network Settings
    Opts = null
    Opts.Input.Network = input_path + "Highway_Network.net"
    Opts.Input.Database = input_path + "Topeka Network.DBD"
    Opts.Global.[Link to Link Penalty Method] = "Internal"
    ok = RunMacro("TCB Run Operation", "Network Settings", Opts, &Ret)
    if !ok then goto quit
// STEP 2: Assignment
    Opts = null
    Opts.Input.Database = input_path + "Topeka Network.DBD"
    Opts.Input.Network = input_path + "Highway_Network.net"
    Opts.Input.[OD Matrix Currency] = {input_path + "PA2OD.mtx", "Total", "Rows", "Cols"}
    Opts.Field.[VDF Fld Names] = {"[Travel Time]", "[[AB Capacity] / [BA Capacity]]", "Alpha", "Beta", "None"}
    Opts.Global.[Load Method] = "CUE"
    Opts.Global.[Loading Multiplier] = 1
    Opts.Global.[N Conjugate] = 2
    Opts.Global.Convergence = 0.0001
    Opts.Global.Iterations = 500
    Opts.Global.[VDF DLL] = "bpr.vdf"
    Opts.Global.[VDF Defaults] = {, , 0.15, 4, 0}
    Opts.Output.[Flow Table] = output_path + "ASN_LinkFlow.bin"
    Opts.Output.[Iteration Log] = output_path + "IterationLog.bin"
    ok = RunMacro("TCB Run Procedure", "Assignment", Opts, &Ret)
    if !ok then goto quit
    quit:
        Return( RunMacro("TCB Closing", ok, True ) )
endMacro

