function data = wrapper

load ../results
addpath /home/cisa/mountpoint/mfit-master/
rng shuffle

nrtrials = 200;
nrits = 10000;
data.bounds = [0 9];
data.sd = 2;

ws = 0:1/10:1;

for i = 1:nrits
    
    disp(['Iteration ', num2str(i), '/', num2str(nrits),'.'])
    
    rews = generate_rews(nrtrials,data.bounds,data.sd);
    rews = rews./9;
    
    rewardrate = zeros(1,length(ws));
    
    x = median(results.x(:,1:3));

    for w_i = 1:length(ws)
        
        x(4) = ws(w_i);
        
        output = MBMF_high_effort_arm_sim(x,rews);          % simulate behavior
        rewardrate(w_i) = sum(output.R)/length(output.R);   % store reward rate for each value of w
        
    end
    
    params = polyfit(zscore(ws),zscore(rewardrate),1);      % compute slope
    data.slope(i) = params(1);
    data.rewardrate(:,i) = rewardrate;
    
end

end