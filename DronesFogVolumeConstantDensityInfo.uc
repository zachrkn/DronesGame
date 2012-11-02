//==========================CLASS DECLARATION==================================
class DronesFogVolumeConstantDensityInfo extends FogVolumeConstantDensityInfo
    placeable;
	
//==========================EVENTS==========================================
event PostBeginPlay()
{
	super.PostBeginPlay();
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	bStatic=FALSE
	bNoDelete=FALSE
	
    Begin Object Name=AutomaticMeshComponent0
        StaticMesh=DronesPackage.Meshes.FogCube
    End Object
	
	Begin Object Name=FogVolumeComponent0
		//Density=0.0001
		Density=0.003
	End Object

}