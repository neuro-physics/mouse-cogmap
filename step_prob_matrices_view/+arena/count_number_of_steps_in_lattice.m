function N = count_number_of_steps_in_lattice(r,L)
% r -> linear lattice index position, i.e. r(i) = y(i) + x(i)*L, where (x,y) -> (1..L,1..L) are the lattice coords
% this function should have the same functionality as the one with the same name in
% D:\Dropbox\p\uottawa\data\animal_trajectories\mouse_track\process_mouse_trials_lib.py
%
% returns
% N(i,j) -> number of steps from site j to site i
    if iscell(r)
        N = cellfun(@(rr)count_internal(rr,L),r,'UniformOutput',false);
    else
        N = count_internal(r,L);
    end
end

function N = count_internal(r,L)
    N = sparse(r(2:end),r(1:(end-1)),ones(numel(r)-1,1),L^2,L^2); % this function sums all entries with repeated i,j into N(i,j)
end