function output = compute_model_simu(params,s, rews, model) %taking out b

ntrials = length(s);


if model == 1
    
    for k = 1:ntrials 
        
        %high effort
        if 1 == 1 %s(k) == 1 
            % parameters
            b = params(1);           % softmax inverse temperature
            lr = params(4);          % learning rate
            lambda = params(5);      % eligibility trace decay
            w = 0; %x(4);           % mixing weight

            % initialization
            Qmf1 = zeros(1,3);
            Qmf2 = zeros(3,2);
            Qmf3 = zeros(3,1);                    % Q(s,a): state-action value function for Q-learning
            Tm = cell(2,1);
            Tm{1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
            Tm{2}(:,:,1) = [1 0 0; 0 1 0];        % transition matrix
            Tm{2}(:,:,2) = [1 0 0; 0 0 1];        % transition matrix
            Tm{2}(:,:,3) = [0 1 0; 0 0 1];        % transition matrix
            N = size(rews,1);
            output.A = zeros(N,2);
            output.R = zeros(N,1);
            output.S = zeros(N,3);

            Qmb2 = zeros(3,2);

            % loop through trials
            for t = 1:N

                s1_stims = datasample(1:3,2,'Replace',false);

                Tm1 = Tm{1}(s1_stims,:); % temporary Tm1

                for state = 1:3
                    Qmb2(state,:) = Tm{2}(:,:,state)*Qmf3;
                end

                disp(max(Qmb2,[],2))

                Qmb1 = Tm1*max(Qmb2,[],2);

                state(1) = 1;

                %% choices + updating
                % level 1

                Q = w*Qmb1' + (1-w)*Qmf1(s1_stims);               % mix TD and model value
                ps = exp(b*Q)/sum(exp(b*Q));                      %compute choice probabilities for each action
                action = find(rand<cumsum(ps),1);                 % choose
                a(1) = s1_stims(action);

                state(2) = find(Tm{1}(a(1),:));

                % level 2

                Q = w*Qmb2(state(2),:) + (1-w)*Qmf2(state(2),:);
                ps = exp(b*Q)/sum(exp(b*Q));                      %compute choice probabilities for each action
                a(2) = find(rand<cumsum(ps),1);                   % choose

                state(3) = find(Tm{2}(a(2),:,state(2)));

                % level 3

                reward = rews(k,state(3));

                %% updating
                % level 1
                dtQ(1) = Qmf2(state(2),a(2)) - Qmf1(a(1));
                Qmf1(a(1)) = Qmf1(a(1)) + lr*dtQ(1);

                % level 2
                dtQ(2) = Qmf3(state(3)) - Qmf2(state(2),a(2));
                Qmf2(state(2),a(2)) = Qmf2(state(2),a(2)) + lr*dtQ(2);
                Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*dtQ(2);

                % level 3
                dtQ(3) = reward - Qmf3(state(3));
                Qmf3(state(3)) = Qmf3(state(3)) + lr*dtQ(3);
                Qmf2(state(2),a(2)) = Qmf2(state(2),a(2)) + lambda*lr*dtQ(3);
                Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*dtQ(3);

                %% store stuff
                output.A(k,:) = a;
                output.R(k,1) = rews(k,state(3));
                output.S(k,:) = state;
                output.s1_stims(k,:) = s1_stims;

            end

        else

            % parameters
            b = x(1);           % softmax inverse temperature
            lr = x(2);          % learning rate
            lambda = x(3);      % eligibility trace decay
            w = x(4);           % mixing weight

            % initialization
            Qmf = zeros(2,3);
            Q2 = zeros(3,1);                      % Q(s,a): state-action value function for Q-learning
            Tm = cell(2,1);
            Tm{1} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
            Tm{2} = [1 0 0; 0 1 0; 0 0 1];        % transition matrix
            N = size(rews,1);
            output.A = zeros(N,2);
            output.R = zeros(N,1);
            output.S = zeros(N,2);

            % loop through trials
            for t = 1:N

                s1 = ceil(rand*2);

                Qmb = Tm{s1}*Q2;                              % compute model-based value function

                Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value

                ps = exp(b*Q)/sum(exp(b*Q));                  % compute choice probabilities for each action
                a = find(rand<cumsum(ps),1);                  % choose

                s2 = a;

                dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
                Qmf(s1,a) = Qmf(s1,a) + lr*dtQ(1);            % update TD value function

                dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)

                Q2(s2) = Q2(s2) + lr*dtQ(2);                  % update TD value function
                Qmf(s1,a) = Qmf(s1,a) + lambda*lr*dtQ(2);     % eligibility trace

                % store stuff
                output.A(k,1) = a;
                output.R(k,1) = rews(k,s2);
                output.S(k,:) = [s1 s2];

            end

            
        end
            

        

    end
    
end

end




