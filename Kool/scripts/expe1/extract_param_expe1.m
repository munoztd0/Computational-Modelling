
dbstop if error

clear all

cd ~
home = pwd;
homedir = [home '/Project/Kool/data/'];

expe = {'1'}; %'2';'3'; '4'};
model = {'model'; 'model_exhaustive'}; 


for j = 1:length(expe)
    expX = ['experiment_' char(expe(j))];
    file_exp = fullfile(homedir, expX);
    cd (file_exp)
    load("groupdata.mat")
    fields = {'gender','age', 'N', 'time_elapsed', 'tasktime', 'practice', 'instructiontime', 'totaltime', 'state0', 'state1','stim_0_1', 'stim_0_2', 'rt0', 'rt1', 'rt2', 'stim_1_1', 'stim_1_2', 'stim_1_3', 'response0', 'response1', 'score', 'rews', 'rews1', 'rews2', 'rews3'};
    data = rmfield(groupdata.subdata,fields);
    
    data = data(groupdata.i); %keep only ID of subject who didnt missed too much
    SUBDATA = data;
    
    for i = 1:length(model)
        modX = char(model(i));
        file_mod = fullfile(homedir, expX, modX);
        cd (modX)
        load("results.mat")
        params.(modX) = results.x;
        BIC.(modX) = results.bic;
        loglik.(modX) = results.loglik;
        cd (file_exp)
    end

    
    cd (homedir)
    save('PARAMS','params')
    save('BIC','BIC')
    save('LL','loglik')
    save('SUBDATA','SUBDATA')
    
end