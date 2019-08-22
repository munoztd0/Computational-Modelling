function data = wrapper

load ../results

rng shuffle

nrtrials = 200;
nrits = 10000;
data.bounds = [0.25 0.75];
data.sd = 0.025;

ws = 0:1/10:1;

for i = 1:nrits
    
    disp(['Iteration ', num2str(i), '/', num2str(nrits),'.'])
    
    probs = generate_ps(nrtrials,data.bounds,data.sd);
    
    rewardrate = zeros(1,length(ws));
    
    x = median(results.x(:,1:3));
    
    for w_i = 1:length(ws)
        
        x(4) = ws(w_i);
        
        output = MBMF_low_effort_arm_sim(x,probs);                 % simulate behavior
        rewardrate(w_i) = sum(output.R)/length(output.R);   % store reward rate for each value of w
        
    end
    
    params = polyfit(zscore(ws),zscore(rewardrate),1);      % compute slope
    data.slope(i) = params(1);
    data.rewardrate(:,i) = rewardrate;
    
end

end