function r = sum_cell_of_vectors(c1,c2)
% c1 = { [a1,a2,a3,...,an], [b1,b2,b3,...,bn], ... }
% c2 = { [s1,s2,s3,...,sn], [t1,t2,t3,...,tn], ... }
%
% returns r{k} = c1{k} + c2{k}
    r = mat2cell(cell2mat(   reshape(c1,[],1)    ) + cell2mat( reshape(c2,[],1)  ),ones(1,numel(c1)),numel(c1{1}))';
end