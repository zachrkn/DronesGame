//==========================CLASS DECLARATION==================================
class DronesBrickPhantom extends KActor
    placeable;
	
	
//==========================VARIABLES==========================================
var MaterialInstanceConstant matInst;

//==========================EVENTS==========================================
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	LoseCollision();
	SetPhysics(PHYS_None);
	SetMaterial();
}



//==========================FUNCTIONS==========================================\
function SetMaterial()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInterface ThisMaterialInterface01;
	local MaterialInstanceConstant ThisMaterialInstanceConstant;
	local float CurrentOpacity;
	
	ThisMaterialInterface01 = MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetMaterial(0, ThisMaterialInterface01);
	}
	
	matInst = new(None) Class'MaterialInstanceConstant';
    matInst.SetParent(StaticMeshComponent.GetMaterial(0));
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetMaterial(0, matInst);
	}
	
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisMaterialInstanceConstant = ThisStaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
	}
	ThisMaterialInstanceConstant.GetScalarParameterValue('Opacity', CurrentOpacity);
	ThisMaterialInstanceConstant.SetScalarParameterValue('Opacity',0.8F);
	ThisMaterialInstanceConstant.GetScalarParameterValue('Opacity', CurrentOpacity);
}


function LoseCollision()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	// set the collision so the target brick no longer collides with the other bricks
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetBlockRigidBody(FALSE);
		ThisStaticMeshComponent.SetTraceBlocking(FALSE, FALSE);
	}
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bWakeOnLevelStart=TRUE
	bStatic=FALSE
	bNoDelete=FALSE
	bBlockActors=TRUE
	bMovable=TRUE
	bCollideActors=TRUE
	
	bNoEncroachCheck=FALSE
	
	bPawnCanBaseOn=TRUE
	bCanStepUpOn=FALSE

	Begin Object Name=StaticMeshComponent0
        StaticMesh=DronesPackage.Meshes.Brick_large_mesh

		BlockRigidBody=TRUE
		CollideActors=TRUE
		BlockActors=TRUE
		bNotifyRigidBodyCollision=TRUE
		ScriptRigidBodyCollisionThreshold=0.0001
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		RBChannel=RBCC_Untitled2
		RBCollideWithChannels=(Default=TRUE, GameplayPhysics=FALSE, Untitled1=FALSE, Untitled2=TRUE)
		
		MaxDrawDistance=0
    End Object
/*
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bOwnerNoSee=FALSE
		BlockRigidBody=FALSE
		CollideActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockActors=FALSE
		bNotifyRigidBodyCollision=FALSE
		HiddenEditor=TRUE
		HiddenGame=TRUE
		//What to change if you'd like to use your own meshes and animations
	  SkeletalMesh=SkeletalMesh'DronesPackage.SkeletalMeshes.brick_large_skeletalmesh'
	End Object
	Components.Add(InitialSkeletalMesh);
*/
}

