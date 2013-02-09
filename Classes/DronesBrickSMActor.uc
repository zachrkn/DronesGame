//==========================CLASS DECLARATION==================================
class DronesBrickSMActor extends StaticMeshActor
//class DronesBrickSMActor extends DynamicSMActor
//class DronesBrickSMActor extends Actor
    placeable;
	
//==========================VARIABLES==========================================
var DronesBrickShell BrickParentShell;

var float TimeToNextPhysCheck;

var array<vector> VelArray;
var int NumTicksVelAtZero;
//==========================EVENTS==========================================
/*
event Tick(float DeltaTime)
{

	local DronesGravityVolume GVol;
	
	TimeToNextPhysCheck -= DeltaTime;


	if( Physics == PHYS_RigidBody )
	{
		CheckVelocityAndDisablePhysicsIfInStasis();
	}


	if( TimeToNextPhysCheck <= 0 )
	{
		if( IsSpaceUnderneath() )
		{
			`Log("Brick: " $Self$ " and there is space underneath, so i'm setting physics to RigidBody");
			SetPhysics(PHYS_RigidBody);
		}


		`Log("Brick: " $Self$ " setting physics to RigidBody!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		SetPhysics(PHYS_RigidBody);

		TimeToNextPhysCheck = RandRange(100, 150) / 10.0;
	}
	
	foreach TouchingActors(class'DronesGravityVolume', GVol)
	{
		if( GVol.GravityZ == 0 )
		{
			SetPhysics(PHYS_None);
		}
	}
}
*/

event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
//	`Log("RBC! Brick: "$Self$" Location: "$Location$" OtherComponent: "$OtherComponent$ " OtherComponent.Owner: "$OtherComponent.Owner);
//	`Log("RigidCollisionData.TotalNormalForceVector: " $RigidCollisionData.TotalNormalForceVector);
//	`Log("RigidCollisionData.TotalFrictionForceVector: " $RigidCollisionData.TotalFrictionForceVector);
/*	
	if( 	(RigidCollisionData.TotalNormalForceVector.X > 40) || (RigidCollisionData.TotalNormalForceVector.X < -40) ||
		(RigidCollisionData.TotalNormalForceVector.Y > 40) || (RigidCollisionData.TotalNormalForceVector.Y < -40) ||
		(RigidCollisionData.TotalNormalForceVector.Z > 40) || (RigidCollisionData.TotalNormalForceVector.Z < -40) )
	{
		`Log("Brick: " $Self$ " RBC SO STRONG that I'm Calling ParentShell function to replace SMBrick with KBrick! WHoopie kayyah mother fucker!");
		BrickParentShell.DestroySMBrickAndSpawnKBrick();
	}
*/
}
//==========================FUNCTIONS==========================================
function CheckVelocityAndDisablePhysicsIfInStasis()
{
	local vector RunningAverage;
	local vector ThisVel;

//	`Log("Brick: " $Self$ " velocity: " $Velocity);
	
	VelArray.AddItem(Velocity);
	
	if( VelArray.Length > 100)
	{
		VelArray.Remove(0,1);
	}
	
	foreach VelArray(ThisVel)
	{
		RunningAverage.X += Abs(ThisVel.X);
		RunningAverage.Y += Abs(ThisVel.Y);
		RunningAverage.Z += Abs(ThisVel.Z);
	}
	
	RunningAverage.X /= VelArray.Length;
	RunningAverage.Y /= VelArray.Length;
	RunningAverage.Z /= VelArray.Length;
	
	if( (RunningAverage.X < 1) && (RunningAverage.Y < 1) && (RunningAverage.Z < 1) )
	{
		NumTicksVelAtZero++;
	}
	else
	{
		NumTicksVelAtZero=0;
	}

	if( NumTicksVelAtZero>3 )
	{
//		`Log("Brick: " $Self$ " I've been in stasis for a while, so disabling physics");
		SetPhysics(PHYS_None);
	}
}

function SetBrickParentShell(DronesBrickShell BrickParent)
{
	BrickParentShell = BrickParent;
}


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	TimeToNextPhysCheck=10
	
	bStatic=FALSE
	bNoDelete=FALSE
	bBlockActors=TRUE
	bMovable=TRUE
	bCollideActors=TRUE
//	bCollideWorld=TRUE
	
	bNoEncroachCheck=FALSE
	
	bCanStepUpOn=FALSE
	
//	bCallRigidBodyWakeEvents=TRUE
	
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
//		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
		Materials[0]=MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';
    End Object
/*
	Begin Object class=CylinderComponent Name=MyCollisionComponent
		CollisionRadius=+0010.000000
		CollisionHeight=+0010.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		Translation=(X=0.0000000,Y=0.00000000,Z=0.00000000 )
	End Object
	
	Components.Add(MyCollisionComponent)
	
	CollisionComponent=MyCollisionComponent
*/
/*
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)
*/
}

