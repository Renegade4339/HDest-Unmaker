class ArmaggedonBallTail:IdleDummy{
	default{
		+forcexybillboard
		scale 1.8;renderstyle "add";
		Translation "112:127=176:191", "224:231=170:175", "168:168=170:170";
	}
	states{
	spawn:
		BFS1 AB 2 bright A_FadeOut(0.2);
		loop;
	}
}

class CastingArmageddon: Inventory {default{inventory.maxamount 1;}}
class ArchonPainSignal: Inventory {default{inventory.maxamount 1;}}
class SpellSuccessSignal: Inventory {default{inventory.maxamount 1;}}

class ArmageddonPuff:RedParticleFountain{
	default{
		-invisible +nointeraction +forcexybillboard +bloodlessimpact
		+noblood +alwayspuff -allowparticles +puffonactors +puffgetsowner +forceradiusdmg
		+hittracer
		renderstyle "add";
		damagetype "Armageddon";
		Translation "112:127=176:191", "224:231=170:175", "168:168=170:170";
		scale 0.8;
		obituary "%o got zapped by a powerful demonic attack and was unmade from existence.";
	}
	states{
	spawn:
		BFE2 A 1 bright nodelay{
			if(target)target=target.target;
			A_StartSound("misc/bfgrail",9005);
		}
		BFE2 A 3 bright{
			A_Explode(random(160,640),320,0);

			//teleport victim
			if(
				tracer
				&&tracer!=target
				&&!tracer.player
				&&!tracer.special
				&&(
					!tracer.bismonster
					||tracer.health<1
				)
				&&!random(0,3)
			){
				spawn("TeleFog",tracer.pos,ALLOW_REPLACE);

				vector3 teleportedto=(0,0,0);

				thinkeriterator mobfinder=thinkeriterator.create("HDMobBase");
				actor mo;
				int ccc=level.killed_monsters;
				while(mo=HDMobBase(mobfinder.next())){
					if(ccc<1)break;
					if(mo.health>0)continue;
					ccc--;
					setz(mo.spawnpoint.z);
					if(checkmove(mo.spawnpoint.xy)){
						teleportedto=mo.spawnpoint;
						break;
					}
				}

				if(teleportedto==(0,0,0))teleportedto=(
					frandom(-20000,20000),
					frandom(-20000,20000),
					frandom(-20000,20000)
				);

				tracer.setorigin(teleportedto,false);
				tracer.setz(clamp(tracer.pos.z,tracer.floorz,tracer.ceilingz-tracer.height));
				tracer.vel=(frandom(-10,10),frandom(-10,10),frandom(10,20));
				spawn("TeleFog",tracer.pos,ALLOW_REPLACE);
			}
		}
		BFE2 ABCDE 2 bright A_FadeOut(0.1);
		stop;
	}
}

class MeteorSpawner:HDMobBase{
	default{
		+ghost +ismonster -countkill -solid
		+nogravity +lookallaround -shootable +neverrespawn
		radius 12;height 24;mass 1;
		species "MeteorSpawners"; //required for A_RadiusGive.
	}
action void A_SendSuccessSignal(){
master.giveinventory("SpellSuccessSignal",1);
}

action void A_AcknowledgePainSignal(){
A_JumpIfInventory("ArchonPainSignal",1,"death");
}

override void tick(){
if(!master)destroy();
super.tick();
}

override void postbeginplay(){
if(master){
master.giveinventory("SpellSuccessSignal",1);
A_Warp(AAPTR_MASTER,0,0,ceilingz-24,angle,WARPF_NOCHECKPOSITION);
}
if(!master)destroy();
super.postbeginplay();
}

	states{
	spawn:
		TNT1 A 1 nodelay A_Look();
		stop;

	see:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1{ A_FaceTarget(20,20); A_JumpIfInventory("ArchonPainSignal",1,"death");}
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1{A_FaceTarget(15,15); A_JumpIfInventory("ArchonPainSignal",1,"death");}
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1{A_FaceTarget(10,10); A_JumpIfInventory("ArchonPainSignal",1,"death");}
	fire:
		TNT1 A 1 A_SpawnProjectile("ArmageddonBall",12,0,angle,CMF_AIMDIRECTION,pitch);
		stop;
	death:
		TNT1 A 1{if(master){master.TakeInventory("CastingArmageddon",1);master.TakeInventory("ArchonPainSignal",1);}}
		stop;
	}
}

class MeteorSpawner2:IdleDummy{
int shotsleft;
	default{
		+ghost +ismonster -countkill -solid
		+nogravity +lookallaround -shootable +neverrespawn
		radius 12;height 24;mass 1;health 1;
		species "MeteorSpawners"; //required for A_RadiusGive.
	}
action void A_SendSuccessSignal(){
master.giveinventory("SpellSuccessSignal",1);
}

action void A_AcknowledgePainSignal(){
A_JumpIfInventory("ArchonPainSignal",1,"death");
}

override void tick(){
if(!master)destroy();
super.tick();
}

override void postbeginplay(){
if(master){
master.giveinventory("SpellSuccessSignal",1);
A_Warp(AAPTR_MASTER,0,0,ceilingz-24,angle,WARPF_NOCHECKPOSITION);
}
if(!master)destroy();
super.postbeginplay();
}

	states{
	spawn:
		TNT1 A 0 nodelay{shotsleft=random(5,40);}
		TNT1 A 1 A_Look();
		stop;

	see:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1{ A_FaceTarget(20,20); A_JumpIfInventory("ArchonPainSignal",1,"death");}
	fire:
		TNT1 A 0 A_JumpIfInventory("ArchonPainSignal",1,"death");
		TNT1 A 0{if(shotsleft<1)setstatelabel("death");}
		TNT1 A 1 A_SetTics(random(1,34));
		TNT1 A 1{A_SpawnProjectile("UnmakerBallGuided",random(-24,24),random(-6,6),random(-10,10),CMF_AIMDIRECTION,pitch-random(-5,5)); shotsleft--;}
		loop;
	death:
		TNT1 A 1{if(master){master.TakeInventory("CastingArmageddon",1);master.TakeInventory("ArchonPainSignal",1);}}
		stop;
	}
}

class ArchonSpark:HDActor{
	default{
		+nointeraction +forcexybillboard +bright
		radius 0;height 0;
		renderstyle "add";alpha 0.1; scale 0.16;
		Translation "112:127=176:191", "224:231=170:175", "168:168=170:170";
	}
	states{
	spawn:
		BFE2 DDDDDDDDDD 1 bright nodelay A_FadeIn(0.1);
		BFE2 D 1 A_FadeOut(0.3);
		wait;
	}
}

class ArmageddonBall:HDFireball{
	int ballripdmg;
	default{
		-notelestomp +telestomp
		+skyexplode +forceradiusdmg +ripper -noteleport +notarget
		+bright
		Translation "112:127=176:191", "224:231=170:175", "168:168=170:170";
		renderstyle "add";
		damagefunction(ballripdmg);
		+boss
		deathsound "weapons/bfgx"; seesound "";
		obituary "$OB_MPBFG_BOOM";
		alpha 0.9;
		scale 2;
		height 12;
		radius 12;
		speed 20;
		gravity 0;
	}
	void A_BFGBallZap(){
		if(pos.z-floorz<12)vel.z+=1;
		else if(ceilingz-pos.z<19)vel.z-=1;

		for(int i=0;i<10;i++){
			A_SpawnParticle("ff 55 88",
				SPF_RELATIVE|SPF_FULLBRIGHT,
				35,frandom(4,8),0,
				frandom(-8,8),frandom(-8,8),frandom(0,8),
				frandom(-1,1),frandom(-1,1),frandom(1,2),
				-0.1,frandom(-0.1,0.1),-0.05
			);
		}

		vector2 oldaim=(angle,pitch);
		blockthingsiterator it=blockthingsiterator.create(self,2048);
		while(it.Next()){
			actor itt=it.thing;
			if(
				(itt.bismonster||itt.player)
				&&itt!=target
				&&itt.health>0
				&&!target.isfriend(itt)
				&&!target.isteammate(itt)
				&&checksight(itt)
			){
				A_Face(itt,0,0);
				A_CustomRailgun((0),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",0,0,2048,18,0.2,1.0
				);
				break;
			}
		}
		angle=oldaim.x;pitch=oldaim.y;
	}
	void A_BFGBallSplodeZap(){
		blockthingsiterator it=blockthingsiterator.create(self,4096);
		while(it.Next()){
			actor itt=it.thing;
			if(
				(itt.bismonster||itt.player)
				&&itt!=target
				&&itt.health>0
				&&checksight(itt)
			){
				A_Face(itt,0,0);
				int hhh=min(itt.health,4096);
				for(int i=0;i<hhh;i+=2048){
					A_CustomRailgun((0),0,"","ff 55 88",
						RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
						0,50.0,"ArmageddonPuff",3,3,2048,18,0.2,1.0
					);
					A_CustomRailgun((0),0,"","ff 55 88",
						RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
						0,50.0,"ArmageddonPuff",3,3,4096,18,0.2,1.0
					); //fuck it. double it
				}
			}
		}
	}
	states{
	spawn:
		TNT1 A 0 nodelay{
			//A_BFGSpray();
			ballripdmg=1;
		}
		BFS1 AB 2 A_SpawnItemEx("ArmaggedonBallTail",0,0,0,vel.x*0.2,vel.y*0.2,vel.z*0.2,0,168,0);
		BFS1 A 0{
			ballripdmg=random(500,1000);
			bripper=false;
		}
		goto spawn2;
	spawn2:
		BFS1 AB 3 A_SpawnItemEx("ArmaggedonBallTail",0,0,0,vel.x*0.2,vel.y*0.2,vel.z*0.2,0,168,0);
		---- A 0; //A_BFGBallZap();
		---- A 0 A_Corkscrew();
		loop;
	death:
		BFE1 A 2;
		BFE1 B 2 A_Explode(640,1024,0);
		BFE1 B 4{
			DistantQuaker.Quake(self,
				12,200,16384,20,512,1024,256
			);
			DistantNoise.Make(self,"world/bfgfar");
		}
		TNT1 AAAAA 0 A_SpawnItemEx("HDSmokeChunk",random(-2,0),random(-3,3),random(-2,2),random(-5,0),random(-5,5),random(0,5),random(100,260),SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		TNT1 AAAAA 0 A_SpawnItemEx("ArmaggedonBallRemains",-1,0,-12,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		BFE1 CCCC 2;
		BFE1 CCC 0 A_SpawnItemEx("HDSmoke",random(-4,0),random(-3,3),random(0,4),random(-1,1),random(-1,1),random(1,3),0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		BFE1 DEF 6;
		BFE1 F 3 bright A_FadeOut(0.1);
		wait;
	}
}

class ArmaggedonBallRemains:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			stamina=0;
		}
	spawn2:
		TNT1 AAAA 1 A_SpawnParticle(
			"ff 55 88",SPF_FULLBRIGHT,35,
			size:frandom(1,8),0,
			frandom(-16,16),frandom(-16,16),frandom(0,8),
			frandom(-1,1),frandom(-1,1),frandom(1,2),
			frandom(-0.1,0.1),frandom(-0.1,0.1),-0.05
		);
		TNT1 A 0 A_SpawnItemEx("HDSmoke",random(-3,3),random(-3,3),random(-3,3),random(-1,1),random(-1,1),random(1,3),0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0{stamina++;}
		TNT1 A 0 A_JumpIf(stamina<10,"spawn2");
		TNT1 AAAAAA 2 A_SpawnParticle(
			"ff 55 88",SPF_FULLBRIGHT,35,
			size:frandom(1,8),0,
			frandom(-16,16),frandom(-16,16),frandom(0,8),
			frandom(-1,1),frandom(-1,1),frandom(1,2),
			frandom(-0.1,0.1),frandom(-0.1,0.1),-0.05
		);
		stop;
	}
}

class Archonsploder:HDActor{
	int ud;
	default{
		+noblockmap +missile +nodamagethrust
		gravity 0;height 6;radius 6;
		damagefactor(0);
	}
	override void postbeginplay(){
		super.postbeginplay();
		A_ChangeVelocity(1,0,0,CVF_RELATIVE);
		distantnoise.make(self,"world/rocketfar");
	}
	states{
	death:
		TNT1 A 0{
			if(ceilingz-pos.z<(pos.z-floorz)*3) ud=-5;
			else ud=5;
		}
		TNT1 AA 0 A_SpawnItemEx("HDSmoke", -1,0,ud,
			frandom(-2,2),frandom(-2,2),0,
			frandom(-15,15),SXF_NOCHECKPOSITION
		);
	xdeath:
	spawn:
		TNT1 A 0 nodelay;
		TNT1 AA 0 A_SpawnItemEx("HDExplosion",
			random(-1,1),random(-1,1),2, 0,0,0,
			0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS
		);
		TNT1 A 2 A_SpawnItemEx("HDExplosion",0,0,0,
			0,0,2,
			0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS
		);
	death2:
		TNT1 AA 0 A_SpawnItemEx("HDSmoke",-1,0,1,
			random(-2,3),random(-2,2),0,
			random(-15,15),SXF_NOCHECKPOSITION
		);
		TNT1 A 21{
			A_AlertMonsters();
			DistantQuaker.Quake(self,4,35,512,10);
		}stop;
	}
}

class ArchonBallTail:HDActor{
	default{
		+nointeraction
		+forcexybillboard
		renderstyle "add";
		alpha 0.6;
		scale 0.7;
	}
	states{
	spawn:
		ARCB A 0 A_Jump(128,"spawn2");
		ARCB DEFGHI 2 bright{ A_FadeOut(0.2); A_StartSound("baron/ballhum",volume:0.4,attenuation:6.);}
		stop;
	death2:
		ARCB JKLMN 2 bright{ A_FadeOut(0.2); A_StartSound("baron/ballhum",volume:0.4,attenuation:6.);}
		stop;
	}
}

class ArchonBall:SlowProjectile{
	bool isrocket;
	default{
		+forcexybillboard
		projectile;
		+seekermissile
		damagetype "balefire";
		renderstyle "normal";
		decal "gooscorch";
		alpha 0.8;
		scale 0.6;
		radius 4;
		height 6;
		speed 20;
		damage 6;
		seesound "baron/attack";
		deathsound "baron/shotx";
	}
	int user_counter;
	override void postbeginplay(){
		super.postbeginplay();

		let hdmb=hdmobbase(target);
		if(hdmb)hdmb.firefatigue+=int(HDCONST_MAXFIREFATIGUE*0.1);
	}

	override void ExplodeSlowMissile(line blockingline,actor blockingobject){
		if(max(abs(skypos.x),abs(skypos.y))>=32768){destroy();return;}
		bmissile=false;
		//damage
		//NOTE: basic impact damage calculation is ALREADY in base SlowProjectile!
		if(blockingobject){
			int dmgg=random(32,128);
			if(primed&&isrocket){
				double dangle=absangle(angle,angleto(blockingobject));
				if(dangle<20){
					dmgg+=random(200,600);
					if(hd_debug)A_Log("CRIT!");
				}else if(dangle<40)dmgg+=random(100,400);
			}
			blockingobject.damagemobj(self,target,dmgg,"Piercing");
		}else doordestroyer.destroydoor(self,42,frandom(3,16));

		//explosion
		if(!inthesky){
			A_SprayDecal("Scorch",16);
			A_HDBlast(
				pushradius:256,pushamount:128,fullpushradius:96,
				fragradius:HDCONST_ONEMETRE*(10+0.2*stamina),fragtype:"HDB_frag",
				immolateradius:128,immolateamount:random(3,60),
				immolatechance:isrocket?random(1,stamina):25
			);
			actor xpl=spawn("Archonsploder",pos-(0,0,1),ALLOW_REPLACE);
			xpl.target=target;xpl.master=master;xpl.stamina=stamina;
		}else{
			distantnoise.make(self,"world/rocketfar");
		}
		A_SpawnChunksFrags("HDB_frag",180,0.8+0.05*stamina);
		destroy();return;
	}

	states{
	spawn:
		ARCB A 0 bright nodelay A_StartSound("baron/attack");
		ARCB EDC 1 bright;
		ARCB ABABA 2 bright;
		ARCB BAB 3 bright;
	spawn2:
		ARCB A 2 bright A_SeekerMissile(5,10);
		ARCB B 2 bright A_SpawnItemEx("ArchonBallTail",-3,0,3,3,0,random(1,2),0,161,0);
		ARCB A 2 bright A_SeekerMissile(5,9);
		ARCB B 2 bright A_SpawnItemEx("ArchonBallTail",-3,0,3,3,0,random(1,2),0,161,0);
		ARCB A 2 bright A_SeekerMissile(4,8);
		ARCB B 2 bright A_SpawnItemEx("ArchonBallTail",-3,0,3,3,0,random(1,2),0,161,0);
		ARCB A 2 bright A_SeekerMissile(3,6);
		ARCB B 2 bright A_SpawnItemEx("ArchonBallTail",-3,0,3,3,0,random(1,2),0,161,0);
	spawn3:
		TNT1 A 0 A_JumpIf(user_counter>4,"spawn4");
		TNT1 A 0 {user_counter++;}
		ARCB A 3 bright A_SeekerMissile(1,1);
		ARCB B 3 bright A_SpawnItemEx("ArchonBallTail",-3,0,3,3,0,random(1,2),0,161,0);
		loop;
	spawn4:
		ARCB A 3 bright A_SpawnItemEx("ArchonBallTail",-3,0,3,3,0,random(1,2),0,161,0);
		TNT1 A 0 A_JumpIf(pos.z-floorz<10,2);
		ARCB B 3 bright A_ChangeVelocity(frandom(-0.2,1),frandom(-1,1),frandom(-1,0.9),CVF_RELATIVE);
		loop;
		ARCB B 3 bright A_ChangeVelocity(frandom(-0.2,1),frandom(-1,1),frandom(-0.6,1.9),CVF_RELATIVE);
		loop;
	death:
		ARCB A 0 A_Jump(128,"death2");
		ARCB DEFGHI 4 bright A_FadeOut(0.2);
		stop;
	death2:

		ARCB JKLMN 4 bright A_FadeOut(0.2);
		stop;
	}
}

class BaronUnmaker:PainMonster{
	default{
		height 64;
		radius 17;
		mass 1000;
		+boss
		seesound "ubaron/sight";
		painsound "ubaron/pain";
		deathsound "ubaron/death";
		activesound "ubaron/active";
		obituary "$OB_DEFAULT";
		tag "\cr++ \cgENTITY NAME NOT FOUND \cr++\c-";

		+nofear +frightening +doharmspecies +quicktoretaliate +neverrespawn
		maxtargetrange 65536;
		damagefactor "hot",0.8;
		damagefactor "cold",0.7;
		damagefactor "slashing",0.86;
		damagefactor "piercing",0.95;
		damagefactor "balefire",0.3;
		damagefactor "armageddon",0;
		meleedamage 24;
		meleerange 58;
		health 10000;
		speed 12;
		painchance 4;
		hdmobbase.shields 10000;
	}
	bool pissing;
	bool castingarmageddon;
	int meteorscheck;
	int ticsforloop3;
	int pissleft;
	int timearmageddon;
	int crittimearmageddon;

	static bool IsSkyAbove(Actor a)
	{
		FLineTraceData data;
		a.LineTrace(0, a.ceilingz - a.floorz + 64, -90, flags: TRF_NOSKY | TRF_THRUACTORS, data: data);
		return data.HitType == data.TRACE_HitNone;
	}

	static void Spark(actor caller,int sparks=1,double sparkheight=10){
		actor a;vector3 spot;
		vector3 origin=caller.pos+(0,0,sparkheight);
		double spp;double spa;
		for(int i=0;i<sparks;i++){
			spp=caller.pitch+frandom(-20,20);
			spa=caller.angle+frandom(-20,20);
			spot=random(32,57)*(cos(spp)*cos(spa),cos(spp)*sin(spa),-sin(spp));
			a=caller.spawn("ArchonSpark",origin+spot,ALLOW_REPLACE);
			a.vel+=caller.vel*0.9-spot*0.03;
		}
	}

	//preserved just in case matt decided to nuke A_UnmakeLevel.
	//nothing to see here, go away
	action void A_UnmakeLevelUnmaker(int unmintensity=1){HDUnmaker.UnmakeLevelUnmaker(unmintensity);}
	static void UnmakeLevelUnmaker(int unmintensity=1){
		for(int k=0;k<unmintensity;k++){
			sector thissector=level.sectors[random(0,level.sectors.size()-1)];
			int dir=random(-3,3);
			double zatpoint=thissector.floorplane.ZAtPoint(thissector.centerspot);
			thissector.MoveFloor(dir,zatpoint,0,zatpoint>0?-1:1,false);
			dir=random(-3,3);
			zatpoint=thissector.ceilingplane.ZAtPoint(thissector.centerspot);
			thissector.MoveCeiling(dir,zatpoint,0,zatpoint>0?-1:1,false);
			thissector.changelightlevel(random(-random(3,4),3));
			//then maybe add some textures
			textureid shwal;
			switch(random(0,4)){
			case 1:
				shwal=texman.checkfortexture("WALL63_2",texman.type_any);break;
			case 2:
				shwal=texman.checkfortexture("W94_1",texman.type_any);break;
			case 3:
				shwal=texman.checkfortexture("FIREBLU1",texman.type_any);break;
			case 4:
				shwal=texman.checkfortexture("SNAK"..random(7,8).."_1",texman.type_any);break;
			default:
				shwal=texman.checkfortexture("ASHWALL2",texman.type_any);break;
			}
			for(int i=0;i<thissector.lines.size();i++){
				line lnn=thissector.lines[i];

				for(int j=0;j<2;j++){
					if(!lnn.sidedef[j])continue;
					if(!lnn.sidedef[j].GetTexture(side.top))lnn.sidedef[j].SetTexture(side.top,shwal);
					if(!lnn.sidedef[j].GetTexture(side.bottom))lnn.sidedef[j].SetTexture(side.bottom,shwal);
				}
			}
		}
	}

	override double bulletshell(vector3 hitpos,double hitangle){
		return frandom(3,12);
	}
	override double bulletresistance(double hitangle){
		return max(0,frandom(0.8,1.)-hitangle*0.008);
	}
	override void postbeginplay(){
		super.postbeginplay();
		resize(0.95,1.05);
		pissleft=2000; //piss tank.
	}
	override void tick(){
		super.tick();
		if(!isfrozen()&&firefatigue>0)firefatigue-=12;
		if(!isfrozen()&&pissleft<1999&&
		!pissing)pissleft+=2; //refueling.
	}
	enum BaronUnmakerStats{
		BU_HPMAX=10000,
		BU_OKAY=BU_HPMAX*7/10,
		BU_BAD=BU_HPMAX*3/10,
	}

	void A_BlurWander(bool dontlook=false){
		A_HDWander(dontlook?0:CHF_LOOK);
		A_SpawnItemEx("ArchonBlur",frandom(-2,2),frandom(-2,2),frandom(-2,2),flags:SXF_TRANSFERTRANSLATION|SXF_TRANSFERSPRITEFRAME);
	}
	void A_BlurChase(){
		speed=getdefaultbytype(getclass()).speed;

		A_HDChase();
		A_SpawnItemEx("ArchonBlur",frandom(-2,2),frandom(-2,2),frandom(-2,2),flags:SXF_TRANSFERTRANSLATION|SXF_TRANSFERSPRITEFRAME);
	}

	states{
	spwander:
		BOS4 ABCDABCD 7 A_BlurWander();
		BOS4 A 0{
			if(!random(0,1))setstatelabel("spwander");
			else A_Recoil(-0.4);
		}//fallthrough to spawn
	spawn:
		BOS4 AA 8 A_HDLook();
		BOS4 A 1 A_SetTics(random(1,16));
		BOS4 BB 8 A_HDLook();
		BOS4 B 1 A_SetTics(random(1,16));
		BOS4 CC 8 A_HDLook();
		BOS4 C 1 A_SetTics(random(1,16));
		BOS4 DD 8 A_HDLook();
		BOS4 D 1 A_SetTics(random(1,16));
		BOS4 A 0{
			if(bambush)setstatelabel("spawn");
			else{
				if(!random(0,5))A_StartSound("ubaron/active",CHAN_VOICE);
				if(!random(0,5))setstatelabel("spwander");
			}
		}loop;

	see:
		BOS4 ABCD 4 A_BlurChase();
		TNT1 A 0 A_JumpIfTargetInLOS("see");
		goto roam;
	roam:
		BOS4 A 0 A_JumpIfTargetInLOS("missile");
		BOS4 A 0 A_ShoutAlert(0.3,SAF_SILENT);
		BOS4 ABCD 4 A_BlurWander(CHF_LOOK);
		loop;
	missile:
		BOS4 ABCD 3{
			A_FaceTarget(30);
			if(A_JumpIfTargetInLOS("shoot",10))setstatelabel("shoot");
		}
		BOS4 E 0 A_JumpIfTargetInLOS("missile");
		---- A 0 setstatelabel("see");
	shoot:
		BOS4 E 0 A_AlertMonsters(0,AMF_TARGETEMITTER);
		BOS4 E 0 A_Jump(64,"ArmageddonConfirmation");
		BOS4 E 0 A_Jump(80,"MissileSweep","MissilePissConfirmation");
		BOS4 E 0 A_Jump(128,"MissileFuckYouConfirmation");
		BOS4 E 0 A_Jump(128,"MissileSkullConfirmation","MissileMissile");
		goto see; //if the player's too close

	melee:
		BOS4 E 3 A_FaceTarget();
		BOS4 F 1;
		BOS4 G 3{
			A_CustomMeleeAttack(random(20,100),"baron/melee","","claws",true);
		}
		BOS4 H 3;
		---- A 0 A_JumpIfTargetInsideMeleeRange("melee2");
		goto see;
	melee2:
		BOS4 J 3 A_FaceTarget();
		BOS4 I 1;
		BOS4 J 3{
			A_CustomMeleeAttack(random(20,100),"baron/melee","","claws",true);
		}
		BOS4 K 3;
		---- A 0 A_JumpIfTargetInsideMeleeRange("melee");
		goto see;

	MissileSkullConfirmation:
		BOS4 D 1 A_JumpIfCloser(128,"shoot");
		BOS4 # 0 A_JumpIfInventory("UnmakerUpgrade2Icon",1,"MissileSkull");
		goto shoot;
	MissileSkull:
		BOS4 Q 12 A_FaceTarget(0,0);
		BOS4 Q 12 bright{
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
				A_CustomRailgun((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"BFGPuffUnmaker",5,4,2048,18,0.2,1.0,"",28);
}
		BOS4 Q 18;
		goto see;
	MissileMissile:
		BOS4 # 0 A_JumpIfCloser(192,"shoot");
		BOS4 Q 16 A_FaceTarget(20,20);
		BOS4 Q 6 bright A_SpawnProjectile("UnmakerBeam",38,0,-2,CMF_AIMDIRECTION,pitch);
		BOS4 Q 6 bright A_SpawnProjectile("UnmakerBeam",46,0,-9,CMF_AIMDIRECTION,pitch);
		BOS4 Q 6 bright A_SpawnProjectile("UnmakerBeam",56,0,-17,CMF_AIMDIRECTION,pitch);
		BOS4 Q 6 bright A_SpawnProjectile("UnmakerBeam",66,0,-24,CMF_AIMDIRECTION,pitch);
		BOS4 Q 12;
		---- A 0 setstatelabel("see");
	MissileFuckYouConfirmation:
		BOS4 D 1 A_JumpIfCloser(32,"shoot");
		BOS4 F 0 A_JumpIfInventory("UnmakerUpgrade1Icon",1,"MissileFuckYou");
		goto shoot;
	MissileFuckYou:
		BOS4 F 4 A_FaceTarget(20,20);
		BOS4 E 6;
		BOS4 MN 6;
		BOS4 O 12 bright A_SpawnProjectile("UnmakerBall",28,0,0,CMF_AIMDIRECTION,pitch);
		BOS4 PN 6;
		---- A 0 setstatelabel("see");

	MissilePissConfirmation:
		UMKR A 0{if(pissleft<1)setstatelabel("shoot");}
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade3Icon",1,"MissilePiss");
		goto shoot;

	MissilePiss:
		BOS4 QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ 1 A_FaceTarget(0.1,0.1);
		UMKR A 0{
			ticsforloop3=0;
			pissing=true;
			A_StartSound("weapons/unmakerbeamstart",CHAN_WEAPON);
		}
	MissilePissLoop:
		BOS4 Q 1{
			if(pissleft>0){
			pissleft--;
			A_Recoil(0.01);
			A_FaceTarget(0.15,0.15);
			A_CustomRailgun ((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,0,50.0,"EgonUnmaker",0,0,0,1,0.2,1,"None",28);
						if (hdunm_unmakearchon)
						{
							A_UnmakeLevelUnmaker(10);
						}
			ticsforloop3++;
			}else setstatelabel("MissilePissEnd");
			}

		UMKR A 0{
if(ticsforloop3>105)setstatelabel("MissilePiss2");
		}
		loop;

	MissilePiss2:
		UMKR A 0{
			ticsforloop3=0;
			A_StartSound("weapons/unmakerbeamloop",CHAN_WEAPON,CHANF_LOOPING);
		}
	MissilePissLoop2:
		BOS4 Q 1{
			if(pissleft>0){
			pissleft--;
			A_Recoil(0.01);
			A_FaceTarget(0.2,0.2);
			A_CustomRailgun ((10),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,0,50.0,"EgonUnmaker",0,0,0,1,0.2,1,"None",28);
						if (hdunm_unmakearchon)
						{
							A_UnmakeLevelUnmaker(10);
						}
			ticsforloop3++;
			}else setstatelabel("MissilePissEnd");
			}
		BOS4 A 0{
			if(frandom(0,0.1)){
				pissleft--;
			}
		}
		loop;

	MissilePissEnd:
		BOS4 Q 1{
			pissing=false;
			A_FaceTarget(0.1,0.1);
			A_StartSound("weapons/unmakerbeamend",CHAN_WEAPON);
				A_CustomRailgun((5),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"EgonUnmaker",0,0,2048,18,0.2,1.0,"None",28);
						if (hdunm_unmakearchon)
						{
							A_UnmakeLevelUnmaker(1);
						}
			}
		BOS4 Q 1;
		UMKR A 0{
			if(pissleft>0){
				pissleft--;
			}
		}
		BOS4 Q 1;
		goto see;

	ArmageddonConfirmation:
		UMKR A 0{
				if (BaronUnmaker.IsSkyAbove(self))
				{
					SetStateLabel("ArmageddonConfirmationB");
					return;
				}
		}
		goto shoot;

	ArmageddonConfirmationB:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade1Icon",1,"ArmageddonConfirmation2A");
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade2Icon",1,"ArmageddonConfirmation2B");
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade3Icon",1,"ArmageddonConfirmation2C");
		goto shoot;
	ArmageddonConfirmation2A:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade2Icon",1,"ArmageddonConfirmation3C");
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade3Icon",1,"ArmageddonConfirmation3B");
		goto shoot;
	ArmageddonConfirmation2B:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade1Icon",1,"ArmageddonConfirmation3C");
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade3Icon",1,"ArmageddonConfirmation3A");
		goto shoot;
	ArmageddonConfirmation2C:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade1Icon",1,"ArmageddonConfirmation3B");
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade2Icon",1,"ArmageddonConfirmation3A");
		goto shoot;
	ArmageddonConfirmation3A:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade1Icon",1,"EngageArmaggedon");
		goto shoot;
	ArmageddonConfirmation3B:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade2Icon",1,"EngageArmaggedon");
		goto shoot;
	ArmageddonConfirmation3C:
		UMKR A 0 A_JumpIfInventory("UnmakerUpgrade3Icon",1,"EngageArmaggedon");
		goto shoot;
	EngageArmaggedon:
		BOS4 M 1 A_TakeInventory("SpellSuccessSignal",1);
		BOS4 F 4 A_FaceTarget(20,20);
		BOS4 E 6;
		BOS4 M 6;
		BOS4 M 0 A_Jump(192,"CastDownMeteors");
		BOS4 M 0{
		binvulnerable=true;
		bnopain=true;
		bnoblood=true;
		castingarmageddon=true;
		let meteor = spawn("MeteorSpawner",pos,ALLOW_REPLACE);
		if(meteor){
				meteor.master=self;
				tracer=meteor;
				setstatelabel("ArmageddonSpawnConfirmation");
				}
			}
	ArmageddonSpawnConfirmation:
		BOS4 M 1 A_JumpIfInventory("SpellSuccessSignal",1,"ArmageddonProcessing");
		goto armageddonend;
	ArmageddonProcessing:
		BOS4 M 2{
			BaronUnmaker.Spark(self,1,height-10);
			A_StartSound("weapons/bfgcharge",(timearmageddon>6)?CHAN_AUTO:CHAN_WEAPON);
			A_SetTics(max(1,6-int(timearmageddon*0.3)));
			timearmageddon++;
		}
		#### B 0{
			if(timearmageddon>21)setstatelabel("finisharmageddon");
		}loop;
	finisharmageddon:
		#### B 0{
			timearmageddon=0;
			crittimearmageddon=15;
			A_StartSound("weapons/bfgf",CHAN_WEAPON);
		}
		BOS4 M 3{
			crittimearmageddon--;
			A_StartSound("weapons/bfgcharge",random(9005,9007));
			BaronUnmaker.Spark(self,1,height-10);
			if(crittimearmageddon<5){
				setstatelabel("finisharmageddon2");
			}else if(crittimearmageddon<10)A_SetTics(2);
			else if(crittimearmageddon<5)A_SetTics(1);
		}wait;

	finisharmageddon2:
		BOS4 NN 1{
			crittimearmageddon--;
			BaronUnmaker.Spark(self,1,height-10);
			}
		BOS4 O 1{
			crittimearmageddon--;
			BaronUnmaker.Spark(self,1,height-10);
			}
		goto unleashthearmageddon;
	unleashthearmageddon:
		BOS4 O 1{
			crittimearmageddon--;
			BaronUnmaker.Spark(self,1,height-10);
			}
		BOS4 P 1{
			A_SpawnProjectile(
			"ExplosionEffectUnmakerBaronHarmless",
			28,0,0,2,pitch
			);
			binvulnerable=false;
			bnopain=false;
			bnoblood=false;
			castingarmageddon=false;
			}
		BOS4 P 10;
		goto see;

	CastDownMeteors:
		BOS4 M 0{castingarmageddon=true;}
		BOS4 M 0{
		let meteor = spawn("MeteorSpawner2",pos,ALLOW_REPLACE);
		if(meteor2){
				meteor2.master=self;
				tracer=meteor2;
				setstatelabel("ArmageddonSpawnConfirmation2");
				}
			}
	ArmageddonSpawnConfirmation2:
		BOS4 M 1 A_JumpIfInventory("SpellSuccessSignal",1,"Wrath");
		goto armageddonend;
	Wrath:
		BOS4 M 6{
			BaronUnmaker.Spark(self,1,height-10);
			A_StartSound("weapons/bfgcharge",CHAN_AUTO);
			if(!tracer)setstatelabel("armageddonend");
		}
		wait;
	armageddonend:
		BOS4 N 6{
						if(castingarmageddon){
					binvulnerable=false;
					bnopain=false;
					bnoblood=false;
					castingarmageddon=false;
		if(tracer){
				tracer.destroy();
				}
			}
		}
		goto see;

	pain:
		BOS4 P 0{
						if(castingarmageddon){
					binvulnerable=false;
					bnopain=false;
					bnoblood=false;
					castingarmageddon=false;
		if(tracer){
				tracer.destroy();
				}
				}
			}
		BOS4 H 0{
			if(pissing){
			pissing=false;
			A_FaceTarget(0.5,0.5);
			A_StartSound("weapons/unmakerbeamend",CHAN_WEAPON);
				A_CustomRailgun((5),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"EgonUnmaker",0,0,2048,18,0.2,1.0,"None",28);
				}
			if(pissleft>0){
				pissleft--;
			}
		}
		BOS4 Q 6 A_Pain();
		BOS4 Q 3 A_Jump(116,"see","MissilePain");
	MissileSweep:
		BOS4 D 1 A_JumpIfCloser(192,"shoot");
		BOS4 F 4 A_FaceTarget(20,20);
		BOS4 E 6;
		BOS4 E 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,6,56-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,-6,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",56,6,-6,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 F 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,4,46-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,-3,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",46,4,-3,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 F 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,38-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,-1,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",38,0,-1,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 G 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,32-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,1,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",32,0,1,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 G 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,32-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,3,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",32,0,3,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 G 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,32-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,6,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",32,0,6,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 H 6;
		BOS4 E 2 A_FaceTarget(20,20);
	MissileSweep2:
		BOS4 J 4 A_FaceTarget(20,20);
		BOS4 I 6;
		BOS4 I 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,6,56-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,6,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",56,6,6,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 J 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,4,46-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,3,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",46,4,3,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 J 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,38-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,1,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",38,0,1,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);

		BOS4 K 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,32-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,-1,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",32,0,-1,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 K 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,32-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,-3,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",32,0,-3,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 K 2 A_SpawnItemEx("ArchonBall",cos(pitch)*1,0,32-(sin(pitch))*1,cos(pitch)*20,0,-sin(pitch)*1,-6,SXF_TRANSFERTRANSLATION|SXF_TRANSFERPITCH|SXF_SETMASTER|SXF_SETTARGET);
//A_SpawnProjectile("MiniBBall",32,0,-6,CMF_AIMDIRECTION|FPF_TRANSFERTRANSLATION,pitch);
		BOS4 L 6;
		BOS4 I 2 A_Jump(194,"see");
		goto MissileSweep;

	MissilePain:
		BOS4 Q 12 A_FaceTarget(0,0);
		BOS4 Q 12 bright A_SpawnProjectile("UnmakerBall",28,0,0,2,pitch);
		BOS4 Q 18;
		goto See;

	death.bleedout:
	death.telefrag:
		---- A 0{bodydamage+=666*5;}
		---- A 0 A_Quake(2,64,0,600);
		BOS4 P 0{
						if(castingarmageddon){
					binvulnerable=false;
					bnopain=false;
					bnoblood=false;
					castingarmageddon=false;
		if(tracer){
				tracer.destroy();
				}
				}
			}
		BOS4 H 0{
			if(pissing){
			pissing=false;
			A_FaceTarget(0.1,0.1);
			A_StartSound("weapons/unmakerbeamend",CHAN_WEAPON);
				A_CustomRailgun((5),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"EgonUnmaker",0,0,2048,18,0.2,1.0,"None",28);
				}
			if(pissleft>0){
				pissleft--;
			}
		}
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,20,10,0,8,45,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,35,10,0,8,135,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,50,10,0,8,225,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,65,10,0,8,315,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 S 8 A_Scream();
		BOS4 T 8;
		BOS4 U 8 A_NoBlocking();
		BOS4 V 8{
			for(int i=45;i<360;i+=90){
				A_SpawnItemEx("HDExplosion",
					4,-4,20,vel.x,vel.y,vel.z+1,i,
					SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS|SXF_ABSOLUTEMOMENTUM
				);
				A_SpawnItemEx("HDSmokeChunk",0,0,0,
					vel.x+frandom(-12,12),
					vel.y+random(-12,12),
					vel.z+frandom(4,16),
					0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
				);
		}
			
	if(countinv("UnmakerUpgrade1Icon")){
			A_DropItem("HDOrangeDemonKey");
			A_TakeInventory("UnmakerUpgrade1Icon",1);
		}
	if(countinv("UnmakerUpgrade2Icon")){
			A_DropItem("HDPurpleDemonKey");
			A_TakeInventory("UnmakerUpgrade2Icon",1);
		}
	if(countinv("UnmakerUpgrade3Icon")){
			A_DropItem("HDCyanDemonKey");
			A_TakeInventory("UnmakerUpgrade3Icon",1);
		}
			A_DropItem("HDUnmaker"); //ALWAYS drop this
	A_SpawnItemEx("ExplosionEffectUnmakerBaronHarmless",0,0,height/2,
					0,
					0,
					0,
					0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
				);
			A_Quake(3,26,0,220,"none");
		}
		BOS4 V 6;
		BOS4 W 4 bright A_SetRenderStyle(1,STYLE_ADD);
		BOS4 WXYZ 2 bright;
		BOS4 [ 1 bright;
		stop;

	death:
		---- A 0{bodydamage+=666*5;}
		---- A 0 A_Quake(2,64,0,600);
		BOS4 P 0{
						if(castingarmageddon){
					binvulnerable=false;
					bnopain=false;
					bnoblood=false;
					castingarmageddon=false;
		if(tracer){
				tracer.destroy();
				}
				}
			}
		BOS4 H 0{
			if(pissing){
			pissing=false;
			A_FaceTarget(0.1,0.1);
			A_StartSound("weapons/unmakerbeamend",CHAN_WEAPON);
				A_CustomRailgun((5),0,"","ff 55 88",
					RGF_CENTERZ|RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT,
					0,50.0,"EgonUnmaker",0,0,2048,18,0.2,1.0,"None",28);
				}
			if(pissleft>0){
				pissleft--;
			}
		}
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,20,10,0,8,45,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,35,10,0,8,135,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,50,10,0,8,225,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 R 2 A_SpawnItemEx("BFGShard",0,0,65,10,0,8,315,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		BOS4 S 8 A_Scream();
		BOS4 T 8;
		BOS4 U 8 A_NoBlocking();
		BOS4 V 8{
			for(int i=45;i<360;i+=90){
				A_SpawnItemEx("HDExplosion",
					4,-4,20,vel.x,vel.y,vel.z+1,i,
					SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS|SXF_ABSOLUTEMOMENTUM
				);
				A_SpawnItemEx("HDSmokeChunk",0,0,0,
					vel.x+frandom(-12,12),
					vel.y+random(-12,12),
					vel.z+frandom(4,16),
					0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
				);
		}
	if(countinv("UnmakerUpgrade1Icon")){
			A_DropItem("HDOrangeDemonKey");
			A_TakeInventory("UnmakerUpgrade1Icon",1);
		}else
	if(countinv("UnmakerUpgrade2Icon")){
			A_DropItem("HDPurpleDemonKey");
			A_TakeInventory("UnmakerUpgrade2Icon",1);
		}else
	if(countinv("UnmakerUpgrade3Icon")){
			A_DropItem("HDCyanDemonKey");
			A_TakeInventory("UnmakerUpgrade3Icon",1);
		}else
	if(countinv("UnmakerUpgrade2Icon")){
			A_DropItem("HDPurpleDemonKey");
			A_TakeInventory("UnmakerUpgrade2Icon",1);
		}else
	if(countinv("UnmakerUpgrade1Icon")){
			A_DropItem("HDOrangeDemonKey");
			A_TakeInventory("UnmakerUpgrade1Icon",1);
		}
			A_DropItem("HDUnmaker"); //ALWAYS drop this
				A_SpawnItemEx("ExplosionEffectUnmakerBaron",0,0,height/2,
					0,
					0,
					0,
					0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
				);
			A_Quake(3,26,0,220,"none");
		}
		BOS4 V 6;
		BOS4 W 4 bright A_SetRenderStyle(1,STYLE_ADD);
		BOS4 WXYZ 2 bright;
		BOS4 [ 1 bright;
		stop;
	}
}

class ExplosionEffectUnmakerBaron:IdleDummy{
	default{

		+bright
Translation "112:127=176:191", "224:231=170:175", "168:168=170:170";
		renderstyle "add";
		deathsound "weapons/bfgx";
		alpha 0.9;
		height 6;
		radius 6;
		speed 10;
		gravity 0;
	}
	states{
	spawn:
		TNT1 A 0;
	death:
		BFE1 A 2 A_Scream();
		BFE1 B 2 A_Explode(160,512,0);
		BFE1 B 4{
			DistantQuaker.Quake(self,
				6,100,16384,10,256,512,128
			);
			DistantNoise.Make(self,"world/bfgfar");
		}
		TNT1 AAAAA 0 A_SpawnItemEx("HDSmokeChunk",random(-2,0),random(-3,3),random(-2,2),random(-5,0),random(-5,5),random(0,5),random(100,260),SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		TNT1 AAAAA 0 A_SpawnItemEx("BaronExplosionRemains",-1,0,-12,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		BFE1 CCCC 2;
		BFE1 CCC 0 A_SpawnItemEx("HDSmoke",random(-4,0),random(-3,3),random(0,4),random(-1,1),random(-1,1),random(1,3),0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		BFE1 DEF 6;
		BFE1 F 3 bright A_FadeOut(0.1);
		wait;
	}
}

class ExplosionEffectUnmakerBaronHarmless:IdleDummy{
	default{
		+bright
Translation "112:127=176:191", "224:231=170:175", "168:168=170:170";
		renderstyle "add";
		deathsound "weapons/bfgx";
		alpha 0.9;
		height 6;
		radius 6;
		speed 10;
		gravity 0;
	}
	states{
	spawn:
		TNT1 A 0;
	death:
		BFE1 A 2 A_Scream();
		BFE1 B 2;
		BFE1 B 4{
			DistantQuaker.Quake(self,
				6,100,16384,10,256,512,128
			);
			DistantNoise.Make(self,"world/bfgfar");
		}
		TNT1 AAAAA 0 A_SpawnItemEx("HDSmokeChunk",random(-2,0),random(-3,3),random(-2,2),random(-5,0),random(-5,5),random(0,5),random(100,260),SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		TNT1 AAAAA 0 A_SpawnItemEx("BaronExplosionRemains",-1,0,-12,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);

		BFE1 CCCC 2;
		BFE1 CCC 0 A_SpawnItemEx("HDSmoke",random(-4,0),random(-3,3),random(0,4),random(-1,1),random(-1,1),random(1,3),0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,16);
		BFE1 DEF 6;
		BFE1 F 3 bright A_FadeOut(0.1);
		wait;
	}
}

class BaronExplosionRemains:IdleDummy{
	string pcol;
	states{
	spawn:
		TNT1 A 0 nodelay{
			pcol="ff 55 88";
			stamina=0;
		}
	spawn2:
		TNT1 AAAA 1 A_SpawnParticle(
			pcol,SPF_FULLBRIGHT,35,
			size:frandom(1,8),0,
			frandom(-16,16),frandom(-16,16),frandom(0,8),
			frandom(-1,1),frandom(-1,1),frandom(1,2),
			frandom(-0.1,0.1),frandom(-0.1,0.1),-0.05
		);
		TNT1 A 0 A_SpawnItemEx("HDSmoke",random(-3,3),random(-3,3),random(-3,3),random(-1,1),random(-1,1),random(1,3),0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0{stamina++;}
		TNT1 A 0 A_JumpIf(stamina<10,"spawn2");
		TNT1 AAAAAA 2 A_SpawnParticle(
			pcol,SPF_FULLBRIGHT,35,
			size:frandom(1,8),0,
			frandom(-16,16),frandom(-16,16),frandom(0,8),
			frandom(-1,1),frandom(-1,1),frandom(1,2),
			frandom(-0.1,0.1),frandom(-0.1,0.1),-0.05
		);
		stop;
	}
}

class ArchonBlur:HDActor{
	default{
		+nointeraction
		alpha 0.6;
	}
	states{
	spawn:
		BOS4 # 0 nodelay A_ChangeVelocity(frandom(-1,3),frandom(-1,1),frandom(-1,1));
		BOS4 # 1 A_FadeOut(0.05);
		wait;
	}
}

/*
ARCHON OF HELL

Legends say that a powerful demonic nobility will come out from the user who used the Unmaker for too long. Not even the demons themselves can withstand an Archon's power, for they possess the powers of the Unmaker itself. Who knows when they'll appear but one thing's for sure: They may be extremely dangerous to engage one.
*/
