/***

Bromanche V0.9  2020-09-07

60% of the time, it works every time!

A collecction of scripts to reduce clicks for the 3D4M 3Dream team.

TODO 
add undo catch to start and end of mirror script
add lowercase left right to search terms in renameLeftRight

***/


macroScript Bromanche
category:"Bromanche tools"
buttonText:"Bromanche"
tooltip:"Bromanche V0.9"
(
    rollout BromancheRollout "Bromanche V0.9" width:230 height:310
    (
    	button 'smthGrps' "Set smoothing" pos:[10,10] width:100 height:50 align:#left
    	button 'tRmv' "Remove turbosmooth" pos:[120,10] width:100 height:50 align:#left
		
    	button 'GetInstance' "Get instanced" pos:[10,70] width:100 height:50 align:#left
		toolTip:"select a modifer and click Get instanced to select objects sharing that modifier"  
		button 'addSufx' "Add R/L suffix" pos:[120,70] width:100 height:50 align:#left enabled:True
		
        button 'Rename' "Rename L/R" pos:[10,130] width:100 height:50 align:#left
        toolTip:"rename every object in a selection, which has Left or Right in it's name" 
    	button 'mirRename' "Mirror & rename" pos:[120,130] width:100 height:50 align:#left
		toolTip:"mirror and rename every object in a selection, which has Left or Right in it's name" 
		
    	button 'WeldVertLarge' "Weld 100" pos:[10,190] width:100 height:50 align:#left 
		button 'WeldVertSmall' "Weld .001" pos:[120,190] width:100 height:50 align:#left
		
    	button 'rmv001' "Remove 001" pos:[10,250] width:100 height:50 align:#left
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

        function renameLeftRight selectedObjects =
        (
            search= #("*Right001", "*Right", "*Left001", "*Left", "*right001", "*right", "*left001", "*left")
            suffx= #("Right001", "Right", "Left001", "Left", "right001", "right", "left001", "left")
            for obj in selectedObjects do
            (
                if obj.center[1] < 0 do
                (	
                    for i = 1 to suffx.count do
                    (    if matchPattern obj.name pattern:search[i] do
                            (
                            old_name= obj.name		
                            obj.name = substituteString old_name suffx[i] "Right"
                            )
                    )
                )
                
                if obj.center[1] > 0 do
                (
                    for i = 1 to suffx.count do
                    (    if matchPattern obj.name pattern:search[i] do
                            (
                            old_name= obj.name		
                            obj.name = substituteString old_name suffx[i] "Left"
                            )
                    )
                )
            
            )
        )
        

        --- Button scripts ---

        on addSufx pressed do
        (
            undo "add suffx" on  
            (   
             selectedObjects = selection as array
                for obj in selectedObjects do
                (   
                    if matchPattern obj.name pattern:"*_Right" or matchPattern obj.name pattern:"*_Left" then
                    (  (continue) )
						
					else
					if obj.center[1] < 0 then
					(obj.name =   obj.name + "_Right")
                        
					else 
					(obj.name =   obj.name + "_Left")
                        
                )
            )
        )

        on smthGrps pressed  do
        (   --- create and array of selected objects, 
            --- check if each is edit poly or editable poly,
            --- set smoothing group to 1 and print name

            if selection != undefined do
         selectedObjects = selection as array 
            for obj in selectedObjects do  
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
         selectedObjects = selection as array
            for obj in selectedObjects do
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



        on Rename pressed  do
        (   --- rename all objects with right or left in thier name, depending on their x position
            undo "renameLeftRight" on
                (selectedObjects = selection as array
                renameLeftRight selectedObjects)
        )

        on mirRename pressed do 
        (   undo "mirror and rename" on
            (
                selectedObjects = selection as array
                affectedObjects = #()
                mirroredObjects = #()
                mirrorRemoved = #()
                renameLeftRight selectedObjects       

                for Obj in selectedObjects do
                (	
                    if (matchPattern obj.name pattern:"*Right" or matchPattern obj.name pattern:"*Left") do
                    (	append affectedObjects obj
                        for index = Obj.modifiers.count to 1 by -1 do
                            (
                            if classOf Obj.modifiers[index] == TurboSmooth do
                               (deleteModifier Obj index )
                            if classOf Obj.modifiers[index] == Mirror  do
                               (deleteModifier Obj index 
                                append mirrorRemoved Obj)
                            )            

                        obvPvt = Obj.pivot
                        objLayer = Obj.layer
                        mirObj = copy Obj 
                        objLayer.addnode mirObj
                        mirObj.wirecolor = obj.wirecolor
                        addModifier mirObj (mirror())
                        objTM = mirObj.objecttransform
                        mirObj.mirror.Mirror_Center.position = (inverse objTM)[4]
                        convertTo mirObj Editable_Poly
                        mirObj.pivot = [obvPvt[1]*-1, obvPvt[2], obvPvt[3]]
                        print mirObj.name
                
                        append mirroredObjects mirObj
                
                    )
                )  

                renameLeftRight mirroredObjects 
                renameLeftRight mirrorRemoved  

                allObjects = #()
                join allObjects affectedObjects
                join allObjects mirroredObjects
                select allObjects
                print "mirrored selected" 
                redrawViews()	
            )
        )
    


    
     
        on tRmv pressed  do
        (    selectedObjects = selection as array
            for obj in selectedObjects do
                for index = obj.modifiers.count to 1 by -1 do
                    if ((classOf obj.modifiers[index]) == TurboSmooth) do
                        deleteModifier obj index  
        )
        
        on rmv001 pressed  do
        (   for x in selection do
            (if matchPattern x.name pattern:"*001" do
                ( old_name= x.name		
                    x.name = substituteString old_name "001" ""
                )		
            )
        )	
        



	)

DestroyDialog BromancheRollout
CreateDialog BromancheRollout 
)
Print "script updated"
 

/* 
lock unlock script
for i in selection do setTransformLockFlags i #all

--cui.RegisterDialogBar - to create docable toolbars
*/

macroScript ZPivot
category:"Bromanche tools"
buttonText:"zPivot"
tooltip:"Center pivot, zero out Z"
(
 selectedObjects = selection as array
    for obj in selectedObjects do 
    (   bb = nodeLocalBoundingBox obj
        objCenter = obj.center
        obj.pivot = [objCenter[1], objCenter[2], bb[1][3]]
    )
)  

macroScript HQ_display
category:"Bromanche tools"
buttonText:"HQ"
tooltip:"high quality viewport without shadows and AO"
(   vp = NitrousGraphicsManager.GetActiveviewportSetting()
    actionMan.executeAction -844228238 "12"  -- vp Lighting and Shadows: High Quality
        vp.ShadowsEnabled = 0
        vp.AmbientOcclusionEnabled = 1
)
macroScript Standard_display
category:"Bromanche tools"
buttonText:"Standard"
tooltip:"standard viewport"
(   vp = NitrousGraphicsManager.GetActiveviewportSetting()
    actionMan.executeAction -844228238 "13"  -- vp Lighting and Shadows: Standard

)  