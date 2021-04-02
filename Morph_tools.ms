macroScript Morphtools
category:"Bromanche tools"
buttonText:"Morph tools"
tooltip:"Morph tools"
(
    rollout MorphRollout "Morph tools" width:230 height:140
    (
    	button 'SkinWrapTargetsArray' "store skin wrap targets" pos:[10,10] width:100 height:50 align:#left
        toolTip:"Selected object will be targets of skin wrap"
    	button 'addSkinWrap' " add skin wrap to selected" pos:[120,10] width:100 height:50 align:#left
		toolTip:"Add a skin wrap to the selected object(s)" 
    	button 'addMorph' "add morph to selected" pos:[10,70] width:100 height:50 align:#left
		toolTip:"Add a morph target to the selected object. Will only work if selected object is a duplicate of target object. Selected object must have '001' in it's name."  
		button 'animMorph' "animate morphs" pos:[120,70] width:100 height:50 align:#left enabled:True
        toolTip:"Animate morph taargets on selected objects"

    
        on SkinWrapTargetsArray pressed do
        (   
            Global sWrapTargets = selection as array
            Print sWrapTargets 
        )

        on addSkinWrap pressed do
        (
            addModifier $ (skin_wrap())
            $.skinwrap.meshlist = sWrapTargets
        )   

        on addMorph pressed do
        (
            for obj in selectedObjects = selection as array do
            (   
                select obj
                addModifier obj (Morpher())
                morphTarget = execute ("$"+ (substring obj.name 1 (obj.name.count - 3)))
                WM3_MC_BuildFromNode obj.morpher 1 morphTarget
                Print "morph added"
            )

        )
    
        on animMorph pressed do
        (
            with animate on  -- things done in here will be animated
            (	
                slidertime = 0
                for obj in selection do
                (
                    WM3_MC_SetValue obj.modifiers["morpher"] 1 0.0
                                
                )
            
                slidertime = 100
                for obj in selection do
                (
                    WM3_MC_SetValue obj.modifiers["morpher"] 1 100.0
                                
                )

            )
            redrawViews()

        )
    
    
    )
DestroyDialog MorphRollout
CreateDialog MorphRollout 

)
Print "morphtools ready"