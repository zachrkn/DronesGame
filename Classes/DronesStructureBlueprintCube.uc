//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintCube extends DronesStructureBlueprint;

//==========================EVENTS==========================================
event PostBeginPlay()
{
	SetBrickRelativeLocationsArray();
	SetBrickRelativeRotationsArray();
	InitializeBrickWorldLocationsAndRotationsArrays();
}

//==========================FUNCTIONS==========================================
function SetBrickRelativeLocationsArray()
{
	local vector v;
	local int currentAdd;
	local int index;
	
		currentAdd = 0;

		for(index = 0; index < 100; index++){
		
			v.X = 0; 				v.Y = 0; 				v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = 0; 				v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = 0; 				v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = BrickSize.X; 		v.Y = 0; 				v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = BrickSize.X; 		v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = BrickSize.X; 		v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = BrickSize.X * 2; 	v.Y = 0; 				v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = -BrickSize.X; 	v.Y = 0; 				v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = -BrickSize.X; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = -BrickSize.X; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = -BrickSize.X * 2; 	v.Y = 0; 				v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = -BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * index;
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
			v.X = -BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * index;
		
		}




}

function SetBrickRelativeRotationsArray()
{
	local int i;
	local rotator r;
	r.Pitch = 0; r.Yaw = 0; r.Roll = 0;
	for (i=0; i<45; i++)
	{
		BrickRelativeRotationsArray[i] = r;
	}
}