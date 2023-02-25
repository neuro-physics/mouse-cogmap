function r = get_start_position(p0,arenaShape,L)
    p0 = lower(p0);
    if strcmpi(arenaShape,'square')
        switch p0
            case 'e'
                r = round((L(1)-1)*L(2) + L(2)/2); % south position
            case 's'
                r = round(ceil(L(1)/2)*L(2)); % east position
            case 'n'
                r = round(floor(L(1)/2)*L(2))+1; % west position
            case 'w'
                r = round(L(2)/2); % north position
            otherwise
                error('position p0 not posible');
        end
    elseif strcmpi(arenaShape,'circle')
        r = arena.get_start_position(p0,'square',L);
    else
        error('only square and circular are allowed');
    end
end