class MiningBase extends MiningBuilding;

function PostBeginPlay(){
	super.PostBeginPlay();
	
	skills[3] = makeHarvester;
	
	tempSkill.key = 10;
	tempSkill.cost = 50;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 5.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Harvester";
	tempSkill.skillDescription = "Build a Harvester to gather resources";
	tempSkill.skillIcon = 3;
	tempSkill.skillButtonIndex = 6;
	tempSkill.requiresTarget = FALSE;
	
	skillsInfo.AddItem(tempSkill);
}

function Tick(float DeltaTime){
	super.Tick(DeltaTime);
}

function makeHarvester(){
	buildUnit(class'MiningHarvester',3);
}

defaultproperties
{
	unitName = "Base"
	maxHealth = 1000

	isStorage = true
	canSetRallyPoint = true
	
	teamMaterials[0] = Material'UDKRTSGameContent.Materials.Structures.HQMaterial_2'
	teamMaterials[1] = Material'UDKRTSGameContent.Materials.Structures.HQMaterial_1'
	teamMaterials[2] = Material'UDKRTSGameContent.Materials.Structures.HQMaterial_0'
	teamMaterials[3] = Material'UDKRTSGameContent.Materials.Structures.HQMaterial_3'
	teamMaterials[4] = Material'UDKRTSGameContent.Materials.Structures.HQMaterial_4'
	teamMaterials[5] = Material'UDKRTSGameContent.Materials.Structures.HQMaterial_5'
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=TRUE
		bCastDynamicShadow=TRUE
		bOwnerNoSee=FALSE
		LightEnvironment=MyLightEnvironment;
		CollideActors=TRUE
		BlockActors=TRUE
		BlockRigidBody=TRUE
        BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		SkeletalMesh=SkeletalMesh'UDKRTSGameContent.SkeletalMeshes.PlaceHolderStructure'
		Materials(0)=Material'UDKRTSGameContent.Materials.Structures.HQMaterial_0'
	End Object
	
	Components.add(InitialSkeletalMesh)
	unitMesh = InitialSkeletalMesh
	CollisionComponent=InitialSkeletalMesh
}