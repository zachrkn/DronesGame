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
	local rotator r;
	local int currentAdd;
	local int index;
	local int index2;
	local int index3; 
	local int levels;
/*
	currentAdd = 0;
	levels = (int(RandRange(2,2)));

	for(index = 0; index < levels; index++){
	for(index2 = 0; index2 < (levels/2); index2++){
	for(index3 = 0; index3 < levels; index3++){
		v.X = -(BrickSize.X * index3);
		v.Y = -(BrickSize.Y * index2); 
		v.Z = BrickSize.Z * index;
		BrickRelativeLocationsArray[currentAdd] = v; 

		r.Pitch = 0; 
		r.Yaw = 0; 
		r.Roll = 0;
		BrickRelativeRotationsArray[currentAdd] = r;
		currentAdd++;
	}
	}
	}
*/
	v.X = 0;
	v.Y = 0;
	v.Z = 0;
	BrickRelativeLocationsArray[0] = v; 
	
	v.X = 40;
	v.Y = 0;
	BrickRelativeLocationsArray[1] = v; 
	
	v.X = 0;
	v.Y = 80;
	BrickRelativeLocationsArray[2] = v; 
	
	v.X = 40;
	v.Y = 80;
	BrickRelativeLocationsArray[3] = v; 
	
	v.X = 0;
	v.Y = 0;
	v.Z = 40;
	BrickRelativeLocationsArray[4] = v; 
	
	v.X = 40;
	v.Y = 0;
	BrickRelativeLocationsArray[5] = v; 
	
	v.X = 0;
	v.Y = 80;
	BrickRelativeLocationsArray[6] = v; 
	
	v.X = 40;
	v.Y = 80;
	BrickRelativeLocationsArray[7] = v; 
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