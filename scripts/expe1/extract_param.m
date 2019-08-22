
dbstop if error

clear all

cd ~
home = pwd;
homedir = [home '/Project/Kool/data/'];

expe = {'1'; '2';'3'; '4'};
model = {'model'; 'model_hierarchical'}; 


for j = 1:length(expe)
    expX = ['experiment_' char(expe(j))];
    file_exp = fullfile(homedir, expX);
    cd (file_exp)
    load("groupdata.mat")
    fields = {'gender','age', 'N', 'time_elapsed', 'tasktime', 'practice', 'instructiontime', 'totaltime', 'state0', 'state1','stim_0_1', 'stim_0_2', 'rt0', 'rt1', 'rt2', 'stim_1_1', 'stim_1_2', 'stim_1_3', 'response0', 'response1', 'score', 'rews', 'rews1', 'rews2', 'rews3'};
    
    if strcmp(expX,'experiment_3')
         fields = {'gender','age', 'N', 'tasktime', 'practice', 'instructiontime', 'totaltime', 'beforepracticetime', };
    elseif strcmp(expX,'experiment_4')
        fields = {'gender','age', 'N', 'tasktime', 'practice', 'instructiontime', 'totaltime', 'beforepracticetime'};
    end
   
    data = rmfield(groupdata.subdata,fields);
    SUBDATA.(expX) = data;
    
    for i = 1:length(model)
        modX = char(model(i));
        file_mod = fullfile(homedir, expX, modX);
        cd (modX)
        load("results.mat")
        params.(expX).(modX) = results.x;
        BIC.(expX).(modX) = results.bic;
        loglik.(expX).(modX) = results.loglik;
        cd (file_exp)
    end

    
    cd (homedir)
    save('PARAMS','params')
    save('BIC','BIC')
    save('LL','loglik')
    save('SUBDATA','SUBDATA')
    
end