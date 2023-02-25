function [x,x_group] = boxplot_prepare_data(x_cell)
% each entry in x_cell is a different group for the box plot
    N       =   sum(cellfun(@numel,x_cell));
    x       =  ones(N,1);
    x_group = zeros(N,1);
    n       = 0;
    for i = 1:numel(x_cell)
        start_ind                  = n + 1;
        end_ind                    = n + numel(x_cell{i});
        n                          = n + numel(x_cell{i});
        x(start_ind:end_ind)       = x_cell{i}(:);
        x_group(start_ind:end_ind) = i.*ones(numel(x_cell{i}),1);
    end
end