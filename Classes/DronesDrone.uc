//==========================CLASS DECLARATION==================================
class DronesDrone extends UDKPawn;

//==========================VARIABLES==========================================
var() PointLightComponent AttachedLight;
var LinearColor DroneColor;
	
//==========================EVENTS==========================================
event PostBeginPlay()
{
/*
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local MaterialInterface ThisMaterialInterface01;
	
	ThisMaterialInterface01 = MaterialInstanceConstant'DronesPackage.Materials.BrickMaterialInstanceConstant';
//Material'WP_LinkGun.Materials.M_WP_LinkGun_MF_3_new'
//Material'JW_LightEffects.Materials.M_CloudShadow'
//Material'Envy_Effects.flares.Materials.M_EFX_3d_Ray_2_Red'
//Material'Engine_MI_Shaders.M_ES_Phong_Opaque_Liquid_Master_01'
//Material'Envy_Effects.Level.M_Ring'
//Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Overlay'
//Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'
//Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
//Material'WP_ShockRifle.Effects.M_Shock_colorball_mesh_sphere'
//Material'GenericFoliage01.ruins.FX.M_UDK_TorchFire01'
//Material'UN_Liquid.SM.Materials.M_UN_Liquid_SM_NanoBlack_03_Master'
//Material'VH_Scorpion.Materials.M_VH_Scorpion_Boost02'
	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		//ThisSkeletalMeshComponent.SetMaterial(0, ThisMaterialInterface01);
	}
*/

    super.PostBeginPlay();
    AddDefaultInventory(); //GameInfo calls it only for players, so we have to do it ourselves for AI.
	
	//SetCollisionType(COLLIDE_NoCollision);
	//SetCollisionType(COLLIDE_TouchAll);
	
	SetPhysics(PHYS_Flying);
	//Physics == PHYS_Falling;
	
	//Mesh.AttachComponentToSocket(AttachedLight, 'Bone001');		
}

event Tick( float DeltaTime)
{
	AirSpeed = DronesGame(WorldInfo.Game).CurrentDroneSpeed;
}

//==========================FUNCTIONS==========================================
function UpdateDroneColor()
{
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local MaterialInstanceConstant ThisMaterialInstanceConstant;
	local DronesDroneAIController AIController;
	//local vector AtoB, MidPoint;
	local vector DestinationRangeCenter;
	local LinearColor NewColor;
	
	AIController = DronesDroneAIController(Controller);
	// find midpoint of targetdestinationrange
	DestinationRangeCenter = DronesDroneAIController(Controller).DestinationRangeCenter;
	
	// map that range to color value so that 0,0,100 is white
	NewColor.R = Abs(AIController.StructureBlueprint.StructureLocation.X / 4000);
	NewColor.G = Abs(AIController.StructureBlueprint.StructureLocation.Y / 4000);
	NewColor.B = Abs((AIController.StructureBlueprint.StructureLocation.Z - 100) / 300);
	NewColor.A = 1;
	`Log("NewColor.R "$NewColor.R$" NewColor.G "$NewColor.G$" NewColor.B "$NewColor.B);
	
	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		ThisMaterialInstanceConstant = ThisSkeletalMeshComponent.CreateAndSetMaterialInstanceConstant(0);
	}
	
	ThisMaterialInstanceConstant.SetVectorParameterValue('DroneColor',NewColor);
	
	DroneColor = NewColor;
}

function Feed()
{
	if (DrawScale < 2.5)
	{
		SetDrawScale(DrawScale+0.5);
	}
}

function Kill()
{
	local DronesDroneAIController ThisController;

	DronesGame(WorldInfo.Game).Drones.RemoveItem(Self);
	ThisController = DronesDroneAIController(Controller);
	
	ThisController.Unpossess();
	ThisController.Destroy();
	Destroy();
}

function ToggleHighlightOn()
{
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local MaterialInstanceConstant ThisMaterialInstanceConstant;
	
	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		ThisMaterialInstanceConstant = ThisSkeletalMeshComponent.CreateAndSetMaterialInstanceConstant(0);
	}
	ThisMaterialInstanceConstant.SetScalarParameterValue('Highlight',0.5);
}

function ToggleHighlightOff()
{
	local SkeletalMeshComponent ThisSkeletalMeshComponent;
	local MaterialInstanceConstant ThisMaterialInstanceConstant;

	foreach ComponentList(class'SkeletalMeshComponent', ThisSkeletalMeshComponent)
	{
		ThisMaterialInstanceConstant = ThisSkeletalMeshComponent.CreateAndSetMaterialInstanceConstant(0);
	}
	ThisMaterialInstanceConstant.SetScalarParameterValue('Highlight',0.0);
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	DroneColor=(R=0,G=0,B=0,A=1)

	bNoEncroachCheck=TRUE
	bCollideWorld=FALSE
//	bCollideActors=TRUE
//	bBlockActors=FALSE
	bMovable=TRUE
	
	bCanStrafe=TRUE
	LandMovementState=Idle
	//bReducedSpeed=TRUE
		
	DrawScale=.8;
	
	//Setting up the light environment
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.00,G=.00,B=.00,A=1)
		AmbientShadowColor=(R=0.0,G=0.0,B=0.0)
		bSynthesizeSHLight=FALSE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=FALSE
		CollideActors=FALSE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		//What to change if you'd like to use your own meshes and animations
	    //SkeletalMesh=SkeletalMesh'DronesPackage.SkeletalMeshes.sphere_fordrone_fbxtest_Sphere001'
	    SkeletalMesh=SkeletalMesh'DronesPackage.SkeletalMeshes.sphere_fordrone_lowerpolycount'
        AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
        PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		RBChannel=RBCC_Untitled1
		RBCollideWithChannels=(Default=FALSE, GameplayPhysics=FALSE, Untitled1=FALSE, Untitled2=FALSE)
	End Object
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh); 
	
	
    Begin Object Name=CollisionCylinder
	CollisionHeight=+25.000000
    End Object


	Begin Object class=PointLightComponent name=LComp
        LightColor=(R=255,G=255,B=255)
        CastShadows=false
        bEnabled=true
        Radius=400.000000
        FalloffExponent=15.000000
        Brightness=.7000000
        CastStaticShadows=False
        CastDynamicShadows=False
        bCastCompositeShadow=False
        bAffectCompositeShadowDirection=False
    End Object
	AttachedLight=LComp
	
    ControllerClass=class'DronesDroneAIController'

    bJumpCapable=false
    bCanJump=false
	AirSpeed=0.0
}