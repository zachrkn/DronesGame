//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintCube extends DronesStructureBlueprint;

//==========================VARIABLES==========================================
var int NumLayers;

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
		
		NumLayers = RandRange(2,20);

		for(index = 0; index < NumLayers; index++){
		
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
				BrickRelativeLocationsArray[currentAdd] = v; currentAdd++;
		
		}




}

function SetBrickRelativeRotationsArray()
{
	local int i;
	local rotator r;
	r.Pitch = 0; r.Yaw = 0; r.Roll = 0;
	for (i=0; i<NumLayers*15; i++)
	{
		BrickRelativeRotationsArray[i] = r;
	}
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	NumLayers=10
}