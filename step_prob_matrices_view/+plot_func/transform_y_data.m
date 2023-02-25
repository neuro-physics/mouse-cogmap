function h = transform_y_data(h,transf_func)
    for i = 1:numel(h)
        h(i).YData = transf_func(h(i).YData);
    end
end