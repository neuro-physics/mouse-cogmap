function m = average_direction_angle(th,dim,to_deg)
% https://www.themathdoctors.org/averaging-angles/
    if (nargin < 2) || isempty(dim)
        dim = [];
    end
    if (nargin < 3) || isempty(to_deg)
        to_deg = false;
    end
    c = 1;
    if to_deg
        c = 180/pi;
    end
    m = c.*atan2(sum(sin(th),dim,'omitnan'),sum(cos(th),dim,'omitnan'));
end