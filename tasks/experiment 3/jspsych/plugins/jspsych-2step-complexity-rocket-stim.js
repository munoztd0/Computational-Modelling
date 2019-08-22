/**
* jspsych-2step-complexity-stim
* Wouter Kool
*
* plugin for displaying a space and aliens version of the model-based/model-free 2-step task as reported in Doll et al. (2015)
*
**/

(function($) {
	jsPsych["2step-complexity-rocket-stim"] = (function() {

		var plugin = {};
		
		//var planet_score = 0;
		
		var displayColor = '#0738db';
		var borderColor = '#197bff';
		var textColor = '#b8fff6';
		
		plugin.create = function(params) {

			params = jsPsych.pluginAPI.enforceArray(params, ['stimuli', 'choices']);
			
			var trials = new Array(params.nrtrials);
			
			for (var i = 0; i < trials.length; i++) {
				
				trials[i] = {};
				trials[i].rocket_order = params.rocket_order;
				trials[i].transitions0 = params.transitions0;
				trials[i].transitions1 = params.transitions1;
				trials[i].high_effort = params.high_effort;
				trials[i].rocket_learning_criterion = params.rocket_learning_criterion;
				trials[i].planet_score = params.planet_score;
				
				// timing parameters
				trials[i].effortcue_time = params.effortcue_time || 1000;
				trials[i].probecue_time = params.probecue_time || 1000;
				trials[i].feedback_time = params.feedback_time || 500;
				trials[i].planet_time = params.planet_time || 2000;
				trials[i].ITI = params.ITI || 500;
				
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
				//planet_score = 0;
			}
			
			var target = Math.ceil(Math.random()*3);
			
			var rocket_order = trial.rocket_order;
			
			var planet_score = trial.planet_score;
			var accuracy = 0;
			var response = new Array(2)
			var choice = new Array();
			var state = new Array();
			for (var i = 0; i < 2; i++) {	
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
			
			if (trial.high_effort==1) {
				
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
			
			var state_names = ["space_station","earth","purple","red","yellow"];
			var state_colors = [
				[100, 100, 100],
				[5, 157, 190],
				[115, 34, 130],
				[211, 0, 0],
				[240, 187, 57],
			];
			
			// store responses
			var setTimeoutHandlers = [];
			
			var keyboardListener = new Object;	

			//var state = 0;
			
			var choices = new Array;
			
			// function to end trial when it is time
			var end_trial = function(){
				
				kill_listeners();
				kill_timers();
								
				// gather the data to store for the trial
				
				var trial_data = {
					"state2": state[2],
					"target": target,
					"accuracy": accuracy,
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
							
				// only record the first response
				if (response[part].key == -1){
					response[part] = info;
				}
								
				display_stimuli(2); //feedback
														
				// record response
				if (trial.high_effort == 1){
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
					
					display_stimuli(2);
					var handle_feedback = setTimeout(function() {
						display_element.html('');
						next_part();
					}, trial.feedback_time);
					setTimeoutHandlers.push(handle_feedback);
					
				} else {
					
					if (part == 1) {
						if (state[2]==target) {
							accuracy = 1;
							planet_score = planet_score + 1;
						} else {
							accuracy = 0;
							planet_score = 0;
						}
					}	
					
					display_stimuli(2);
					
					part = part + 1;
					
					var handle_feedback = setTimeout(function() {
						display_stimuli(3);
						var handle_planet = setTimeout(function() {
							end_trial();
						}, trial.planet_time);
						setTimeoutHandlers.push(handle_planet);		
					}, trial.feedback_time);
					setTimeoutHandlers.push(handle_feedback);
					
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
				
				target_name = state_names[target+1];
				
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
					$('#jspsych-2step-complexity-probe-stim-middle').css('background-image', 'url(img/probe_'+target_name+'_planet.png)');
					$('#jspsych-2step-complexity-probe-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">correct: '+planet_score+'/'+trial.rocket_learning_criterion+'</div>'))
				}
				
				if (stage == 0) {
					if (trial.high_effort == 1){
						state_name = state_names[0];
						state_color = state_colors[0];	
					} else {
						state_name = state_names[1];
						state_color = state_colors[1];
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
					
					$('#jspsych-2step-complexity-top-stim-left').append($('<div id="sub-div" style="padding-left:20px; text-align:left;">'))
					$('#sub-div').append($('<div id="jspsych-2step-complexity-mini-multiplier">'))
					$('#jspsych-2step-complexity-mini-multiplier').append($('<span></span>'))
					$('#jspsych-2step-complexity-mini-multiplier').css('background-image', 'url(img/'+target_name+'_planet_small.png)');
					
					$('#jspsych-2step-complexity-top-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">correct: '+planet_score+'/'+trial.rocket_learning_criterion+'</div>'))
					display_element.append($('<div>', {
						style: 'clear:both',
					}));
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-left',
					}));
					if (trial.high_effort == 0) {
						display_element.append($('<div>', {
							id: 'jspsych-2step-complexity-bottom-stim-filler',
						}));
					}
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-middle',
					}));
					if (trial.high_effort == 0) {
						display_element.append($('<div>', {
							id: 'jspsych-2step-complexity-bottom-stim-filler',
						}));
					}
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-bottom-stim-right',
					}));
					
					
					if (trial.high_effort==1) { //two stimuli
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
					
					$('#jspsych-2step-complexity-top-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">correct: '+planet_score+'/'+trial.rocket_learning_criterion+'</div>'))
					if (part<2) {
						$('#jspsych-2step-complexity-top-stim-left').append($('<div id="sub-div" style="padding-left:20px; text-align:left;">'))
						$('#sub-div').append($('<div id="jspsych-2step-complexity-mini-multiplier">'))
						$('#jspsych-2step-complexity-mini-multiplier').append($('<span></span>'))
						$('#jspsych-2step-complexity-mini-multiplier').css('background-image', 'url(img/'+target_name+'_planet_small.png)');
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
					
					if (part < 2) {
						if (trial.high_effort==1) { //two stimuli
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
					if (trial.high_effort == 1){ // two stimuli
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
				
				if (stage==3) {
					display_element.html('');
					$('.jspsych-display-element').css('background-image', 'url("img/'+state_name+'_planet.png")');
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-probe-stim-left',
					}));
				
					$('#jspsych-2step-complexity-probe-stim-left').append($('<div id="sub-div" style="padding-left:20px; text-align:left;">'))
					$('#sub-div').append($('<div id="jspsych-2step-complexity-mini-multiplier">'))
					$('#jspsych-2step-complexity-mini-multiplier').append($('<span></span>'))
					$('#jspsych-2step-complexity-mini-multiplier').css('background-image', 'url(img/'+target_name+'_planet_small.png)');
				
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-probe-stim-middle',
					}));
					if (accuracy == 1) {
						$('#jspsych-2step-complexity-probe-stim-middle').css('background-image', 'url("img/checkmark.png")');
					} else {
						$('#jspsych-2step-complexity-probe-stim-middle').css('background-image', 'url("img/cross.png")');
					}
					
					
					display_element.append($('<div>', {
						id: 'jspsych-2step-complexity-probe-stim-right',
					}));
					$('#jspsych-2step-complexity-probe-stim-right').append($('<div id="sub-div-2" style="padding-right:20px; text-align:right;">correct: '+planet_score+'/'+trial.rocket_learning_criterion+'</div>'))
					
				}
				
			};
			
			var start_response_listener = function(){
				
				choices = all_choices[part];
								
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
				
			}
			
			display_stimuli(-0.5);
			var handle_probecue = setTimeout(function() {
				display_stimuli(0);
				var handle_effortcue = setTimeout(function() {
					next_part();
				}, trial.effortcue_time);
				setTimeoutHandlers.push(handle_effortcue);
			}, trial.probecue_time);
			setTimeoutHandlers.push(handle_probecue);
			//}
			
		};
		
		return plugin;
		
	})();
})(jQuery);
