Macro "Creat FT Map" (Args)

    //  Get node and line layer names
    {node_layer, line_layer} = RunMacro("TCB Add DB Layers", Args.[Highway DB])
     FT = RunMacro("G30 new map",Args.[Highway DB], "False")

     line_sty = RunMacro ("G30 setup line styles")
     colors = RunMacro ("G30 setup colors")

     SetMap(FT)
     SetLayer(line_layer)
     solid = line_sty [2]
     dash = line_sty[6]

     map_styles = {solid, solid, solid, solid, solid, solid, solid, solid, dash}

     map_colors =  {colors[2],                     //Other 
                    colors[17],                   //Interstate(Blue)
			  colors[30],                   //Expressway (Brown)
                    colors[5],                     //Major Arterial (Red)
		  	  colors[25],                    //Minor Arterial  (Green)
		  	  colors[18],                    //Collector (Purple)
		  	  colors[1],                     //Local (Black)
		  	  colors[2],                     //Ramp (Grey)
		  	  colors[2]}                     //Connectors (Grey)                  


     map_widths = {0, 4, 3, 2, 1.5, 1, 1, 1, 0}  //Interstate to Connectors

     val_th = CreateTheme("Facility Type", line_layer+".FT", "Categories",9,)

     SetThemeLineStyles(val_th, map_styles)
     SetThemeLineColors(val_th, map_colors)
     SetThemeLineWidths(val_th, map_widths)
     SetThemeClassLabels(val_th, {"Other", "Interstate", "Expressway", "Major Arterial", "Minor Arterial", "Collector", "Local", "Ramp", "Connectors"})
     Showtheme(, "Facility Type")    

//Map Legend
     RunMacro("G30 create legend")   
   
     stg = GetLegendSettings(FT)
     stg[2]={1, 0, 0, 0, 1, 4}
     stg[3]={1,1,1}
     stg[4][1] = "arial|Bold|18"  //Title font
     stg[4][2] = "arial|Bold|12"  //Footnote font
     stg[4][3] = "arial|Bold|14"  //Subtitle font
     stg[4][4] = "arial|Bold|12"  //Item font
     stg[5][1] = "Topeka Model" 
      
     SetLegendSettings(FT ,stg)

     SetLabels("Endpoints|", "Label", {{"Font", "Arial|Bold|10"},{"Alignment", "N"}})
     SaveMap(, Args.[FT Map])  
     
     return(1)
     
endMacro
