/**
* jspsych-2step-complexity-stim
* Wouter Kool
*
* plugin for displaying a space and aliens version of the model-based/model-free 2-step task as reported in Doll et al. (2015)
*
**/

(function($) {
	jsPsych["2step-complexity-stim"] = (function() {

		var plugin = {};
		
		var score = 0;
		
		var displayColor = '#0738db';
		var borderColor = '#197bff';
		var textColor = '#b8fff6';
		
		plugin.create = function(params) {

			params = jsPsych.pluginAPI.enforceArray(params, ['stimuli', 'choices']);
			
			var trials = new Array(params.nrtrials);
			
			for (var i = 0; i < trials.length; i++) {
				
				trials[i] = {};
				trials[i].practice = params.practice || 0;
				trials[i].rews = params.rews;
				trials[i].subid = params.subid;
				
				trials[i].index = i;
				trials[i].trialsperblock = params.trialsperblock;
				trials[i].nrblocks = params.nrblocks;
				trials[i].rocket_order = params.rocket_order;
				trials[i].transitions0 = params.transitions0;
				trials[i].transitions1 = params.transitions1;
				
				// timing parameters
				trials[i].effortcue_time = params.effortcue_time || 1000;
				trials[i].feedback_time = params.feedback_time || 500;
				trials[i].ITI = params.ITI || 500;
				trials[i].timeout_time = params.timeout_time || 1500;
				trials[i].timing_response = params.timing_response || 2000; // if -1, then wait for response forever
				trials[i].score_time = params.score_time || 1500;
				trials[i].totalscore_time = params.totalscore_time || 1000;
				trials[i].points_loop_time = params.points_loop_time || 200;
				trials[i].postbreak_time = params.postbreak_time || 1000;
				
			}
			return trials;
			
		};
		
		plugin.trial = function(display_element, trial) {
			
			// if any trial variables are functions
			// this evaluates the function and replaces
			// it with the output of the function
			
			trial = jsPsych.pluginAPI.evaluateFunctionParameters(trial);
								
			progress = jsPsych.progress();
			if (progress.current_trial_local == 0) {
				score = 0;
			}
			
			var rocket_order = trial.rocket_order;
			
			var response = new Array(3)
			var choice = new Array();
			var state = new Array();
			for (var i = 0; i < 3; i++) {	
				response[i] = {rt: -1, key: -1};
				choice[i] = -1;
				state[i] = -1;
			}
			
			var stims = new Array(2);
			stims[0] = [-1,-1];
			stims[1] = [-1,-1,-1];
			
			var transitions = new Array();
			transitions[0] = trial.transitions0;
			transitions[1] = trial.transitions1;
			
			var current_state = -1;
			
			var high_effort = Math.round(Math.random());
			
			if (high_effort==1) {
				
				var part = -1;
				
				var stimsperstate0 = [[1,2],[1,3],[2,3]];
				state[0] = Math.ceil(Math.random()*3);
				stims[0] = shuffle(stimsperstate0[state[0]-1]);
				
				var stimsperstate1 = [[rocket_order[0],rocket_order[4]],[rocket_order[1],rocket_order[5]],[rocket_order[2],rocket_order[3]]];

				
				current_state = state[0];
				state[1] = -1;
				
				var all_choices = [["F","H"],["F","H"],["space"]];
				
				
				
			} else {
				
				var part = 0;
				
				var stimsperstate1 = [rocket_order[0],rocket_order[1],rocket_order[2]];
				stimsperstate1 = [stimsperstate1, [rocket_order[3],rocket_order[4],rocket_order[5]]];
				state[1] = Math.ceil(Math.random()*2);
				stims[1] = shuffle(stimsperstate1[state[1]-1]);
				
				//transitions[1] = trial.transitions1_low;
				
				current_state = state[1];
				state[0] = -1;
				
				var all_choices = [[],["F","G","H"],["space"]];
				
			}
			
			var points = 0;
			
			var pause = 0;
			
			if (trial.practice == 0) {
				var state_names = ["space_station","earth","purple","red","yellow"];
				var state_colors = [
					[100, 100, 100],
					[5, 157, 190],
					[115, 34, 130],
					[211, 0, 0],
					[240, 187, 57],
				];
			} else {
				var state_names = ["space_station","earth","p_purple","p_red","p_yellow"];
				var state_colors = [
					[100, 100, 100],
					[5, 157, 190],
					[115, 34, 130],
					[211, 0, 0],
					[240, 187, 57],
				];
			}
			
			// store responses
			var setTimeoutHandlers = [];
			
			var keyboardListener = new Object;	

			//var state = 0;
			
			var choices = new Array;
			
			var points_loop_counter = 0;
			
			var points_loop = function() {
				if (points_loop_counter < Math.abs(points)) {
					points_loop_counter = points_loop_counter + 1;
					display_stimuli(3);
					setTimeout(function () {
						points_loop();
					}, trial.points_loop_time);
				} else {
					score = score + points;
					end_trial();
				}
			}
			
			
			// function to end trial when it is time
			var end_trial = function(){
				
				kill_listeners();
				kill_timers();
								
				// gather the data to store for the trial
				
				var trial_data = {
					"subid": trial.subid,
					"high_effort": high_effort,
					"state0": state[0],
					"stim_0_1": stims[0][0],
					"stim_0_2": stims[0][1],
					"rt0": response[0].rt,
					"choice0": choice[0],
					"response0": response[0].key,
					"state1": state[1],
					"stim_1_1": stims[1][0],
					"stim_1_2": stims[1][1],
					"stim_1_3": stims[1][2],
					"rt1": response[1].rt,
					"choice1": choice[1],
					"response1": response[1].key,
					"rt2": response[2].rt,
					"points": points,
					"state2": state[2],
					"score": score,
					"practice": trial.practice,
					"rews1": trial.rews[0],
					"rews2": trial.rews[1],
					"rews3": trial.rews[2],
				};
				
				//console.log(trial_data)
				
				jsPsych.data.write(trial_data);
				
				var handle_totalscore = setTimeout(function() {
					// clear the display
					display_element.html('');
					$('.jspsych-display-element').css('background-image', '');
				
					// move on to the next trial
					var handle_ITI = setTimeout(function() {
						jsPsych.finishTrial();
					}, trial.ITI);
					setTimeoutHandlers.push(handle_ITI);
				}, trial.totalscore_time);
				setTimeoutHandlers.push(handle_totalscore);
				
			};
			
			// function to handle responses by the subject
			var after_response = function(info){
				
				kill_listeners();
				kill_timers();
				
				if (pause == 0) {
							
					// only record the first response
					if (response[part].key == -1){
						response[part] = info;
					}
								
					display_stimuli(2); //feedback
				
					if (trial.timing_response>0) {
						var extra_time = trial.timing_response-response[part].rt;
					} else {
						var extra_time = 0;
					}
					
					
					if (part < 2) { // space stations or rockets
						
						// record response
						if (high_effort == 1){
							if (String.fromCharCode(response[part].key)==choices[0]) { // left response
								choice[part] = stims[part][0];
							} else { // right response
								choice[part] = stims[part][1];								
							}
						} else {
							if (String.fromCharCode(response[part].key)==choices[0]) { // left response
								choice[part] = stims[part][0];
							} else { // right response
								if (String.fromCharCode(response[part].key)==choices[1]) { // middle response
									choice[part] = stims[part][1];
								} else { // right response
									choice[part] = stims[part][2];
								}
							}
						}
						
						//next state
						state[part+1] = transitions[part][choice[part]-1];
						current_state = state[part+1];
						
						if (part == 0){
							newstims = shuffle(stimsperstate1[state[1]-1]);
							stims[1][0] = newstims[0];
							stims[1][1] = newstims[1];
						}
						
						var handle_feedback = setTimeout(function() {
							display_element.html('');
							next_part();
						}, trial.feedback_time+extra_time);
						setTimeoutHandlers.push(handle_feedback);
					
					} else { // aliens
												
						points = trial.rews[current_state-1];
					
						display_stimuli(2);
						var handle_feedback = setTimeout(function() {
							display_stimuli(3);
							var handle_score = setTimeout(function() {
								points_loop();
							}, trial.score_time);
							setTimeoutHandlers.push(handle_score);
						}, trial.feedback_time+extra_time);
						setTimeoutHandlers.push(handle_feedback);
					}			
						
				} else {
					
					pause = 0;
					
					display_element.html('');
					
					var handle_postbreak = setTimeout(function(){
						display_stimuli(0);
						var handle_effortcue = setTimeout(function() {
							next_part();
						}, trial.effortcue_time);
						setTimeoutHandlers.push(handle_effortcue);
					}, trial.postbreak_time);
					setTimeoutHandlers.push(handle_postbreak);
					
				}
								
			};
			
			var display_stimuli = function(stage){
				
				kill_timers();
				kill_listeners();
				
				// this can be optimized
				if (part == 2) {
					state_name = state_names[current_state+1];
					state_color = state_colors[current_state+1];
				} else {
					state_name = state_names[part];
					state_color = state_colors[part];
				}
				
				if (stage == 0) {
					if (high_effort == 1){
						state_name = state_names[0];
						state_color = state_colors[0];	
					} else {
						state_name = state_names[1];
						state_color = state_colors[1];
					}
				}
								
				if (stage==-1) { // timeout	at first levels
					if (part == 2) {// aliens
						$('#jspsych-2step-complexity-bottom-stim-middle').html('<br><br>X');
						$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim_deact.png)');
					} else {
						if (high_effort==1) { // two stimuli
							$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'_deact.png)');
							$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'_deact.png)');
							if (part == 0) {
								$('#jspsych-2step-complexity-bottom-stim-left').html('<br><br><br>X');
								$('#jspsych-2step-complexity-bottom-stim-right').html('<br><br><br>X');								
							} else {
								$('#jspsych-2step-complexity-bottom-stim-left').html('<br><br>X');
								$('#jspsych-2step-complexity-bottom-stim-right').html('<br><br>X');
							}
						} else { // three stimuli
							$('#jspsych-2step-complexity-bottom-stim-left').html('<br><br>X');
							$('#jspsych-2step-complexity-bottom-stim-middle').html('<br><br>X');
							$('#jspsych-2step-complexity-bottom-stim-right').html('<br><br>X');
							$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'_deact.png)');
							$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'_deact.png)');
							$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][2]+'_deact.png)');
						}
					}
					if (trial.practice == 0) {
						$('#jspsych-2step-complexity-top-stim-right').html($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">score: '+score+'</div>'))
					}
				}
				
				if (stage==0) { // effort cue
					display_element.html('');

					$('.jspsych-display-element').css('background-image', 'url("img/'+state_name+'_planet.png")');				
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-top-stim-left',
					}));
					
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-top-stim-middle',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-top-stim-right',
					}));
					if (trial.practice == 0) {
						$('#jspsych-2step-complexity-top-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">score: '+score+'</div>'))
					}
					display_element.append($('<div>', {
						style: 'clear:both',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-left',
					}));
					if (high_effort == 0) {
						display_element.append($('<div>', {
							id: 'jspsych-2step-complexity-bottom-stim-filler',
						}));
					}
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-middle',
					}));
					if (high_effort == 0) {
						display_element.append($('<div>', {
							id: 'jspsych-2step-complexity-bottom-stim-filler',
						}));
					}
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-right',
					}));
					
					
					if (high_effort==1) { //two stimuli
						$('#jspsych-2step-complexity-top-stim-left').css('height', '100px');
						$('#jspsych-2step-complexity-top-stim-middle').css('height', '100px');
						$('#jspsych-2step-complexity-top-stim-right').css('height', '100px');
						$('#jspsych-2step-complexity-bottom-stim-left').css('width', '200px');
						$('#jspsych-2step-complexity-bottom-stim-right').css('width', '200px');
						$('#jspsych-2step-complexity-bottom-stim-left').css('height', '200px');
						$('#jspsych-2step-complexity-bottom-stim-right').css('height', '200px');
						$('#jspsych-2step-complexity-bottom-stim-middle').css('width', '50px');
					} else {
						$('#jspsych-2step-complexity-bottom-stim-middle').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
						$('#jspsych-2step-complexity-bottom-stim-middle').css('border-width', '1px');
					}
					$('#jspsych-2step-complexity-bottom-stim-left').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
					$('#jspsych-2step-complexity-bottom-stim-right').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
					$('#jspsych-2step-complexity-bottom-stim-left').css('border-width', '1px');
					$('#jspsych-2step-complexity-bottom-stim-right').css('border-width', '1px');
				}
				
				if (stage==1) { // choice stages cue
					display_element.html('');

					$('.jspsych-display-element').css('background-image', 'url("img/'+state_name+'_planet.png")');				
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-top-stim-left',
					}));
					
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-top-stim-middle',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-top-stim-right',
					}));
					if (trial.practice == 0) {
						$('#jspsych-2step-complexity-top-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">score: '+score+'</div>'))
					}
					display_element.append($('<div>', {
						style: 'clear:both',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-left',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-middle',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-right',
					}));
					
					if (part == 2){ // aliens
						$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim.png)');
						$('#jspsych-2step-complexity-bottom-stim-middle').css('width', '170px');
					} else {
						if (high_effort==1) { //two stimuli
							if (part == 0) {
								$('#jspsych-2step-complexity-top-stim-left').css('height', '100px');
								$('#jspsych-2step-complexity-top-stim-middle').css('height', '100px');
								$('#jspsych-2step-complexity-top-stim-right').css('height', '100px');
								$('#jspsych-2step-complexity-bottom-stim-left').css('width', '200px');
								$('#jspsych-2step-complexity-bottom-stim-right').css('width', '200px');
								$('#jspsych-2step-complexity-bottom-stim-left').css('height', '200px');
								$('#jspsych-2step-complexity-bottom-stim-right').css('height', '200px');
							}
							$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'.png)');
							$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'.png)');
							$('#jspsych-2step-complexity-bottom-stim-middle').css('width', '50px');
						} else { // three stimuli
							$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'.png)');
							$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'.png)');
							$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][2]+'.png)');
						}
					}
				}
				
				if (stage==2) { // feedback
					if (part == 2) { // aliens
						$('#jspsych-2step-complexity-bottom-stim-middle').addClass('jspsych-2step-complexity-bottom-stim-border');
						$('#jspsych-2step-complexity-bottom-stim-middle').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
					} else {
						if (high_effort == 1){ // two stimuli
							if (String.fromCharCode(response[part].key)==choices[0]) { // left response
								$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'_deact.png)');
								$('#jspsych-2step-complexity-bottom-stim-left').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
								if (part == 0) {
									$('#jspsych-2step-complexity-bottom-stim-left').addClass('jspsych-2step-complexity-bottom-stim-border-big');
								} else {
									$('#jspsych-2step-complexity-bottom-stim-left').addClass('jspsych-2step-complexity-bottom-stim-border');
								}
							} else { // right response
								$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'_deact.png)');
								$('#jspsych-2step-complexity-bottom-stim-right').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
								if (part == 0) {
									$('#jspsych-2step-complexity-bottom-stim-right').addClass('jspsych-2step-complexity-bottom-stim-border-big');
								} else {
									$('#jspsych-2step-complexity-bottom-stim-right').addClass('jspsych-2step-complexity-bottom-stim-border');
								}
							}
							
						} else { // three stimuli
							if (String.fromCharCode(response[part].key)==choices[0]) { // left response
								$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'_deact.png)');
								$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][2]+'_deact.png)');
								$('#jspsych-2step-complexity-bottom-stim-left').addClass('jspsych-2step-complexity-bottom-stim-border');
								$('#jspsych-2step-complexity-bottom-stim-left').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
							} else {
								if (String.fromCharCode(response[part].key)==choices[1]) { // middle response
									$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'_deact.png)');
									$('#jspsych-2step-complexity-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][2]+'_deact.png)');
									$('#jspsych-2step-complexity-bottom-stim-middle').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
									$('#jspsych-2step-complexity-bottom-stim-middle').addClass('jspsych-2step-complexity-bottom-stim-border');
								} else {
									$('#jspsych-2step-complexity-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][0]+'_deact.png)');
									$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim_'+stims[part][1]+'_deact.png)');
									$('#jspsych-2step-complexity-bottom-stim-right').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
									$('#jspsych-2step-complexity-bottom-stim-right').addClass('jspsych-2step-complexity-bottom-stim-border');
								}
							}
						}
					}
				}
				
				if (stage==3) { // reward
					
					if (points==0) {
						$('#jspsych-2step-complexity-top-stim-middle').css('background-image', 'url(img/noreward.png)');
					} else {
						if (points>0) {
							$('#jspsych-2step-complexity-bottom-stim-middle').css('background-image', 'url(img/'+state_name+'_stim.png)');
							$('#jspsych-2step-complexity-top-stim-middle').css('background-image', 'url(img/treasure_'+(points-points_loop_counter)+'.png)');
							extra_text = '+';
						}
						if (points_loop_counter==0) {
							text = '';
						} else {
							text = extra_text+(points_loop_counter);
						}
						$('#jspsych-2step-complexity-top-stim-middle').html('<br><br>'+text);
						if (trial.practice == 0) {
							$('#sub-div-2').html('score: '+(score+points_loop_counter));
						}
					}					
				}
				
			};
			
			var start_response_listener = function(){
				
				if (pause == 0) {
					choices = all_choices[part];
				} else {
					choices = ["space"];
				}
								
				if(JSON.stringify(choices) != JSON.stringify(["none"])) {
					var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
						callback_function: after_response,
						valid_responses: choices,
						rt_method: 'date',
						persist: false,
						allow_held_key: false,
					});
				}
				
			}
			
			var kill_timers = function(){
				for (var i = 0; i < setTimeoutHandlers.length; i++) {
					clearTimeout(setTimeoutHandlers[i]);
				}
			}
			
			var kill_listeners = function(){
				// kill keyboard listeners
				if(typeof keyboardListener !== 'undefined'){
					jsPsych.pluginAPI.cancelAllKeyboardResponses();
				}
			}
			
			var next_part = function(){
								
				part = part + 1;
								
				kill_timers();
				kill_listeners();

				display_stimuli(1);
				start_response_listener();
								
				if (trial.timing_response>0) {	
					var handle_response = setTimeout(function() {
						kill_listeners();
						display_stimuli(-1);
						var handle_timeout = setTimeout(function() {
							end_trial();
						}, trial.timeout_time);
						setTimeoutHandlers.push(handle_timeout);
					}, trial.timing_response);
					setTimeoutHandlers.push(handle_response);
				}
				
			}
			
			if ((trial.practice==1)||(trial.index==0)||(trial.index%trial.trialsperblock != 0)){
				display_stimuli(0);
				var handle_effortcue = setTimeout(function() {
					next_part();
				}, trial.effortcue_time);
				setTimeoutHandlers.push(handle_effortcue);
			} else {
				pause = 1;
				display_element.html('');
				display_element.append($('<div>', {
					html: 'You completed block '+((trial.index)/trial.trialsperblock)+'/'+trial.nrblocks+'. You can take a break now.<br><br>Press space to continue.',
				}));
				start_response_listener();
			}
			
		};
		
		return plugin;
		
	})();
})(jQuery);
