class MiningMarine extends MiningInfantry;

var ParticleSystem							muzzleFlashTemplate;
var ParticleSystemComponent					muzzleFlash;

function PreBeginPlay(){
	super.PreBeginPlay();

	tempSkill.key = 10;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Attack";
	tempSkill.skillDescription = "Attacks the targeted unit";
	tempSkill.skillIcon = 1;
	tempSkill.skillButtonIndex = 15;
	tempSkill.requiresTarget = FALSE;

	skillsInfo.AddItem(tempSkill);
	
	unitMesh.AttachComponentToSocket(weaponMesh, 'WeaponSocket');
    muzzleFlash = new class'ParticleSystemComponent';
    muzzleFlash.bAutoActivate=true;
    muzzleFlash.SetTemplate(muzzleFlashTemplate);
    weaponMesh.AttachComponentToSocket(muzzleFlash,'MussleFlashSocket');
}

defaultproperties
{
	unitName = "Marine"
	moveSpeed = 200
	turnRate = 0.2f
	radius = 40

	spotNBR = 5
		
	attackRate = 0.5f
	attackBurst = 3
	attackDamage = 10
	attackRange = 300
		
	maxHealth = 150
	teamMaterials[0] = Material'UDKRTSGameContent.Materials.units.IronGuardMaleMaterial_0'
	teamMaterials[1] = Material'UDKRTSGameContent.Materials.Units.IronGuardMaleMaterial_1'
	teamMaterials[2] = Material'UDKRTSGameContent.Materials.Units.IronGuardMaleMaterial_2'
	teamMaterials[3] = Material'UDKRTSGameContent.Materials.Units.IronGuardMaleMaterial_3'
	teamMaterials[4] = Material'UDKRTSGameContent.Materials.Units.IronGuardMaleMaterial_4'
	teamMaterials[5] = Material'UDKRTSGameContent.Materials.Units.IronGuardMaleMaterial_5'
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)
	

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bOwnerNoSee=FALSE
		LightEnvironment=MyLightEnvironment;
		CollideActors=TRUE
		BlockActors=TRUE
        BlockRigidBody=TRUE
        BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		PhysicsAsset=PhysicsAsset'MineralMiningGameContent.PhysicsAssets.IronGuardMale_Physics'
		AnimSets(0)=AnimSet'UDKRTSGameContent.AnimSets.BipedAnimations'
		AnimTreeTemplate=AnimTree'UDKRTSGameContent.AnimTrees.BipedAnimTree'
		SkeletalMesh=SkeletalMesh'UDKRTSGameContent.SkeletalMeshes.IronGuardMale'
	End Object
	
	Begin Object Class=SkeletalMeshComponent Name=weapon
		SkeletalMesh=SkeletalMesh'UDKRTSGameContent.SkeletalMeshes.ShockRifle'
		bUpdateSkelWhenNotRendered=False
		ReplacementPrimitive=None
		LightEnvironment=MyLightEnvironment
		Scale3D=(X=1,Y=0.75,Z=1)
		LightingChannels=(bInitialized=True,Dynamic=True)
		CastShadow=false
		bCastDynamicShadow=false
		bOwnerNoSee=false
    End Object
	
	Components.Add(InitialSkeletalMesh)
	unitMesh=InitialSkeletalMesh
	weaponMesh=weapon;
	muzzleFlashTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	CollisionComponent=InitialSkeletalMesh
}