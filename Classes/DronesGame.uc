//==========================CLASS DECLARATION==================================
class DronesGame extends SimpleGame;
//class DronesGame extends UTGame;

//==========================VARIABLES==========================================
/** Holds an array of my brick actors
 *	Set in the function PostBeginPlay 
 *  Used in the function PostBeginPlay */
var array<DronesBrickKActor> Bricks;
var array<DronesDrone> Drones;

var float OverallDroneSpeed;
var float CurrentDroneSpeed;

//==========================EVENTS==========================================
/** Inherited from parent class */
event PostBeginPlay()
{
	local DronesBrickKActor NewBrick, Brick;
	local DronesDrone NewDrone;
	local int i;
	local rotator r;
	local vector v;

			
	// invoke the PostBeginPlay method of the parent class
	super.PostBeginPlay();

	/*
	r.Pitch = 0;
	r.Yaw = 0;
	r.Roll = 0;
	
	v.X = 0;
	v.Y = 0;
	v.Z = 20;
	NewBrick = Spawn(class'DronesBrickKActor',,,v,r,,);
	NewBrick.SetPhysics(PHYS_rigidbody);
	Bricks.AddItem(NewBrick);
	
	v.X = 40;
	v.Y = 0;
	v.Z = 20;
	NewBrick = Spawn(class'DronesBrickKActor',,,v,r,,);
	NewBrick.SetPhysics(PHYS_rigidbody);
	Bricks.AddItem(NewBrick);
	
	foreach Bricks(Brick)
	{
		`Log("Brick: "$Brick$" Location: "$Brick.Location);
	}
	foreach Bricks(Brick)
	{
		IsBrickSizedLocationOccupied(Brick.Location, Brick.Rotation);
	}
	*/
	

	// spawn bricks
	for( i=0; i<1000; i++)
	{
		v.X = RandRange(-2500, 2500);
		v.Y = RandRange(-2500, 2500);
		v.Z = RandRange(50, 500);
		r.Pitch = 0;
		r.Yaw = 0;
		r.Roll = 0;

		NewBrick = Spawn(class'DronesBrickKActor',,,v,r,,);
		NewBrick.SetPhysics(PHYS_rigidbody);
			
		Bricks.AddItem(NewBrick);
	}

	// spawn drones
	for( i=0; i<5; i++)
	{
		v.X = i*1000;
		v.Y = 0;
		v.Z = 80;
		
		NewDrone = Spawn(class'DronesDrone',,,v,r,,);
		DronesDroneAIController(NewDrone.Controller).InitializeRandomBlueprint();
		NewDRone.UpdateDroneColor();
		
		Drones.AddItem(NewDrone);
	}

}

event Tick ( float DeltaTime )
{
	local DronesDrone FreshDrone;
	local vector v;

	//`Log("number of Drones" $NumActors);
/*
	If (Drones.Length <= 0)
	{
		v.X = 0;
		v.Y = 0;
		v.Z = 500;
		FreshDrone = Spawn(class'DronesDrone',,,v,,,);
		FreshDrone.Controller = Spawn(class'DronesDroneAIController');
		FreshDrone.Controller.Possess(FreshDrone, FALSE);
		//`Log("end of game");
		//ConsoleCommand("open DronesLandscape01");
	}
*/
}

/*
event Tick ( float Deltatime)
{
	local DronesBrickKActor ThisDronesBrickKActor;
	local int Index;
	`Log(" ");
	`Log("Presort");
	foreach Bricks(ThisDronesBrickKActor, Index)
	{
		`Log("ThisDronesBrickKActor: "$ThisDronesBrickKActor$" at index: "$Index$" at location: "$ThisDronesBrickKActor.Location.X);
	}
	
	Bricks.Sort(SortBricksRandomly);
	
	`Log("Postsort");
	foreach Bricks(ThisDronesBrickKActor, Index)
	{
		`Log("ThisDronesBrickKActor: "$ThisDronesBrickKActor$" at index: "$Index$" at location: "$ThisDronesBrickKActor.Location.X);
	}
}
*/

//==========================FUNCTIONS==========================================
delegate int SortBricks(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
	if(BrickA.Location.X > BrickB.Location.X)
	{
		return 1;
	}
	else
	{
		return -1;
	}
}

/*
function SortBricksRandomly(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
while(Bricks.length > 0)
{
    i = Rand(Bricks.length);
    SortedBricks[SortedBricks.length] = Bricks[i];
    Bricks.Remove(i,1);
}

// SortedBricks should now be a randomized Bricks
}
*/

function Actor GetStaticMeshActorInstanceByTag(name actorTag)
{
	local StaticMeshActor actorInstance;

	foreach AllActors(class'StaticMeshActor', actorInstance)
	{
		if(actorInstance.Tag == actorTag)
			return actorInstance;
	}

	return None;
}

function Actor GetDecalActorMovableInstanceByTag(name actorTag)
{
	local DecalActorMovable actorInstance;

	foreach AllActors(class'DecalActorMovable', actorInstance)
	{
		if(actorInstance.Tag == actorTag)
			return actorInstance;
	}

	return None;
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return Default.Class;
}

//==========================DEFAULT PROPERTIES==========================================
defaultproperties
{
	OverallDroneSpeed = 15

	//MapPrefixes[1]='Tube_stairs_map_map'
	HUDType=class'Drones.DronesHUDWrapper'
	PlayerControllerClass=class'Drones.DronesPlayerController'
	//PlayerControllerClass=class'UTPlayerController'
	DefaultPawnClass=class'DronesPawn'
	//DefaultPawnClass=class'UTPawn'

}

