//==========================CLASS DECLARATION==================================
class DronesBrickKActor extends KActor
//class DronesBrickKActor extends KAsset
    placeable;
	
//==========================VARIABLES==========================================
var bool bAvailable;
var MaterialInstanceConstant matInst;

var array<DronesBrickConstraint> ConstraintsApplied;

//==========================EVENTS==========================================
simulated event FellOutOfWorld (class<DamageType> dmgType)
{
	DronesGame(WorldInfo.Game).AvailableBricks.RemoveItem(Self);
	Destroy();
}

simulated event OutsideWorldBounds ()
{
	DronesGame(WorldInfo.Game).AvailableBricks.RemoveItem(Self);
	Destroy();
}

simulated event PostBeginPlay()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInterface ThisMaterialInterface01;

	super.PostBeginPlay();

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
}

event Tick (float DeltaTime)
{
//	local SkeletalMeshComponent ThisSkeletalMeshComponent;
//	local vector SocketLocation;
//	local int i;

	local DronesBrickConstraint ThisConstraint;
	
	
	foreach ConstraintsApplied(ThisConstraint)
	{
		//`Log("Brick: "$Self$" constraint: "$ThisConstraint);
	}
	//`Log("Tick! Brick: "$Self$" Location: "$Location);
	
/*
	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		for (i=1; i<7; i++)
		{
		switch( i )
		{
			case 1:
				ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket01', SocketLocation);
				DrawDebugSphere(SocketLocation, 5, 5, 255, 0, 0);
				break;
			case 2:
				ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket02', SocketLocation);
				DrawDebugSphere(SocketLocation, 5, 5, 255, 255, 0);
				break;
			case 3:
				ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket03', SocketLocation);
				DrawDebugSphere(SocketLocation, 5, 5, 0, 255, 0);
				break;
			case 4:
				ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket04', SocketLocation);
				DrawDebugSphere(SocketLocation, 5, 5, 0, 255, 255);
				break;
			case 5:
				ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket05', SocketLocation);
				DrawDebugSphere(SocketLocation, 5, 5, 0, 0, 255);
				break;
			case 6:
				ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket06', SocketLocation);
				DrawDebugSphere(SocketLocation, 5, 5, 255, 0, 255);
				break;
		}
		}
	}
*/
}

event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{
	super.ApplyImpulse(ImpulseDir, ImpulseMag, HitLocation, HitInfo, DamageType);
	`Log("In event ApplyImpulse");
}

//==========================FUNCTIONS==========================================
function MakeUnavailable()
{
	DronesGame(WorldInfo.Game).AvailableBricks.RemoveItem(self);
	DronesGame(WorldInfo.Game).UnavailableBricks.AddItem(self);
	
}

function MakeAvailable()
{
	DronesGame(WorldInfo.Game).AvailableBricks.AddItem(self);
	DronesGame(WorldInfo.Game).UnavailableBricks.RemoveItem(self);
}

function ToggleHighlightOn()
{
	matInst.SetScalarParameterValue('Highlight',0.5);
}

function ToggleHighlightOff()
{
	matInst.SetScalarParameterValue('Highlight',0.0);
}

function SetBaseToDrone(DronesDrone InDrone)
{
	SetHardAttach(TRUE);
	SetBase(InDrone, , InDrone.Mesh, 'Bone001Socket');
	// set physics to interpolating so the brick will move along with the drone correctly
	SetPhysics(PHYS_Interpolating);
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

function SetBaseToSelf()
{
	SetHardAttach(FALSE);
	SetBase(none);
	// set physics to rigid body so the brick moves and acts like a brick again
	SetPhysics(PHYS_RigidBody);
}

function LoseMomentum()
{
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBLinearVelocity(vect(0,0,0));
		ThisStaticMeshComponent.SetRBAngularVelocity(vect(0,0,0));
	}
}

function GainCollision()
{		
	local StaticMeshComponent ThisStaticMeshComponent;	
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetBlockRigidBody(TRUE);
		ThisStaticMeshComponent.SetTraceBlocking(TRUE, TRUE);
	}
}


function SetPositionAndRotation(vector InLoc, rotator InRot)
{		
	local StaticMeshComponent ThisStaticMeshComponent;
	foreach ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
	{
		ThisStaticMeshComponent.SetRBPosition(InLoc);
		ThisStaticMeshComponent.SetRBRotation(InRot);
	}	
	SetLocation(InLoc);
	SetRotation(InRot);
}
			
function CreateConstraintWithBrick(DronesBrickKActor InBrick)
{
	local DronesBrickConstraint NewConstraint;
	NewConstraint = Spawn(class'DronesBrickConstraint',,,Location,,,);
	NewConstraint.InitConstraint(Self, InBrick);
	InBrick.ConstraintsApplied.AddItem(NewConstraint);
	ConstraintsApplied.AddItem(NewConstraint);			
}

function CreateConstraintWithAllTouchingBricks()
{
	local Actor traceHit;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc, traceExtent;
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket07', startTraceLoc);
		ThisSkeletalMeshComponent.GetSocketWorldLocationAndRotation('Socket08', endTraceLoc);	
		traceExtent.X = 20.1;
		traceExtent.Y = 20.1;
		traceExtent.Z = 20.1;
		traceHit = Trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, ,traceExtent, ,);
	
		if(traceHit!=NONE)
		{
			if(traceHit.class == class'DronesBrickKActor')
			{
				if( (traceHit != Self) )
				{
					CreateConstraintWithBrick(DronesBrickKActor(traceHit));
				}
			}
		}	
	}
}


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bAvailable=TRUE

	bWakeOnLevelStart=TRUE
	bStatic=FALSE
	bNoDelete=FALSE
	bBlockActors=TRUE
	bMovable=TRUE
	
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
    End Object

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bOwnerNoSee=FALSE
		BlockRigidBody=FALSE
		CollideActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockActors=TRUE
		bNotifyRigidBodyCollision=FALSE
		HiddenEditor=TRUE
		HiddenGame=TRUE
		//What to change if you'd like to use your own meshes and animations
	  SkeletalMesh=SkeletalMesh'DronesPackage.SkeletalMeshes.brick_large_skeletalmesh'
	End Object
	Components.Add(InitialSkeletalMesh);

}

