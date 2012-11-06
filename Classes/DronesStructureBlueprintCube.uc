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
		
	v.X = 0; 				v.Y = 0; 				v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[15] = v;
	v.X = 0; 				v.Y = BrickSize.Y; 		v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[16] = v;
	v.X = 0; 				v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[17] = v;
	v.X = BrickSize.X; 		v.Y = 0; 				v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[18] = v;
	v.X = BrickSize.X; 		v.Y = BrickSize.Y; 		v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[19] = v;
	v.X = BrickSize.X; 		v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[20] = v;
	v.X = BrickSize.X * 2; 	v.Y = 0; 				v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[21] = v;
	v.X = BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[22] = v;
	v.X = BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[23] = v;
	v.X = -BrickSize.X; 	v.Y = 0; 				v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[24] = v;
	v.X = -BrickSize.X; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[25] = v;
	v.X = -BrickSize.X; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[26] = v;
	v.X = -BrickSize.X * 2; 	v.Y = 0; 				v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[27] = v;
	v.X = -BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[28] = v;
	v.X = -BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z;
		BrickRelativeLocationsArray[29] = v;
		
	v.X = 0; 				v.Y = 0; 				v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[30] = v;
	v.X = 0; 				v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[31] = v;
	v.X = 0; 				v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[32] = v;
	v.X = BrickSize.X; 		v.Y = 0; 				v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[33] = v;
	v.X = BrickSize.X; 		v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[34] = v;
	v.X = BrickSize.X; 		v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[35] = v;
	v.X = BrickSize.X * 2; 	v.Y = 0; 				v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[36] = v;
	v.X = BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[37] = v;
	v.X = BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[38] = v;
	v.X = -BrickSize.X; 	v.Y = 0; 				v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[39] = v;
	v.X = -BrickSize.X; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[40] = v;
	v.X = -BrickSize.X; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[41] = v;
	v.X = -BrickSize.X * 2; 	v.Y = 0; 				v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[42] = v;
	v.X = -BrickSize.X * 2; 	v.Y = BrickSize.Y; 		v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[43] = v;
	v.X = -BrickSize.X * 2; 	v.Y = -BrickSize.Y; 	v.Z = BrickSize.Z * 2;
		BrickRelativeLocationsArray[44] = v;

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