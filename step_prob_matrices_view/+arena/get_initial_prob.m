function P0 = get_initial_prob(L,shape)
    if (nargin < 2) || isempty(shape)
        shape = 'circle';
    end
    assert(any(strcmpi(shape,{'circle','square'})),'shape must be either circle or square')
    if strcmpi(shape,'circle')
        P0 = arena.normalize_cols(arena.get_circle_arena(L));
    else
        P0 = arena.normalize_cols(arena.get_square_arena(L));
    end
end