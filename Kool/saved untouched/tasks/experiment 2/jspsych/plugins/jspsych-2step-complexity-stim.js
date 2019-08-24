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
		
		var correct_probes = 0
		
		var probe_indices = [0,1,2,3,4,5,6,7,8,9,10,11];
		var probe_efforts = [1,1,1,1,1,1,0,0,0,0,0,0];
		var probe_targets = [1,2,3,1,2,3,1,2,3,1,2,3];
		
		var probe_starting_states = [-1,-1,-1,-1,-1,-1,1,1,1,2,2,2];
		var probe_repetitions = [1,1,1,2,2,2,1,1,1,2,2,2];
		
		plugin.create = function(params) {

			params = jsPsych.pluginAPI.enforceArray(params, ['stimuli', 'choices']);
			
			var trials = new Array(params.nrtrials);
			
			for (var i = 0; i < trials.length; i++) {
				
				trials[i] = {};
				trials[i].subid = params.subid;
				
				trials[i].practice = params.practice || 0;
				trials[i].rews = params.rews;
				
				trials[i].index = i;
				trials[i].trialsperblock = params.trialsperblock;
				trials[i].nrblocks = params.nrblocks;
				trials[i].rocket_order = params.rocket_order;
				trials[i].transitions0 = params.transitions0;
				trials[i].transitions1 = params.transitions1;
				
				if ((params.practice == 1) || (params.probe_trials.indexOf(i+1)==-1)) {
					trials[i].probe_trial = 0;
				} else {
					trials[i].probe_trial = 1;
					trials[i].probe_reward = params.probe_reward;
				}
				
				trials[i].double_transitions = double_transitions;
				
				// timing parameters
				trials[i].effortcue_time = params.effortcue_time || 1000;
				trials[i].probecue_time = params.probecue_time || 3000;
				trials[i].feedback_time = params.feedback_time || 1000;
				trials[i].ITI = params.ITI || 500;
				trials[i].timeout_time = params.timeout_time || 1500;
				trials[i].timing_response = params.timing_response || 10000; // if -1, then wait for response forever
				trials[i].score_time = params.score_time || 1000;
				trials[i].totalscore_time = params.totalscore_time || 1000;//2000;
				trials[i].points_loop_time = params.points_loop_time || 200;
				trials[i].diamond_time = params.diamond_time || 3000;
				trials[i].postbreak_time = params.postbreak_time || 1000;
				
			}
			return trials;
			
		};
		
		plugin.trial = function(display_element, trial) {
			
			// if any trial variables are functions
			// this evaluates the function and replaces
			// it with the output of the function
			
			trial = jsPsych.pluginAPI.evaluateFunctionParameters(trial);
			
			if (trial.index == 0){
				probe_indices = shuffle(probe_indices);
				
				for (k = 0; k < 6; k++){ //only the first 6 (high-effort) require special treatment
					var possible_starting_states = [1,2,3];
					var current_target = probe_targets[k];
					var bad_starting_state = double_transitions.indexOf(current_target); // find index of starting state with two transitions to final state
					possible_starting_states.splice(bad_starting_state,1); // throw that one out
					probe_starting_states[k] = possible_starting_states[probe_repetitions[k]-1];
				}
			}
			
			progress = jsPsych.progress();
			if (progress.current_trial_local == 0) {
				score = 0;
			}
			
			var probe_index = -1;
			var probe_effort = -1;
			var probe_target = -1;
			var probe_starting_state = -1;
			
			if (trial.probe_trial==0) {
				
				var actual_rews = trial.rews;
				var high_effort = Math.round(Math.random());
				
			} else {
				
				var actual_rews = [0,0,0];
				
				probe_index = probe_indices[0];
				probe_indices.splice(0,1);
				probe_effort = probe_efforts[probe_index];
				probe_target = probe_targets[probe_index];
				probe_starting_state = probe_starting_states[probe_index];
				
				actual_rews[probe_target-1] = trial.probe_reward;
				var high_effort = probe_effort;
				
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
			
			if (high_effort==1) {
				
				var part = -1;
				
				var stimsperstate0 = [[1,2],[1,3],[2,3]];
				// transitions = 
				
				if (trial.probe_trial == 0){
					state[0] = Math.ceil(Math.random()*3);
				} else {
					state[0] = probe_starting_state;
				}
				
				stims[0] = shuffle(stimsperstate0[state[0]-1]);
				
				var stimsperstate1 = [[rocket_order[0],rocket_order[4]],[rocket_order[1],rocket_order[5]],[rocket_order[2],rocket_order[3]]];
				
				current_state = state[0];
				state[1] = -1;
				
				var all_choices = [["F","H"],["F","H"],["space"]];
				
			} else {
				
				var part = 0;
				
				var stimsperstate1 = [rocket_order[0],rocket_order[1],rocket_order[2]];
				stimsperstate1 = [stimsperstate1, [rocket_order[3],rocket_order[4],rocket_order[5]]];
				
				if (trial.probe_trial == 0){
					state[1] = Math.ceil(Math.random()*2);
				} else {
					state[1] = probe_starting_state;
				}
				
				stims[1] = shuffle(stimsperstate1[state[1]-1]);
				
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
					"probe_trial": trial.probe_trial,
					"probe_index": probe_index,
					"probe_effort": probe_effort,
					"probe_target": probe_target,
					"probe_starting_state": probe_starting_state,
					"practice": trial.practice,
					"rews1": trial.rews[0],
					"rews2": trial.rews[1],
					"rews3": trial.rews[2],
					"actual_rews1": actual_rews[0],
					"actual_rews2": actual_rews[1],
					"actual_rews3": actual_rews[2],
					"correct_probes": correct_probes,
				};
				
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
						}, trial.feedback_time);
						setTimeoutHandlers.push(handle_feedback);
					
					} else { // aliens
												
						points = actual_rews[current_state-1];
						
						if (points!=trial.probe_reward) { // regular
							var handle_feedback = setTimeout(function() {
								display_stimuli(3);
								var handle_score = setTimeout(function() {
									points_loop();
								}, trial.score_time);
								setTimeoutHandlers.push(handle_score);
							}, trial.feedback_time);
							setTimeoutHandlers.push(handle_feedback);
						} else { // diamond
							display_stimuli(2);
							var handle_feedback = setTimeout(function() {
								display_stimuli(3);
								var handle_diamond = setTimeout(function() {
									if (points==probe_reward) {
										correct_probes = correct_probes + 1;
									}
									score = score + points;
									end_trial();
								}, trial.diamond_time);
								setTimeoutHandlers.push(handle_diamond);
							}, trial.feedback_time);
							setTimeoutHandlers.push(handle_feedback);
						}
					
					}			
						
				} else {
					
					pause = 0;
					
					display_element.html('');
					
					var handle_postbreak = setTimeout(function(){
						if (trial.probe_trial==0) {
							display_stimuli(0);
							var handle_effortcue = setTimeout(function() {
								next_part();
							}, trial.effortcue_time);
							setTimeoutHandlers.push(handle_effortcue);
						} else {
							display_stimuli(-0.5);
							var handle_probecue = setTimeout(function() {
								display_stimuli(0);
								var handle_effortcue = setTimeout(function() {
									next_part();
								}, trial.effortcue_time);
								setTimeoutHandlers.push(handle_effortcue);
							}, trial.probecue_time);
							setTimeoutHandlers.push(handle_probecue);
						}
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
				
				if (stage == -0.5) {
					target_name = state_names[probe_target+1];
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
				
				if (stage==-0.5){//probe cue
					$('.jspsych-display-element').css('background-image', 'url("img/earth_planet.png")');
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-probe-stim-left',
					}));					
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-probe-stim-middle',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-probe-stim-right',
					}));
					$('#jspsych-2step-complexity-probe-stim-middle').css('background-image', 'url(img/probe_'+target_name+'.png)');
					if (trial.practice == 0) {
						$('#jspsych-2step-complexity-probe-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">score: '+score+'</div>'))
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
						if (trial.probe_trial==1) {
							$('#jspsych-2step-complexity-top-stim-left').append($('<div id="sub-div" style="padding-left:20px; text-align:left;">'))
							$('#sub-div').append($('<div id="jspsych-2step-complexity-mini-multiplier">'))
							$('#jspsych-2step-complexity-mini-multiplier').append($('<span></span>'))
							$('#jspsych-2step-complexity-mini-multiplier').css('background-image', 'url(img/'+target_name+'_stim_small.png)');
						}
						//$('#jspsych-2step-complexity-mini-multiplier').append($('<div class="b2" style="background: color url('path')"></div>'))
						
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
						if (trial.probe_trial==1) {
							$('#jspsych-2step-complexity-top-stim-left').append($('<div id="sub-div" style="padding-left:20px; text-align:left;">'))
							$('#sub-div').append($('<div id="jspsych-2step-complexity-mini-multiplier">'))
							$('#jspsych-2step-complexity-mini-multiplier').append($('<span></span>'))
							$('#jspsych-2step-complexity-mini-multiplier').css('background-image', 'url(img/'+target_name+'_stim_small.png)');
						}
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
						if (points!=trial.probe_reward) {
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
						} else { //diamond
							$('#jspsych-2step-complexity-top-stim-middle').css('background-image', 'url(img/diamond.png)');
							$('#jspsych-2step-complexity-top-stim-middle').html('<br><br>+'+points);
							$('#sub-div-2').html('score: '+(score+points));
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

				if (trial.probe_trial==0) {
					display_stimuli(0);
					var handle_effortcue = setTimeout(function() {
						next_part();
					}, trial.effortcue_time);
					setTimeoutHandlers.push(handle_effortcue);
				} else {
					display_stimuli(-0.5);
					var handle_probecue = setTimeout(function() {
						display_stimuli(0);
						var handle_effortcue = setTimeout(function() {
							next_part();
						}, trial.effortcue_time);
						setTimeoutHandlers.push(handle_effortcue);
					}, trial.probecue_time);
					setTimeoutHandlers.push(handle_probecue);
				}
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
