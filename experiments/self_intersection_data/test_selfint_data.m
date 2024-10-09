clearvars
close all

%load('self_intersection_fixtgt_reltgt.mat');
%load('self_intersection_fixtgt_reltgt_vth0.2.mat');
%load('self_intersection_fixtgt_reltgt_vth0.2_1st_half.mat');
load('self_intersection_fixtgt_reltgt_vth0.2_2nd_half.mat');

n_trials = numel(trial_labels_rt);

% making observation matrices
% rows -> trials; cols -> observations (i.e., different mice)
n_selfint_rt = cell2mat(cellfun(@(all_mice)cellfun(@(x)numel(x),all_mice),selfint_st_rt(1:n_trials),'UniformOutput',false)');
n_selfint_ft = cell2mat(cellfun(@(all_mice)cellfun(@(x)numel(x),all_mice),selfint_st_ft(1:n_trials),'UniformOutput',false)');

% average over mice (cols,dim==2)
n_selfint_rt_mean = mean(n_selfint_rt,2);
n_selfint_rt_std  =  std(n_selfint_rt,[],2);
n_selfint_ft_mean = mean(n_selfint_ft,2);
n_selfint_ft_std  =  std(n_selfint_ft,[],2);

ax = axes;
hold(ax,'on');
errorbar(ax,1:n_trials,n_selfint_rt_mean,n_selfint_rt_std,':ob','DisplayName','static entrance');
errorbar(ax,1:n_trials,n_selfint_ft_mean,n_selfint_ft_std,':sr','DisplayName','random entrance');
xlabel(ax,'trial');
ylabel(ax,'number of self-crossings')
set(ax,'yscale','log')
legend(ax)