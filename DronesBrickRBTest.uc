//==========================CLASS DECLARATION==================================
class DronesBrickRBTest extends KActor
    placeable;
	
//==========================VARIABLES==========================================

//==========================EVENTS==========================================
event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	//`Log("Brick "$Self$" Touch "$Other$"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

event RigidBodyCollision (PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	//`Log("Brick "$Self$" RBC "$OtherComponent$"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

event Bump (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	//`Log("Brick "$Self$" Bump "$Other$"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

simulated event PostBeginPlay()
{
/*
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInterface ThisMaterialInterface01;
	local PrimitiveComponent ThisPrimitiveComponent;
	local ERBCollisionChannel ThisRBChannel;
*/
	//`Log("Brick "$Self$" PostBeginPlay!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	
	super.PostBeginPlay();
	/*
	ThisRBChannel = RBCC_Untitled1;
	CollisionComponent.SetRBChannel(ThisRBChannel);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, TRUE);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Nothing, FALSE);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Pawn, FALSE);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_GameplayPhysics, FALSE);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Untitled1, FALSE);
	*/
	/*
	foreach ComponentList(class'PrimitiveComponent', ThisPrimitiveComponent)
	{
		`Log("Brick "$Self$" PostBeginPlay, for each PrimitiveComponent: "$ThisPrimitiveComponent);
		ThisPrimitiveComponent.SetRBChannel(ThisRBChannel);
	}
	*/	
}

event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{
	super.ApplyImpulse(ImpulseDir, ImpulseMag, HitLocation, HitInfo, DamageType);
	`Log("In event ApplyImpulse");
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bWakeOnLevelStart=TRUE
	bMovable=TRUE
		
	bPawnCanBaseOn=TRUE
	bCanStepUpOn=FALSE
	
	//bBlockActors=TRUE
	
	//CollisionType=COLLIDE_BlockAll
	
	Begin Object Name=StaticMeshComponent0
        StaticMesh=DronesPackage.Meshes.Brick_large_mesh
		//BlockRigidBody=TRUE
		//CollideActors=TRUE
		//BlockActors=FALSE
		//bNotifyRigidBodyCollision=TRUE
		//ScriptRigidBodyCollisionThreshold=0.0001
		//BlockZeroExtent=TRUE
		//BlockNonZeroExtent=TRUE
    End Object
}

