visual studio shortcuts ctr+k for keyboard short cuts 
ctrl + p for command pallett




--- smooht script
selected_objects = selection as array 
for mirObj in selected_objects do  
(
    if classof mirObj == Editable_Poly do
    (
        num_faces = polyop.getNumfaces mirObj
        faces = (for i in 1 to num_faces collect i) as bitarray
        polyOp.setFaceSmoothGroup mirObj faces 1
    )
        
    if classof mirObj == PolyMeshObject do
    (   
       for index = mirObj.modifiers.count to 1 by -1 do
        (
            if ((classOf mirObj.modifiers[index]) == Edit_Poly) do
            (
                modi = mirObj.modifiers[index]
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
    print (mirObj.name as string + " smoothing groups set to 1")
)
        
--- weld script

spinner to set weld ammount

then set weld threshold to spinnerA push weld


---mirror and rename
listOfObjects = #()
tMod = TurboSmooth()
theObjects = selection as array

for Obj in theObjects do
(	
	if (matchPattern obj.name pattern:"*Right" or matchPattern obj.name pattern:"*Left") do
	--- should be a better way of checking this in an array
	(	
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
	(
		addModifier obj (copy tMod)
	)
	)






