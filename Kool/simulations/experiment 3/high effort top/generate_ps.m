function rewards = generate_ps(nrtrials,bounds,sd)

terminal_states = 3;

bounds = sort(bounds);

rewards = zeros(nrtrials,terminal_states);

rewards(1,:) = rand(1,3)*(bounds(2)-bounds(1))+bounds(1);

for t = 2:nrtrials
        for s = 1:terminal_states
            d = normrnd(0,sd);
            rewards(t,s) = rewards(t-1,s)+d;
            rewards(t,s) = min(rewards(t,s),max(bounds(2)*2 - rewards(t,s), bounds(1)));
            rewards(t,s) = max(rewards(t,s),min(bounds(1)*2 - rewards(t,s), bounds(2)));
        end
end