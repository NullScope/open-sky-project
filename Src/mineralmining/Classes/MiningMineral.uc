class MiningMineral extends MiningResource; 

function PostBeginPlay(){
	super.PostBeginPlay();
	
	info.name = "Minerals";
	info.resourceIndex = 0;
	info.maxCapacity = 1000;
	
	currentCapacity = info.maxCapacity;
}

defaultproperties
{
	unitName = "Minerals";
	radius = 100
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=InitialSkeletalMesh
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bOwnerNoSee=FALSE
		LightEnvironment=MyLightEnvironment
        BlockRigidBody=TRUE
        CollideActors=TRUE
        BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		StaticMesh=StaticMesh'LT_Clutter.SM.Mesh.S_LT_Clutter_SM_Rubble4'
		Materials(0)=Material'RTSEx_SCTer.Resources.Rock_Material'
	End Object

	Components.Add(InitialSkeletalMesh)
	CollisionComponent=InitialSkeletalMesh
	DrawScale3D=(X=1.5,Y=1.5,Z=1.5)
}