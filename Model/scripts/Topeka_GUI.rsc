/*
 Title: Topeka Model 

 About: Main script that builds GUI and runs all model stages
 
 Description: 
 
 Authors: Amar Sarvepalli,Sarvepalli@pbworld.com
 Created: June-26-2016 

*/

// Checks installed tcad version
Macro "Topeka Model Version"
    model_version = 20160626
    required_tc_version = 7
    return({model_version, required_tc_build, required_tc_version})
EndMacro

Macro "OpenTopekaGUI"
  RunDbox("Topeka Model")
EndMacro


// Creates Model GUI
Dbox "Topeka Model"
    right, center toolbox nokeyboard
    title: "Topeka MPO Model"

    init do
        Shared project_dbox, scenario_dbox, ui_file, ScenArr, ScenSel, prj_dry_run, 
        StepFlagVec, scen_data_dir, loop_n, loop, run_type, feedbackConverge, BatchTimerOpts, BatchOptions, archive_type

        BatchTimerOpts.NoBatchTiming = True      
        BatchOptions.MatrixCompression = True

        Global FTGT_glob,c_0,c_1,c_2,Dcycle,Ddf
        Global d_wt,w_wt
                
        ui_file = GetInterface() 
        model_title = "Topeka Model"
        {ModelInfo, StageInfo, MacroInfo,} = RunMacro("TCP Load Model", model_title)

        {model_table,,,model_version,} = ModelInfo
        {StepMacro, StepTitle, StepFlag, StepAcce} = MacroInfo
        StageName = StageInfo[1]
        stages = StageName.length

        // if !RunMacro("TCP Update Scenarios in Project Dbox", scenario_file, &ScenArr, &ScenSel, &ScenNames, stages, 0, Args) then return()
        if !RunMacro("TCP Update Project Dbox", model_title, stages, &ScenNames) then return()
        if !RunMacro("TCP Convert Step Flags", StepFlag, StageName, &StepFlagVec) then return()
        RunMacro("feedback init")
        
        single_stage = 0        
        run_type = 1
        archive_type = 1
        project_dbox = 1
        feedbackConverge = 0
    enditem

    update do
      if project_dbox = -99 then
         RunMacro("closing")
      else do
        // if !RunMacro("TCP Update Scenarios in Project Dbox", scenario_file, &ScenArr, &ScenSel, &ScenNames, stages, 1, Args) then return()
        if !RunMacro("TCP Update Project Dbox", model_title, stages, &ScenNames) then return()
        if cur_loop <= loop_n then StepFlag = StepFlagVec[cur_loop] else StepFlag = StepFlagVec[all_loops]
      end
    endItem
    close do RunMacro("closing") endItem


    // Define User Interface
    // 1. Scenario settings
    button 1.5,0 icons: "bmp\\Topeka_Logo.bmp", "bmp\\Topeka_Logo.bmp"
    frame 0.5, 6.5, 40, 8.8 prompt: "Scenarios"
    Scroll List 1.5, 7.5, 32.0, 3.5 multiple list: ScenNames variable: ScenSel do
      RunMacro("TCP Update Scenarios", model_title, stages, model_table)
    endItem
    
    button 20, 12, 12.0, 2.0 prompt: "Setup" do
      RunDbox("TCP Scenario Manager", model_title, model_table)
    enditem   
     
    // Archive buttons
    radio list  1.5, 11.4, 16, 3.5 prompt: "Archive" variable: archive_type
    radio button 2, 12.6 prompt: "Overwrite"      help: "Overwrites Outputs"
    radio button 2, 13.8 prompt: "Archive"        help: "Archives Inputs & Outputs"

    // 2. Run and Feedback Loop Settings
    radio list  0.5, 15.7, 40, 6 prompt: "Run" variable: run_type
    radio button 2, 16.9 prompt: "Stage"      help: "Check to run one stage"
    radio button 14, Same prompt: "Loop"      help: "Check to run one loop"
    radio button 25, Same prompt: "All Loops" help: "Check to run all loops"
    
    popdown menu 28, 18.2, 7, 10 prompt: "Max. Feedback Loops"  list: MFB_List  variable: loop_n do
      RunMacro("update feedback")
    enditem
    popdown menu 28, 19.5, 7, 10 prompt: "Start Feedback Loop"  list: FB_List  variable: cur_loop do
       if cur_loop <= loop_n then StepFlag = StepFlagVec[cur_loop] else StepFlag = StepFlagVec[all_loops]
    enditem
    
    // Network button
    button "Topeka_A1" 1, 22 icons: "bmp\\plansetup.bmp" do cur_stage = 1  RunMacro("set steps") enditem
    button "Topeka_B1" after, same, 19.0, 1.6  prompt:StageName[1]  do cur_stage = 1  RunMacro("run stages") enditem
    button "Topeka_C1" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 1) enditem

    // Skimming button
    button "Topeka_A2" 1, After icons: "bmp\\planskim.bmp" do cur_stage = 2  RunMacro("set steps") enditem
    button "Topeka_B2" after, same, 19.0, 1.6  prompt:StageName[2]  do cur_stage = 2  RunMacro("run stages") enditem
    button "Topeka_C2" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 2) enditem

    // Trip Generation button
    button "Topeka_A3" 1, After icons: "bmp\\plantripgen.bmp" do cur_stage = 3  RunMacro("set steps") enditem
    button "Topeka_B3" after, same, 19.0, 1.6  prompt:StageName[3]  do cur_stage = 3  RunMacro("run stages") enditem
    button "Topeka_C3" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 3) enditem

    // Distribution Choice button
    button "Topeka_A4" 1, After icons: "bmp\\plantripdist.bmp" do cur_stage = 4  RunMacro("set steps") enditem
    button "Topeka_B4" after, same, 19.0, 1.6  prompt:StageName[4]  do cur_stage = 4  RunMacro("run stages") enditem
    button "Topeka_C4" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 4) enditem

    // PA to OD button
    button "Topeka_A5" 1, After icons: "bmp\\planmodesplit.bmp" do cur_stage = 5  RunMacro("set steps") enditem
    button "Topeka_B5" after, same, 19.0, 1.6  prompt:StageName[5]  do cur_stage = 5  RunMacro("run stages") enditem
    button "Topeka_C5" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 5) enditem

    // Highway Assignment button
    button "Topeka_A6" 1, After icons: "bmp\\planassign.bmp" do cur_stage = 6  RunMacro("set steps") enditem
    button "Topeka_B6" after, same, 19.0, 1.6  prompt:StageName[6]  do cur_stage = 6  RunMacro("run stages") enditem
    button "Topeka_C6" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 6) enditem

    // Create Map button
    button "Topeka_A7" 1, After icons: "bmp\\plannetwork.bmp" do cur_stage = 7  RunMacro("set steps") enditem
    button "Topeka_B7" after, same, 19.0, 1.6  prompt:StageName[7]  do cur_stage = 7  RunMacro("run stages") enditem
    button "Topeka_C7" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 7) enditem

    // Reporting button
    button "Topeka_A8" 1, After icons: "bmp\\planmatrix.bmp" do cur_stage = 8  RunMacro("set steps") enditem
    button "Topeka_B8" after, same, 19.0, 1.6  prompt:StageName[8]  do cur_stage = 8  RunMacro("run stages") enditem
    button "Topeka_C8" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 8) enditem

    // Quit button     
    button     1,  After, 40, 1.6  prompt: "Quit"      do Runmacro("closing") enditem
    text  25, after variable: "v " + i2s(model_version)

    // GUI Macros
    Macro "set steps" do
       SetAlternateInterface()
       RunDbox("TCP Set Step Flags", StepTitle[cur_stage], &StepFlag[cur_stage], StepAcce[cur_stage])
    enditem

    Macro "run stages" do
       scen_data_dir = ScenArr[ScenSel[1]][3]
       // - Create output and report folders if they do not exist already
       on error do
         goto lab1
       end
       CreateDirectory(scen_data_dir+"output")
       lab1:
       on error default
       on error do
         goto lab2
       end
       CreateDirectory(scen_data_dir+"Reports")
       lab2:
       on error default
       //
       
       repfile=scen_data_dir+"Reports\\TopekaModel.xml"
       logfile=scen_data_dir+"Reports\\TopekaLog.xml"
       // oldrepfile=GetReportFileName()
       // oldlogfile=GetLogFileName()
       SetReportFileName(repfile)
       SetLogFileName(logfile)
       shared d_LogInfo
       d_LogInfo.[Report File] = repfile
       d_LogInfo.[Log File]    = logfile
       
       ScenName = ScenArr[ ScenSel[1] ][1] 
       if run_type = 1 then single_stage = 1 else single_stage = 0 
       	x = {cur_stage, cur_loop, run_type, StepMacro, StepFlag, ScenArr, ScenSel}
       if RunMacro("TCP Check Stage Files", cur_stage, single_stage, StepFlag, ScenArr, ScenSel) then
       	  RunMacro("TCP Run Scen Stages", cur_stage, cur_loop, run_type, StepMacro, &StepFlag, ScenArr, ScenSel,)
       
       // if feedback converged then run last loop, last stage
       if feedbackConverge = 1 then do 
       	  cur_loop = loop_n+1
       	  cur_stage = 7
       end
       	         
       // if oldrepfile <> null then SetReportFileName(oldrepfile)
       // if oldlogfile <> null then SetLogFileName(oldlogfile)
       // shared d_LogInfo
       // d_LogInfo.[Report File] = oldrepfile
       // d_LogInfo.[Log File]    = oldlogfile 
       
       // vws = GetViewNames()
       // for i = 1 to vws.length do
       //    CloseView(vws[i])
       // end
    enditem

    Macro "closing" do
       if RunMacro("TCP Close Project Dbox") = 1 then return()
    enditem
      
    Macro "feedback init" do
      all_loops = StepFlagVec.length    // max. # of feedback loops
      loop_n = all_loops                // max. # of loops that can be chosen, excluding final-steps loop
      Dim MFB_List[loop_n]
      for i = 1 to loop_n do MFB_List[i] = i end
      RunMacro("update feedback")
    enditem

    Macro "update feedback" do
      FB_List = Subarray(MFB_List, 1, loop_n)+ {"Final"} 
      cur_loop = 1
      StepFlag = StepFlagVec[cur_loop]
    enditem
enddbox

Macro "addfields" (in_value)
   // This macro adds permanent fields to a table if they are not present
   fldnames = in_value[1]
   struct = GetTableStructure(in_value[2])
   viewflds = getFields(in_value[2],numeric)
   
   for i=1 to struct.length do
    struct[i]=struct[i]+{struct[i][1]}
   end

   for i=1 to fldnames.length do
      pos = ArrayPosition(viewflds[1],{fldnames[i]},)
      if pos = 0 then do
         newstr = newstr + {{fldnames[i],"Real", 10, 3,"false",null,null,null,null}}
         modtab = 1
      end
   end

   if modtab = 1 then do
     newstr = struct+newstr
     ModifyTable(in_value[2],newstr)
   end
EndMacro


Macro "CloseAllViews"
  vws = GetViewNames()
  for i = 1 to vws.length do
    ok =   CloseView(vws[i])
  end
  Return(ok)
EndMacro



/*-----------------------------**
** Syntax for "TCB ..." Macros **
**-----------------------------*/
/*
Macros used in batch run
========================

"TCB Init"                                                              initialize for a batch run

"TCB Closing"   (run_status, show_flag)                                 close a batch run
    run_status:     1 if batch run is successful; 0 otherwise
    show_flag :     1 if to display batch-run ending message; 0 otherwise

"TCB Error" (error_message)                                             report batch run error
    error_message:  message to put into the batch error file

"TCB Run Procedure" (step_idx, proc_name, Options, ReturnArray)         run a procedure
    step_idx:       integer, sub-step index for the procedure inside current batch step
    proc_name:      string, name of procedure to run
    Options:        array, options passed to the procedure
    ReturnArray:    array, values returned from the procedure
    Return:         integer, 1 if successful; 0 otherwise

"TCB Run Operation" (step_idx, oper_name, Options)                      run an operation
    step_idx:       integer, sub-step index for the operation inside current batch step
    oper_name:      string, name of operation to run
    Options:        array, options passed to the operation
    Return:         integer, 1 if successful; 0 otherwise

"TCB Run Macro" (step_idx, macro_name, Arguments)                       run a macro
    step_idx:       integer, sub-step index for the macro inside current batch step
    macro_name:     string, name of macro to run
    Arguments:      array, arguments passed to the macro
    Return:         integer, 1 if successful; 0 otherwise

"TCB Run Command" (step_idx, command_name, command_line)                run a DOS command-line program
    step_idx:       integer, sub-step index for the command inside current batch step
    macro_name:     string, name of command to run
    command_line:   string, path + name of the command-line program
    Return:         integer, 1 if successful; 0 otherwise

"TCB Add DB Layers" (db_file)                                           add database layers to workspace
    db_file:        database file (*.dbd, *.cdf)
    Return:         array of strings, actual names of layers opened

"TCB Add RS Layers" (rs_file, return_flag, new_map_flag)                add a route system to current or new map
    rs_file:        string, route system file (*.rts)
    return_flag:    string, "All" or null
    new_map_flag:   integer, 1 - to open a new map with the route system,
                             0 - add route system to current map
    Return:         array of strings, all layers in the route system if return_flag = "All", or
                    string, name of route system layer if return_flag <> "All"

"TCB OpenTable" (desired_view_name, table_type, table_spec)             open a table file
    ( for arguments and return values, see GISDK help on OpenTable() )

"TCB OpenMatrix" (file_name, file_based)                                open a matrix file
    ( for arguments and return values, see GISDK help on OpenMatrix() )

"TCB Add View Fields" ({view_name, Field_Info, Default_Values})         add/modify fields to/in a dataview
    view_name   string, name of dataview
    Field_Info  array, field specifications in the format of 
                {name, type[, width[, decimals[, indexing [, action[, position]]]]]},
                name      string, name of a field, or
                          array of strings, in the form of {start-field, end-field} for a range of fiends.
                type      string, value: integer|real|character
                indexing  strings,  value: true|yes|false|no
                width     integer, field width
                decimals  integer, number of decimals
                position  integer, desired position of field in question
                action    string, value: REFORMAT -- change format of existing field(s)
                                         REPLACE  -- replace an existing field at a position with new field(s)
                                         INSERT   -- insert new field(s) in a desired position
                                         APPEND   -- append new field(s) at the end of existing fields
    Default_Value   a single value to initialize all specified fields, or
                    an array of values to initialize each field
    Return:         integer, 1 if successful; 0 otherwise

"TCB Create Formula Fields" (view, Expressions, Field_names, Fields)    create formula fields in a view
    Expressions     array, expressions of formula fields
    Field_names     array of string, desired names of foumula fields
    Fields          array of string, returned actual names of formula fields created
    Return:         integer, 1 if successful; 0 otherwise

"TCB Assign TNet Set" (Set_info, option_name, set_name)                 assign a selection set into transit network
    Set_info        array of strings, {"None"} - to delete the specified selection set from network, or
                                      {db_file|layer, view_name, set_name, query}
                                            db_file:    database file path
                                            layer:      layer name on with selection set is based
                                            layer_name: desired name when layer is opened
                                            set_name:   name of the selection set
                                            query:      query to create the selection set
    option_name     string, name of selection set option to be stored in network
    set_name        string, name of selection set to be stored in network
    Return:         integer, 1 if successful; 0 otherwise

"TCB Balance" (view, PA_Flds, Methods, Weights)                         do production and attraction balancing
    view        string, name of dataview
    PA_Flds     array, in the format of {P_flds, A_flds}
                P_flds:  array of strings, field names of production fields for the purposes
                A_flds:  array of strings, field names of attraction fields for the purposes
    Methods     array of strings,  methods for all the purposes, value: "P"|"A"|"W"|"S"
                    P--hold by prod., A--hold by attraction, W--weighted sum, S--add to total
    Weights     array of real values, production weight for each purposes if method is "W"
                                      total amount for each purposes if method is "S"
    Return:     integer, 1 if successful; 0 otherwise

"TCB Save Set to Table" (Set_info, Fields, SortOrder, tb_file)          save a selection set to a table file
    Set_info    array, information on source of selection set, in the format of
                    view_name|set_name
                        view_name:  view name to save
                        set_name:   name of the selection set to save
                    {table_file, view_name, set_name, query}
                        table_file: table file path
                        view_name:  desired view name
                        set_name:   name of the selection set
                        query:      query to create selection set
                    {database file|layer, view_name, set_name, query}
                        see help on "TCB Assign TNet Set"
    Fields      array of strings, names of the fields to save
    SortOrder   not used
    tb_file     string, file path of the new table to which the selection set is saved
    Return:     integer, 1 if successful; 0 otherwise

"TCB Create Table" (tb_file, FldInfo, IDInfo)                           create a new table
    tb_file     string, file path of the table to be created 
    FldInfo     array, specifications of fields, in the format of 
                    {Names, Types, Widths, Decimals}
                        Names:      array of strings, name of fields
                        Types:      array of strings, value - "I"|"R"|"C"  (integer, real, string)
                        Widths:     array of integers, field widths
                        Decimals:   array of integers, number of decimals (ignored if field type is not real)
    IDInfo      array, information on ID values for the new table, in the format of
                    {source_view_file, source_id_field, sort_order}
                        source_view_file: array of strings, in the format of 
                            {table_file, view_name}         // get datview from a table 
                            {db_file|layer, view_name}      // get dataview from a layer in a geographical file
                        source_id_field: string, ID field in the source dataview
                        sort_order: array, as required in macro function GetRecordsValues()
    Return:     integer, 1 if successful; 0 otherwise

"TCB Get Data Vectors" (vw_info, Fields)                  get data vectors based for fields in a dataview
    vw_info     string, table file name, or view name, or view|set
    Fields      array of strings,  names of fields for data vectors; null for all fields
    Return:     option array, containing data vectors for specified fields
*/

