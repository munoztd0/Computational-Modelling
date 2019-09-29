%             %%
% 
%             %% choices + updating
%             % level 0
%                % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
%             
%             
%         else
%             
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
%             ps = exp(b1*high_Q(2,:))/sum(exp(b1*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
% 
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%             
% 
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value
%             %low_Q = Qmb;
%             
%             ps = exp(b1*low_Q)/sum(exp(b1*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
%         end
%         
%     elseif model == 2
% 
%         % parameters model 2 = simple MB
%         w = 1;          % mixing weight
% 
%         %high effort
%         if c(k) == 1 
%                 %notes
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
%             ps = exp(b1*high_Q(2,:))/sum(exp(b1*high_Q(2,:)));                      %compute choice probabilities for each action
%             
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
% 
%        %low effort
%         else
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value
%             %low_Q = Qmb;
%             
%             ps = exp(b1*low_Q)/sum(exp(b1*low_Q));                  % compute choice probabilities for each action
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
% 
%         end
%         
%     elseif model == 3
% 
%         % parameters model 3 = MF exhaustive
%         w = 0;
% 
%         %high effort
%         if c(k) == 1 
%             
%             %notes:
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
%             ps = exp(b2*high_Q(2,:))/sum(exp(b2*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%             
% 
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value
%             %low_Q = Qmb;
%             
%             ps = exp(b3*low_Q)/sum(exp(b3*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
% 
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
%         end 
%         
%     elseif model == 4
% 
%         % parameters model 4 = MB exaustive
%         w = 1;
% 
%         %high effort
%         if c(k) == 1 
% 
%              %notes:
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
%             ps = exp(b2*high_Q(2,:))/sum(exp(b2*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%            
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value
%             %low_Q = Qmb;
%             
%             ps = exp(b3*low_Q)/sum(exp(b3*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
% 
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
% 
%         end
%         
%     elseif model == 5
% 
%         % parameters model 5 = simple mixed model
% 
%         w = w1;           % mixing weight
% 
%         %high effort
%         if c(k) == 1 
% 
%                         %notes:
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
%             ps = exp(b1*high_Q(2,:))/sum(exp(b1*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%             
% 
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value
%             
%             ps = exp(b1*low_Q)/sum(exp(b1*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
% 
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
%         end
%         
%     elseif model == 6
% 
%         % parameters model 6 = mixed model with 3 betas
%         w = w1;
% 
% 
%         %high effort
%         if c(k) == 1 
% 
%             %notes:
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w*Qmb1' + (1-w)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w*Qmb2(s(2),:) + (1-w)*Qmf2(s(2),:);
%             ps = exp(b2*high_Q(2,:))/sum(exp(b2*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%             
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w*Qmb + (1-w)*Qmf(s1,:)';                 % mix TD and model value
%             %low_Q = Qmb;
%             
%             ps = exp(b3*low_Q)/sum(exp(b3*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
% 
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
%         end
%         
%     elseif model == 7
% 
%         % parameters model 7 = mixed model with 3 weights
% 
%         %high effort
%         if c(k) == 1 
% 
%                         %notes:
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w2*Qmb2(s(2),:) + (1-w2)*Qmf2(s(2),:);
%             ps = exp(b1*high_Q(2,:))/sum(exp(b1*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%             
% 
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w3*Qmb + (1-w3)*Qmf(s1,:)';                 % mix TD and model value
%             
%             ps = exp(b1*low_Q)/sum(exp(b1*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
% 
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;
% 
%         end   
%         
%     elseif model == 8
% 
%         % parameters model 8 = mixed model exhaustive
% 
%         %high effort
%         if c(k) == 1 
% 
%                         %notes:
%             %Tm1 = subdata.Tm_top(subdata.stims0(t,:),:)
%             %disp(max(Qmb2,[],2));
%             %Tm{2} = subdata.Tm_middle(subdata.middle_stims{2}(state,:),:)
%             %(s1_stims) = (subdata.stims0(t,:))
%             
%             Tm1 = Tm{1}(s1_stims,:); % temporary Tm1
% 
%             for s = 1:3
%                 Qmb2(s,:) = Tm{2}(:,:,s)*Qmf3;
%             end
% 
%             Qmb1 = Tm1*max(Qmb2,[],2);
% 
%             s(1) = 1;
% 
%             %% choices + updating
%             % level 0
%             high_Q(1,:) = w1*Qmb1' + (1-w1)*Qmf1(s1_stims); 
%             ps = exp(b1*high_Q(1,:))/sum(exp(b1*high_Q(1,:)));                      %compute choice probabilities for each action
%             rand1 = rand;
%             action = find(rand1<cumsum(ps),1);                 % choose
% 
%             a(1) = s1_stims(action);
% 
%             s(2) = find(Tm{1}(a(1),:));
% 
% 
%             % level 1
% 
%             high_Q(2,:) = w2*Qmb2(s(2),:) + (1-w2)*Qmf2(s(2),:);
%             ps = exp(b2*high_Q(2,:))/sum(exp(b2*high_Q(2,:)));                      %compute choice probabilities for each action
%             rand2 = rand;
%             a(2) = find(rand2<cumsum(ps),1);                   % choose
% 
%             s(3) = find(Tm{2}(a(2),:,s(2)));
% 
%             % level 2
% 
%             reward = rews(k,s(3));
% 
%             %% updating
%             %level 1
%             high_dtQ(1) = Qmf2(s(2),a(2)) - Qmf1(a(1));
%             Qmf1(a(1)) = Qmf1(a(1)) + lr*high_dtQ(1);
% 
%             % level 2
%             high_dtQ(2) = Qmf3(s(3)) - Qmf2(s(2),a(2));
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lr*high_dtQ(2);
%             Qmf1(a(1)) = Qmf1(a(1)) + lambda*lr*high_dtQ(2);
% 
%             % level 3
%             high_dtQ(3) = reward - Qmf3(s(3));
%             Qmf3(s(3)) = Qmf3(s(3)) + lr*high_dtQ(3);
%             Qmf2(s(2),a(2)) = Qmf2(s(2),a(2)) + lambda*lr*high_dtQ(3);
%             Qmf1(a(1)) = Qmf1(a(1)) + (lambda^2)*lr*high_dtQ(3);
% 
%             %% store stuff           
%             output.high.s1_stims(k,:) = s1_stims;
%             output.high.rand1(k) = rand1;
%             output.high.rand2(k) = rand2;
%             
%             
% 
%        %low effort
%         else
%             
%             rand1 = ceil(rand*2);
%             s1 = rand1;
%             
%             Qmb = Tm_low{s1}*Q2;                          % compute model-based value function
% 
%             low_Q = w3*Qmb + (1-w3)*Qmf(s1,:)';                 % mix TD and model value
%    
%             
%             ps = exp(b3*low_Q)/sum(exp(b3*low_Q));                  % compute choice probabilities for each action
%             
%             rand2 = rand;
%             a = find(rand2<cumsum(ps),1);                  % choose
% 
%             s2 = a;
% 
%             low_dtQ(1) = Q2(s2) - Qmf(s1,a);                  % backup with actual choice (i.e., sarsa)
%             Qmf(s1,a) = Qmf(s1,a) + lr*low_dtQ(1);            % update TD value function
% 
%             low_dtQ(2) = rews(k,s2) - Q2(s2);                 % prediction error (2nd choice)
% 
%             Q2(s2) = Q2(s2) + lr*low_dtQ(2);                  % update TD value function
%             Qmf(s1,a) = Qmf(s1,a) + lambda*lr*low_dtQ(2);     % eligibility trace
% 
%             % store stuff
% 
%             output.low.rand1(k) = rand1;
%             output.low.rand2(k) = rand2;