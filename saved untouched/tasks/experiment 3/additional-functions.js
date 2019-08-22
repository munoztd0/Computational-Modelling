var instructions_1a_text = function(){
	var instructions = ["<div align=center>Welcome to this HIT!<br><br>Please read all following instructions very carefully.<br><br>It takes some time, but otherwise you will not know what to do.</div>",
	"<div align=center>In this HIT, you are an employee of a space mining company. You will be traveling from earth<br> to look for space treasure on three different planets:<br><br><img style='margin:0px auto;display:block;height:200px' src='img/example_planets.png',/></div>", 
	"<div align=center>Each planet has one alien on it and each alien has its own space treasure mine.<br><br><img style='margin:0px auto;display:block;height:100px' src='img/example_aliens.png',/><br>Once you arrive to each planet, you will ask the alien for space treasure from its mine.</div>",
	"<div align=justify>These aliens are nice, so if an alien just brought treasure up from the mine, it will share it with you. Space treasure looks like this:<br><br><img style='margin:0px auto;display:block' src='img/treasure.png'/><br>Sometimes, the alien will not bring up any treasure and you'll see an empty circle:<br><br><img style='margin:0px auto;display:block' src='img/noreward.png'/></div>",
	"<div align=justify>If an alien has a good mine, it means it can easily dig up space treasure and it will be very likely to have some to share. It might not have treasure every time you ask, but it will most of the time.<br><br>Another alien might have a bad mine that is hard to dig through at the moment and won't have treasure to share most times you ask.<br><br>At the end of each trial, the space treasure that you earned will be converted to points.<br><Br>Each piece of space treasure will be worth one point.</div>",
	//"<div align=justify>If an alien has a good mine, it means it can easily dig up a lot of space treasure for you:<br><br><img style='margin:0px auto;display:block' src='img/treasure_9.png',/><br>Another alien might have a bad mine that gives only a little treasure:<br><br><img style='margin:0px auto;display:block' src='img/treasure_1.png',/><br>The quality of each alien's mine will change during the game. Aliens with a bad mine might get to a part of the mine that has more treasure, and those with a good mine might find less space treasure later on.<br><br>Changes in an alien's mine will happen slowly. So, you have to focus to get as much treasure as possible by finding the alien with the best mine at each point in time.</div>",
	"<div align=justify>Each time you encounter an alien on a planet, you should press the SPACE key to ask it to mine. You will then see whether you got treasure. Try practicing a few times.</div>"];
	return instructions
};

var instructions_1b_text = function(){
	var instructions = ["<div align=center>You may have noticed that this alien's mine was good. It gave you space treasure most of the time.<br><br>The mines of other aliens might be less good. To see this, you are going to ask another alien for treasure a few times.</div>"];
	return instructions
};

var instructions_1c_text = function(){
	var instructions = ["<div align=justify>See, this alien was not in a very good part of the mine, and could share very little space treasure.<br><br>Sometimes, an alien's mine is neither very good nor very bad. To see this, you will ask a third alien for treasure a few times.</div>"];
	return instructions
};

var instructions_2_text = function(){
	var instructions = ["<div align=justify>Good! You have learned that even though the purple alien had a better mine, you couldn't be sure that it had treasure all the time. At the same time, even though the red alien had almost no treasure to share, it was still able to sometimes give you some treasure.</div>",
	"<div align=justify>The treasure an alien can give will change during the game. Those with a good mine might get to a part of the mine where it is hard to dig. Those with little to share might find easier treasure to dig.<br><br>Any changes in an alien's mine will happen slowly, so it is important to focus to get as much treasure as possible.<br><br>While the chance an alien has treasure to share changes over time, it changes slowly. So an alien with a good treasure mine right now will stay good for a while.<br><br>To find the alien with the best mine at each point in time, you must concentrate.</div>",
	"<div align=justify>Now that you know about the treasure, you can learn how the travel to the planets works.<br><br>On each trial, you will travel from earth to one of three planets, a purple planet, a red planet, and a yellow planet:<br><br><img style='margin:0px auto;display:block;height:200px' src='img/example_planets.png',/></div>",
	"<div align=justify>On each trial, the space mining company will give you a choice of which <strong  class='highlight'>spaceship</strong> to take. Each time, they will give you a choice between three different spaceships:</div><div align=center style='white-space: pre;'><br><br><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[0]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[1]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[2]+".png'/>                    <img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[3]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[4]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[5]+".png'/><br><br></div><div align=justify>Sometimes, you'll be choosing between the three spaceships on the left, and sometimes you'll be choosing between the three spaceships on the right. You can always choose the left spaceship by pressing the 'F' key, the middle spaceship by pressing the 'G' key, and the right spaceship by pressing the 'H' key.</div>",
	"<div align=justify>Each spaceship will fly to one of the three planets.<br><br>For each set of three ships, one spaceship will fly ALWAYS to the purple planet, one will ALWAYS fly to the red planet, and the third will ALWAYS fly to the yellow planet.<br><br>It does not matter in which position the spaceship appears (left, middle, or right). The same spaceship will always travel to the same planet.</div>",
	"<div align=justify>Let's practice flying to the planets! On each practice trial you will first see which planet you need to travel to from one of the following displays: <br><br><img style='margin:0px auto;display:block;height:200px' src='img/example_probes_planet.png'/><br><br>The planet, and therefore the display, will change from trial to trial. You will need to do this correctly <strong class='highlight'>10 times</strong> in a row before you can proceed. There will be a counter on screen to indicate how far along you are.</div>"];
	return instructions
};

var instructions_3_text = function(){
	var instructions = ["<div align=justify>The space mining company is currently doing some tests on how they transport their employees to the planets. Therefore, one some trials they will first give you a choice between <strong class='highlight'>spacestations</strong>:<br><br><img style='margin:0px auto;display:block;height:100px' src='img/example_stations.png'/><br><br>In these space stations, you will then find two of the spaceships you practiced with before:<br><br></div><div align=center style='white-space: pre;'><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[0]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[4]+".png'/>                    <img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[1]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[5]+".png'/>                    <img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[2]+".png'/><img style='margin:3px;height:100px' src='img/earth_stim_"+rocket_order[3]+".png'/><br><br></div><div align=justify>One of the space stations will ALWAYS contain the left most pair of spaceships, one of them will ALWAYS contain the middle pair of spaceships, and one of them will ALWAYS contain the right pair of spaceships. The spaceships will then travel to the planets that you just practiced.</div>",
	"<div align=justify>On these trials, you will first choose between two <strong class='highlight'>spacestations</strong>. You can always choose the left spacestation by pressing the 'F' key, and the right spaceship by pressing the 'H' key.<br><br>Next, your choice of spacestation will lead to a pair of <strong class='highlight'>spaceships</strong>. You can choose the left space ship by pressing the 'F' key, and the right spaceship by pressing the 'H' key.<br><br>The spaceship will then fly to one of three planets, just like you practiced before.</div>",
	"<div align=justify>Let's practice flying to the planets with the spacestations! At the start of each practice trial you will see which planet to go to. You will have to pick the spacestations and spaceships that will get you that planet.<br><br>There is always a space station that will have one of the two spaceships you need to travel to the planet, but sometimes the other space station will not have the right spaceships.<br><br>You need to do this correctly <strong class='highlight'>10 times</strong> in a row before you can proceed, and so you will have to concentrate on which spaceships and space stations to pick.</div>"];
	return instructions
};

var instructions_4_text = function(){
	var instructions = ["<div align=justify>You now know how to fly to the planets and how the space treasure works, so you are ready to practice them together.<br><br>On space station trials, you will pick between two space stations, and then between two spaceships to fly to a planet. On spaceship trials, you get a choice between three spaceships to fly to a planet. You can tell what kind of trial it will by the number of containers presented at the start.<br><br>On the planet, you will then ask the alien mine for you.<br><br>Your goal will be to get as much treasure as possible.</div>",
	"<div align=justify>Here are a few hints before you start: <br><br>Hint #1:<br>Remember which aliens have treasure. How good a mine is changes slowly, so an alien that has a lot of treasure to share now will be very likely to share with you in the near future.<br><br>Hint #2:<br>Remember, each alien has its own mine. Just because one alien has a bad mine, does not mean another has a good mine. Also, there are no funny patterns in how likely it is that an alien shares treasure with you, like every other time you ask, or depending on which spaceship or space station you took. The aliens are not tricking you.<br><br>Hint #3:<br>The spaceships and space stations you choose are important because often an alien on one planet is better than the aliens on the other planets. You can find more treasure by finding the spaceships and space stations that take you to the right planet.</div>",
	"<div align=justify>In the real experiment, we are only going to give you 2 seconds for each response (2 seconds for the spaceships and space stations, and 2 seconds for the alien). At the beginning that won't seem like very much time and you may find the task difficult. Over time, as you learn to play, you will find that 2 seconds is enough time to make good decisions.<br><br>Our advice is to think carefully about your strategy, but also to trust your instincts. By concentrating you can increase the number of points you win by a lot. There is an element of chance, but a lot of room for skill as well.<br><br>Now, you will do 25 practice trials. These don't count, and have no time limit in order to help you learn.</div>"];
	return instructions
};

var instructions_5_text = function(){
	var instructions_2 = ["<div align=justify>OK, you've finished all practice phases. In the real game, you will find new aliens with new mines on the three planets, but everything else will be the same.<br><br>Let's review everything we've learned and then begin playing.<br><br>Remember, you want to find as much space treasure as you can by flying to planets and asking an alien to mine for you. The chance that an alien can share space treasure with you changes slowly over time, so you need to concentrate and be flexible to keep track of which aliens, spaceships, and space stations are good right now.</div>",
	"<div align=justify>The spaceships and space stations will always be on screen for 2 seconds, even after you already made a decision. Because of this, you will not be able to finish the experiment faster by making your decisions more quickly. Every MTurk worker will complete the HIT in exactly the same time, so use the time you have for each decision to your advantage!<br><br>You will get a bonus payment of 9 dollar cents for every 10 points you earn. <br><br>The game lasts for 200 trials and you will have 2 seconds for each choice, and that takes a little more than 30 minutes.<br><br>You will be given the opportunity for a break in the middle of the HIT.<br><br>The HIT will start after you press 'next', make sure you have your fingers on the 'F', 'G', and 'H' keys! Good luck!</div>"];
	return instructions_2
}

//Then, you will do 200 real trials for money and with restricted time. At the end we have a few final questions. All together, this takes most people about 30 minutes.

function createMemberInNormalDistribution(mean,std_dev){
	return mean + (gaussRandom()*std_dev);
}
/*
* Returns random number in normal distribution centering on 0.
* ~95% of numbers returned should fall between -2 and 2
*/
function gaussRandom() {
	var u = 2*Math.random()-1;
	var v = 2*Math.random()-1;
	var r = u*u + v*v;
	/*if outside interval [0,1] start over*/
	if(r == 0 || r > 1) return gaussRandom();

	var c = Math.sqrt(-2*Math.log(r)/r);
	return u*c;

	/* todo: optimize this algorithm by caching (v*c) 
	* and returning next time gaussRandom() is called.
	* left out for simplicity */
}

function shuffle(o){
	for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
	return o;
}

var images = [
'img/yellow_stim.png',
'img/yellow_stim_deact.png',
'img/yellow_planet.png',
'img/yellow_planet_small.png',
'img/treasure.png',
'img/space_station_stim_3.png',
'img/space_station_stim_3_deact.png',
'img/space_station_stim_2.png',
'img/space_station_stim_2_deact.png',
'img/space_station_stim_1.png',
'img/space_station_stim_1_deact.png',
'img/space_station_planet.png',
'img/red_stim.png',
'img/red_stim_deact.png',
'img/red_planet.png',
'img/red_planet_small.png',
'img/purple_stim.png',
'img/purple_stim_deact.png',
'img/purple_planet.png',
'img/purple_planet_small.png',
'img/probe_yellow_planet.png',
'img/probe_red_planet.png',
'img/probe_purple_planet.png',
'img/p_yellow_stim.png',
'img/p_yellow_stim_deact.png',
'img/p_yellow_planet.png',
'img/p_red_stim.png',
'img/p_red_stim_deact.png',
'img/p_red_planet.png',
'img/p_purple_stim.png',
'img/p_purple_stim_deact.png',
'img/p_purple_planet.png',
'img/noreward.png',
'img/example_values.png',
'img/example_stations.png',
'img/example_probes_planet.png',
'img/example_planets.png',
'img/example_aliens.png',
'img/earth_stim_6.png',
'img/earth_stim_6_deact.png',
'img/earth_stim_5.png',
'img/earth_stim_5_deact.png',
'img/earth_stim_4.png',
'img/earth_stim_4_deact.png',
'img/earth_stim_3.png',
'img/earth_stim_3_deact.png',
'img/earth_stim_2.png',
'img/earth_stim_2_deact.png',
'img/earth_stim_1.png',
'img/earth_stim_1_deact.png',
'img/earth_planet.png',
'img/diamond.png',
'img/cross.png',
'img/checkmark.png',
];

function save_data(data,table_name){
	
for (i = 0; i < data.length; i++) {
	delete data[i].internal_chunk_id;
	delete data[i].trial_index_global;
	delete data[i].trial_type;
	/*if (table_name == "space_mult_subinfo") {
		delete data[i].key_press;
		delete data[i].rt;
		delete data[i].trial_index;
		}*/
	}
		
	$.ajax({
		type:'post',
		cache: false,
		url: 'savedata.php', // change this to point to your php file.
		// opt_data is to add additional values to every row, like a subject ID
		// replace 'key' with the column name, and 'value' with the value.
		data: {
			table: table_name,
			json: JSON.stringify(data),
		},
		success: function(){
			console.log("hieperdepiep");
		}// write the result to javascript console
		//success: function(output) { console.log(output); } // write the result to javascript console
	});
}

function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}