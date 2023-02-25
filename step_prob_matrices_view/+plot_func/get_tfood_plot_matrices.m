function [t_food_mat,t_food_err_mat,L_mat,trials_mat] = get_tfood_plot_matrices(si_exp,L_values,trial_values)
    get_t_food     = @(si) reshape(arrayfun(@(a)mean([a.trial(:).t_food]),si.learning_stage),[],1);
    get_t_food_err = @(si) reshape(arrayfun(@(a)func.stderr(double([a.trial(:).t_food])),si.learning_stage),[],1);
    t_food             = cellfun(@(si)    get_t_food(si),si_exp,'UniformOutput',false);
    t_food_err         = cellfun(@(si)get_t_food_err(si),si_exp,'UniformOutput',false);
    [L_mat,trials_mat] = meshgrid(L_values,trial_values);
    t_food_mat         = cell2mat(t_food);
    t_food_err_mat     = cell2mat(t_food_err);
end