package jam
{
	import adultswim.ScoreComponent;
	import punk.Text;
	import punk.Textplus;
	import punk.core.Alarm;
	import punk.util.Input;
	
	public class SubmitMenu extends MenuWorld
	{
		
		private var draw:uint;
		
		private var num:uint = 0;
		
		private const TEXT_SMALLSEP:uint = 14;
		
		private const WAIT_LONG:uint = 80;
		
		private var alarm:Alarm;
		
		private var score:int;
		
		private var canGo:Boolean = false;
		
		private var timeText:Textplus;
		
		private const TEXT_BIGSEP:uint = 24;
		
		private var scoreText:Textplus;
		
		private const WAIT_SHORT:uint = 40;
		
		private var aScore:Alarm;
		
		private var partsAt:uint;
		
		private var scoreDraw:uint = 0;
		
		private const TEXT_START:uint = 42;
		
		private var menuCont:MenuButton;
		
		private var levelsText:Textplus;
		
		public function SubmitMenu()
		{
			this.alarm = new Alarm(22, this.onAlarm, Alarm.PERSIST);
			this.aScore = new Alarm(this.WAIT_SHORT, this.onCount, Alarm.PERSIST);
			this.draw = this.TEXT_START;
			super();
		}
		
		private function particleBurst(y:int, num:int = 40):void
		{
			var ax:int = 0;
			for (var i:int = 0; i < num; i++)
			{
				ax = FP.choose(-30, -20, -10, 0, 10, 20, 30);
				(FP.world as MenuWorld).createParticles(1, 160 + ax, y, 10, 16777215, 2, 1, 1.5, 0.5, 0, 180, 12, 4);
			}
		}
		
		override public function update():void
		{
			super.update();
			if (this.timeText && this.timeText.scaleX > 1)
			{
				this.timeText.scaleY = this.timeText.scaleX = this.timeText.scaleX - 0.05;
			}
			if (this.scoreText && this.scoreText.scaleX > 1)
			{
				this.scoreText.scaleY = this.scoreText.scaleX = this.scoreText.scaleX - 0.05;
			}
			if (this.levelsText && this.levelsText.scaleX > 1)
			{
				this.levelsText.scaleY = this.levelsText.scaleX = this.levelsText.scaleX - 0.05;
			}
			if (this.menuCont && Input.pressed("skip"))
			{
				this.cont(null);
			}
		}
		
		private function submit(m:MenuButton):void
		{
			remove(m);
			var temp:int = ((Stats.saveData.levelNum - 1) * (Stats.saveData.mode == 0 ? 40000 : 90000) - Stats.saveData.time) * 10;
			temp = Math.max(this.score, 0);
			if (this.score != temp)
			{
				return;
			}
			ScoreComponent.submit(Assets.SUBMIT_IDS[Stats.saveData.mode], this.score);
		}
		
		override public function init():void
		{
			super.init();
			FP.musicVolume = FP.musicVolume / 2;
			this.score = (Stats.saveData.levelNum * (Stats.saveData.mode == 0 ? 40000 : 90000) - Stats.saveData.time) * 10;
			this.score = Math.max(this.score, 0);
			Stats.saveData.levelNum++;
			if (Stats.saveData.levelNum < Assets.TOTAL_LEVELS[Stats.saveData.mode])
			{
				Stats.save();
			}
			addAlarm(this.alarm);
			addAlarm(this.aScore, false);
			var t:Text = new Text("Scoring Time!", 160, 20);
			t.color = 16777215;
			t.size = 16;
			t.center();
			add(t);
		}
		
		private function onCount():void
		{
			if (this.scoreDraw < this.score)
			{
				FP.play(Assets.SndWin);
				this.particleBurst(this.partsAt, 20);
				this.scoreDraw = this.scoreDraw + Math.max(1007, Math.ceil((this.score - this.scoreDraw) / 6));
				this.scoreDraw = Math.min(this.scoreDraw, this.score);
				if (this.score >= 1000000)
				{
					this.scoreText.text = String(Math.floor(this.scoreDraw / 1000000)) + "," + this.digits(Math.floor(this.scoreDraw % 1000000 / 1000)) + "," + this.digits(this.scoreDraw % 1000);
				}
				else if (this.score >= 1000)
				{
					this.scoreText.text = String(Math.floor(this.scoreDraw / 1000)) + "," + this.digits(this.scoreDraw % 1000);
				}
				else
				{
					this.scoreText.text = this.digits(this.scoreDraw);
				}
				this.scoreText.scaleX = this.scoreText.scaleY = 1.3 + Math.random() * 0.4;
				this.scoreText.center();
				if (this.scoreDraw == this.score)
				{
					removeAlarm(this.aScore);
					this.alarm.start();
				}
				else
				{
					this.aScore.totalFrames = 5;
					this.aScore.start();
				}
			}
		}
		
		private function digits(num:uint, digits:uint = 2):String
		{
			var lead:String = "";
			for (var i:int = digits; i > 0; )
			{
				if (num < Math.pow(10, i))
				{
					lead = "0" + lead;
					i--;
					continue;
				}
				break;
			}
			return lead + String(num);
		}
		
		private function onAlarm():void
		{
			var t:Text = null;
			var m:MenuButton = null;
			
			if (Main.instance.level_select.state == false)
			{
			}
			else
			{
				if (this.num == 0)
				{
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					t = new Text("You Completed", 160, this.draw);
					
					t.color = 16777215;
					t.size = 8;
					t.center();
					add(t);
					
					this.alarm.totalFrames = this.WAIT_SHORT;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_SMALLSEP
					
					this.particleBurst(this.draw);
					
					this.levelsText = new Textplus(Main.instance.level_select.level.name, 160, this.draw);
					
					this.levelsText.color = 16777215;
					this.levelsText.size = 16;
					this.levelsText.center();
					this.levelsText.scaleX = this.levelsText.scaleY = 1.5;
					add(this.levelsText);
					
					this.alarm.totalFrames = this.WAIT_LONG;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
					
					t = new Text("In", 160, this.draw);
					
					t.color = 16777215;
					t.size = 8;
					t.center();
					add(t);
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					this.timeText = new Textplus(Stats.saveData.getTimePlusX(Main.instance.level.time), 160, this.draw);
					this.timeText.color = 16777215;
					this.timeText.size = 16;
					this.timeText.center();
					this.timeText.scaleX = this.timeText.scaleY = 1.5;
					add(this.timeText);
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					t = new Text("Your Best Time", 160, this.draw);
					
					t.color = 16777215;
					t.size = 8;
					t.center();
					add(t);
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					if (Main.instance.LEVELS_BEST [Main.instance.level_select.level.name] == -1)
					{
						Main.instance.LEVELS_BEST [Main.instance.level_select.level.name] = Main.instance.level.time;
					}
					else
					{
						Main.instance.LEVELS_BEST [Main.instance.level_select.level.name] = Math.min (Main.instance.level.time, Main.instance.LEVELS_BEST [Main.instance.level_select.level.name]);
					}
					
					this.timeText = new Textplus(Stats.saveData.getTimePlusX(Main.instance.LEVELS_BEST [Main.instance.level_select.level.name]), 160, this.draw);
					this.timeText.color = 16777215;
					this.timeText.size = 24;
					this.timeText.center();
					this.timeText.scaleX = this.timeText.scaleY = 2.0;
					add(this.timeText);
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					this.menuCont = new MenuButton("Done", 160, this.draw + 24, this.cont);
					add(this.menuCont);
					
					Main.instance.SaveLevelsBest ();
				}
				
				this.num++;
				
				return;
			}
			
			if (Main.instance.config.OPTIONS.USE_TAS == false)
			{
				if (this.num == 0)
				{
					t = new Text("Your IL Time", 160, this.draw);
					
					t.color = 16777215;
					t.size = 8;
					t.center();
					add(t);
					this.alarm.totalFrames = this.WAIT_SHORT;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					FP.play(Assets.SndRank6);
					this.particleBurst(this.draw);
					this.timeText = new Textplus(Stats.saveData.getTimePlusX(Main.instance.level.time), 160, this.draw);
					this.timeText.color = 16777215;
					this.timeText.size = 16;
					this.timeText.center();
					this.timeText.scaleX = this.timeText.scaleY = 1.5;
					add(this.timeText);
					this.alarm.totalFrames = this.WAIT_LONG;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
					
					t = new Text("Your Best Time", 160, this.draw);
					
					t.color = 16777215;
					t.size = 8;
					t.center();
					if (Main.instance.level_select.state == false)
					{
						add(t);
					}
					
					this.alarm.totalFrames = this.WAIT_SHORT;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					var bt:Object = Main.instance.GetBestTime(Main.instance.level.text.split(" ").join("_").toUpperCase(), Assets.PREFIXES[Stats.saveData.mode]);
					
					var best_time:String = (bt) ? Stats.saveData.getTimePlusX(uint (String (bt))) : "--:--:--";
					
					FP.play(Assets.SndRank6);
					this.particleBurst(this.draw);
					this.timeText = new Textplus(best_time, 160, this.draw);
					this.timeText.color = 16777215;
					this.timeText.size = 16;
					this.timeText.center();
					this.timeText.scaleX = this.timeText.scaleY = 1.5;
					if (Main.instance.level_select.state == false)
					{
						add(this.timeText);
					}
					this.alarm.totalFrames = this.WAIT_LONG;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
					
					if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
					{
						t = new Text("Your Total Time Was...", 160, this.draw);
					}
					else
					{
						t = new Text("Your Total Time So Far Is...", 160, this.draw);
					}
					t.color = 16777215;
					t.size = 8;
					t.center();
					add(t);
					this.alarm.totalFrames = this.WAIT_SHORT;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					FP.play(Assets.SndRank6);
					this.particleBurst(this.draw);
					this.timeText = new Textplus(Stats.saveData.formattedTime, 160, this.draw);
					this.timeText.color = 16777215;
					this.timeText.size = 16;
					this.timeText.center();
					this.timeText.scaleX = this.timeText.scaleY = 1.5;
					add(this.timeText);
					this.alarm.totalFrames = this.WAIT_LONG;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
					
					if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
					{
						t = new Text("And You Completed...", 160, this.draw);
					}
					else
					{
						t = new Text("And You\'ve Completed...", 160, this.draw);
					}
					t.color = 16777215;
					t.size = 8;
					t.center();
					add(t);
					this.alarm.totalFrames = this.WAIT_SHORT;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					FP.play(Assets.SndRank6);
					this.particleBurst(this.draw);
					//if (Main.instance.level_select.state == false)
					//{
						this.levelsText = new Textplus(Stats.saveData.levelNum - 1 + " Levels", 160, this.draw);
					//}
					//else
					//{
						//this.levelsText = new Textplus(Main.instance.level_select.level.name, 160, this.draw);
					//}
					this.levelsText.color = 16777215;
					this.levelsText.size = 16;
					this.levelsText.center();
					this.levelsText.scaleX = this.levelsText.scaleY = 1.5;
					add(this.levelsText);
					this.alarm.totalFrames = this.WAIT_LONG;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
					
					t = new Text("Which gives you a score of...", 160, this.draw);
					t.color = 16777215;
					t.size = 8;
					t.center();
					//if (Main.instance.level_select.state == false)
					//{
						add(t);
					//}
					this.alarm.totalFrames = this.WAIT_SHORT;
					this.alarm.start();
					this.draw = this.draw + this.TEXT_SMALLSEP;
					
					FP.play(Assets.SndRank6);
					this.particleBurst(this.draw);
					this.partsAt = this.draw;
					this.scoreText = new Textplus("0", 160, this.draw);
					this.scoreText.color = 16777215;
					this.scoreText.size = 16;
					this.scoreText.center();
					this.scoreText.scaleX = this.scoreText.scaleY = 1.5;
					//if (Main.instance.level_select.state == false)
					//{
						add(this.scoreText);
					//}
					this.aScore.start();
					this.draw = this.draw + 8;
					
					FP.play(Assets.SndWin);
					this.particleBurst(165);
					this.particleBurst(195);
					//m = new MenuButton("Submit Score",160,this.draw + 16,this.submit);
					//add(m);
					if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
					{
						this.menuCont = new MenuButton("Done", 160, this.draw + 24, this.cont);
					}
					else
					{
						this.menuCont = new MenuButton("Onward!", 160, this.draw + 24, this.cont);
					}
					add(this.menuCont);
					
					this.scoreDraw = this.score;
					
					FP.play(Assets.SndWin);
					this.particleBurst(this.partsAt, 20);
					this.scoreText.text = String(this.scoreDraw);
					this.scoreText.scaleX = this.scoreText.scaleY = 1.3 + Math.random() * 0.4;
					this.scoreText.center();
				}
			}
			else
			{
				t = new Text("Score is temporarily disabled due to TAS usage", 160, this.draw);
				
				t.color = 16777215;
				t.size = 8;
				t.center();
				add(t);
				
				this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
				this.draw = this.draw + this.TEXT_SMALLSEP;
				this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
				this.draw = this.draw + this.TEXT_SMALLSEP;
				this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
				this.draw = this.draw + this.TEXT_SMALLSEP;
				this.draw = this.draw + this.TEXT_BIGSEP * 0.75;
				this.draw = this.draw + this.TEXT_SMALLSEP;
				this.draw = this.draw + 8;
				
				FP.play(Assets.SndWin);
				if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
				{
					this.menuCont = new MenuButton("Done", 160, this.draw + 24, this.cont);
				}
				else
				{
					this.menuCont = new MenuButton("Onward!", 160, this.draw + 24, this.cont);
				}
				add(this.menuCont);
				
				this.scoreDraw = this.score;
				
				this.onCount();
			}
			
			this.num++;
			
			return;
			
			if (this.num == 0)
			{
				if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
				{
					t = new Text("Your Total Time Was...", 160, this.draw);
				}
				else
				{
					t = new Text("Your Total Time So Far Is...", 160, this.draw);
				}
				t.color = 16777215;
				t.size = 8;
				t.center();
				add(t);
				this.alarm.totalFrames = this.WAIT_SHORT;
				this.alarm.start();
				this.draw = this.draw + this.TEXT_SMALLSEP;
			}
			else if (this.num == 1)
			{
				FP.play(Assets.SndRank6);
				this.particleBurst(this.draw);
				this.timeText = new Textplus(Stats.saveData.formattedTime, 160, this.draw);
				this.timeText.color = 16777215;
				this.timeText.size = 24;
				this.timeText.center();
				this.timeText.scaleX = this.timeText.scaleY = 1.5;
				add(this.timeText);
				this.alarm.totalFrames = this.WAIT_LONG;
				this.alarm.start();
				this.draw = this.draw + this.TEXT_BIGSEP;
			}
			else if (this.num == 2)
			{
				if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
				{
					t = new Text("And You Completed...", 160, this.draw);
				}
				else
				{
					t = new Text("And You\'ve Completed...", 160, this.draw);
				}
				t.color = 16777215;
				t.size = 8;
				t.center();
				add(t);
				this.alarm.totalFrames = this.WAIT_SHORT;
				this.alarm.start();
				this.draw = this.draw + this.TEXT_SMALLSEP;
			}
			else if (this.num == 3)
			{
				FP.play(Assets.SndRank6);
				this.particleBurst(this.draw);
				this.levelsText = new Textplus(Stats.saveData.levelNum - 1 + " Levels", 160, this.draw);
				this.levelsText.color = 16777215;
				this.levelsText.size = 24;
				this.levelsText.center();
				this.levelsText.scaleX = this.levelsText.scaleY = 1.5;
				add(this.levelsText);
				this.alarm.totalFrames = this.WAIT_LONG;
				this.alarm.start();
				this.draw = this.draw + this.TEXT_BIGSEP;
			}
			else if (this.num == 4)
			{
				t = new Text("Which gives you a score of...", 160, this.draw);
				t.color = 16777215;
				t.size = 8;
				t.center();
				add(t);
				this.alarm.totalFrames = this.WAIT_SHORT;
				this.alarm.start();
				this.draw = this.draw + this.TEXT_SMALLSEP;
			}
			else if (this.num == 5)
			{
				FP.play(Assets.SndRank6);
				this.particleBurst(this.draw);
				this.partsAt = this.draw;
				this.scoreText = new Textplus("0", 160, this.draw);
				this.scoreText.color = 16777215;
				this.scoreText.size = 24;
				this.scoreText.center();
				this.scoreText.scaleX = this.scoreText.scaleY = 1.5;
				add(this.scoreText);
				this.aScore.start();
				this.draw = this.draw + 48;
			}
			else if (this.num == 6)
			{
				FP.play(Assets.SndWin);
				this.particleBurst(165);
				this.particleBurst(195);
				m = new MenuButton("Submit Score", 160, this.draw, this.submit);
				add(m);
				if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
				{
					this.menuCont = new MenuButton("Done", 160, this.draw + 32, this.cont);
				}
				else
				{
					this.menuCont = new MenuButton("Onward!", 160, this.draw + 32, this.cont);
				}
				add(this.menuCont);
			}
			this.num++;
		}
		
		private function cont(m:MenuButton):void
		{
			FP.play(Assets.SndWin);
			if (Main.instance.level.repeat == false)
			{
				if (Stats.saveData.levelNum >= Assets.TOTAL_LEVELS[Stats.saveData.mode])
				{
					Assets.playBye();
					add(new FuzzTransition(FuzzTransition.MENU, MainMenu));
				}
				else
				{
					add(new FuzzTransition(FuzzTransition.NEW, null, false, Stats.saveData.levelNum));
				}
			}
			else
			{
				add(new FuzzTransition(FuzzTransition.NEW, null, false, Stats.saveData.levelNum - 1));
			}
			
			FP.musicVolume = FP.musicVolume * 2;
			remove(this.menuCont);
			this.menuCont = null;
		}
	}
}
