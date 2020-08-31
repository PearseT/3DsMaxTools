/***

Bro-manche V 0.0.4  2020-08-17

60% of the time, it works every time!

A collecction of scripts to reduce clicks for the 3D4M 3Dream team.

***/


macroScript Bromanche
category:"Bromanche tools"
tooltip:"Start Bromanche"
(
    rollout BromancheRollout "Bromanche" width:230 height:310
    (
    	button 'smthGrps' "Set smoothing" pos:[10,10] width:100 height:50 align:#left
    	button 'tRmv' "Remove turbosmooth" pos:[120,10] width:100 height:50 align:#left
		
    	button 'Get Instance' "Get instanced" pos:[10,70] width:100 height:50 align:#left
		toolTip:"select a modifer and click Get instanced to select objects sharing that modifier"  
		button 'temp' "===" pos:[120,70] width:100 height:50 align:#left enabled:false
		
    	button 'Rename' "Rename L/R" pos:[10,130] width:100 height:50 align:#left
    	button 'mirRename' "Mirror & rename" pos:[120,130] width:100 height:50 align:#left
		toolTip:"mirror and rename every object in a selection, which has Left or Right in it's name" 
		
    	button 'WeldVertLarge' "Weld 100" pos:[10,190] width:100 height:50 align:#left 
		button 'WeldVertSmall' "Weld .001" pos:[120,190] width:100 height:50 align:#left
		
    	--button 'btn9' "--" pos:[10,250] width:100 height:50 align:#left
    	--button 'btn10' "---" pos:[120,250] width:100 height:50 align:#left   
        
        --- Functions ---

        function weldVertex obj weldTreshold =
        (
            if classof obj == PolyMeshObject then
            (             
                theEditPolyMod = modPanel.getCurrentObject()        
                theEditPolyMod.weldVertexThreshold = weldTreshold
                theEditPolyMod.buttonOp #weldVertex
            )
    
            if classOf obj == Editable_Poly then
            (
                
                obj.weldThreshold = weldTreshold
                undo on obj.EditablePoly.weldFlaggedVertices ()
            )
            else
                (
                    print "not editpoly !"
                )
        )

        --- Button scripts ---

        on smthGrps pressed  do
        (   --- create and array of selected objects, 
            --- check if each is edit poly or editable poly,
            --- set smoothing group to 1 and print name

            if selection != undefined do
            selected_objects = selection as array 
            for obj in selected_objects do  
            (
                if classof obj == Editable_Poly do
                (
                    num_faces = polyop.getNumfaces obj
                    faces = (for i in 1 to num_faces collect i) as bitarray
                    polyOp.setFaceSmoothGroup obj faces 1
                )
                    
                if classof obj == PolyMeshObject do
                (   
                for index = obj.modifiers.count to 1 by -1 do
                    (
                        if ((classOf obj.modifiers[index]) == Edit_Poly) do
                        (
                            modi = obj.modifiers[index]
                            modi.SetEPolySelLevel #face

                            max modify mode
                            modpanel.setcurrentobject modi
                            
                            modi.select #face #{1..modi.getnumfaces()}
                            modi.smoothinggroupstoclear = -1
                            modi.setoperation #setsmooth
                            modi.smoothinggroupstoset = 1

                            modi.SetEPolySelLevel #Object
                        )
                    )

                )
                print (obj.name as string + " smoothing groups set to 1")
            )
        )
         
    on WeldVertSmall pressed  do
    (    weldVertex selection[1] .001
        
        )
        
    on WeldVertLarge pressed  do
    (    weldVertex selection[1] 100
        
        )

    on Trmv pressed  do
    (
        theObjects = selection as array
        for obj in theObjects do
            for index = obj.modifiers.count to 1 by -1 do
                if ((classOf obj.modifiers[index]) == TurboSmooth) do
                    deleteModifier obj index 
        
        )
    on GetInstance pressed  do
    ( ---get object sharing instance from modifer stack selection
        modifiers = #()
        stack_obj = modPanel.getCurrentObject()
        modifiers = refs.dependentNodes stack_obj
        select modifiers 
        )

     )
DestroyDialog BromancheRollout
CreateDialog BromancheRollout 
)
Print "Done1"
/*

    
    on Rename pressed  do
    (   --- rename all objects with right or left in thier name, depending on their x position
        --- this should really be a function
        theObjects = selection as array
        search= #("*Right001", "*Right", "*Left001", "*Left")
	    suffx= #("Right001", "Right", "Left001", "Left")
        for obj in theObjects do
        (
            if obj.center[1] < 0 do
            (	print obj.name
                for i = 1 to suffx.count do
                (    if matchPattern obj.name pattern:search[i] do
                        (print i
                        old_name= obj.name		
                        obj.name = substituteString old_name suffx[i] "Right"
                        )
                )
            )
            
            if obj.center[1] > 0 do
            (	print obj.name
                for i = 1 to suffx.count do
                (    if matchPattern obj.name pattern:search[i] do
                        (print i
                        old_name= obj.name		
                        obj.name = substituteString old_name suffx[i] "Left"
                        )
                )
            )
        
        )
    )

    --- notes rename should be a function, in this script i want to run it once on every object before i mirror, adn then collect the mirrored object and run it again on them.
    on mirRename pressed do 
    (   theObjects = selection as array
        
        search= #("*Right001", "*Right", "*Left001", "*Left")
        suffx= #("Right001", "Right", "Left001", "Left")

        listOfObjects = #()
        tMod = TurboSmooth()

        --- for loop to mirror and collaps objects in selection
        for Obj in theObjects do
        (	
            if (matchPattern obj.name pattern:"*Right" or matchPattern obj.name pattern:"*Left") do
            (	---need to check if mirrored object exists
                for index = Obj.modifiers.count to 1 by -1 do
                    (if ((classOf Obj.modifiers[index]) == TurboSmooth or (classOf Obj.modifiers[index]) == Mirror ) do
                                deleteModifier Obj index 
                    )
                
                
                mirObj = copy Obj 
                addModifier mirObj (mirror())
                objTM = mirObj.objecttransform
                mirObj.mirror.Mirror_Center.position = (inverse objTM)[4]
                convertTo mirObj Editable_Poly
                print mirObj.name
        
                append listOfObjects Obj
                append listOfObjects mirObj
        
            )
        )		
    
        for obj in listOfObjects do
        (--- rename all objects with suffx depending on x direction
            if obj.center[1] < 0 do
            (	print obj.name
                for i = 1 to suffx.count do
                (    if matchPattern obj.name pattern:search[i] do
                        (print i
                        old_name= obj.name		
                        obj.name = substituteString old_name suffx[i] "Right"
                        )
                )
            )
            
             if obj.center[1] > 0 do
            (	print obj.name
                for i = 1 to suffx.count do
                (    if matchPattern obj.name pattern:search[i] do
                        (print i
                        old_name= obj.name		
                        obj.name = substituteString old_name suffx[i] "Left"
                        )
                )
            )   
        )
    )
    
        
    )
    on tRmv pressed  do
    (    theObjects = selection as array
        for obj in theObjects do
            for index = obj.modifiers.count to 1 by -1 do
                if ((classOf obj.modifiers[index]) == TurboSmooth) do
                    deleteModifier obj index  
        )
		
	)
)
DestroyDialog BromancheRollout
CreateDialog BromancheRollout



/* 
lock unlock script
for i in selection do setTransformLockFlags i #all



*/