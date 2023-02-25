function d = calc_lattice_site_distance(s1,s2,L)
% s1 and s2 are two linearized indices sites in a lattice of size L=[L1,L2]
    % position of the site 1
    [y1,x1] = ind2sub(L,s1);
        
    % position of the site 2
    [y2,x2] = ind2sub(L,s2);
    
    d = vecnorm([x1,y1]-[x2,y2]);
end