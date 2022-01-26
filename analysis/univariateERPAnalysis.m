% To-do List:
% plotting figure 1a and 1b:
% 1a. topographies for the difference of two conditions across participants
% (data_diff)
% 1b. grand averaging ERP on electrodes across participants (occipital and frontal electrodes poolings)

% Clear the environment
close all;
clear;
clc;
restoredefaultpath; 

% Add FieldTrip path
addpath /Users/batiyilmaz/Documents/FieldTrip;
ft_defaults;

% load data
workingDir = '/Volumes/BATIDISK/Visual_Masking_Preprocessed_Files';
addpath('/Users/batiyilmaz/Desktop')

subjList = dir(fullfile(workingDir, 'subj*'));
load(fullfile(workingDir,'channel_labels.mat'), 'full_labels');

% pre-allocate 
data_high = nan(length(subjList),64,110);
data_low = nan(length(subjList),64,110);

% loop over the names
for i = 1 : length(subjList)
    subjID=subjList(i).name;
    %subjectNum = 1; subjectName = sprintf('subj%02d',subjectNum);
    preprocessedFile = fullfile(workingDir, subjID, strcat(subjID,'_preprocessed.mat'));
    load(preprocessedFile, 'data_clean');
    
    % load data into 4-D matrix you need to insert something here
    conditions = unique(data_clean.trialinfo)';
    data_C = nan(length(conditions),64,110);
    %avgtrial = squeeze(nanmean(DA,1));
    
    % get channel flag
    flagChan = ismember(full_labels, data_clean.label);
    
    for ci = conditions
        % find conditions
        flagCond=(data_clean.trialinfo==ci);
        % select condition from fieldtrip format data
        cfg=[];
        cfg.trials = flagCond;
        data_cond = ft_selectdata(cfg, data_clean);
        
        
        % change the data cell to matrix
        data_cond_M = cat(3,data_cond.trial{:});
        data_cond_M = permute(data_cond_M, [3 1 2]);
        % baseline normalization
        data_cond_M = doUNN(data_cond_M,1:10);
        %data_C(ci,:,flagChan,:) = data_cond_M;
        if size(data_cond_M,1) > 53 
            i,ci
        end
        data_C(ci,flagChan,:) = nanmean(data_cond_M,1);
    end
    
    % split data for high and low visibility conditions
    data_high(i,:,:) = squeeze(nanmean(data_C(1:24,:,:),1));
    data_low(i,:,:) = squeeze(nanmean(data_C(25:48,:,:),1));
end
% get difference for the two conditions
data_diff = data_high-data_low;

%% Making Figures
% figure 1a: comparison plots for pooling occipital pooling
LIA_1 = ismember(full_labels,{'Pz','Oz','POz'});
%LIA_1 = ismember(full_labels,{'O1','Oz','O2'});
% occipital-temporal pooling
LIA_2 = ismember(full_labels,{'P5','P7', 'PO7', 'P6', 'P8', 'PO8'});

figure;
plot(-99:10:1000,squeeze(mean(data_high(:,LIA_2,:),[1,2],'omitnan')));
%title('High Visibility Condition - Occipital Pooling');
title('High Visibility Condition - Occipital-Temporal Pooling');
hold on;
plot(-99:10:1000,squeeze(mean(data_low(:,LIA_2,:),[1,2],'omitnan')));
%title('Low Visibility Condition - Occipital Pooling');
title('Low Visibility Condition - Occipital-Temporal Pooling');

% figure 1b
figure; 
plot(-99:10:1000,squeeze(mean(data_diff(:,LIA_2,:),[1,2], 'omitnan')));
%title('Difference Wave of the Conditions - Occipital Pooling');
title('Difference Wave of the Conditions - Occipital-Temporal Pooling');


figure;
pi = 0;
for chi=60:63
    pi = pi + 1;
    subplot(4,5,pi);
    plot(squeeze(mean(data_high(:,chi,:),1,'omitnan')));
    hold on;
    plot(squeeze(mean(data_low(:,chi,:),1,'omitnan')));
    title(full_labels{chi})
end