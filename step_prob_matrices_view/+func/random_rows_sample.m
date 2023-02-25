function x = random_rows_sample(X,sample_size,n_samples)
    x = cellfun(@(c)X(func.getRandomSample(sample_size,size(X,1)),:),cell(1,n_samples),'UniformOutput',false);
end