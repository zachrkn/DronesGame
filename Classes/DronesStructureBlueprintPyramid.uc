//==========================CLASS DECLARATION==================================
class DronesStructureBlueprintPyramid extends DronesStructureBlueprint;

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

	v.X = 0; 				v.Y = 0; 				v.Z = 0;
		BrickRelativeLocationsArray[0] = v;
	v.X = 0; 				v.Y = BrickSize.Y; 		v.Z = 0;
		BrickRelativeLocationsArray[1] = v;
	v.X = 0; 				v.Y = -BrickSize.Y; 	v.Z = 0;
		BrickRelativeLocationsArray[2] = v;
	v.X = BrickSize.X; 		v.Y = 0; 				v.Z = 0;
		BrickRelativeLocationsArray[3] = v;
	v.X = BrickSize.X; 		v.Y = BrickSize.Y; 		v.Z = 0;
		BrickRelativeLocationsArray[4] = v;
	v.X = BrickSize.X; 		v.Y = -BrickSize.Y; 	v.Z = 0;
		BrickRelativeLocationsArray[5] = v;
	v.X = BrickSize.X * 2; 	v.Y = 0; 				v.Z = 0;
		BrickRelativeLocationsArray[6] = v;
	v.X = BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = 0;
		BrickRelativeLocationsArray[7] = v;
	v.X = BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = 0;
		BrickRelativeLocationsArray[8] = v;
	v.X = -BrickSize.X; 	v.Y = 0; 				v.Z = 0;
		BrickRelativeLocationsArray[9] = v;
	v.X = -BrickSize.X; 	v.Y = BrickSize.Y; 		v.Z = 0;
		BrickRelativeLocationsArray[10] = v;
	v.X = -BrickSize.X; 	v.Y = -BrickSize.Y; 	v.Z = 0;
		BrickRelativeLocationsArray[11] = v;
	v.X = -BrickSize.X * 2; 	v.Y = 0; 				v.Z = 0;
		BrickRelativeLocationsArray[12] = v;
	v.X = -BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = 0;
		BrickRelativeLocationsArray[13] = v;
	v.X = -BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = 0;
		BrickRelativeLocationsArray[14] = v;

	v.X = BrickSize.X; 		v.Y = BrickSize.Y / 2; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[15] = v;
	v.X = BrickSize.X; 		v.Y = -BrickSize.Y / 2; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[16] = v;
	v.X = 0; 				v.Y = BrickSize.Y / 2; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[17] = v;
	v.X = 0; 				v.Y = -BrickSize.Y / 2; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[18] = v;
	v.X = -BrickSize.X; 	v.Y = BrickSize.Y / 2; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[19] = v;
	v.X = -BrickSize.X; 	v.Y = -BrickSize.Y / 2; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[20] = v;
	
	v.X = 0;				v.Y = 0;				v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[21] = v;

}

function SetBrickRelativeRotationsArray()
{
	local int i;
	local rotator r;
	r.Pitch = 0; r.Yaw = 0; r.Roll = 0;
	for (i=0; i<22; i++)
	{
		BrickRelativeRotationsArray[i] = r;
	}
}