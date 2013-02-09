//==========================CLASS DECLARATION==================================
class DronesBrickConstraint extends RB_HingeActor
    placeable;
	
//==========================EVENTS==========================================
simulated event PostBeginPlay()
{	
	ConstraintSetup.bSwingLimited=TRUE;
	ConstraintSetup.bTwistLimited=TRUE;
	ConstraintSetup.TwistLimitAngle=0;
	ConstraintSetup.Swing1LimitAngle=0;
	ConstraintSetup.Swing2LimitAngle=0;
	ConstraintSetup.bAngularBreakable=TRUE;
	ConstraintSetup.AngularBreakThreshold=1.8;
	ConstraintSetup.bLinearBreakable=TRUE;
	ConstraintSetup.LinearBreakThreshold=1.8; // 1.8
}

//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{
	bStatic=FALSE
	bNoDelete=FALSE
}

