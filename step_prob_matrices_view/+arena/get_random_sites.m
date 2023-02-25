function r = get_random_sites(sample_size,arena_L,arena_shape,return_as_xy_coords)
% returns r with size(r) == sample_size
% where each entry is a lattice site in the arena grid of shape arena_shape
% each entry in r can be translated to an arena x,y-coordinate by using func.myind2sub([L,L],r,true)
% if return_as_xy_coords is true
% then each random coordinate is a row in r
% there will be numel(sample_size) rows in r
    if isscalar(sample_size)
        sample_size = [1,sample_size];
    end
    if isscalar(arena_L)
        arena_L = [arena_L,arena_L]; % if L is scalar, then we assume arena to be squared
    end
    if (nargin < 4) || isempty(return_as_xy_coords)
        return_as_xy_coords = true;
    end
    valid_arena_shapes = {'square','circle'};
    assert( any(strcmpi(arena_shape,valid_arena_shapes)), sprintf('The valid shapes for the arena are %s',strjoin(valid_arena_shapes,', '))  );
    
    % getting the arena
    if strcmpi(arena_shape,'circle')
        A = arena.get_circle_arena(arena_L);
    else
        A = arena.get_square_arena(arena_L);
    end
    [i,j]             = find(A); % getting all the sites of the arena
    arena_sites       = unique([i;j]);
    
    % selecting the indices of the random sites
    k = randi([1,numel(arena_sites)],sample_size);
    
    % the lattice sites are
    r = arena_sites(k);
    
    if return_as_xy_coords
        arena_coords = func.myind2sub(arena_L,arena_sites,true);
        r = arena_coords(k(:),:);
    end
    
    
end