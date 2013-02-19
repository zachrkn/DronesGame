//==========================CLASS DECLARATION==================================
class DronesPawn extends Pawn;

//==========================VARIABLES==========================================
/** Distance to offset the camera from the player in unreal units
 *  Set in DefaultProperties
 *	Used in function CalcCamera */
var float CamOffsetDistance; 

/** How high camera is relative to pawn pelvis
 *  Set in DefaultProperties
 *	Used in function CalcCamera */
var float CamHeight;

/** Keep track of the controller rotation value from the previous tick
 *  Set in DefaultProperties
 *	Used in the function CalcCamera 
 *	Declared here so as to be persistent */
var rotator PreviousUnboundedRotation;

/** The camera location and rotation after movement is calculated in each tick
 *  Set in the function CalcCamera
 *	Used in the class DronesPlayerController in the exec function StartFire (handles left click) */
var vector FinalCameraLocation;
var rotator FinalCameraRotation;

//==========================EVENTS==========================================
/** Inherited from parent class */
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
//	SetCollisionType(COLLIDE_NoCollision);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	`Log("Pawn Touched this: " $Other);
}

event Landed(vector HitNormal, Actor FloorActor)
{
/*
	TakeFallingDamage();
	if ( Health > 0 )
		PlayLanded(Velocity.Z);
	LastHitBy = None;
*/
}

//==========================FUNCTIONS==========================================
/** Inherited from parent class
 *	Update pawn rotation
 *	Called in the class DronesPlayerController in the function UpdateRotation
 *	This function is only called when the right mouse is not down */
 /*
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	local rotator RotationToFace;

	NewRotation.Pitch = 0;

	//NewRotation = RLerp(NewRotation,NewRotation,0.1,true);
	RotationToFace = FinalCameraRotation;
	RotationToFace.Pitch = 0;
	SetRotation(RotationToFace);
}
*/

/** Inherited from parent class
 *	Calculates position and rotation for camera */
/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
//	local vector CameraLocation;
//	local vector HitLoc, HitNorm, vecCamHeight;
	local rotator CurrentUnboundedRotation;  // holds Controller.Rotation, but pitch is flipped so instead of 0 thru 65507 it is -32753 thru 32753
	local rotator RotationDifference; // the amount that the controller rotation has changed since the last tick.
	local rotator BoundedRotation; // holds the current rotation once it's been bounded.  The only purpose for this variable to exist locally is for its name to make understanding the code easier.  It could be collapsed into the FinalCameraRotation variable which is class-level
	
	local vector X, Y, Z, CamDir, CamStart, CameraTranslateScale;
	local float CollisionRadius;
		
	// if CurrentUnboundedRotation.Pitch goes below center and flips to 65536, make it go negative instead.
	CurrentUnboundedRotation = Controller.Rotation; // Controller.Rotation is inherited from a parent class (PlayerController?), and is a CONST.  Assign to Current.Rotation so I can adjust
	if(CurrentUnboundedRotation.Pitch > 32768)
	{
		CurrentUnboundedRotation.Pitch -= 65536;
	}

	//Because I'm bounding the rotation, I need to keep my own persistent record of what the rotation values are
	// I also need to just add the rotation difference each tick, because it's being bounded
	// FinalCameraRotation holds the persistent value, but for the sake of using variable names that make sense, I use BoundedRotation within this function when I'm bounding rotation
	// So, I need to assign the value of FinalCameraRotation (persistent) to BoundedRotation (local) 
	
	// determine how much the the camera rotation has changed from the last tick.  CurrentUnboundedRotation and PreviousUnboundedRotation are unbounded
	RotationDifference = CurrentUnboundedRotation - PreviousUnboundedRotation;
	
	// set PreviousUnboundedRotation to CurrentUnboundedRotation for the benefit of the next tick
	PreviousUnboundedRotation = CurrentUnboundedRotation;
	
	// get persistent rotation value in FinalCameraRotation into local variable, BoundedRotation
	BoundedRotation = FinalCameraRotation;
	
	// Add to the persistent bounded pitch rotation the difference between in rotation between the current tick and the previous tick
	BoundedRotation.Pitch = Clamp( (BoundedRotation.Pitch + RotationDifference.Pitch), -25000, 15000);

	BoundedRotation.Yaw += RotationDifference.Yaw;


	BoundedRotation.Yaw = Clamp( (BoundedRotation.Yaw + RotationDifference.Yaw), Rotation.Yaw-10000, Rotation.Yaw+25000);

	// Output the final rotation value
	FinalCameraRotation = BoundedRotation;
	out_CamRot = FinalCameraRotation;
	
	CamStart = Location;
	//CamStart.Z += CameraZOffset;
	CamStart.Z += CamHeight;
//	vecCamHeight.Z = CamHeight;
	
	GetAxes(FinalCameraRotation, X, Y, Z);
	
	CollisionRadius = GetCollisionRadius();
	
	CameraTranslateScale.X = -0.5F;
	CameraTranslateScale.Y = -0.2F;
	CameraTranslateScale.Z = 0;
	
	X *= CollisionRadius * CameraTranslateScale.X;
	Y *= CollisionRadius * CameraTranslateScale.Y;
	Z *= CollisionRadius * -1.0f;
	CamDir = X + Y + Z;
	
	FinalCameraLocation = CamStart - CamDir;
	
	//Output the final camera location value
	out_CamLoc = FinalCameraLocation;


	//trace to check if cam running into wall/floor
//	if(Trace(HitLoc,HitNorm,out_CamLoc,Location,false,vect(12,12,12))!=none)
//	{
//		out_CamLoc = HitLoc + vecCamHeight;
//	}


   return true;
}
*/
//==========================DEFAULT PROPERTIES==========================================
defaultproperties
{
	CamHeight = 47.0
	CamOffsetDistance=200.0
	
	//PreviousUnboundedRotation=(Pitch=0,Yaw=-108928,Roll=0)
	PreviousUnboundedRotation=(Pitch=0,Yaw=0,Roll=0)
	
	//Setting up the light environment
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.00,G=.00,B=.00,A=1)
		AmbientShadowColor=(R=0.0,G=0.0,B=0.0)
		bSynthesizeSHLight=FALSE
	End Object
	Components.Add(MyLightEnvironment)
	
	//Setting up the mesh and animset components
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		//CastShadow=true
		CastShadow=false
		//bCastDynamicShadow=true
		bCastDynamicShadow=false
		//bOwnerNoSee=false
		bOwnerNoSee=true
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=true
		CollideActors=true
		BlockZeroExtent=true
		//What to change if you'd like to use your own meshes and animations
      SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
      AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
      PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	End Object
	
	//Setting up a proper collision cylinder
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh); 
	CollisionType=COLLIDE_BlockAll

	Begin Object Name=CollisionCylinder
	CollisionRadius=+0023.000000
	CollisionHeight=+0050.000000
	End Object
	CylinderComponent=CollisionCylinder

}