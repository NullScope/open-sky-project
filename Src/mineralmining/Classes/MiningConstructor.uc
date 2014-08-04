class MiningConstructor extends MiningActor_Comandable;

var ParticleSystemComponent				EMPParticle;
var ParticleSystemComponent				base1Particle;
var ParticleSystemComponent				base2Particle;
var ParticleSystemComponent				base3Particle;
var ParticleSystemComponent				base4Particle;
var ParticleSystemComponent				link1Particle;
var ParticleSystemComponent				link2Particle;
var ParticleSystemComponent				link3Particle;
var ParticleSystemComponent				link4Particle;

var MiningHarvester 					MiningBuilder;
var MiningBuilding						currentMiningBuilding;
var class<MiningBuilding>				BuildingToSpawn;
var float 								constructionTime;
var float 								currentConstructionTime;

function PostBeginPlay()
{
	super.PostBeginPlay();

	isExecuting = true;

	skills[0] = none;
	skills[1] = none;
	skills[2] = stop;
	preSkills[0] = none;
	preSkills[1] = none;
	
	skillsInfo.remove(0, skillsInfo.Length);

	tempSkill.key = 0;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Filler";
	tempSkill.skillDescription = "";
	tempSkill.skillIcon = 0;
	tempSkill.skillButtonIndex = -1;
	tempSkill.requiresTarget = FALSE;

	skillsInfo.AddItem(tempSkill);
	skillsInfo.AddItem(tempSkill);
	

	tempSkill.key = 11;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Stop";
	tempSkill.skillDescription = "Stops the construction of this unit";
	tempSkill.skillIcon = 3;
	tempSkill.skillButtonIndex = 15;
	tempSkill.requiresTarget = FALSE;

	skillsInfo.AddItem(tempSkill);

	// link1Particle.SetVectorParameter('LinkBeamEnd', Location + unitMesh.GetSocketByName('Center').RelativeLocation);
	// link2Particle.SetVectorParameter('LinkBeamEnd', Location + unitMesh.GetSocketByName('Center').RelativeLocation);
	// link3Particle.SetVectorParameter('LinkBeamEnd', Location + unitMesh.GetSocketByName('Center').RelativeLocation);
	// link4Particle.SetVectorParameter('LinkBeamEnd', Location + unitMesh.GetSocketByName('Center').RelativeLocation);
	// unitMesh.AttachComponentToSocket(link1Particle, 'altBeam_1');
	// unitMesh.AttachComponentToSocket(link2Particle, 'altBeam_2');
	// unitMesh.AttachComponentToSocket(link3Particle, 'altBeam_3');
	// unitMesh.AttachComponentToSocket(link4Particle, 'altBeam_4');
}

function stop()
{
	kill();
}

auto state building{
	function update(float DeltaTime){
		local rotator 							rot;
		local MiningBuilding 					tempBuilding;

		if(MiningBuilder != none){

			if(!MiningBuilder.IsInState('building')){
				MiningBuilder = none;
				return;
			}

			currentConstructionTime += DeltaTime;

			if(currentConstructionTime >= constructionTime){
				Rot.Pitch = (0.0f     *DegToRad) * RadToUnrRot;
				Rot.Roll =  (0          *DegToRad) * RadToUnrRot;
				Rot.Yaw =   (0.0f      *DegToRad) * RadToUnrRot;
				tempBuilding = Spawn(BuildingToSpawn,MiningPlayerOwner,,Location+vect(0,0,1000), rot);
				tempBuilding.setTeam(team);
				tempBuilding.setDesiredLanding(Location);
				tempBuilding.moveSpeed = 900;
				tempBuilding.unitLand();
				currentMiningBuilding = tempBuilding;
				MiningBuilder = none;
				GotoState('waitingForLanding');
			}

		}
	}
}

event Bump(Actor Other,  PrimitiveComponent OtherComp,  Vector HitNormal){
	super.Bump(Other, OtherComp, HitNormal);
	MiningPlayerOwner.ClientMessage(Other.Class);
	if(Other == currentMiningBuilding){
		currentMiningBuilding.desactivateLanding();
		currentMiningBuilding.moveSpeed = 0;
		currentMiningBuilding = none;
		kill();
		GotoState('idle');
	}
}

state waitingForLanding{

}

function setConstructionTime(float newConstructionTime){
	constructionTime = newConstructionTime;
}

function setMiningBuilder(MiningHarvester newBuilder){
	MiningBuilder = newBuilder;
}

function setBuildingToSpawn(class<MiningBuilding> newBuilding){
	BuildingToSpawn = newBuilding;
}

DefaultProperties
{
	unitName = "Constructor"
	maxHealth = 1
	radius = 50;
	canWalk = false
	bIsStationary = true
	ObstacleType = EShape_Circle

	/*Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)*/

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=TRUE
		bCastDynamicShadow=TRUE
		bOwnerNoSee=FALSE
		//LightEnvironment=MyLightEnvironment;
		CollideActors=TRUE
		BlockActors=TRUE
        BlockRigidBody=TRUE
        BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		SkeletalMesh=SkeletalMesh'MineralMiningGameContent.SkeletalMeshes.SM_Constructor'
		Scale = 6;
	End Object
	//DrawScale3D=(X=6,Y=6,Z=2)
	//EMP EFFECT
	/*Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_Deployables_EMP_Mine_VehicleDisabled'
	End Object

	EMPParticle = ParticleSystemComponent0;*/

	//BASE RED PARTICLES
	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_Flagbase_Empty_Idle_Red'
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent2
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_Flagbase_Empty_Idle_Red'
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent3
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_Flagbase_Empty_Idle_Red'
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent4
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_Flagbase_Empty_Idle_Red'
	End Object

	base1Particle = ParticleSystemComponent1
	base2Particle = ParticleSystemComponent2
	base3Particle = ParticleSystemComponent3
	base4Particle = ParticleSystemComponent4

	//GOLD LINK PARTICLES
	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent5
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_Linkgun_Altbeam_Gold'
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent6
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_Linkgun_Altbeam_Gold'
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent7
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_Linkgun_Altbeam_Gold'
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent8
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_Linkgun_Altbeam_Gold'
	End Object

	link1Particle = ParticleSystemComponent5
	link2Particle = ParticleSystemComponent6
	link3Particle = ParticleSystemComponent7
	link4Particle = ParticleSystemComponent8

	Components.Add(InitialSkeletalMesh)
	unitMesh=InitialSkeletalMesh
	CollisionComponent=InitialSkeletalMesh
}