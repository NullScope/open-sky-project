class MiningRallyPoint extends Actor;

defaultproperties
{
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)
	
	Begin Object Class=StaticMeshComponent Name=InitialStaticMesh
		CastShadow=false
		bCastDynamicShadow=false
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true
        CollideActors=false
        BlockZeroExtent=false
		BlockNonZeroExtent=false
		StaticMesh=StaticMesh'UDKRTSGameContent.StaticMeshes.RallyPoint'
	End Object
	
	Components.Add(InitialStaticMesh)
}